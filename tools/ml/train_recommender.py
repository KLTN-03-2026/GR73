import os
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
from google.cloud import firestore
from datetime import datetime, timezone

def _to_dt(v):
    if hasattr(v, 'timestamp'):
        try:
            return datetime.fromtimestamp(v.timestamp(), tz=timezone.utc)
        except Exception:
            pass
    if isinstance(v, datetime):
        return v
    return datetime.now(tz=timezone.utc)

def fetch_posts(db):
    posts = {}
    for doc in db.collection('posts').stream():
        d = doc.to_dict() or {}
        created = _to_dt(d.get('createdAt'))
        posts[doc.id] = {
            'price': float(d.get('price') or 0.0),
            'area': float(d.get('area') or 0.0),
            'bedrooms': float(d.get('bedrooms') or 0.0),
            'bathrooms': float(d.get('bathrooms') or 0.0),
            'isFeatured': bool(d.get('isFeatured') or False),
            'city': str(d.get('city') or ''),
            'createdAt': created,
        }
    return posts

def fetch_events(db, days=180):
    evs = []
    for doc in db.collection('recommend_events').stream():
        d = doc.to_dict() or {}
        evs.append({
            'userId': str(d.get('userId') or ''),
            'postId': str(d.get('postId') or ''),
            'event': str(d.get('event') or ''),
            'context': d.get('context') or {},
            'createdAt': _to_dt(d.get('createdAt')),
        })
    if days is not None:
        cutoff = datetime.now(tz=timezone.utc)
        evs = [e for e in evs if (cutoff - e['createdAt']).days <= days]
    return evs

def build_feature(post, ctx):
    price_norm = max(0.0, min(1.0, (post['price'] / 20000000.0)))
    area_norm = max(0.0, min(1.0, (post['area'] / 120.0)))
    bed_norm = max(0.0, min(1.0, (post['bedrooms'] / 4.0)))
    bath_norm = max(0.0, min(1.0, (post['bathrooms'] / 3.0)))
    featured = 1.0 if post['isFeatured'] else 0.0
    days = (datetime.now(tz=timezone.utc) - post['createdAt']).days
    recency_norm = max(0.0, min(1.0, (days / 60.0)))
    city_ctx = str((ctx or {}).get('city', ''))
    city_match = 1.0 if city_ctx and city_ctx == post['city'] else 0.0
    budget_norm = 0.0
    return [price_norm, area_norm, bed_norm, bath_norm, featured, recency_norm, city_match, budget_norm]

def make_dataset(posts, events):
    favs = [e for e in events if e['event'] == 'favorite_add' and e['postId'] in posts]
    views = [e for e in events if e['event'] == 'view' and e['postId'] in posts]
    n_pos = len(favs)
    n_neg = min(len(views), max(n_pos, 1))
    views = views[:n_neg]
    X = []
    y = []
    for e in favs:
        X.append(build_feature(posts[e['postId']], e.get('context')))
        y.append(1.0)
    for e in views:
        X.append(build_feature(posts[e['postId']], e.get('context')))
        y.append(0.0)
    return np.array(X, dtype=np.float32), np.array(y, dtype=np.float32)

def train_and_export(X, y, out_dir='tools/ml/outputs', epochs=10):
    os.makedirs(out_dir, exist_ok=True)
    scaler = MinMaxScaler()
    Xs = scaler.fit_transform(X)
    X_train, X_val, y_train, y_val = train_test_split(Xs, y, test_size=0.2, random_state=42)
    inputs = tf.keras.Input(shape=(Xs.shape[1],), dtype=tf.float32)
    x = tf.keras.layers.Dense(32, activation='relu')(inputs)
    x = tf.keras.layers.Dense(16, activation='relu')(x)
    outputs = tf.keras.layers.Dense(1, activation='sigmoid')(x)
    model = tf.keras.Model(inputs, outputs)
    model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['AUC'])
    model.fit(X_train, y_train, validation_data=(X_val, y_val), epochs=epochs, batch_size=64)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    open(os.path.join(out_dir, 'model.tflite'), 'wb').write(tflite_model)
    np.save(os.path.join(out_dir, 'scaler_min.npy'), scaler.min_)
    np.save(os.path.join(out_dir, 'scaler_scale.npy'), scaler.scale_)

def main():
    db = firestore.Client()
    posts = fetch_posts(db)
    events = fetch_events(db)
    X, y = make_dataset(posts, events)
    if X.shape[0] == 0:
        print('No data')
        return
    train_and_export(X, y)
    print('Done')

if __name__ == '__main__':
    main()


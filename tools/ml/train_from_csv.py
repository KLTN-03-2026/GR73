import os
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import MinMaxScaler
import csv

def read_posts(path):
    posts = {}
    with open(path, newline='') as f:
        r = csv.DictReader(f)
        for row in r:
            posts[row['postId']] = {
                'price': float(row.get('price') or 0.0),
                'area': float(row.get('area') or 0.0),
                'bedrooms': float(row.get('bedrooms') or 0.0),
                'bathrooms': float(row.get('bathrooms') or 0.0),
                'isFeatured': row.get('isFeatured') == '1',
                'city': row.get('city') or '',
                'createdDays': float(row.get('createdDays') or 0.0),
            }
    return posts

def read_events(path):
    evs = []
    with open(path, newline='') as f:
        r = csv.DictReader(f)
        for row in r:
            evs.append({
                'userId': row.get('userId') or '',
                'postId': row.get('postId') or '',
                'event': row.get('event') or '',
                'city': row.get('city') or '',
            })
    return evs

def build_feature(p, city):
    price_norm = max(0.0, min(1.0, p['price'] / 20000000.0))
    area_norm = max(0.0, min(1.0, p['area'] / 120.0))
    bed_norm = max(0.0, min(1.0, p['bedrooms'] / 4.0))
    bath_norm = max(0.0, min(1.0, p['bathrooms'] / 3.0))
    featured = 1.0 if p['isFeatured'] else 0.0
    recency_norm = max(0.0, min(1.0, p['createdDays'] / 60.0))
    city_match = 1.0 if city and city == p['city'] else 0.0
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
        X.append(build_feature(posts[e['postId']], e['city']))
        y.append(1.0)
    for e in views:
        X.append(build_feature(posts[e['postId']], e['city']))
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
    posts = read_posts('tools/ml/data/posts.csv')
    events = read_events('tools/ml/data/recommend_events.csv')
    X, y = make_dataset(posts, events)
    if X.shape[0] == 0:
        print('No data')
        return
    train_and_export(X, y)
    print('Done')

if __name__ == '__main__':
    main()


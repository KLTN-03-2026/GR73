import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/membership.dart';
import '../models/payment.dart';
import '../config/payment_config.dart';

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static String generateId() {
    return _firestore.collection('payments').doc().id;
  }

  static Future<void> createPayment({
    required String id,
    required String userId,
    required Membership plan,
    required String method,
    String status = 'pending',
  }) async {
    final payment = Payment(
      id: id,
      userId: userId,
      membershipId: plan.id,
      amount: plan.price,
      method: method,
      status: status,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('payments').doc(id).set(payment.toMap());
    if (status == 'submitted') {
       await _firestore.collection('payments').doc(id).update({
        'submittedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<String> createOrder({
    required String userId,
    required Membership plan,
    required String method,
  }) async {
    final id = generateId();
    await createPayment(id: id, userId: userId, plan: plan, method: method);
    return id;
  }

  static Future<void> markSuccess(String paymentId, Membership plan, String userId) async {
    await _firestore.collection('payments').doc(paymentId).update({'status': 'success'});
    await FirebaseService.updateMembershipBenefits(
      userId: userId,
      membershipId: plan.id,
      durationDays: plan.durationDays,
      quotaAdd: plan.quotaAdd,
    );
  }

  static Future<void> submitPayment(String paymentId) async {
    await _firestore.collection('payments').doc(paymentId).update({
      'status': 'submitted',
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  static Map<String, String> vietcombankInfo(String paymentId, String userEmail) {
    final content = 'PAY-$paymentId-$userEmail';
    return {
      'bank': PaymentConfig.bankName,
      'accountName': PaymentConfig.bankAccountName,
      'accountNumber': PaymentConfig.bankAccountNumber,
      'branch': PaymentConfig.bankBranch,
      'content': content,
    };
  }

  static Future<void> simulatePayPalSuccess(String paymentId) async {
    await _firestore.collection('payments').doc(paymentId).update({'gateway': 'paypal', 'note': PaymentConfig.paypalNote});
    await Future.delayed(const Duration(seconds: 1));
    await submitPayment(paymentId);
  }

  static Future<void> approvePaymentByAdmin(String paymentId) async {
    final doc = await _firestore.collection('payments').doc(paymentId).get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final userId = (data['userId'] ?? '') as String;
    final planId = (data['membershipId'] ?? 'basic') as String;
    final plan = Membership.plans().firstWhere((p) => p.id == planId, orElse: () => Membership.plans().first);
    await markSuccess(paymentId, plan, userId);
  }
}

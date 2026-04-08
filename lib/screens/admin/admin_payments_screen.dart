import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../config/app_router.dart';
import '../../widgets/common/wr_logo.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  String _statusFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatVnd(num vnd) {
    final s = vnd.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i - 1;
      b.write(s[idx]);
      if (i % 3 == 2 && idx != 0) b.write('.');
    }
    return b.toString().split('').reversed.join();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'submitted':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _chip(String label, String value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _statusFilter = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context);
    if (ap.user?.role != 'admin') {
      return Scaffold(
        appBar: AppBar(title: Row(children: [WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)), const SizedBox(width: 8), const Text('Quản lý thanh toán')])),
        body: const Center(child: Text('Chỉ admin mới truy cập trang này')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Row(children: [WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)), const SizedBox(width: 8), const Text('Quản lý thanh toán')])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Duyệt yêu cầu nâng cấp', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Danh sách các giao dịch cần xác nhận từ người dùng.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm giao dịch (Mã, User ID, Nội dung, Số tiền)...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            _chip('Tất Cả', 'all'),
            _chip('Chờ Duyệt', 'submitted'),
            _chip('Đã Duyệt', 'success'),
            _chip('Đã Hủy', 'failed'),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 5))]),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Expanded(flex: 2, child: Text('MÃ GD / NGÀY', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('TÀI KHOẢN', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('GÓI & SỐ TIỀN', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 3, child: Text('NỘI DUNG CK', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text('TRẠNG THÁI', style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('payments').orderBy('createdAt', descending: true).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var docs = snapshot.data!.docs;
                      if (_statusFilter != 'all') {
                        docs = docs.where((d) => (d.data()['status'] ?? 'pending') == _statusFilter).toList();
                      }
                      
                      if (_searchQuery.isNotEmpty) {
                        docs = docs.where((d) {
                          final data = d.data();
                          final id = d.id.toLowerCase();
                          final userId = (data['userId'] ?? '').toString().toLowerCase();
                          final amount = (data['amount'] ?? 0).toString();
                          final email = (data['userEmail'] ?? '').toString().toLowerCase();
                          final content = (email.isNotEmpty ? 'pay-$id-$email' : 'pay-$id').toLowerCase();
                          return id.contains(_searchQuery) ||
                                 userId.contains(_searchQuery) ||
                                 amount.contains(_searchQuery) ||
                                 content.contains(_searchQuery);
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return const Center(child: Text('Không có giao dịch phù hợp'));
                      }
                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final data = docs[i].data();
                          final id = docs[i].id;
                          final status = (data['status'] ?? 'pending').toString();
                          final email = (data['userEmail'] ?? '').toString();
                          final method = (data['method'] ?? '').toString();
                          final planId = (data['membershipId'] ?? '').toString();
                          final amount = (data['amount'] ?? 0) as num;
                          final createdAt = DateTime.tryParse((data['createdAt'] ?? '') as String? ?? '') ?? DateTime.now();
                          final dateStr = '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}:${createdAt.second.toString().padLeft(2, '0')} | ${createdAt.day}/${createdAt.month}/${createdAt.year}';
                          final content = email.isNotEmpty ? 'PAY-$id-$email' : 'PAY-$id';
                          
                          return InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Xử lý giao dịch $id'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Tài khoản: ${data['userId'] ?? '—'}'),
                                      const SizedBox(height: 8),
                                      Text('Gói: ${planId.toUpperCase()}'),
                                      Text('Số tiền: ${_formatVnd(amount)} ₫'),
                                      Text('Nội dung: $content'),
                                      const SizedBox(height: 8),
                                      Text('Trạng thái: $status'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Đóng'),
                                    ),
                                    if (status == 'submitted' || status == 'pending') ...[
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection('payments').doc(id).update({'status': 'failed'});
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã từ chối'), backgroundColor: Colors.red));
                                        },
                                        child: const Text('Hủy', style: TextStyle(color: Colors.red)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await PaymentService.approvePaymentByAdmin(id);
                                          if (!context.mounted) return;
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã duyệt và nâng cấp'), backgroundColor: Colors.green));
                                        },
                                        child: const Text('Duyệt'),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              child: Row(children: [
                                Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(id, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12))])),
                                Expanded(flex: 2, child: Text((data['userId'] ?? '').toString().isNotEmpty ? (data['userId'] as String) : '—', style: const TextStyle(fontWeight: FontWeight.w600))),
                                Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(planId.isNotEmpty ? planId[0].toUpperCase() + planId.substring(1) : '—', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('${_formatVnd(amount)} ₫'),
                                  const SizedBox(height: 4),
                                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(999)), child: Text(method.isNotEmpty ? method : 'Bank', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer))),
                              ])),
                                Expanded(flex: 3, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(8)), child: Text(content))),
                                Expanded(flex: 2, child: Align(alignment: Alignment.centerLeft, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)), child: Text(status == 'success' ? 'Đã duyệt' : status == 'failed' ? 'Đã hủy' : status == 'submitted' ? 'Chờ duyệt' : 'Khởi tạo', style: TextStyle(color: _statusColor(status)))))),
                              ]),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

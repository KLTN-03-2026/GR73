import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/membership.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';

class ManagePlansScreen extends StatefulWidget {
  const ManagePlansScreen({super.key});

  @override
  State<ManagePlansScreen> createState() => _ManagePlansScreenState();
}

class _ManagePlansScreenState extends State<ManagePlansScreen> {
  List<Membership> _plans = Membership.plans();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatVnd(double vnd) {
    final s = vnd.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i - 1;
      b.write(s[idx]);
      if (i % 3 == 2 && idx != 0) b.write('.');
    }
    return b.toString().split('').reversed.join();
  }

  void _editPlan(Membership plan) async {
    final nameCtrl = TextEditingController(text: plan.name);
    final priceCtrl = TextEditingController(text: plan.price.toStringAsFixed(0));
    final quotaCtrl = TextEditingController(text: plan.quotaAdd.toString());
    final durationCtrl = TextEditingController(text: plan.durationDays.toString());
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa gói'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên gói')),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá (VND/tháng)')),
              const SizedBox(height: 8),
              TextField(controller: quotaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tăng hạn mức bài')),
              const SizedBox(height: 8),
              TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thời hạn (ngày)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final updated = Membership(
                id: plan.id,
                name: nameCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text.trim()) ?? plan.price,
                durationDays: int.tryParse(durationCtrl.text.trim()) ?? plan.durationDays,
                quotaAdd: int.tryParse(quotaCtrl.text.trim()) ?? plan.quotaAdd,
              );
              setState(() {
                _plans = _plans.map((p) => p.id == plan.id ? updated : p).toList();
              });
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _addPlan() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final quotaCtrl = TextEditingController();
    final durationCtrl = TextEditingController(text: '30');
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm gói mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên gói')),
              const SizedBox(height: 8),
              TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá (VND/tháng)')),
              const SizedBox(height: 8),
              TextField(controller: quotaCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tăng hạn mức bài')),
              const SizedBox(height: 8),
              TextField(controller: durationCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thời hạn (ngày)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              final newPlan = Membership(
                id: id,
                name: nameCtrl.text.trim(),
                price: double.tryParse(priceCtrl.text.trim()) ?? 0,
                durationDays: int.tryParse(durationCtrl.text.trim()) ?? 30,
                quotaAdd: int.tryParse(quotaCtrl.text.trim()) ?? 0,
              );
              setState(() {
                _plans = [..._plans, newPlan];
              });
              Navigator.pop(context);
            },
            child: const Text('+ Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context);
    if (ap.user?.role != 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
            const SizedBox(width: 8),
            const Text('Quản lý gói Premium'),
          ]),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text('Chỉ admin mới truy cập trang Quản lý gói', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          const Text('Quản lý gói Premium'),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text('Quản lý thành viên'),
            ),
            const SizedBox(height: 12),
            Text('Quản lý gói Premium', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Thêm / sửa / xóa gói — thay đổi sẽ áp dụng cho trang Premium.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm gói...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addPlan,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: const Text('+ Thêm gói mới'),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final filteredPlans = _plans.where((p) => p.name.toLowerCase().contains(_searchQuery)).toList();
                
                if (filteredPlans.isEmpty) {
                  return const Center(child: Text('Không tìm thấy gói nào'));
                }

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: filteredPlans.map((p) {
                    return SizedBox(
                      width: isWide ? constraints.maxWidth / 3 - 12 : constraints.maxWidth,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppTheme.primaryColor, Colors.orange]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.diamond, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(p.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text('Phù hợp cho nhu cầu đăng tin', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 12),
                            Text('${_formatVnd(p.price)} đ/tháng', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _editPlan(p),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                    child: const Text('Chỉnh sửa'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        _plans = _plans.where((x) => x.id != p.id).toList();
                                      });
                                    },
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                    child: const Text('Xóa'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

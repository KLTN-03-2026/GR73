import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/wr_logo.dart';
import '../../models/membership.dart';
import '../../providers/auth_provider.dart';
import '../../config/app_router.dart';
import '../../services/firebase_service.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

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

  List<String> _getFeatures(String planId) {
    switch (planId) {
      case 'basic':
        return [
          'Đăng 20 tin mỗi tháng',
          'Hiển thị tin cơ bản',
          'Hỗ trợ qua email',
          'Thời hạn 30 ngày',
        ];
      case 'pro':
        return [
          'Đăng không giới hạn tin',
          'Tin được đẩy lên đầu trang',
          'Huy hiệu "Đối tác uy tín"',
          'Hỗ trợ ưu tiên 24/7',
          'Báo cáo thống kê chi tiết',
          'Thời hạn 30 ngày',
        ];
      case 'vip':
        return [
          'Mọi quyền lợi của gói Premium',
          'Banner quảng cáo trang chủ',
          'Đội ngũ hỗ trợ riêng',
          'Xác thực doanh nghiệp',
          'API tích hợp hệ thống',
          'Thời hạn 30 ngày',
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context);
    final plans = Membership.plans();
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          const Text('Nâng cấp thành viên'),
        ]),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'Bảng giá dịch vụ',
                      style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chọn gói phù hợp với nhu cầu của bạn',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nâng cấp để mở khóa các tính năng cao cấp và tiếp cận hàng ngàn khách hàng tiềm năng mỗi ngày.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Current membership
            Builder(builder: (context) {
              final mId = ap.user?.membershipId;
              final role = ap.user?.role ?? 'user';
              final hasMembership = (mId != null && mId.isNotEmpty);
              final currentName = hasMembership
                  ? plans.firstWhere((p) => p.id == mId, orElse: () => plans.first).name
                  : 'Chưa đăng ký gói nào';
              if (role == 'admin') {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 4)),
                  ]),
                  child: const Text('Tài khoản admin không áp dụng gói Membership'),
                );
              }
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [
                  BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 4)),
                  ]),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Gói hiện tại: $currentName', style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),

            // Plans List
            LayoutBuilder(builder: (context, constraints) {
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: plans.map((p) {
                  final isPro = p.id == 'pro';
                  final isVip = p.id == 'vip';
                  
                  Color primaryColor;
                  if (p.id == 'basic') { primaryColor = Theme.of(context).colorScheme.secondary; }
                  else if (p.id == 'pro') { primaryColor = Theme.of(context).colorScheme.primary; }
                  else { primaryColor = Colors.orange; }

                  return Container(
                    width: constraints.maxWidth > 600 ? 300 : double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: isPro 
                          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                          : Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (isPro)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(22),
                                  bottomLeft: Radius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'Phổ biến nhất',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon & Name
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isVip ? Icons.workspace_premium : (isPro ? Icons.star : Icons.person),
                                  color: primaryColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                p.name,
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _formatVnd(p.price),
                                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryColor),
                                  ),
                                  Text(
                                    'đ/tháng',
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Divider(),
                              const SizedBox(height: 24),
                              
                              // Features
                              ..._getFeatures(p.id).map((feature) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(feature, style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                                    ),
                                  ],
                                ),
                              )),
                              
                              const SizedBox(height: 32),
                              
                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (ap.user?.role == 'admin') {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Admin không cần đăng ký Membership'), backgroundColor: Colors.blue),
                                      );
                                      return;
                                    }
                                    if (ap.user == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Vui lòng đăng nhập để nâng cấp'),
                                          action: SnackBarAction(
                                            label: 'Đăng nhập',
                                            onPressed: () => Navigator.pushNamed(context, AppRouter.login),
                                            textColor: Colors.white,
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    final mId = ap.user!.membershipId;
                                    if (mId != null && mId.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Bạn đang dùng gói hiện tại'),
                                          content: const Text('Bạn phải xác nhận hủy gói đang sử dụng trước khi đăng ký gói mới.'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
                                            ElevatedButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                await FirebaseService.cancelMembership(ap.user!.id);
                                                await ap.refreshUser();
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Đã hủy gói hiện tại. Vui lòng chọn lại gói để đăng ký'), backgroundColor: Colors.orange),
                                                );
                                              },
                                              child: const Text('Hủy gói'),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }
                                    Navigator.pushNamed(context, AppRouter.payment, arguments: p);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isPro ? Theme.of(context).colorScheme.primary : (isVip ? Colors.orange : Theme.of(context).colorScheme.surface),
                                    foregroundColor: isPro || isVip ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: isPro || isVip ? BorderSide.none : BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                                    ),
                                    elevation: isPro || isVip ? 4 : 0,
                                  ),
                                  child: Text(
                                    'Chọn gói này',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
            
            const SizedBox(height: 40),
            
            // Footer Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thanh toán an toàn & bảo mật. Bạn có thể hủy gói bất cứ lúc nào.',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

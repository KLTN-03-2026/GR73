import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_theme.dart';
import '../../config/payment_config.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/membership.dart';
import '../../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPlanId = 'basic';
  String _method = 'Vietcombank';
  bool _isProcessing = false;
  bool _initialized = false;
  String? _paymentId;
  Map<String, String>? _bankInfo;
  bool _submitted = false;

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

  Widget _qr(String asset, {String? url}) {
    return Image.asset(
      asset,
      height: 160,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        if (url != null && url.isNotEmpty) {
          return CachedNetworkImage(
            imageUrl: url,
            height: 160,
            fit: BoxFit.contain,
            placeholder: (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 160,
                width: 160,
                color: Colors.white,
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        }
        return Container(
          height: 160,
          alignment: Alignment.center,
          child: Text(AppLocalizations.of(context)!.qrNotFound),
        );
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is Membership) {
        _selectedPlanId = arg.id;
      }
      _paymentId = PaymentService.generateId();
      final ap = Provider.of<AuthProvider>(context, listen: false);
      if (ap.user != null) {
        _bankInfo = PaymentService.vietcombankInfo(_paymentId!, ap.user!.email);
      }
      _initialized = true;
    }
  }

  Future<void> _submit() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    if (ap.user == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginToPay),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.fixed,
          action: SnackBarAction(
            label: AppLocalizations.of(context)!.login,
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ),
      );
      return;
    }
    
    if (_submitted) return;

    setState(() => _isProcessing = true);
    try {
      final currentMid = ap.user!.membershipId;
      if (currentMid != null && currentMid.isNotEmpty) {
        messenger.showSnackBar(const SnackBar(content: Text('Bạn phải hủy gói hiện tại trước khi đăng ký gói mới'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.fixed));
        return;
      }
      final plans = Membership.plans();
      final plan = plans.firstWhere((p) => p.id == _selectedPlanId, orElse: () => plans.first);

      if (_method == 'Vietcombank') {
        await PaymentService.createPayment(
          id: _paymentId!,
          userId: ap.user!.id,
          plan: plan,
          method: _method,
          status: 'submitted',
        );
        setState(() { _submitted = true; });
        if (!mounted) return;
        messenger.showSnackBar(const SnackBar(content: Text('Đã gửi xác nhận, vui lòng đợi admin duyệt'), backgroundColor: Colors.green, behavior: SnackBarBehavior.fixed));
      } else {
        // PayPal or others
        await PaymentService.createPayment(
          id: _paymentId!,
          userId: ap.user!.id,
          plan: plan,
          method: _method,
          status: 'pending',
        );
        if (_method == 'PayPal') {
           await PaymentService.simulatePayPalSuccess(_paymentId!);
           setState(() { _submitted = true; });
           if (!mounted) return;
           messenger.showSnackBar(const SnackBar(content: Text('Thanh toán PayPal thành công, chờ duyệt'), backgroundColor: Colors.green, behavior: SnackBarBehavior.fixed));
        } else {
           await PaymentService.submitPayment(_paymentId!);
           setState(() { _submitted = true; });
        }
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context)!.paymentError}$e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.fixed));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = Membership.plans();
    Membership _currentPlan() => plans.firstWhere((p) => p.id == _selectedPlanId, orElse: () => plans.first);
    String _buttonLabel() {
      if (_method == 'Vietcombank') {
        if (!_submitted) return 'Gửi xác nhận';
        return 'Đã gửi, chờ duyệt';
      }
      return AppLocalizations.of(context)!.pay;
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          WRLogo(size: 24, onTap: () => Navigator.pushNamed(context, AppRouter.home)),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.payment),
        ]),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.orderInfo, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _selectedPlanId,
                        items: plans
                            .map((p) => DropdownMenuItem(
                                  value: p.id,
                                  child: Text('${p.name} • ${p.price.toStringAsFixed(0)} VND • +${p.quotaAdd} ${AppLocalizations.of(context)!.posts}'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedPlanId = v ?? 'basic'),
                      ),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.paymentMethod, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['Vietcombank', 'PayPal']
                            .map((m) => ChoiceChip(
                                  label: Text(m),
                                  selected: _method == m,
                                  onSelected: (_) => setState(() => _method = m),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      if (_method != 'Vietcombank')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: _qr(PaymentConfig.paypalQrAsset, url: PaymentConfig.paypalQrUrl)),
                            const SizedBox(height: 8),
                            Text(AppLocalizations.of(context)!.paypalNote),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Builder(builder: (context) {
                        final plan = _currentPlan();
                        final vat = (plan.price * 0.10);
                        final total = (plan.price + vat);
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2430),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 12))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Gói ${plan.name}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.bolt, color: Colors.purple[300]),
                                  const SizedBox(width: 8),
                                  const Expanded(child: Text('Tin được ưu tiên hiển thị, hạn mức đăng tin cao', style: TextStyle(color: Colors.white70)))
                                ],
                              ),
                              const SizedBox(height: 16),
                              Divider(color: Colors.white12),
                              const SizedBox(height: 12),
                              Text('Tóm tắt đơn hàng', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Expanded(child: Text('Gói đăng ký Hàng tháng', style: TextStyle(color: Colors.white70))),
                                  Text('₫${_formatVnd(plan.price)}', style: const TextStyle(color: Colors.white))
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Expanded(child: Text('VAT (10%)', style: TextStyle(color: Colors.white70))),
                                  Text('₫${_formatVnd(vat)}', style: const TextStyle(color: Colors.white))
                                ],
                              ),
                              const SizedBox(height: 10),
                              Divider(color: Colors.white12),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Expanded(child: Text('Đến hạn hôm nay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                  Text('₫${_formatVnd(total)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (_method == 'Vietcombank')
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      SizedBox(height: 80, width: 80, child: _qr(PaymentConfig.vietQrAsset, url: PaymentConfig.vietQrUrl)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('${PaymentConfig.bankName} • ${PaymentConfig.bankBranch}', style: const TextStyle(color: Colors.white)),
                                            const SizedBox(height: 4),
                                            Text('Tên TK: ${PaymentConfig.bankAccountName}', style: const TextStyle(color: Colors.white70)),
                                            Text('Số TK: ${PaymentConfig.bankAccountNumber}', style: const TextStyle(color: Colors.white70)),
                                            const SizedBox(height: 4),
                                            Text('Nội dung: ${(_bankInfo?['content'] ?? 'PAY-ORDER')}', style: const TextStyle(color: Colors.white70)),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text('Bằng việc thanh toán, bạn đồng ý với điều khoản dịch vụ và chính sách bảo mật', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing || (_method == 'Vietcombank' && _submitted) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isProcessing ? AppLocalizations.of(context)!.processing : _buttonLabel()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

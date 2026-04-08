import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:App_WRStudios/config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../config/app_router.dart';
import '../../config/constants.dart';
import '../../widgets/common/wr_logo.dart';
import '../../config/admin_config.dart';
import '../../services/firebase_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterValidEmailBeforeRecovery), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      await FirebaseService.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recoveryEmailSent(email)), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recoveryError(e)), backgroundColor: Colors.red),
      );
    }
  }
  @override
  void initState() {
    super.initState();
    if (AdminConfig.adminEmail.isNotEmpty) {
      _emailController.text = AdminConfig.adminEmail;
    }
    if (AdminConfig.adminPassword.isNotEmpty) {
      _passwordController.text = AdminConfig.adminPassword;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      if (authProvider.isLoggedIn) {
        if (kIsWeb && authProvider.user?.role == 'admin') {
          Navigator.pushReplacementNamed(context, AppRouter.admin);
        } else {
          Navigator.pushReplacementNamed(context, AppRouter.home);
        }
      } else if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Container(
                width: 900,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 800;
                    final left = Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: isWide
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24),
                              )
                            : const BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WRLogo(
                            size: 36,
                            showText: true,
                            onTap: () => Navigator.pushReplacementNamed(context, AppRouter.home),
                          ),
                          const SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!.helloWelcome,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 8),
                          Text(AppLocalizations.of(context)!.dontHaveAccount, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8))),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.register);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: Text(AppLocalizations.of(context)!.registration),
                          ),
                        ],
                      ),
                    );

                  final rightForm = Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.login,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                labelText: AppLocalizations.of(context)!.email,
                                hintText: AppLocalizations.of(context)!.email,
                                prefixIcon: Icons.person_outline,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppConstants.emailRequired;
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                    return AppConstants.emailInvalid;
                                  }
                                  return null;
                                },
                                filled: true,
                                borderColor: Colors.transparent,
                                focusedBorderColor: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _passwordController,
                                labelText: AppLocalizations.of(context)!.password,
                                hintText: AppLocalizations.of(context)!.password,
                                prefixIcon: Icons.lock_outline,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppConstants.passwordRequired;
                                  }
                                  if (value.length < 6) {
                                    return AppConstants.passwordMinLength;
                                  }
                                  return null;
                                },
                                filled: true,
                                borderColor: Colors.transparent,
                                focusedBorderColor: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(onPressed: _handleForgotPassword, child: Text(AppLocalizations.of(context)!.forgotPassword)),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  child: Text(AppLocalizations.of(context)!.login),
                                ),
                              ),
                              if (AdminConfig.adminEmail.isNotEmpty && AdminConfig.adminPassword.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(AppLocalizations.of(context)!.adminFilled, style: Theme.of(context).textTheme.bodySmall),
                              ],
                              const SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!.loginWithSocial,
                                  style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SocialIconButton(
                                    asset: 'assets/icons/facebook.png',
                                    disabled: Provider.of<AuthProvider>(context).isLoading,
                                  onPressed: () async {
                                      final ap = Provider.of<AuthProvider>(context, listen: false);
                                      await ap.loginWithFacebook();
                                      if (!context.mounted) return;
                                      if (ap.isLoggedIn) {
                                        if (kIsWeb && ap.user?.role == 'admin') {
                                          Navigator.pushReplacementNamed(context, AppRouter.admin);
                                        } else {
                                          Navigator.pushReplacementNamed(context, AppRouter.home);
                                        }
                                      } else if (ap.error != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(ap.error!),
                                            backgroundColor: ap.error!.toLowerCase().contains('huỷ') ? Colors.orange : Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _SocialIconButton(
                                    asset: 'assets/icons/google.png',
                                    disabled: Provider.of<AuthProvider>(context).isLoading,
                                  onPressed: () async {
                                      final ap = Provider.of<AuthProvider>(context, listen: false);
                                      await ap.loginWithGoogle();
                                      if (!context.mounted) return;
                                      if (ap.isLoggedIn) {
                                        if (kIsWeb && ap.user?.role == 'admin') {
                                          Navigator.pushReplacementNamed(context, AppRouter.admin);
                                        } else {
                                          Navigator.pushReplacementNamed(context, AppRouter.home);
                                        }
                                      } else if (ap.error != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(ap.error!), backgroundColor: Colors.red),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: left),
                        Expanded(child: rightForm),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        left,
                        rightForm,
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String asset;
  final VoidCallback onPressed;
  final bool disabled;
  const _SocialIconButton({required this.asset, required this.onPressed, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: IconButton(
        onPressed: disabled ? null : onPressed,
        icon: Image.asset(asset, width: 24, height: 24),
      ),
    );
  }
}

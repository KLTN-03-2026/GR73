import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:App_WRStudios/config/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../config/app_router.dart';
import '../../config/constants.dart';
import '../../widgets/common/wr_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.passwordsDoNotMatch),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );

      if (!mounted) return;
      if (authProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registerSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRouter.login);
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
                      color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 800;
                  final leftForm = Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.registration,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _nameController,
                                labelText: AppLocalizations.of(context)!.username,
                                hintText: AppLocalizations.of(context)!.username,
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppConstants.nameRequired;
                                  }
                                  return null;
                                },
                                filled: true,
                                borderColor: Colors.transparent,
                                focusedBorderColor: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _emailController,
                                labelText: AppLocalizations.of(context)!.email,
                                hintText: AppLocalizations.of(context)!.email,
                                prefixIcon: Icons.email_outlined,
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
                                controller: _phoneController,
                                labelText: AppLocalizations.of(context)!.phone,
                                hintText: AppLocalizations.of(context)!.phone,
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppConstants.phoneRequired;
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
                              const SizedBox(height: 16),
                              CustomTextField(
                                controller: _confirmPasswordController,
                                labelText: AppLocalizations.of(context)!.confirmPassword,
                                hintText: AppLocalizations.of(context)!.confirmPassword,
                                prefixIcon: Icons.lock_outline,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return AppConstants.passwordRequired;
                                  }
                                  if (value != _passwordController.text) {
                                    return AppLocalizations.of(context)!.passwordsDoNotMatch;
                                  }
                                  return null;
                                },
                                filled: true,
                                borderColor: Colors.transparent,
                                focusedBorderColor: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  child: Text(AppLocalizations.of(context)!.registration),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  final rightPanel = Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: isWide
                          ? const BorderRadius.only(
                              topRight: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            )
                          : const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const WRLogo(size: 36, showText: true),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.welcomeBack,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.alreadyHaveAccount, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8))),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, AppRouter.login);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text(AppLocalizations.of(context)!.login),
                        ),
                      ],
                    ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: leftForm),
                        Expanded(child: rightPanel),
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        leftForm,
                        rightPanel,
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

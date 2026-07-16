import 'package:attendance_management_system/core/utils/validators.dart';
import 'package:attendance_management_system/core/widgets/buttons/primary_button.dart';
import 'package:attendance_management_system/data/providers/auth_provider.dart';
import 'package:attendance_management_system/features/auth/register/register_page.dart';
import 'package:attendance_management_system/features/dashboard/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/auth_layout.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_footer.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();

    if (provider.isLoading) return;

    try {
      final success = await provider.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
          (route) => false,
        );
      } else {
        _formKey.currentState!.validate();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AuthLayout(
      child: AuthCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Welcome Back',
                subtitle: 'Sign in to your account',
              ),

              const SizedBox(height: 32),

              CustomTextField(
                controller: _identifierController,
                label: 'Email or Staff ID',
                hint: 'Enter your email or staff id',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.loginIdentifier,
                onChanged: (_) {
                  context.read<AuthProvider>().clearLoginError();
                },
              ),

              const SizedBox(height: 20),

              PasswordField(
                controller: _passwordController,
                label: 'Password',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }

                  return null;
                },
                onChanged: (_) {
                  context.read<AuthProvider>().clearLoginError();
                },
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO:
                    // Forgot Password
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),

              const SizedBox(height: 20),

              if (authProvider.loginError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authProvider.loginError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              PrimaryButton(
                text: 'Login',
                icon: Icons.login_rounded,
                isLoading: authProvider.isLoading,
                isIconLeading: false,
                onPressed: _login,
              ),

              const SizedBox(height: 24),

              AuthFooter(
                text: "Don't have an account?",
                actionText: "Register",
                onPressed: () async {
                  context.read<AuthProvider>().resetLoginState();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return RegisterPage();
                      },
                    ),
                  );
                  _identifierController.clear();
                  _passwordController.clear();

                  context.read<AuthProvider>().resetLoginState();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

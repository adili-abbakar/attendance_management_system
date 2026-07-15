import 'package:attendance_management_system/core/utils/validators.dart';
import 'package:attendance_management_system/data/models/auth/user.dart';
import 'package:attendance_management_system/data/services/auth_service.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/buttons/primary_button.dart';
import '../widgets/auth_card.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_layout.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/password_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  String? _emailError;
  String? _staffIdError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _staffIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _staffIdController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();

    _emailError = null;
    _staffIdError = null;
  }

  Future<void> _register() async {
    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _emailError = null;
      _staffIdError = null;
    });

    try {
      final result = await AuthService.instance.register(
        User(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          staffId: _staffIdController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;

      if (result.success) {
        setState(() => _isLoading = false);

        _clearForm();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);

        return;
      }

      setState(() {
        _isLoading = false;
        _emailError = result.emailError;
        _staffIdError = result.staffIdError;
      });

      _formKey.currentState!.validate();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: AuthCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeader(
                title: 'Create Account',
                subtitle: 'Register to continue',
              ),

              const SizedBox(height: 32),

              CustomTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline_rounded,
                validator: Validators.name,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (value) => _emailError ?? Validators.email(value),
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() => _emailError = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: _staffIdController,
                label: 'Staff ID',
                hint: 'Enter your staff ID',
                prefixIcon: Icons.badge_outlined,
                validator: (value) =>
                    _staffIdError ?? Validators.staffId(value),
                onChanged: (_) {
                  if (_staffIdError != null) {
                    setState(() => _staffIdError = null);
                  }
                },
              ),

              const SizedBox(height: 20),

              PasswordField(
                controller: _passwordController,
                label: 'Password',
                validator: Validators.password,
                onChanged: (_) {
                  if (_confirmPasswordController.text.isNotEmpty) {
                    _formKey.currentState?.validate();
                  }
                },
              ),

              const SizedBox(height: 20),

              PasswordField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                validator: (value) =>
                    Validators.confirmPassword(value, _passwordController.text),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                text: 'Create Account',
                icon: Icons.person_add_alt_1_rounded,
                isLoading: _isLoading,
                isIconLeading: false,
                onPressed: _register,
              ),

              const SizedBox(height: 24),

              AuthFooter(
                text: 'Already have an account?',
                actionText: 'Login',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

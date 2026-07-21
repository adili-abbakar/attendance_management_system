import 'package:attendance_management_system/core/utils/validators.dart';
import 'package:attendance_management_system/features/auth/models/user.dart';
import 'package:attendance_management_system/features/auth/services/auth_service.dart';
import 'package:attendance_management_system/features/auth/widgets/password_field.dart';
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _passwordController = TextEditingController();

  List<User> _users = [];

  bool _isEditing = false;
  int? _editingId;

  String? _emailError;
  String? _staffIdError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _staffIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _editingId = null;
    _isEditing = false;

    _emailError = null;
    _staffIdError = null;

    _nameController.clear();
    _emailController.clear();
    _staffIdController.clear();
    _passwordController.clear();

    setState(() {});
  }

  Future<void> _loadUsers() async {
    _users = await AuthService.instance.getUsers();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    if (_isEditing) {
      final result = await AuthService.instance.updateUser(
        User(
          id: _editingId!,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          staffId: _staffIdController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully.')),
        );

        _clearForm();
        await _loadUsers();

        return;
      }

      setState(() {
        _emailError = result.emailError;
        _staffIdError = result.staffIdError;
      });

      _formKey.currentState!.validate();

      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User created successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      _clearForm();
      await _loadUsers();
      return;
    }

    setState(() {
      _emailError = result.emailError;
      _staffIdError = result.staffIdError;
    });

    _formKey.currentState!.validate();
  }

  void _editUser(User user) {
    _editingId = user.id;
    _isEditing = true;

    _nameController.text = user.name;
    _emailController.text = user.email;
    _staffIdController.text = user.staffId;
    _passwordController.text = user.password;

    setState(() {});
  }

  Future<void> _deleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete "${user.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final deleted = await AuthService.instance.deleteUser(user.id!);

    if (!mounted) return;

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully.')),
      );

      await _loadUsers();
    }
  }

  @override
  void initState() {
    super.initState();

    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("SQLite Playground")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 850) {
                  return _mobileLayout(colors);
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildForm(colors)),
                    const SizedBox(width: 24),
                    Expanded(flex: 6, child: _buildList(colors)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileLayout(ColorScheme colors) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildForm(colors),
          const SizedBox(height: 24),
          _buildList(colors),
        ],
      ),
    );
  }

  Widget _buildForm(ColorScheme colors) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                _isEditing ? "Edit User" : "Create User",
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: Validators.name,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  return _emailError ?? Validators.email(value);
                },
                onChanged: (_) {
                  if (_emailError != null) {
                    setState(() {
                      _emailError = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _staffIdController,
                decoration: const InputDecoration(
                  labelText: "Staff ID",
                  prefixIcon: Icon(Icons.badge_outlined),
                ),

                validator: (value) {
                  return _staffIdError ?? Validators.staffId(value);
                },
                onChanged: (_) {
                  if (_staffIdError != null) {
                    setState(() {
                      _staffIdError = null;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              PasswordField(
                controller: _passwordController,
                label: 'Password',
                validator: Validators.password,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveUser,
                  icon: Icon(_isEditing ? Icons.save : Icons.person_add),
                  label: Text(_isEditing ? "Update User" : "Create User"),
                ),
              ),

              if (_isEditing) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _clearForm,
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(ColorScheme colors) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text("Users", style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _loadUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
                ),
              ],
            ),

            const SizedBox(height: 20),
            if (_users.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text("No users found.")),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = _users[index];
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: colors.surfaceContainerHighest,
                    leading: CircleAvatar(child: Text(user.id.toString())),
                    title: Text(user.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        Text(user.staffId),
                        Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              onPressed: () => _editUser(user),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => _deleteUser(user),
                              color: Colors.red,
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

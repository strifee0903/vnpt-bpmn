import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../components/colors.dart';
import '../../shared/dialog_utils.dart';
import 'auth_manager.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'uName': '',
    'uEmail': '',
    'uPass': '',
    'uAddress': '',
    'uBirthday':'',
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _obscurePassword = true;
  DateTime? _selectedBirthday;
  final _birthdayController = TextEditingController();


  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      // Check mounted before setState
      setState(() {
        _selectedBirthday = pickedDate;
        _birthdayController.text = "${pickedDate.toLocal()}".split(' ')[0];
        _authData['uBirthday'] = _birthdayController.text;
      });
    }
  }


  Future<bool> _validateFields() async {
    final username = _authData['uName'] ?? '';
    final email = _authData['uEmail'] ?? '';
    final password = _authData['uPass'] ?? '';
    final address = _authData['uAddress'] ?? '';
    final birthday = _authData['uBirthday'] ?? '';


    // Validate password (for both login and signup)
    if (password.isEmpty) {
      await showErrorDialog(context, 'Please enter a password');
      return false;
    }
    if (password.length < 8) {
      await showErrorDialog(
          context, 'Password must be at least 8 characters long');
      return false;
    }

    if (email.isEmpty) {
      await showErrorDialog(context, 'Please enter a email');
      return false;
    }

    // Additional validations for signup mode
    if (_authMode == AuthMode.signup) {
      // Validate username
      if (username.isEmpty) {
        await showErrorDialog(context, 'Username cannot be blank!');
        return false;
      }
      if (username.length <= 3) {
        await showErrorDialog(
            context, 'Username must be more than 3 characters long');
        return false;
      }

      if (address.isEmpty) {
        await showErrorDialog(context, 'Please enter a address');
        return false;
      }

      // Validate phone
      if (birthday.isEmpty) {
        await showErrorDialog(context, 'Please enter a birthday');
        return false;
      }
    }

    return true; // All validations passed
  }

  Future<void> _submit() async {
    if (!mounted) return; // Early return if not mounted

    _formKey.currentState!.save();
    _isSubmitting.value = true;

    print('✅ Auth data after save: $_authData');

    // Validate fields and show errors in popup if validation fails
    final isValid = await _validateFields();
    if (!isValid) {
      if (mounted) {
        // Check mounted before updating
        _isSubmitting.value = false;
      }
      return;
    }

    try {
      final authManager = context.read<AuthManager>();
      if (_authMode == AuthMode.login) {
        await authManager.login(
          _authData['uEmail']!,
          _authData['uPass']!,
        );
      } else {
        await authManager.signup(
            _authData['uName']!,
            _authData['uEmail']!,
            _authData['uPass']!,
            _authData['uAddress']!,
            _authData['uBirthday']!);
        await authManager.logout();
        if (mounted) {
          await showSuccessDialog(
              context, 'Account created successfully! Please log in.');
        }
        // Only proceed if still mounted
        if (mounted) {
          final email = _authData['uEmail'];
          final password = _authData['uPass'];
          _authData['uName'] = '';
          _authData['uPass'] = '';
          _switchAuthMode();
          setState(() {
            _authData['uEmail'] = email!;
            _authData['uPass'] = password!;
            _emailController.text = email;
            _passwordController.text = password;
          });
        }
      }
    } catch (error) {
      log('$error');
      if (mounted) {
        String errorMessage = error.toString();
        while (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring('Exception: '.length);
        }
        showErrorDialog(context, errorMessage);
      }
    }

    // Check mounted before updating UI
    if (mounted) {
      _isSubmitting.value = false;
    }
  }

  void _switchAuthMode() {
    if (mounted) {
      // Check mounted before setState
      setState(() {
        _authMode =
            _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Container(
            width: double.infinity,
            height: size.height * 0.9,
            decoration: const BoxDecoration(
              color: color17,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    _authMode == AuthMode.signup
                        ? "Register new account!"
                        : "Login to your account!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 25,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                      color: color4,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_authMode == AuthMode.signup) ...[
                          _buildUsernameField(),
                        ],
                        _buildEmailField(),
                        _buildPasswordField(),
                        if (_authMode == AuthMode.signup) ...[
                          _buildBirthdayField(),
                          _buildAddressField(),
                        ],
                        
                        // if (_authMode == AuthMode.signup) ...[
                        // ],
                        ValueListenableBuilder<bool>(
                          valueListenable: _isSubmitting,
                          builder: (context, isSubmitting, child) {
                            return isSubmitting
                                ? const CircularProgressIndicator()
                                : _buildSubmitButton();
                          },
                        ),
                        _buildAuthModeSwitchButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
      hintText: "Username",
      icon: Icons.person,
      onSaved: (value) => _authData['uName'] = value!,
    );
  }

  Widget _buildAddressField() {
    return _buildTextField(
      hintText: "Address",
      icon: Icons.phone,
      onSaved: (value) => _authData['uAddress'] = value!,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      hintText: "Email",
      icon: Icons.email,
      controller: _emailController,
      onSaved: (value) => _authData['uEmail'] = value!,
    );
  }

  Widget _buildBirthdayField() {
    return _buildTextField(
      hintText: "Birthday (yyyy-mm-dd)",
      icon: Icons.cake,
      controller: _birthdayController,
      onSaved: (value) {
        _authData['uBirthday'] = value!;
      },
      suffixIcon: const Icon(Icons.calendar_today, color: color1),
      readOnly: true,
      onTap: () => _selectBirthday(context),
    );
  }



  Widget _buildPasswordField() {
    return _buildTextField(
      hintText: "Password",
      icon: Icons.lock,
      obscureText: _obscurePassword,
      controller: _passwordController,
      onSaved: (value) => _authData['uPass'] = value!,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: color1,
        ),
        onPressed: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
      ),
    );
  }


  Widget _buildAuthModeSwitchButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _authMode == AuthMode.login
              ? "Does not have any account?"
              : "Already have an account?",
          style: TextStyle(
            color: color4,
            fontSize: 15,
          ),
        ),
        TextButton(
          onPressed: _switchAuthMode,
          child: Text(
            _authMode == AuthMode.login ? 'Register here' : 'Login here',
            style: TextStyle(
              color: color4,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: size.width * 0.8,
      height: 55,
      decoration: BoxDecoration(
        color: color4,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        onPressed: _submit,
        child: Text(
          _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP',
          style: TextStyle(color: color13, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
    TextEditingController? controller,
    void Function(String?)? onSaved,
    void Function()? onTap,
    Widget? suffixIcon,
  }) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        cursorColor: color1,
        style: const TextStyle(height: 1, fontSize: 16),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: color1,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: color1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          suffixIcon: suffixIcon,
        ),
        onSaved: onSaved,
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: color13,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color4, width: 1.5),
      ),
      child: child,
    );
  }
}

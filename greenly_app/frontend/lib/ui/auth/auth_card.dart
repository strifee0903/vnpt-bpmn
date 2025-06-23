import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/dialog_utils.dart';
import 'auth_manager.dart';

enum AuthMode { signup, login }

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData = {
    'uName': '',
    'uEmail': '',
    'uPass': '',
    'uAddress': '',
    'uBirthday': '',
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _obscurePassword = true;
  DateTime? _selectedBirthday;
  final _birthdayController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  // Green color palette
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color backgroundGreen = Color(0xFFF1F8E9);
  static const Color softGreen = Color(0xFFE8F5E8);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && mounted) {
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
      await showErrorDialog(context, 'Please enter an email');
      return false;
    }

    if (_authMode == AuthMode.signup) {
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
        await showErrorDialog(context, 'Please enter an address');
        return false;
      }

      if (birthday.isEmpty) {
        await showErrorDialog(context, 'Please select your birthday');
        return false;
      }
    }

    return true;
  }

  Future<void> _submit() async {
    if (!mounted) return;

    _formKey.currentState!.save();
    _isSubmitting.value = true;

    final isValid = await _validateFields();
    if (!isValid) {
      if (mounted) {
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

    if (mounted) {
      _isSubmitting.value = false;
    }
  }

  void _switchAuthMode() {
    if (mounted) {
      setState(() {
        _authMode =
            _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height:
          _authMode == AuthMode.login ? size.height * 0.65 : size.height * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_slideAnimation),
        child: FadeTransition(
          opacity: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mode indicator
                  Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: softGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title
                  // Text(
                  //   _authMode == AuthMode.signup
                  //       ? "Join the Green Community"
                  //       : "Welcome Back!",
                  //   style: const TextStyle(
                  //     fontSize: 24,
                  //     fontWeight: FontWeight.bold,
                  //     color: darkGreen,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  Text(
                    _authMode == AuthMode.signup
                        ? "Start your eco-friendly journey"
                        : "Welcome back!",
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryGreen.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Form fields
                  if (_authMode == AuthMode.signup) ...[
                    _buildUsernameField(),
                    const SizedBox(height: 16),
                  ],
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  if (_authMode == AuthMode.signup) ...[
                    const SizedBox(height: 16),
                    _buildBirthdayField(),
                    const SizedBox(height: 16),
                    _buildAddressField(),
                  ],
                  const SizedBox(height: 25),

                  // Submit button
                  ValueListenableBuilder<bool>(
                    valueListenable: _isSubmitting,
                    builder: (context, isSubmitting, child) {
                      return isSubmitting
                          ? Container(
                              height: 50,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      primaryGreen),
                                ),
                              ),
                            )
                          : _buildSubmitButton();
                    },
                  ),
                  const SizedBox(height: 10),

                  // Auth mode switch
                  _buildAuthModeSwitchButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    return _buildTextField(
      hintText: "Choose a username",
      icon: Icons.person_outline,
      onSaved: (value) => _authData['uName'] = value!,
    );
  }

  Widget _buildAddressField() {
    return _buildTextField(
      hintText: "Your address",
      icon: Icons.location_on_outlined,
      onSaved: (value) => _authData['uAddress'] = value!,
    );
  }

  Widget _buildEmailField() {
    return _buildTextField(
      hintText: "Email address",
      icon: Icons.email_outlined,
      controller: _emailController,
      onSaved: (value) => _authData['uEmail'] = value!,
    );
  }

  Widget _buildBirthdayField() {
    return _buildTextField(
      hintText: "Select your birthday",
      icon: Icons.cake_outlined,
      controller: _birthdayController,
      onSaved: (value) {
        _authData['uBirthday'] = value!;
      },
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        color: primaryGreen.withOpacity(0.7),
        size: 20,
      ),
      readOnly: true,
      onTap: () => _selectBirthday(context),
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      hintText: "Password",
      icon: Icons.lock_outline,
      obscureText: _obscurePassword,
      controller: _passwordController,
      onSaved: (value) => _authData['uPass'] = value!,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: primaryGreen.withOpacity(0.7),
          size: 20,
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
              ? "New to Greenly? "
              : "Already have an account? ",
          style: TextStyle(
            color: darkGreen.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: _switchAuthMode,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            _authMode == AuthMode.login ? 'Sign Up' : 'Login',
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryGreen, lightGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextButton(
        onPressed: _submit,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          _authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: backgroundGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: softGreen,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        cursorColor: primaryGreen,
        style: const TextStyle(
          fontSize: 16,
          color: darkGreen,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: primaryGreen.withOpacity(0.7),
            size: 22,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: darkGreen.withOpacity(0.5),
            fontSize: 14,
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onSaved: onSaved,
      ),
    );
  }
}

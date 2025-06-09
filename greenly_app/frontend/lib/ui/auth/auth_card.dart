import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../components/colors.dart';
import 'auth_manager.dart';
// import '../../components/paths.dart';

class AuthCard extends StatefulWidget {
  final bool isLogin;
  final VoidCallback? onSwitchAuthMode;

  const AuthCard({Key? key, required this.isLogin, this.onSwitchAuthMode})
      : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _acceptTerms = false;
  bool _obscurePassword = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ecoGreen,
              onPrimary: textNatureLight,
              onSurface: textNatureDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: ecoGreen,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!widget.isLogin && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the terms and conditions'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authManager = Provider.of<AuthManager>(context, listen: false);
      if (widget.isLogin) {
        await authManager.login(
          uEmail: _emailController.text.trim(),
          uPass: _passController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Welcome back eco-warrior!'),
            backgroundColor: ecoGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        await authManager.register(
          uName: _nameController.text.trim(),
          uEmail: _emailController.text.trim(),
          uPass: _passController.text.trim(),
          uAddress: _addressController.text.trim(),
          uBirthday: _birthdayController.text.trim(),
        );
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Welcome to the Greenly community!'),
            backgroundColor: ecoGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on EmailVerificationRequiredException catch (e) {
      if (!widget.isLogin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${widget.isLogin ? 'Login' : 'Registration'} failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 0), // Reduced vertical margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: mistWhite,
      child: Padding(
        padding: !widget.isLogin ? EdgeInsets.fromLTRB(25, 25, 25, 10) : EdgeInsets.fromLTRB(25, 25, 25, 25),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.isLogin)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(color: textNatureDark, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.person_outline, color: ecoGreen),
                    filled: true,
                    fillColor: skyLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: textNatureDark, fontSize: 14),
                  prefixIcon: const Icon(Icons.email_outlined, color: ecoGreen),
                  filled: true,
                  fillColor: skyLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter your email';
                  if (!value.contains('@')) return 'Please enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 20), // Reduced spacing
              TextFormField(
                controller: _passController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: textNatureDark, fontSize: 14),
                  prefixIcon: const Icon(Icons.lock_outlined, color: ecoGreen),
                  filled: true,
                  fillColor: skyLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: ecoGreen,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Please enter a password';
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: widget.isLogin ? 8 : 20),
              if (!widget.isLogin)
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: const TextStyle(color: textNatureDark, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.home_outlined, color: ecoGreen),
                    filled: true,
                    fillColor: skyLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your address' : null,
                ),
              const SizedBox(height: 20),
              if (!widget.isLogin)
                TextFormField(
                  controller: _birthdayController,
                  decoration: InputDecoration(
                    labelText: 'Birthday',
                    labelStyle: const TextStyle(color: textNatureDark, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.cake_outlined, color: ecoGreen),
                    filled: true,
                    fillColor: skyLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today_outlined,
                          color: ecoGreen),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Please select your birthday' : null,
                ),
              const SizedBox(height: 0),
              if (widget.isLogin)
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value!;
                        });
                      },
                      activeColor: ecoGreen,
                    ),
                    Text(
                      'Remember me',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textNatureDark,
                      ),
                    ),
                    // const Spacer(),
                    // TextButton(
                    //   onPressed: () {
                    //     // Add forgot password functionality
                    //   },
                    //   child: Text(
                    //     'Forgot Password?',
                    //     style: GoogleFonts.poppins(
                    //       fontSize: 14,
                    //       color: textNatureDark,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 10,),
              if (!widget.isLogin)
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value!;
                        });
                      },
                      activeColor: ecoGreen,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: "I agree to the ",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: textNatureDark),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textNatureDark,
                              ),
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textNatureDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12), // Reduced spacing
              if (_isLoading)
                CircularProgressIndicator(color: ecoGreen)
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonPrimary,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.isLogin ? 'Sign In' : 'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textNatureLight,
                    ),
                  ),
                ),
              const SizedBox(height: 8), // Reduced spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      color: textNatureDark.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'or',
                      style: GoogleFonts.poppins(
                        color: textNatureDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: textNatureDark.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 8), // Reduced spacing
              TextButton(
                onPressed: widget.onSwitchAuthMode,
                child: RichText(
                  text: TextSpan(
                    text: widget.isLogin
                        ? "New to Greenly? "
                        : "Already have an account? ",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textNatureDark,
                    ),
                    children: [
                      TextSpan(
                        text: widget.isLogin ? "Join now" : "Sign In",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: textNatureDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }
}
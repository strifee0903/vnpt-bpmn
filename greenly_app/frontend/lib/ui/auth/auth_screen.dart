import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_card.dart';
// import '../../components/paths.dart';
import '../../components/colors.dart';
import '';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              deepForest,
              ecoGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            // Add SingleChildScrollView to handle small screens
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context)
                        .padding
                        .bottom, // Ensure it takes at least the screen height minus padding
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the content vertically
                children: [
                  const SizedBox(height: 20), // Reduced consistent top padding
                  // Eco-friendly leaf icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: mistWhite.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 60,
                      color: textNatureLight,
                    ),
                  ),
                  const SizedBox(height: 12), // Reduced spacing
                  Text(
                    _isLogin ? 'Welcome to Greenly' : 'Join Greenly',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: textNatureLight,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8), // Reduced spacing
                  Text(
                    _isLogin
                        ? 'Your eco-friendly journey starts here'
                        : 'Start your sustainable journey today',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: textNatureLight.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16), // Reduced spacing
                  AuthCard(
                    isLogin: _isLogin,
                    onSwitchAuthMode: _switchAuthMode,
                  ),
                  // const SizedBox(height: 12), // Reduced spacing
                  // Text(
                  //   'By continuing, you agree to our Sustainability Pledge',
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 12,
                  //     color: textNatureLight.withOpacity(0.54),
                  //   ),
                  //   textAlign: TextAlign.center,
                  // ),
                  // const SizedBox(height: 20), // Reduced bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

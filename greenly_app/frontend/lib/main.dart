import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:greenly_app/ui/home/home.dart'; // Import HomePage
import 'ui/pages/mydiary/mydiary.dart';
import 'ui/pages/greenlibrary/greenlibrary.dart'; // Import GreenLibrary
import 'ui/moments/moments.dart'; // Import MomentsPage
=======
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/paths.dart';
>>>>>>> 477bcfc0740c0da90060dda174bea58e74d5d81b

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Dotenv loaded successfully! BASE_URL=${dotenv.env['BASE_URL']}");
  } catch (e) {
    print("❌ Dotenv loaded failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green), // Đồng bộ với theme xanh
        useMaterial3: true,
      ),
      home: const HomePage(),
      routes: {
        '/myDiary': (context) => const MyDiary(),
        '/greenLibrary': (context) => const GreenLibrary(),
        '/moments': (context) =>
            const MomentsPage(), // Thêm route cho MomentsPage
      },
=======
    
    final themeData = ThemeData(
      primarySwatch: Colors.blueGrey,
      scaffoldBackgroundColor: const Color(0xFFE8F5E9),
      textTheme: GoogleFonts.poppinsTextTheme(),
      useMaterial3: true,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A3C34),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1A3C34),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A3C34), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A3C34),
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          color: Colors.black87,
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthManager()),
      ],
      child: Builder(builder: (context) {
        final authManager = Provider.of<AuthManager>(context, listen: false);
        if (!authManager.isInitialized) {
          authManager.initialize();
        }

        return Consumer<AuthManager>(
          builder: (ctx, authManager, child) {
            print('🔴 Building app: isInitialized=${authManager.isInitialized}, isAuth=${authManager.isAuth}, isSplashComplete=${authManager.isSplashComplete}');

            Widget homeScreen;
            if (!authManager.isSplashComplete) {
              homeScreen = const SplashScreen();
            } else if (!authManager.isAuth) {
              homeScreen = const AuthScreen();
            } else {
              homeScreen = const UserScreen();
            }
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Greenly',
              theme: themeData,
              home: homeScreen,
              routes: {
                AuthScreen.routeName: (ctx) => const AuthScreen(),
                UserScreen.routeName: (ctx) => const UserScreen(),
              },
              onGenerateRoute: (settings) {
                print('🔴 Navigating to route: ${settings.name}');
                return MaterialPageRoute(
                  builder: (ctx) => const SafeArea(
                    child: Scaffold(
                      body: Center(child: Text('Page not found')),
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
>>>>>>> 477bcfc0740c0da90060dda174bea58e74d5d81b
    );
  }
}

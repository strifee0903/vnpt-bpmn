import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:greenly_app/ui/user/not_found_screen.dart';
import 'package:provider/provider.dart';

import 'components/colors.dart';
import 'services/moment_service.dart';
import 'ui/auth/auth_manager.dart';
import 'ui/auth/auth_screen.dart';
import 'ui/home/home.dart';
import 'ui/slpash_screen.dart';
import 'ui/pages/greenlibrary/greenlibrary.dart'; // Import GreenLibrary
import 'ui/pages/mydiary/mydiary.dart'; // Import MyDiary
import 'ui/pages/campaign/campaign.dart'; // Import Campaign
import 'ui/moments/moments.dart';
import 'shared/main_layout.dart';

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;

  SlideUpRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            )),
            child: child,
          ),
        );
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;

  ScaleRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            )),
            child: child,
          ),
        );
}

class FadeSlideRoute extends PageRouteBuilder {
  final Widget page;

  FadeSlideRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            const begin = Offset(0.2, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var slideTween = Tween<Offset>(begin: begin, end: end).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: curve),
            );

            return FadeTransition(
              opacity: fadeTween,
              child: SlideTransition(
                position: slideTween,
                child: child,
              ),
            );
          },
        );
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
}

class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;

  SlideLeftRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          ),
        );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Dotenv loaded successfully!");
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
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 255, 158, 158),
      secondary: const Color(0xFFFFF8DC),
      surface: const Color.fromARGB(255, 255, 245, 245),
      surfaceTint: const Color.fromARGB(255, 255, 158, 158),
      primary: const Color.fromARGB(255, 255, 158, 158),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
    );

    final themeData = ThemeData(
      fontFamily: 'Lato',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: color13,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        elevation: 4,
      ),
      dialogTheme: DialogTheme(
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthManager()),
        Provider(create: (_) => MomentService()),
      ],
      child: Builder(builder: (context) {
        final authManager = Provider.of<AuthManager>(context, listen: false);
        if (!authManager.isInitialized) {
          print('🔴 Triggering AuthManager initialization');
          authManager.initialize();
        }

        return Consumer<AuthManager>(
          builder: (ctx, authManager, child) {
            print(
                '🔴 Building app: isInitialized=${authManager.isInitialized}, '
                'isAuth=${authManager.isAuth}, '
                'isSplashComplete=${authManager.isSplashComplete}');

            Widget homeScreen;
            if (!authManager.isSplashComplete) {
              homeScreen = const SplashScreen();
            } else if (!authManager.isAuth) {
              homeScreen = const AuthScreen();
            } else {
              homeScreen = const MainLayout();
            }

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Greenly App',
              theme: themeData,
              home: homeScreen,
              routes: {
                AuthScreen.routeName: (ctx) =>
                    const SafeArea(child: AuthScreen()),
                HomePage.routeName: (ctx) =>
                    const SafeArea(child: MainLayout()),
                '/myDiary': (ctx) => const SafeArea(child: MyDiary()),
                '/greenLibrary': (ctx) => const SafeArea(child: GreenLibrary()),
                '/campaign': (ctx) => const SafeArea(child: Campaign()),
                '/moments': (ctx) => const SafeArea(child: MomentsPage()),
                '/profile': (ctx) => const SafeArea(
                    child: MainLayout(initialIndex: 3)), // Update to MainLayout
              },
              onGenerateRoute: (settings) {
                print('🔴 Navigating to route: ${settings.name}');
                switch (settings.name) {
                  case HomePage.routeName:
                    return SlideUpRoute(page: const MainLayout());
                  case '/myDiary':
                    return SlideRightRoute(page: const MyDiary());
                  case '/greenLibrary':
                    return FadeSlideRoute(page: const GreenLibrary());
                  case '/moments':
                    return ScaleRoute(page: const MomentsPage());
                  case '/profile':
                    return ScaleRoute(
                        page: const MainLayout(
                            initialIndex: 3)); // Update to MainLayout
                  default:
                    print('🔴 Unknown route: ${settings.name}');
                    return SlideUpRoute(page: const NotFoundScreen());
                }
              },
              onUnknownRoute: (settings) {
                return SlideUpRoute(page: const NotFoundScreen());
              },
            );
          },
        );
      }),
    );
  }
}

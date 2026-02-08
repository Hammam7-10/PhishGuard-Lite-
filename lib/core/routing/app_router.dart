import 'package:flutter/material.dart';
import 'package:phishguard_lite/core/nav/report_details_args.dart';
import '../../presentation/screens/add_report_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/report_details_screen.dart';
import '../../presentation/screens/root_shell.dart';
import '../../presentation/screens/splash_screen.dart';

class Routes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const root = '/root';
  static const addReport = '/add-report';
  static const reportDetails = '/report-details';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case Routes.root:
        return MaterialPageRoute(builder: (_) => const RootShell());
      case Routes.addReport:
        return MaterialPageRoute(builder: (_) => const AddReportScreen());
      case Routes.reportDetails:
        {
          final args = settings.arguments;

          // نقبل ReportDetailsArgs أو int مباشرة
          if (args is ReportDetailsArgs) {
            return MaterialPageRoute(
                builder: (_) => ReportDetailsScreen(args: args));
          }

          if (args is int) {
            return MaterialPageRoute(
              builder: (_) =>
                  ReportDetailsScreen(args: ReportDetailsArgs(reportId: args)),
            );
          }

          return _error('Missing ReportDetailsArgs');
        }

      default:
        return _error('Unknown route: ${settings.name}');
    }
  }

  static Route<dynamic> _error(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Navigation Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'services/sms_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/user_management_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final SmsService smsService = SmsService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MOney Admin',
      initialRoute: '/login', //Aqui se define en que pagina inicia la app
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/users': (context) => const UserManagementScreen(),

      },
    );
  }
}

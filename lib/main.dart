import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'services/sms_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final SmsService smsService = SmsService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Money Admin New")),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await smsService.sendPaymentReminder("3001234567", 150000);
            },
            child: Text("Enviar recordatorio de pago"),
          ),
        ),
      ),
    );
  }
}

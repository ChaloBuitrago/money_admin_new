import 'package:flutter_sms/flutter_sms.dart';
import 'package:permission_handler/permission_handler.dart';

class SmsService {
  //Enviar SMS a un número específico

    Future<void> sendSms(String phone, String message) async {
    var status = await Permission.sms.request();
    if (status.isGranted) {
        String result = await sendSMS(
            message: message,
            recipients: [phone],
        );
        print("Resultado: $result");
    } else {
    throw Exception("Permiso SMS no concedido");
    }
    }

    //Ejemplo de mensaje automatico para recordatorio de pago
    Future<void> sendPaymentReminder(String phoneNumber, double montoPendiente,) async {
        String message = "Recordatorio de pago: Tienes un pago pendiente de \$${montoPendiente.toStringAsFixed(2)}.";
        await sendSms(phoneNumber, message);
  }

}
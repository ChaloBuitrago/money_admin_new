# money_admin_new

Aplicación Flutter para gestionar prestamos, pagos, generar reportes y el envío de SMS automaticos a
los clientes de acuerdo con la información registrada en la base de datos. La aplicación estará dirigida
a una persona natural. El admin podra crear usuarios y luego de crearlos podrá asignarles prestamos y pagos
que variará la periodocidad según el cliente.
El admin podra generar reportes de los prestamos y pagos realizados por cada usuario, estos reportes
serán trimestrles y semestrales.

Al momento de la app enviar el mensaje al usuario enviará un resumen de su pretamo, qu ele indicará
el monto total del prestamo, el monto pagado, el monto restante y la fecha del próximo pago.
El mensaje se enviará uno o dos días antes del pago programado, dependiendo de la preferencia del cliente.

## Objetivos

- Gestionar usuarios y prestamos.
- Generar reportes trimestrales y semestrales de los prestamos y pagos realizados.
- Enviar SMS automáticos a los clientes con un resumen de su préstamo, incluyendo el monto total,
  el monto pagado, el monto restante y la fecha del próximo pago.
- Poder gestionar los prestamos que estan activos, los vencidos y los que estan por vencer.

## Entorno de desarrollo

- Flutter SDK: 3.38.0
- Dart SDK: incluido en Flutter SDK
- Android SDK: 36.1.0
- IDE: Android Studio
- SO: Windows 11 Pro

## Estructura del proyecto

lib/
main.dart
screens/
    login_screen.dart
    dashboard_screen.dart
    user_management_screen.dart
    loan_management_screen.dart
    report_screen.dart
models/
    user.dart
    prestamo.dart
    pago.dart
services/
    database_helper.dart
    sms_service.dart
    report_service.dart
workers/
    notification_worker.dart

## Avances por módulo
- [] LoginScreen (pantalla básica con navegación)
- [] DashboardScreen (pantalla con botones de navegación)
- [] UserManagementScreen (CRUD de usuarios)
- [] LoanManagementScreen (gestión de préstamos y pagos)
- [] ReportScreen (generación de reportes)
- [] DatabaseHelper (CRUD en SQLite)
- [] SmsService (envío de notificaciones)
- [] ReportService (cálculo y exportación de reportes)
- [] NotificationWorker (automatización con WorkManager)

## Roadmap
- Fase 1: Configuración inicial ✅ //Completado
- Fase 2: Modelado de datos y servicios ⏳
- Fase 3: Interfaz de usuario
- Fase 4: Automatización y notificaciones
- Fase 5: Reportes
- Fase 6: Documentación y entrega final

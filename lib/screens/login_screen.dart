import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //Credenciales de admin hardcodeadas para demo
  final String adminUser = "admin";
  final String adminPassword = "admin123";

  void login() {
    String user = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (user == adminUser && password == adminPassword) {
      // Aquí iría la lógica para navegar al Dashboard o pantalla principal
      Navigator.pushReplacementNamed(context, "/dashboard");
      print("Login exitoso");
    } else {
      // Mostrar error de autenticación
      ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Usuario o contraseña incorrectos")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: "Usuario"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: login,
              child: const Text("Iniciar Sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
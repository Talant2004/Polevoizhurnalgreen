import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email или телефон'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authService.signInWithEmail(
                    emailController.text,
                    passwordController.text,
                  );
                  Navigator.pushReplacementNamed(context, '/work_card');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Войти'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await authService.signUpWithEmail(
                    emailController.text,
                    passwordController.text,
                  );
                  Navigator.pushReplacementNamed(context, '/work_card');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Зарегистрироваться'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/diagram'),
              child: const Text('Показать схему работы'),
            ),
          ],
        ),
      ),
    );
  }
}
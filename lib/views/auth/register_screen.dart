import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  final _auth = AuthController();

  Future<void> _register() async {
    // 🔹 On nettoie les champs
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    // 🔹 Vérifications locales avant Firebase
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adresse e‑mail et mot de passe obligatoires')),
      );
      return;
    }

    // Vérifie que l’e‑mail ressemble à une adresse réelle
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format d’adresse e‑mail invalide')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.register(email, password);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // 🔹 Affichage plus lisible des erreurs Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur Firebase : ${e.toString()}')),
      );
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _register,
              child: const Text('S’inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
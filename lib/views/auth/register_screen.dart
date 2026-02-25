import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adresse e‑mail et mot de passe obligatoires'),
        ),
      );
      return;
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur Firebase : ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: Text(
          'Créer un compte',
          style: GoogleFonts.poppins(
            color: Colors.indigo[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 40),


            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.indigo[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person_add_alt,
                  color: Colors.indigo, size: 50),
            ),

            const SizedBox(height: 25),
            Text(
              'Bienvenue !',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Créez un compte pour commencer à gérer votre stock.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),

            const SizedBox(height: 40),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _emailCtrl,
                      label: 'Adresse e‑mail',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passCtrl,
                      label: 'Mot de passe',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    _loading
                        ? const CircularProgressIndicator(color: Colors.indigo)
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 60, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _register,
                      child: Text(
                        'S’inscrire',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),


            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Déjà un compte ? Se connecter',
                style: GoogleFonts.poppins(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 0.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.2),
        ),
        labelStyle: GoogleFonts.poppins(),
      ),
    );
  }
}
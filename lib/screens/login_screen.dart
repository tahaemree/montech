import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _activationController = TextEditingController();
  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Önceden giriş yapılmış mı kontrol et
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkLoginStatus();

      // mounted kontrolü
      if (!mounted) return;

      if (authProvider.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KVKK şartlarını kabul etmelisiniz')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result =
        await Provider.of<AuthProvider>(context, listen: false).login(
      _usernameController.text,
      _passwordController.text,
      _activationController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.')),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _activationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.deepPurple],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.checkroom, size: 100, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'MonTech',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Akıllı Mont Teknolojisi',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        hintText: 'Kullanıcı Adı',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kullanıcı adı gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Şifre',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Şifre gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _activationController,
                      decoration: const InputDecoration(
                        hintText: 'Aktivasyon Kodu',
                        prefixIcon: Icon(Icons.vpn_key),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Aktivasyon kodu gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptedTerms = value ?? false;
                            });
                          },
                          fillColor: WidgetStateProperty.all(Colors.white),
                          checkColor: Colors.orange,
                        ),
                        const Expanded(
                          child: Text(
                            'Kişisel Verilerin Korunması Kanunu kapsamında verilerimin işlenmesini kabul ediyorum',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : CustomButton(
                            text: 'Oturum Aç',
                            onPressed: _login,
                          ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // Demo giriş yapmak için
                        _usernameController.text = 'demo';
                        _passwordController.text = 'demo123';
                        _activationController.text = 'MONT2025';
                      },
                      child: const Text(
                        'Demo Giriş',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'home_screen.dart';
// import '../widgets/custom_button.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 30),
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.orange, Colors.deepPurple],
//             begin: Alignment.topRight,
//             end: Alignment.bottomLeft,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.checkroom, size: 100),
//             const SizedBox(height: 20),
//             const Text(
//               'MonTech',
//               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 30),
//             const TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white70,
//                 hintText: 'Kullanıcı Adı',
//               ),
//             ),
//             const SizedBox(height: 20),
//             const TextField(
//               obscureText: true,
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white70,
//                 hintText: 'Şifre',
//               ),
//             ),
//             const SizedBox(height: 20),
//             const TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.white70,
//                 hintText: 'Aktivasyon Kodu',
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 Checkbox(value: false, onChanged: (value) {}),
//                 const Text('KVKK', style: TextStyle(color: Colors.white)),
//               ],
//             ),
//             const SizedBox(height: 20),
//             CustomButton(
//               text: 'Oturum Aç',
//               onPressed: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (_) => const HomeScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

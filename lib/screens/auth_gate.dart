import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_config.dart';
import '../core/app_theme.dart';
import '../widgets/food_illustration.dart';
import 'food_home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: supabaseClient!.auth.onAuthStateChange,
    builder: (context, snapshot) {
      final user = supabaseClient!.auth.currentUser;
      if (user == null) return const SignInPage();
      return FoodHome(key: ValueKey(user.id));
    },
  );
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  String? _error;
  String? _notice;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _notice = null;
    });
    try {
      if (_signUp) {
        await supabaseClient!.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (supabaseClient!.auth.currentUser == null && mounted) {
          setState(() => _notice = 'สมัครแล้ว กรุณาตรวจอีเมลเพื่อยืนยันบัญชี');
        }
      } else {
        await supabaseClient!.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'เชื่อมต่อไม่สำเร็จ กรุณาลองอีกครั้ง');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    width: 112,
                    height: 112,
                    child: FoodIllustration(),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Food Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _signUp
                        ? 'สร้างบัญชีเพื่อเริ่มบันทึกอาหาร'
                        : 'เข้าสู่ระบบเพื่อดูบันทึกของคุณ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'อีเมล',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'กรอกอีเมลให้ถูกต้อง'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'รหัสผ่าน',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'รหัสผ่านอย่างน้อย 6 ตัวอักษร'
                        : null,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (_notice != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _notice!,
                        style: const TextStyle(color: AppColors.green),
                      ),
                    ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.red,
                      padding: const EdgeInsets.all(15),
                    ),
                    child: _busy
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(_signUp ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _signUp = !_signUp;
                      _error = null;
                    }),
                    child: Text(
                      _signUp
                          ? 'มีบัญชีแล้ว? เข้าสู่ระบบ'
                          : 'ยังไม่มีบัญชี? สมัครสมาชิก',
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

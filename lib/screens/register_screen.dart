import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './login_screen.dart';
import './main_menu_screen.dart';
import '../services/database_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _db = DatabaseService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      _showErrorDialog('Termos de Uso', 'Você deve aceitar os termos de uso para continuar.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _db.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (user != null && mounted) {
        _db.printStats();

        _showSuccessDialog(user.name);
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        String errorMessage = 'Erro inesperado. Tente novamente.';

        if (e.toString().contains('email já está cadastrado')) {
          errorMessage = 'Este email já está sendo usado por outra conta.';
        }

        _showErrorDialog('Erro no Cadastro', errorMessage);
      }
    }
  }

  void _showSuccessDialog(String userName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Cadastro Realizado!'),
            ],
          ),
          content: Text(
            'Bem-vindo(a), $userName!\n\n'
                'Seu cadastro foi salvo no banco de dados local. '
                'Agora você já pode começar a usar o Glide Trombone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainMenuScreen(),
                  ),
                );
              },
              child: const Text('Começar'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Termos de Uso'),
          content: const SingleChildScrollView(
            child: Text(
              'TERMOS DE USO DO GLIDE TROMBONE\n\n'
                  '1. ACEITAÇÃO DOS TERMOS\n'
                  'Ao usar este aplicativo, você concorda com estes termos.\n\n'
                  '2. USO DO APLICATIVO\n'
                  '• O app é destinado ao aprendizado musical\n'
                  '• Use fones de ouvido para melhor experiência\n'
                  '• Respeite os direitos autorais das músicas\n\n'
                  '3. PRIVACIDADE E DADOS\n'
                  '• Seus dados são salvos localmente no dispositivo\n'
                  '• O app pode acessar o microfone para detecção de áudio\n'
                  '• Não compartilhamos dados com terceiros\n\n'
                  '4. LIMITAÇÕES\n'
                  '• O app é fornecido "como está"\n'
                  '• Não garantimos 100% de precisão na detecção\n\n'
                  '5. ATUALIZAÇÕES\n'
                  'Estes termos podem ser atualizados periodicamente.\n\n'
                  'Ao aceitar, você concorda com todos os termos acima.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo.shade300,
              Colors.indigo.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_add_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'CRIAR CONTA',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  'Junte-se à comunidade Glide Trombone',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: 40),

                // Formulário de cadastro
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Campo de nome
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Nome completo',
                            hintText: 'Digite seu nome completo',
                            prefixIcon: const Icon(Icons.person_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu nome';
                            }
                            if (value.trim().split(' ').length < 2) {
                              return 'Digite seu nome completo';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Campo de email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Digite seu email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Digite um email válido';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: 'Digite sua senha',
                            prefixIcon: const Icon(Icons.lock_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite sua senha';
                            }
                            if (value.length < 8) {
                              return 'A senha deve ter pelo menos 8 caracteres';
                            }
                            if (!value.contains(RegExp(r'[A-Z]'))) {
                              return 'A senha deve conter pelo menos 1 letra maiúscula';
                            }
                            if (!value.contains(RegExp(r'[0-9]'))) {
                              return 'A senha deve conter pelo menos 1 número';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Campo de confirmar senha
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirmar senha',
                            hintText: 'Digite novamente sua senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, confirme sua senha';
                            }
                            if (value != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Checkbox dos termos
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: Colors.indigo.shade600,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _acceptTerms = !_acceptTerms;
                                  });
                                },
                                child: Text(
                                  'Aceito os ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showTermsDialog,
                              child: Text(
                                'Termos de Uso',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.indigo.shade600,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Botão de cadastrar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Criar Conta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já possui uma conta? ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
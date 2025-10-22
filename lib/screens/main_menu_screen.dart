import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glide_trombone/screens/scores_screen.dart';
import './login_screen.dart';
import '../screens/trombone_practice_screen.dart';
import '../services/audio_service.dart';
import '../screens/tuner_screen.dart';
import '../services/database_service.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  bool _isInitializing = true;
  String _initializationStatus = 'Inicializando...';
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _initializationStatus = 'Carregando serviços de áudio...';
      });

      await AudioService().initialize();

      setState(() {
        _initializationStatus = 'Configurando MIDI...';
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isInitializing = false;
      });

    } catch (e) {
      setState(() {
        _initializationStatus = 'Erro na inicialização: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.shade400,
                Colors.blue.shade600,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_note,
                  size: 80,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 32),
                Text(
                  'Glide Trombone',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 48),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  _initializationStatus,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glide Trombone'),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade400,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom - 48 -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    Text(
                      'Bem-vindo, ${_db.getCurrentUser()?.name.split(' ').first ?? 'Usuário'}!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Escolha uma opção para começar a praticar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),

                    const SizedBox(height: 60),

                    MenuButton(
                      title: 'Praticar com Partitura',
                      subtitle: 'Toque seguindo a partitura em tempo real',
                      icon: Icons.library_music,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrombonePracticeScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    MenuButton(
                      title: 'Afinador',
                      subtitle: 'Afine seu trombone com precisão',
                      icon: Icons.tune,
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TunerScreen(),
                            ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    MenuButton(
                      title: 'Criar Partitura',
                      subtitle: 'Crie suas partituras',
                      icon: Icons.queue_music,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScoresScreen(),
                          ),
                        );
                      },
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Text(
                        'Versão 1.0.0 - Projeto TCC',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
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

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sair'),
          content: Text(
              'Tem certeza que deseja sair, ${_db.getCurrentUser()?.name.split(' ').first}?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Fazer logout no Hive
                await _db.logout();

                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              },
              child: const Text(
                'Sair',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$feature - Em Breve'),
          content: Text(
            'Esta funcionalidade está sendo desenvolvida e '
                'estará disponível em uma próxima versão do app.',
          ),
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
}

class MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  const MenuButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: Colors.indigo.shade600,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:glide_trombone/services/score_database_service.dart';
import './services/database_service.dart';
import './screens/login_screen.dart';
import './screens/main_menu_screen.dart';

void main() async {
  // Garantir que o Flutter esteja inicializado
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar o Hive
    await DatabaseService.initialize();
    await ScoreDatabaseService.initialize();
    print('App inicializado com sucesso!');
  } catch (e) {
    print('Erro ao inicializar o app: $e');
  }

  runApp(const GlideTromboneApp());
}

class GlideTromboneApp extends StatelessWidget {
  const GlideTromboneApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glide Trombone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
      home: const AppInitializer(), // Verificar se usuário já está logado
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Widget que decide qual tela mostrar (Login ou Menu Principal)
class AppInitializer extends StatefulWidget {
  const AppInitializer({Key? key}) : super(key: key);

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    // Verificar se há usuário logado
    final currentUser = _db.getCurrentUser();

    if (currentUser != null) {
      // Usuário já está logado - ir para o menu principal
      print('Usuário já logado: ${currentUser.name}');
      return const MainMenuScreen();
    } else {
      // Nenhum usuário logado - mostrar tela de login
      print('Nenhum usuário logado - mostrando login');
      return const LoginScreen();
    }
  }
}
import 'package:glide_trombone/models/performance_model.dart';
import 'package:glide_trombone/models/score_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import 'package:glide_trombone/models/note_model.dart';

class DatabaseService {
  static const String _userBoxName = 'users';
  static const String _currentUserKey = 'current_user_id';

  static Box<User>? _userBox;
  static Box? _settingsBox;
  static Box<PerformanceModel>? _performanceBox;

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserAdapter());
      print('UserAdapter registrado (typeId: 0)');
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(NoteModelAdapter());
      print('NoteModelAdapter registrado (typeId: 2)');
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ScoreModelAdapter());
      print('ScoreModelAdapter registrado (typeId: 3)');
    }

    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(PerformanceModelAdapter());
      print('PerformanceModelAdapter registrado (typeId: 4)');
    }

    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(PlayedNoteModelAdapter());
      print('PlayedNoteModelAdapter registrado (typeId: 6)');
    }

    _userBox = await Hive.openBox<User>(_userBoxName);
    _settingsBox = await Hive.openBox('settings');
    _performanceBox = await Hive.openBox<PerformanceModel>('performances');

    print('Hive inicializado com sucesso!');
    print('Usuários cadastrados: ${_userBox!.length}');
  }

  Box<User> get userBox {
    if (_userBox == null || !_userBox!.isOpen) {
      throw Exception('UserBox não inicializado! Chame DatabaseService.initialize() primeiro.');
    }
    return _userBox!;
  }

  Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('SettingsBox não inicializado! Chame DatabaseService.initialize() primeiro.');
    }
    return _settingsBox!;
  }

  // ========== OPERAÇÕES DE USUÁRIO ==========

  Future<User?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (await emailExists(email)) {
        throw Exception('Este email já está cadastrado!');
      }

      final user = User.create(
        name: name,
        email: email,
        password: password,
      );

      await userBox.put(user.id, user);

      print('Usuário cadastrado: ${user.name} (${user.email})');
      return user;

    } catch (e) {
      print('Erro ao cadastrar usuário: $e');
      rethrow;
    }
  }

  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = await getUserByEmail(email);

      if (user == null) {
        throw Exception('Email não encontrado!');
      }

      if (!user.isActive) {
        throw Exception('Conta desativada. Entre em contato com o suporte.');
      }

      print('senha${user.password}');
      if (!user.checkPassword(password)) {
        throw Exception('Senha incorreta!');
      }

      user.updateLastLogin();

      await setCurrentUser(user);

      print('Login realizado: ${user.name}');
      return user;

    } catch (e) {
      print('Erro no login: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    await settingsBox.delete(_currentUserKey);
    print('Logout realizado');
  }

  Future<bool> emailExists(String email) async {
    final normalizedEmail = email.toLowerCase().trim();
    return userBox.values.any((user) => user.email == normalizedEmail);
  }

  Future<User?> getUserByEmail(String email) async {
    final normalizedEmail = email.toLowerCase().trim();
    try {
      return userBox.values.firstWhere((user) => user.email == normalizedEmail);
    } catch (e) {
      return null;
    }
  }

  User? getUserById(String id) {
    return userBox.get(id);
  }

  Future<void> setCurrentUser(User user) async {
    await settingsBox.put(_currentUserKey, user.id);
  }

  User? getCurrentUser() {
    final currentUserId = settingsBox.get(_currentUserKey);
    if (currentUserId == null) return null;
    return getUserById(currentUserId);
  }

  bool isUserLoggedIn() {
    return getCurrentUser() != null;
  }

  // ========== OPERAÇÕES GERAIS ==========

  List<User> getAllUsers() {
    return userBox.values.where((user) => user.isActive).toList();
  }

  Future<void> deleteUser(String userId) async {
    final user = getUserById(userId);
    if (user != null) {
      user.isActive = false;
      await user.save();
      print('Usuário desativado: $userId');
    }
  }

  Future<void> updateUser(User user) async {
    await user.save();
    print('Usuário atualizado: ${user.name}');
  }

  Future<void> clearAllData() async {
    await userBox.clear();
    await settingsBox.clear();
    print('Todos os dados foram limpos!');
  }

  static Future<void> close() async {
    await _userBox?.close();
    await _settingsBox?.close();
    print('Todas as boxes do Hive foram fechadas');
  }

  // ========== DEBUG ==========

  void printStats() {
    print('\n=== ESTATÍSTICAS DO BANCO ===');
    print('Total de usuários: ${userBox.length}');
    print('Usuário atual: ${getCurrentUser()?.name ?? 'Nenhum'}');
    print('Usuários ativos: ${getAllUsers().length}');

    if (userBox.isNotEmpty) {
      print('\n👤 === LISTA DE USUÁRIOS ===');
      for (var user in getAllUsers()) {
        print('• ${user.name} (${user.email}) - Criado em: ${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}');
      }
    }
    print('===============================\n');
  }
}
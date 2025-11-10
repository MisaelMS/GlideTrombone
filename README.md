# 🎺 GlideTrombone

Um aplicativo Android de aprendizado interativo de trombone de vara, desenvolvido em Flutter para ajudar iniciantes a dominarem o instrumento através de prática guiada, feedback visual em tempo real e exercícios personalizáveis.

## 📱 Sobre o Projeto

GlideTrombone é uma aplicação educacional que transforma o tablet e smartphone (com foco em tablets) em uma ferramenta de aprendizado para trombone de vara. Com interface intuitiva e recursos de áudio MIDI, o app oferece uma experiência prática que simula tocar o instrumento real, incluindo metrônomo, afinador e sistema de partituras interativas.

## ✨ Funcionalidades Principais

### 🎼 Prática Guiada
- Sistema de partituras interativas com feedback visual em tempo real
- Metrônomo integrado e ajustável para praticar no tempo correto
- Reprodução de áudio das notas corretas para referência auditiva
- Acompanhamento do desempenho durante a execução

### 🎵 Afinador
- Ferramenta de afinação precisa para o trombone
- Feedback visual

### 📝 Criação de Partituras
- Editor de partituras personalizado para criar exercícios próprios
- Sistema de armazenamento local para suas criações

### 👤 Sistema de Usuários
- Autenticação com login e cadastro
- Salvamento automático do progresso

## 🚀 Tecnologias Utilizadas

### Framework e Linguagem
- **Flutter 3.0+** - Framework multiplataforma
- **Dart 3.8.1** - Linguagem de programação

### Principais Dependências
- **flutter_midi_command** (0.5.3) - Processamento MIDI principal
- **flutter_midi_pro** (3.1.4) - Recursos MIDI avançados
- **audioplayers** (5.0.0) - Reprodução de áudio
- **flutter_sound** (9.2.13) - Gravação e processamento de áudio
- **hive** (2.2.3) + **hive_flutter** (1.1.0) - Banco de dados local NoSQL
- **permission_handler** (11.0.0) - Gerenciamento de permissões
- **path_provider** (2.1.1) - Acesso ao sistema de arquivos

### Ferramentas de Desenvolvimento
- **hive_generator** + **build_runner** - Geração automática de código
- **flutter_launcher_icons** - Geração de ícones do app

## 📋 Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.0.0 ou superior)
- [Dart SDK](https://dart.dev/get-dart) (versão 3.0.0 ou superior)
- [Android Studio](https://developer.android.com/studio) com Android SDK (API 21+)
- Dispositivo Android ou Emulador configurado

## 🔧 Instalação

1. **Clone o repositório:**
```bash
git clone https://github.com/MisaelMS/GlideTrombone.git
cd GlideTrombone
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Gere os arquivos do Hive (models):**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Conecte um dispositivo Android ou inicie um emulador**

5. **Execute o aplicativo:**
```bash
flutter run
```

## 📦 Estrutura do Projeto

```
GlideTrombone/
├── android/                    # Configurações Android
├── ios/                        # Configurações iOS (não utilizado)
├── assets/                     # Recursos estáticos
│   ├── sounds/
│   │   └── Trombone.sf2       # Arquivo SoundFont do trombone
│   └── images/
│       └── logo.png           # Logo do aplicativo
├── lib/                        # Código-fonte principal
│   ├── data/                  # Partituras e exercícios pré-definidos
│   ├── exercises/             # Exercícios pré-configurados
│   ├── models/                # Classes de dados
│   │   ├── user.dart         # Modelo de usuário
│   │   ├── score.dart        # Modelo de partitura
│   │   └── performance.dart  # Modelo de desempenho
│   ├── screens/               # Telas do aplicativo
│   │   ├── login_screen.dart
│   │   ├── main_menu_screen.dart
│   │   ├── practice_screen.dart
│   │   ├── tuner_screen.dart
│   │   └── create_score_screen.dart
│   ├── services/              # Serviços e lógica
│   │   ├── database_service.dart
│   │   ├── score_database_service.dart
│   │   └── audio_service.dart
│   ├── widgets/               # Componentes reutilizáveis
│   │   ├── score_display.dart
│   │   └── visual_feedback.dart
│   └── main.dart              # Ponto de entrada
├── pubspec.yaml               # Dependências e configurações
└── README.md                  # Este arquivo
```

## 🎯 Como Usar

### Primeiro Acesso
1. **Crie sua conta:** Na tela inicial, faça cadastro com nome e dados básicos
2. **Faça login:** Entre com suas credenciais

### Menu Principal
No menu principal você encontra três opções:

#### 🎼 Prática
1. Selecione uma partitura da biblioteca ou crie uma nova
2. Ajuste o andamento do metrônomo conforme necessário
3. Pressione play para iniciar o metrônomo
4. Clique nas notas para ouvir como devem soar
5. Toque junto seguindo o feedback visual em tempo real
6. Seu desempenho é automaticamente salvo

#### 🎵 Afinador
1. Toque uma nota no seu trombone
2. O afinador mostrará se está afinado, alto ou baixo
3. Ajuste a vara até alcançar a afinação correta

#### 📝 Criar Partitura
1. Escolha as notas que deseja praticar
2. Configure o andamento e duração
3. Salve para usar na seção de Prática
4. Exercícios salvos ficam disponíveis junto aos pré-definidos

## 📱 Plataformas Suportadas

- ✅ **Android** (API 21+) - Totalmente suportado e testado
- ⚠️ **iOS** - Teoricamente compatível (Flutter é multiplataforma), mas não testado
  - Requer Xcode e configurações adicionais
  - Pode necessitar ajustes nas permissões de áudio no `Info.plist`

## 🔐 Permissões Necessárias

O aplicativo requer as seguintes permissões no Android:

- **Áudio/Microfone** - Para captura de som do afinador
- **Armazenamento** - Para salvar partituras e progresso (gerenciado pelo Hive)

## 🎓 Público-Alvo

Este aplicativo foi desenvolvido especialmente para:
- 🎺 **Iniciantes** que querem aprender trombone de vara
- 📚 **Estudantes de música** praticando fora das aulas
- 🏠 **Praticantes domésticos** sem acesso constante ao instrumento físico
- 👨‍🏫 **Professores** que desejam uma ferramenta de apoio pedagógico

## 🏗️ Arquitetura

O projeto utiliza uma arquitetura em camadas:

- **Presentation Layer** (Screens + Widgets) - Interface do usuário
- **Business Logic Layer** (Services) - Lógica de negócio e processamento
- **Data Layer** (Models + Database) - Persistência e modelos de dados

**Gerenciamento de Estado:** StatefulWidgets com setState
**Banco de Dados:** Hive (NoSQL local) com type adapters gerados

## 🛠️ Compilação para Produção

### Gerar APK
```bash
flutter build apk --release
```

O arquivo gerado estará em:
- APK: `build/app/outputs/flutter-apk/app-release.apk`

## 👤 Autor

**Misael MS**

- GitHub: [@MisaelMS](https://github.com/MisaelMS)
- Projeto: [GlideTrombone](https://github.com/MisaelMS/GlideTrombone)

## 🐛 Problemas Conhecidos e Soluções

### Erro de permissão de áudio
**Problema:** App não captura áudio no afinador
**Solução:** Verifique se concedeu permissão de microfone nas configurações do Android

### Hive não inicializa
**Problema:** Erro ao abrir o app pela primeira vez
**Solução:** Execute `flutter pub run build_runner build` para gerar os adapters

---

<div align="center">

**🎺 Pratique, aprenda e evolua com o GlideTrombone! 🎵**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-21+-3DDC84?logo=android)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-Open_Source-green.svg)](LICENSE)

</div>

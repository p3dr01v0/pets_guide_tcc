import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_user.dart';
import 'package:flutter_application_1/screens/perfis/perfil_est.dart';
import 'package:flutter_application_1/screens/perfis/perfil_user.dart';
import 'package:flutter_application_1/servicos/firebase_options.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future verificarUsuario(String userType) async {
  final user = _auth.currentUser;
  bool estabelecimento;
  if (user != null) {
    final email = user.email;

    try {
      final querySnapshot1 = await _firestore
          .collection('estabelecimentos')
          .where('emailProv', isEqualTo: email)
          .get();

      if (querySnapshot1.docs.isNotEmpty) {
        final doc = querySnapshot1.docs.first;
        final String userType = doc['userType'];

        print('$userType');
        print('$email');
        if (userType == 'provider') {
          estabelecimento = true;
          return estabelecimento;
        } else {
          estabelecimento = false;
          return estabelecimento;
        }
      } else {
        print('Campos necessários do documento não encontrados');
        estabelecimento = false;
        return estabelecimento;
      }
    } on FirebaseException catch (e) {
      // Trate erros de consulta
      print('Erro ao consultar Firestore: $e');
    }
  } else {
    print('erro: Usuário não autenticado');
    estabelecimento = false;
    return estabelecimento;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final bool estabelecimento = await verificarUsuario('provider');
  runApp(MyApp(estabelecimento: estabelecimento));
}

class MyApp extends StatelessWidget {
  final bool estabelecimento;
  const MyApp({required this.estabelecimento, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: estabelecimento
          ? const RoteadorTelaEstabelecimento()
          : const RoteadorTela(),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 243, 236),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF10428B),
          foregroundColor: Colors.white, // Cor do texto na AppBar
        ),
        cardTheme: CardTheme(
          color: Colors.white.withOpacity(1.0),
        ),
      ),
    );
  }
}

class RoteadorTela extends StatelessWidget {
  const RoteadorTela({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const perfilUser();
        } else {
          return const AutentiacacaoTela();
        }
      },
    );
  }
}

class RoteadorTelaEstabelecimento extends StatelessWidget {
  const RoteadorTelaEstabelecimento({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return perfilEst();
        } else {
          return const AutentiacacaoTela();
        }
      },
    );
  }
}

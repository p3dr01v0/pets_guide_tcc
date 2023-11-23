// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/tela_reset_senha_est.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaConfiguracoesEstabelecimento extends StatefulWidget {
  @override
  _TelaConfiguracoesEstabelecimentoState createState() =>
      _TelaConfiguracoesEstabelecimentoState();
}

class _TelaConfiguracoesEstabelecimentoState
    extends State<TelaConfiguracoesEstabelecimento> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _providers = [];

  @override
  void initState() {
    super.initState();
    // Verifique se há um usuário autenticado quando o widget é iniciado
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.all(8.0),
                    leading: const Icon(Icons.lock_reset_rounded),
                    title: const Text('Redefinir Senha'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const TelaResetSenhaEstabelecimento(),
                          ));
                    },
                  )
                ],
              )
            : const Text('Nenhum usuário autenticado'),
      ),
    );
  }
}

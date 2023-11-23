// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';

class TelaResetSenhaEstabelecimento extends StatefulWidget {
  const TelaResetSenhaEstabelecimento({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TelaResetSenhaEstabelecimentoState createState() =>
      _TelaResetSenhaEstabelecimentoState();
}

class _TelaResetSenhaEstabelecimentoState
    extends State<TelaResetSenhaEstabelecimento> {
  final _formKey = GlobalKey<FormState>();

  User? _user;
  String savedCnpj = '';
  String savedEmail = '';

  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  autenticacaoServico authSvc = autenticacaoServico();

  @override
  void initState() {
    super.initState();
    // Verifique se há um usuário autenticado quando o widget é iniciado
    _fetchInfo();
  }

  Future<User?> _checkCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      return user;
    } else {
      return null;
    }
  }

  Future<void> _fetchInfo() async {
    _user = await _checkCurrentUser();

    if (_user != null) {
      final String uid = _user!.uid;
      print(uid);

      final doc =
          await _firestore.collection('estabelecimentos').doc(uid).get();

      setState(() {
        savedCnpj = doc['CNPJ'];
        savedEmail = doc['emailProv'];
      });
      print(savedCnpj);
      print(savedEmail);
    }
  }

  void _submitReset() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _user = _auth.currentUser;

      print(_user!.uid);

      String email = _emailController.text;
      String cnpj = _cnpjController.text;

      authSvc
          .resetarSenhaEstabelecimento(
              uid: _user!.uid, cnpj: cnpj, email: email)
          .then((_) => Navigator.of(context).pop());
      //print(
      //'Usuário logado com UID: ${autenticacaoServico.userCredential.user!.uid}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: const Text('Redefinir Senha'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _cnpjController,
                  decoration: const InputDecoration(labelText: 'CNPJ'),
                  validator: (value) {
                    if (value != savedCnpj) {
                      return 'CNPJ não condiz';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != savedEmail) {
                      return 'E-mail não condiz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                FilledButton(
                    onPressed: () {
                      _submitReset();
                    },
                    child: const Text('Redefinir Senha'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

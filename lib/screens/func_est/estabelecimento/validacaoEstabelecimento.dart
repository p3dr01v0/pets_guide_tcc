// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_est.dart';
import 'package:flutter_application_1/screens/func_est/estabelecimento/validarCriacao.dart';

class ValidacaoEstabelecimento extends StatefulWidget {
  @override
  _ValidacaoEstabelecimentoState createState() =>
      _ValidacaoEstabelecimentoState();
}

class _ValidacaoEstabelecimentoState extends State<ValidacaoEstabelecimento> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    verificarAprovacao();
  }

  Future<void> verificarAprovacao() async {
    print('Entrando na função de validar estabelecimento');
    final user = _auth.currentUser;

    if (user != null) {
      final email = user.email;
      print('usuario ${user.uid} identificado');
      try {
        final querySnapshot = await _firestore
            .collection('estabelecimentos')
            .where('emailProv', isEqualTo: email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final bool approval = doc['approval'];

          print('$approval');
          print('$email');
          if (approval) {
            // Aprovação concedida, redirecione para a tela inicial
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => ValidarCriacao()));
          } else {
            // Aprovação não concedida, retorne para a tela de login
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => TelaRegistroProv()));
          }
        } else {
          print('CACETE');
        }
      } on FirebaseException catch (e) {
        // Trate erros de consulta
        print('Erro ao consultar Firestore: $e');
      }
    } else {
      print('usuario não autenticado');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => TelaRegistroProv()));
    }
    print('Saindo da função de validar estabelecimento sem nada');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Checando validação aguarde',
        ),
      ),
    );
  }
}

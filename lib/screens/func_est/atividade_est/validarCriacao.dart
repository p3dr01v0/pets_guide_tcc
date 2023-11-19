// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_info_est.dart';
import 'package:flutter_application_1/screens/perfis/perfil_est.dart';

class ValidarCriacao extends StatefulWidget {
  @override
  _ValidarCriacaoState createState() => _ValidarCriacaoState();
}

class _ValidarCriacaoState extends State<ValidarCriacao> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    verificarCriacao();
  }

  Future<void> verificarCriacao() async {
    print('Entrando da função de verificar criação');
    final user = _auth.currentUser;

    if (user != null) {
      print(user.uid);
      try {
        final estabelecimentoQuerySnapshot = await _firestore
            .collection('estabelecimentos')
            .where('UID', isEqualTo: user.uid)
            .get();

        if (estabelecimentoQuerySnapshot.docs.isNotEmpty) {
          final estabelecimentoDoc = estabelecimentoQuerySnapshot.docs.first;
          final estabelecimentoID = estabelecimentoDoc.id;

          final informacoesCollection = _firestore
              .collection('estabelecimentos/$estabelecimentoID/informacoes');

          final localizacaoCollection = _firestore
              .collection('estabelecimentos/$estabelecimentoID/localizacao');

          final informacoesSnapshot = await informacoesCollection.get();
          final localizacaoSnapshot = await localizacaoCollection.get();

          if (informacoesSnapshot.docs.isNotEmpty &&
              localizacaoSnapshot.docs.isNotEmpty) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => perfilEst()));
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const telaAddInfo()));
          }
        } else {
          print('Estabelecimento não autenticado: Retornando a tela de login');

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const RoteadorTelaEstabelecimento()));
        }
      } on FirebaseException catch (e) {
        // Trate erros de consulta
        print('Erro ao consultar Firestore: $e');
      }
    }
    print('Saindo da função de verificar criação');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          semanticsLabel: 'Checando se o estabelecimento está criado aguarde',
        ),
      ),
    );
  }
}

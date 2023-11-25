// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_select_avaliacao.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_select_servico.dart';
import 'package:flutter_application_1/screens/atividades_user/ver_avaliacoes.dart';
import 'package:flutter_application_1/style/btn_interface_est.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class TelaEstabelecimento extends StatefulWidget {
  final String estabelecimentoId;

  const TelaEstabelecimento({Key? key, required this.estabelecimentoId})
      : super(key: key);

  @override
  _TelaEstabelecimentoState createState() => _TelaEstabelecimentoState();
}

class _TelaEstabelecimentoState extends State<TelaEstabelecimento> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String nomeEstabelecimento = '';
  String telefone = '';
  String imageEst = '';
  String fundacao = '';
  String rua = '';
  bool agenda = false;
  bool avaliacaoDisponivel = false;

  @override
  void initState() {
    super.initState();
    // Verifique se há um usuário autenticado quando o widget é iniciado
    fetchInfoEstabelecimento();
  }

  Future<void> fetchInfoEstabelecimento() async {
    String estabelecimentoId = widget.estabelecimentoId;
    _user = _auth.currentUser;

    if (_user != null) {
      try {
        final estabelecimentoQuerySnapshot = await _firestore
            .collection('estabelecimentos')
            .where('UID', isEqualTo: estabelecimentoId)
            .get();

        if (estabelecimentoQuerySnapshot.docs.isNotEmpty) {
          final informacoesCollection =
              _firestore.collection('estabelecimentos/$estabelecimentoId/info');
          final localizacaoCollection = _firestore
              .collection('estabelecimentos/$estabelecimentoId/localizacao');

          final informacoesSnapshot = await informacoesCollection.get();
          final localizacaoSnapshot = await localizacaoCollection.get();

          if (informacoesSnapshot.docs.isNotEmpty &&
              localizacaoSnapshot.docs.isNotEmpty) {
            final docInfo = informacoesSnapshot.docs.first;
            final docLocalizacao = localizacaoSnapshot.docs.first;

            setState(() {
              nomeEstabelecimento = docInfo['nome'];
              telefone = docInfo['contato'];
              imageEst = docInfo['imageEstabelecimento'];
              fundacao = docInfo['fundacao'];
              rua = docLocalizacao['rua'];
            });

            final banhoTosaCollection = _firestore
                .collection('estabelecimentos/$estabelecimentoId/banhoETosa')
                .where('nomeAgenda', isNull: false);
            final vetCollection = _firestore
                .collection('estabelecimentos/$estabelecimentoId/veterinario')
                .where('nomeAgenda', isNull: false);
            final petHotelCollection = _firestore
                .collection('estabelecimentos/$estabelecimentoId/hotelPet')
                .where('nomeAgenda', isNull: false);

            final banhoTosaSnapshot = await banhoTosaCollection.get();
            final vetSnapshot = await vetCollection.get();
            final petHotelSnapshot = await petHotelCollection.get();

            if (banhoTosaSnapshot.docs.isNotEmpty ||
                vetSnapshot.docs.isNotEmpty ||
                petHotelSnapshot.docs.isNotEmpty) {
              setState(() {
                agenda = true;
              });
              await fetchAgendamento();
            }
          } else {
            Navigator.of(context).pop();
          }
        } else {
          print('Estabelecimento não autenticado: Retornando a tela de login');
        }
      } on FirebaseException catch (e) {
        print('Erro ao consultar Firestore: $e');
      }
    }

    // ignore: unnecessary_null_comparison
    if (imageEst != null && imageEst.isNotEmpty) {
      Image.network(imageEst);
    } else {
      print('URL da imagem está vazia');
    }

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> fetchAgendamento() async {
    String estabelecimentoId = widget.estabelecimentoId;
    _user = _auth.currentUser;

    if (_user != null) {
      try {
        final agendamentoQuerySnapshot = await _firestore
            .collection('user/${_user!.uid}/agendamentos')
            .where('estabelecimentoId', isEqualTo: estabelecimentoId)
            .where('status', isEqualTo: 4)
            .where('avaliado', isEqualTo: false) // Adicionando a condição aqui
            .get();

        if (agendamentoQuerySnapshot.docs.isNotEmpty) {
          print('A subcoleção "agendamentos" existe em user:${_user!.uid}');

          if (mounted) {
            setState(() {
              avaliacaoDisponivel = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              avaliacaoDisponivel = false;
            });
          }
        }
      } on FirebaseException catch (e) {
        print('Erro ao consultar Firestore: $e');
      }
    }

    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    Color cardBackgroundColor = const Color.fromARGB(255, 252, 252, 252);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: Text(nomeEstabelecimento,
            style: const TextStyle(
              color: Colors.white,
            )),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Card(
                      elevation: 0,
                      color: cardBackgroundColor,
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: NetworkImage(imageEst),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const SizedBox(height: 2),
                                Text(
                                  nomeEstabelecimento,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  telefone,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Desde: $fundacao',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Rua: $rua',
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(height: 20),
                                Visibility(
                                  visible: agenda,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TelaSelectServico(
                                                estabelecimentoId:
                                                    widget.estabelecimentoId,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ButtonStyles.elevatedButtonStyle(
                                          backgroundColor:
                                              const Color(0xFF10428B),
                                          fontSize: 16.0,
                                        ),
                                        child: const Text(
                                          'Agendar Horário',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: avaliacaoDisponivel,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TelaSelectAvaliacao(
                                                      estabelecimentoId: widget
                                                          .estabelecimentoId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ButtonStyles
                                                  .outlinedButtonStyle(
                                                backgroundColor:
                                                    const Color(0xFFFF862D),
                                                fontSize: 16.0,
                                              ),
                                              child: const Text(
                                                'Avaliar',
                                                style: TextStyle(
                                                  color: Color(0xFF10428B),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10.0),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TelaVerAvaliacoes(
                                                      estabelecimentoId: widget
                                                          .estabelecimentoId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: ButtonStyles
                                                  .outlinedButtonStyle(
                                                backgroundColor:
                                                    const Color(0xFFFF862D),
                                                fontSize: 16.0,
                                              ),
                                              child: const Text(
                                                'Ver Avaliações',
                                                style: TextStyle(
                                                  color: Color(0xFF10428B),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: !avaliacaoDisponivel,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TelaVerAvaliacoes(
                                                estabelecimentoId:
                                                    widget.estabelecimentoId,
                                              ),
                                            ),
                                          );
                                        },
                                        style: ButtonStyles.outlinedButtonStyle(
                                          backgroundColor:
                                              const Color(0xFFFF862D),
                                          fontSize: 16.0,
                                        ),
                                        child: const Text(
                                          'Ver Avaliações',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFF10428B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

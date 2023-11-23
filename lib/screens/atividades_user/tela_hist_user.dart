// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_avaliacao.dart';
import 'package:flutter_application_1/screens/interface_user/tela_estabelecimento.dart';
import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';

var logger = Logger();

class TelaHistoricoUser extends StatefulWidget {
  @override
  _TelaHistoricoUserState createState() => _TelaHistoricoUserState();
}

class _TelaHistoricoUserState extends State<TelaHistoricoUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool banhoTosa = false;
  bool veterinario = false;
  bool hotelPet = false;
  String uid = '';

  Map<String, Map<String, String>> petData = {};

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

      // Consulta os pets do usuário com base no UID
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? _getScheduleStream(String uid) {
    if (_user != null) {
      uid = _user!.uid;
      return _firestore
          .collection('user/$uid/agendamentos')
          .where("UID", isEqualTo: uid)
          .orderBy("dataAgendamento", descending: true)
          .snapshots();
    } else {
      return null;
    }
  }

  /*Future<void> _fetchData(String petId, String userId) async {
    final petDoc =
        await _firestore.collection('users/$userId/pets').doc(petId).get();
    String nomePet = petDoc['nome'] as String;
    String racaPet = petDoc['raca'] as String;
    String imagePet = petDoc['imagePet'] as String;

    final userDoc = await _firestore.collection('users').doc(userId).get();
    String nomeUser = userDoc['nome'] as String;

    final info = {
      'nomeUser': userDoc['nome'] as String,
      'nomePet': petDoc['nome'] as String,
      'racaPet': petDoc['raca'] as String,
      'imagePet': petDoc['imagePet'] as String
    };

    setState(() {
      petData[petId] = info;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: const Text('Historico:'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  const SizedBox(height: 30),
                  const SizedBox(height: 30),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _getScheduleStream(uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Erro: ${snapshot.error}');
                          }

                          if (!snapshot.hasData) {
                            return const Text('Nenhum dado disponível.');
                          }

                          final documents = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              // Chame a função fetchData para buscar os dados do pet

                              final String servico =
                                  documents[index]['servico'].toString();
                              final horarioEntrada =
                                  documents[index]['horarioEntrada'].toString();
                              final dataEntrada =
                                  documents[index]['dataEntrada'].toString();
                              final horarioSaida =
                                  documents[index]['horarioSaida'].toString();
                              final dataSaida =
                                  documents[index]['dataSaida'].toString();
                              final statusNumber = documents[index]['status'];
                              final bool avaliacaoDisp =
                                  !documents[index]['avaliado'];
                              final petId = documents[index]['petId'];
                              final userId = documents[index]['UID'];
                              final provId = documents[index]
                                      ['estabelecimentoId']
                                  .toString();
                              final agendamentoId = documents[index].id;
                              String showStatus = '';
                              Color cor = Colors.grey;
                              IconData icone = Icons.circle_outlined;

                              switch (statusNumber) {
                                case 0:
                                  icone = Icons.circle_outlined;
                                  cor = Colors.grey;
                                  showStatus = 'Aguardando Resposta';
                                case 1:
                                  icone = Icons.circle;
                                  cor = Colors.lightBlue;
                                  showStatus = 'Aguardando Check-In';
                                  break;
                                case 2:
                                  icone = Icons.circle;
                                  cor = Colors.orange;
                                  showStatus = 'Em Andamento';
                                  break;
                                case 3:
                                  icone = Icons.circle;
                                  cor = Colors.green;
                                  showStatus =
                                      'Concluído, Aguardando Check-Out';
                                  break;
                                case 4:
                                  icone = Icons.check_circle;
                                  cor = Colors.grey;
                                  showStatus = 'Finalizado';
                                  break;
                                case 5:
                                  icone = Icons.remove_circle_rounded;
                                  cor = const Color.fromARGB(255, 221, 55, 43);
                                  showStatus = 'Cancelado pelo estabelecimento';
                                default:
                                  showStatus =
                                      'Não foi possível identificar o estado de agendamento';
                              }
                              final idAgendamento = documents[index]
                                  .id; // Use .id para obter o ID do documento

                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                elevation: 4.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  title: Text(servico),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Text(
                                          'Check-In: $dataEntrada às $horarioEntrada'),
                                      const SizedBox(height: 2),
                                      if (horarioSaida.isNotEmpty &&
                                          dataSaida.isNotEmpty)
                                        Text(
                                            'Check-Out: $dataSaida às $horarioSaida')
                                      else
                                        const SizedBox(
                                          height: 14,
                                        ),
                                      const SizedBox(height: 14),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(showStatus),
                                          Icon(
                                            size: 18,
                                            icone,
                                            color: cor,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  trailing: statusNumber == 4 && avaliacaoDisp
                                      ? IconButton(
                                          splashRadius: 30,
                                          icon: const Icon(
                                              Icons.rate_review_rounded),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      TelaAvaliacao(
                                                          estabelecimentoId:
                                                              provId,
                                                          agendamentoId:
                                                              agendamentoId),
                                                ));
                                          })
                                      : const SizedBox(
                                          height: 48,
                                          width: 48,
                                        ),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TelaEstabelecimento(
                                                estabelecimentoId: provId),
                                      )),
                                ),
                              );
                            },
                          );
                        }),
                  ),
                ],
              )
            : const Text('Nenhum usuário autenticado'),
      ),
    );
  }
}

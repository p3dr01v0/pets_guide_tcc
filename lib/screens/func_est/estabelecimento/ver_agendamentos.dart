import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';

var logger = Logger();

class TelaVerAgenda extends StatefulWidget {
  final String typeService;
  final String nomeAgenda;

  const TelaVerAgenda(
      {super.key, required this.typeService, required this.nomeAgenda});

  @override
  _TelaVerAgendaState createState() => _TelaVerAgendaState();
}

class _TelaVerAgendaState extends State<TelaVerAgenda> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool banhoTosa = false;
  bool veterinario = false;
  bool hotelPet = false;
  String uid = '';
  String typeService = '';
  String nomeAgenda = '';
  late bool isAccept;
  int i = 0;

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

  Stream<QuerySnapshot> _getScheduleStream(String uid) {
    typeService = widget.typeService;
    nomeAgenda = widget.nomeAgenda;

    uid = _user!.uid;
    return _firestore
        .collection(
            'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
        .where("isAccept", isEqualTo: true)
        .where("status", isNotEqualTo: 4)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: Text('Agendamentos: ${widget.nomeAgenda}'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  const SizedBox(height: 35),
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
                              final String servico =
                                  documents[index]['servico'].toString();
                              final horario =
                                  documents[index]['horario'].toString();
                              final data = documents[index]['data'].toString();
                              final statusNumber = documents[index]['status'];
                              final clientId =
                                  documents[index]['UID'].toString();
                              final nomePet =
                                  documents[index]['petName'].toString();
                              final nomeUser =
                                  documents[index]['userName'].toString();
                              final petImage =
                                  documents[index]['petImage'].toString();
                              String showStatus = '';
                              switch (statusNumber) {
                                case 1:
                                  showStatus = 'Aguardando Check-In';
                                  break;
                                case 2:
                                  showStatus = 'Em Andamento';
                                  break;
                                case 3:
                                  showStatus =
                                      'Concluído, Aguardando Check-Out';
                                  break;

                                default:
                                  showStatus = '';
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
                                      Text('$nomePet de $nomeUser'),
                                      Text(horario),
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      Text("$data às $horario"),
                                      const SizedBox(height: 16),
                                      Text(showStatus)
                                    ],
                                  ),
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // ignore: unnecessary_null_comparison
                                      petImage == "" || petImage == null
                                          ? Container(
                                              height: 48,
                                              width: 48,
                                              child: const Icon(Icons.pets))
                                          : Container(
                                              height: 48,
                                              width: 48,
                                              decoration: BoxDecoration(
                                                shape: BoxShape
                                                    .circle, // ou qualquer outra forma desejada
                                                image: DecorationImage(
                                                  image: NetworkImage(petImage),
                                                  // Imagem padrão ou nenhuma imagem
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                  trailing: SizedBox(
                                    height: 96,
                                    width: 96,
                                    child: Row(
                                      mainAxisAlignment: statusNumber > 1
                                          ? MainAxisAlignment.spaceEvenly
                                          : MainAxisAlignment.end,
                                      children: [
                                        Visibility(
                                          visible: statusNumber > 1,
                                          child: IconButton(
                                              onPressed: () {
                                                _showConfirmUndoDialog(
                                                    idAgendamento,
                                                    context,
                                                    clientId);
                                              },
                                              icon: const Icon(Icons
                                                  .arrow_back_ios_rounded)),
                                        ),
                                        Visibility(
                                          visible: statusNumber < 4,
                                          child: IconButton(
                                              onPressed: () {
                                                _showConfirmCheckInDialog(
                                                    idAgendamento,
                                                    context,
                                                    statusNumber,
                                                    clientId);
                                              },
                                              icon: const Icon(Icons
                                                  .arrow_forward_ios_rounded)),
                                        ),
                                      ],
                                    ),
                                  ),
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

  Future<void> upgradeStatus(String idAgendamento, String userId) async {
    if (_user != null) {
      uid = _user!.uid;

      typeService = widget.typeService;
      nomeAgenda = widget.nomeAgenda;

      final agendamentoDoc = await _firestore
          .collection(
              'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
          .doc(idAgendamento)
          .get();

      final int statusNow = agendamentoDoc['status'];
      int newStatus = statusNow;
      if (newStatus > 3) {
        newStatus = 4;
      } else {
        newStatus = newStatus + 1;
      }
      // ignore: unnecessary_null_comparison
      if (idAgendamento != null || userId != null) {
        if (newStatus < 4) {
          final upgrade = <String, dynamic>{
            "ultimaAlteracao": DateTime.now(),
            "status": newStatus
          };
          try {
            await _firestore
                .collection(
                    'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
                .doc(idAgendamento)
                .update(upgrade)
                .then((_) {
              logger.d('update realizado com sucesso');
            });
          } on FirebaseException catch (e) {
            logger.e(e);
          }
          try {
            await _firestore
                .collection('usuario/$userId/agendamentos')
                .doc(idAgendamento)
                .update(upgrade)
                .then((_) {
              logger.d('update realizado com sucesso');
            });
          } on FirebaseException catch (e) {
            logger.e(e);
          }
        }
        if (newStatus == 4) {
          final upgrade = <String, dynamic>{
            "dataFinalizacao": DateTime.now(),
            "status": newStatus,
            "avaliado": false
          };
          try {
            await _firestore
                .collection(
                    'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
                .doc(idAgendamento)
                .update(upgrade)
                .then((_) {
              logger.d('update realizado com sucesso');
            });
          } on FirebaseException catch (e) {
            logger.e(e);
          }
          try {
            await _firestore
                .collection('usuario/$userId/agendamentos')
                .doc(idAgendamento)
                .update(upgrade)
                .then((_) {
              logger.d('update realizado com sucesso');
            });
          } on FirebaseException catch (e) {
            logger.e(e);
          }
          final infoCollectionRef =
              await _firestore.collection('estabelecimentos/$uid/info').get();
          final infoDoc = infoCollectionRef.docs.first;
          final infoId = infoDoc.id;
          logger.i('buceidow $infoId');

          int servicosConcluidos = infoDoc[
              'servicosConcluidos']; //PRECISA CRIAR UM CAMPO servicosConcluidos

          if (infoId.isNotEmpty) {
            try {
              await _firestore
                  .collection('estabelecimentos/$uid/info')
                  .doc(infoId)
                  .update({"servicosConcluidos": servicosConcluidos + 1}).then(
                      (_) {
                logger.i('update realizado com sucesso, serviço contabilizado');
              });
            } on FirebaseException catch (e) {
              logger.e(e);
            }
          }
        }
      }
    }
  }

  Future<void> downgradeStatus(String idAgendamento, String userId) async {
    if (_user != null) {
      uid = _user!.uid;

      typeService = widget.typeService;
      nomeAgenda = widget.nomeAgenda;

      final agendamentoDoc = await _firestore
          .collection(
              'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
          .doc(idAgendamento)
          .get();

      int statusNow = agendamentoDoc['status'];
      int newStatus = statusNow;
      if (newStatus < 2) {
        newStatus = 1;
      } else {
        newStatus = newStatus - 1;
      }
      // ignore: unnecessary_null_comparison
      if (idAgendamento != null || userId != null) {
        final downgrade = <String, dynamic>{
          "ultimaAlteracao": DateTime.now(),
          "status": newStatus
        };
        try {
          await _firestore
              .collection(
                  'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
              .doc(idAgendamento)
              .update(downgrade)
              .then((_) {
            logger.d('update realizado com sucesso');
          });
        } on FirebaseException catch (e) {
          logger.e(e);
        }
      }
    }
  }

  void _showConfirmCheckInDialog(String idAgendamento, BuildContext context,
      int statusNumber, String userId) {
    //confirmar ações de usuário, medida para anti miss-click

    String dialogText = '';

    switch (statusNumber) {
      case 1:
        dialogText = 'Realizar check-In?';
        break;
      case 2:
        dialogText = 'Concluir serviço?';
        break;
      case 3:
        dialogText =
            'Confirmar check-out e Finalização? Essa ação é irreversível';
        break;
      default:
        dialogText = 'algo deu errado';
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: Text(dialogText),
          actions: [
            TextButton(
              onPressed: () {
                upgradeStatus(idAgendamento, userId);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Feche o diálogo
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmUndoDialog(
      String idAgendamento, BuildContext context, String userId) {
    //confirmar ações de usuário, medida para anti miss-click
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Deseja desfazer a última ação?'),
          actions: [
            TextButton(
              onPressed: () {
                downgradeStatus(idAgendamento, userId);
                Navigator.of(context).pop();
              },
              child: const Text('Confirmar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Feche o diálogo
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}

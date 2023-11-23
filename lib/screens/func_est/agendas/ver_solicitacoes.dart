import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

var logger = Logger();

class TelaVerSolicitacoes extends StatefulWidget {
  final String typeService;
  final String nomeAgenda;

  const TelaVerSolicitacoes(
      {super.key, required this.typeService, required this.nomeAgenda});

  @override
  _TelaVerSolicitacoesState createState() => _TelaVerSolicitacoesState();
}

class _TelaVerSolicitacoesState extends State<TelaVerSolicitacoes> {
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
    uid = _user!.uid;
    typeService = widget.typeService;
    nomeAgenda = widget.nomeAgenda;
    return _firestore
        .collection(
            'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
        .where("isAccept", isEqualTo: false)
        .where("status", isEqualTo: 0)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: Text('Solicitações: ${widget.nomeAgenda}'),
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
                              final horarioEntrada =
                                  documents[index]['horarioEntrada'].toString();
                              final dataEntrada =
                                  documents[index]['dataEntrada'].toString();
                              final nomePet =
                                  documents[index]['petName'].toString();
                              final nomeUser =
                                  documents[index]['userName'].toString();
                              final petImage =
                                  documents[index]['petImage'].toString();

                              final idAgendamento = documents[index]
                                  .id; // Use .id para obter o ID do documento

                              bool isAccept = documents[index]['isAccept'];

                              final clientId = documents[index]['UID'];

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
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Text('$nomePet de $nomeUser'),
                                        Text(horarioEntrada),
                                        const SizedBox(
                                          height: 14,
                                        ),
                                        Text("$dataEntrada às $horarioEntrada"),
                                      ],
                                    ),
                                    leading: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                                    image:
                                                        NetworkImage(petImage),
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
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                updateAcceptStatus(
                                                    idAgendamento, clientId);
                                                logger.d(isAccept);
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TelaVerSolicitacoes(
                                                                typeService: widget
                                                                    .typeService,
                                                                nomeAgenda: widget
                                                                    .nomeAgenda)));
                                              },
                                              icon: const Icon(
                                                  Icons.check_rounded)),
                                          IconButton(
                                              onPressed: () {
                                                _showConfirmdecline(
                                                  idAgendamento,
                                                  context,
                                                  clientId,
                                                );
                                                logger.d(isAccept);
                                              },
                                              icon: const Icon(
                                                  Icons.cancel_outlined)),
                                        ],
                                      ),
                                    )),
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

  Future<void> updateAcceptStatus(String idAgendamento, String userId) async {
    if (_user != null) {
      uid = _user!.uid;

      typeService = widget.typeService;
      nomeAgenda = widget.nomeAgenda;

      final agendamentoDoc = await _firestore
          .collection(
              'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
          .doc(idAgendamento)
          .get();
      final bool acceptance = !agendamentoDoc['isAccept'];

      if (idAgendamento.isNotEmpty || userId.isNotEmpty) {
        final updateAccept = <String, dynamic>{
          "dataAceitacao": DateTime.now(),
          "isAccept": acceptance,
          "status": 1
        };
        try {
          await _firestore
              .collection(
                  'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
              .doc(idAgendamento)
              .update(updateAccept)
              .then((_) {
            logger.d('update realizado com sucesso');
          });
        } on FirebaseException catch (e) {
          logger.e(e);
        }
        try {
          await _firestore
              .collection('user/$userId/agendamentos')
              .doc(idAgendamento)
              .update(updateAccept)
              .then((_) {
            logger.d('update realizado com sucesso');
          });
        } on FirebaseException catch (e) {
          logger.e(e);
        }
      }
    }
  }

  Future<void> declineAcceptStatus(String idAgendamento, String userId) async {
    if (_user != null) {
      uid = _user!.uid;

      typeService = widget.typeService;
      nomeAgenda = widget.nomeAgenda;

      // ignore: unused_local_variable
      final agendamentoDoc = await _firestore
          .collection(
              'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
          .doc(idAgendamento)
          .get();

      if (idAgendamento.isNotEmpty || userId.isNotEmpty) {
        final declineAccept = <String, dynamic>{
          "dataRejeicao": DateTime.now(),
          "status": 5
        };
        try {
          await _firestore
              .collection(
                  'estabelecimentos/$uid/$typeService/$nomeAgenda/agendamentos')
              .doc(idAgendamento)
              .update(declineAccept)
              .then((_) {
            logger.d('update realizado com sucesso');
          });
        } on FirebaseException catch (e) {
          logger.e(e);
        }
        try {
          await _firestore
              .collection('user/$userId/agendamentos')
              .doc(idAgendamento)
              .update(declineAccept)
              .then((_) {
            logger.d('update realizado com sucesso');
          });
        } on FirebaseException catch (e) {
          logger.e(e);
        }
      }
    }
  }

  void _showConfirmdecline(
      String idAgendamento, BuildContext context, String userId) {
    //confirmar ações de usuário, medida para anti miss-click

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text(
              'Tem Certeza que irá rejeitar esse agendamento? Essa ação é irreversível'),
          actions: [
            TextButton(
              onPressed: () {
                declineAcceptStatus(idAgendamento, userId);
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';

var logger = Logger();

class TelaHistoricoHotel extends StatefulWidget {
  final String typeService;
  final String nomeAgenda;

  const TelaHistoricoHotel(
      {super.key, required this.typeService, required this.nomeAgenda});

  @override
  _TelaHistoricoHotelState createState() => _TelaHistoricoHotelState();
}

class _TelaHistoricoHotelState extends State<TelaHistoricoHotel> {
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
        .where("status", isGreaterThan: 3)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: Text('Historico: ${widget.nomeAgenda}'),
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
                              final horarioSaida =
                                  documents[index]['horarioSaida'].toString();
                              final dataSaida =
                                  documents[index]['dataSaida'].toString();
                              final nomePet =
                                  documents[index]['petName'].toString();
                              final nomeUser =
                                  documents[index]['userName'].toString();
                              final petImage =
                                  documents[index]['petImage'].toString();
                              final statusNumber = documents[index]['status'];
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
                                case 4:
                                  showStatus = 'Finalizado';
                                  break;
                                case 5:
                                  showStatus = 'Cancelado';
                                  break;
                                default:
                                  showStatus = '';
                              }
                              // ignore: unused_local_variable
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
                                      const SizedBox(
                                        height: 14,
                                      ),
                                      Text(
                                          "Check-In: $dataEntrada às $horarioEntrada"),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                          "Check-Out: $dataSaida às $horarioSaida"),
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

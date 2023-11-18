// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Historico:'),
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
                              // Chame a função fetchData para buscar os dados do pet

                              final String servico = documents[index]['servico'].toString();
                              final horario = documents[index]['horario'].toString();
                              final data = documents[index]['data'].toString();
                              final petName = documents[index]['petName'].toString();
                              final statusNumber = documents[index]['status'];
                              final petId = documents[index]['petId'];
                              final userId = documents[index]['UID'];
                              String showStatus = '';
                              switch (statusNumber) {
                                case 0:
                                  showStatus = 'Aguardando Resposta';
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
                                      Text(data),
                                      const SizedBox(height: 2),
                                      Text(horario),
                                      const SizedBox(height: 2),
                                      Text('serviço para $petName'),
                                      const SizedBox(height: 12),
                                      Text('ID: $idAgendamento'),
                                      const SizedBox(height: 14),
                                      Text(showStatus)
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
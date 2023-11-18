// ignore_for_file: unused_local_variable, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_hist_user.dart';
import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';

var logger = Logger();

class TelaHistoricoUserHotel extends StatefulWidget {
  @override
  _TelaHistoricoUserHotelState createState() => _TelaHistoricoUserHotelState();
}

class _TelaHistoricoUserHotelState extends State<TelaHistoricoUserHotel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
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
          .collection('user/$uid/agendamentosHotelPet')
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
                  OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaHistoricoUser(),
                            ));
                      },
                      child: const Text('Agendamentos Comuns')),
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
                                      Text(
                                          'Check-In: ${dataEntrada} às ${horarioEntrada}'),
                                      const SizedBox(height: 2),
                                      Text(
                                          'Check-Out: ${dataSaida} às ${horarioSaida}'),
                                      const SizedBox(height: 14),
                                      const SizedBox(height: 16),
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

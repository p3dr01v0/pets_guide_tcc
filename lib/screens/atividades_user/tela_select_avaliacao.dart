
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_avaliacao.dart';
import 'package:logger/logger.dart';

import 'package:firebase_auth/firebase_auth.dart';

var logger = Logger();

class TelaSelectAvaliacao extends StatefulWidget {
  final String estabelecimentoId;

  const TelaSelectAvaliacao({super.key, required this.estabelecimentoId});

  @override
  _TelaSelectAvaliacaoState createState() => _TelaSelectAvaliacaoState();
}

class _TelaSelectAvaliacaoState extends State<TelaSelectAvaliacao> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String uid = '';

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
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? _getScheduleStream(String uid) {
    if (_user != null) {
      uid = _user!.uid;
      final agendamentosQuery = _firestore
          .collection('user/$uid/agendamentos')
          .where("UID", isEqualTo: uid)
          .where("estabelecimentoId", isEqualTo: widget.estabelecimentoId)
          .where("status", isEqualTo: 4)
          .where("avaliado", isNotEqualTo: true)
          .snapshots();
          return agendamentosQuery;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Últimos serviços'),
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

                              final String servico =
                                  documents[index]['servico'].toString();
                              final horario =
                                  documents[index]['horario'].toString();
                              final data = documents[index]['data'].toString();
                              final statusNumber = documents[index]['status'];
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
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TelaAvaliacao(
                                            estabelecimentoId:
                                                widget.estabelecimentoId,
                                                agendamentoId: idAgendamento,
                                          ),
                                        ));
                                  },
                                  title: Text(servico),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Text(data),
                                      const SizedBox(height: 2),
                                      Text(horario),
                                      const SizedBox(height: 14),
                                      Text('ID: $idAgendamento'),
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
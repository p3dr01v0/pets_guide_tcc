import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_agendamento.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaSelectAgenda extends StatefulWidget {
  final String estabelecimentoId;
  final String typeService;

  TelaSelectAgenda(this.estabelecimentoId, this.typeService);

  @override
  _TelaSelectAgendaState createState() => _TelaSelectAgendaState();
}

class _TelaSelectAgendaState extends State<TelaSelectAgenda> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool banhoTosa = false;
  bool veterinario = false;
  bool hotelPet = false;
  String estabelecimentoId = '';
  String typeService = '';
  List<Map<String, dynamic>> _mySchedule = [];

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
      await _fetchSchedule(user.uid);
    }
  }

  Future<void> _fetchSchedule(String uid) async {
    estabelecimentoId = widget.estabelecimentoId;
    typeService = widget.typeService;

    QuerySnapshot querySnapshot = await _firestore
        .collection('estabelecimentos/$estabelecimentoId/$typeService')
        .where('nomeAgenda', isNull: false)
        .get();

    setState(() {
      _mySchedule = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Selecione a agenda'),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  const SizedBox(height: 50),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _mySchedule.length,
                      itemBuilder: (context, index) {
                        final String nomeAgenda =
                            _mySchedule[index]['nomeAgenda'].toString();

                        final horarios =
                            _mySchedule[index]['horarios'] as List<dynamic>;

                        final firstHorario = horarios.isNotEmpty
                            ? horarios.first.toString()
                            : '';
                        final lastHorario =
                            horarios.isNotEmpty ? horarios.last.toString() : '';

                        final services =
                            (_mySchedule[index]['servicos'] as List<dynamic>)
                                .join(', ');

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TelaAgendamento(
                                          estabelecimentoId: estabelecimentoId,
                                          typeService: typeService,
                                          nomeAgenda: nomeAgenda,
                                        )));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            elevation: 4.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title: Text(nomeAgenda),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 6,
                                  ),
                                  Text('$firstHorario - $lastHorario'),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(services),
                                  const SizedBox(
                                    height: 12,
                                  )
                                ],
                              ),
                              trailing: const Icon(Icons.more_vert),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Text('Nenhum usuário autenticado'),
      ),
    );
  }
}
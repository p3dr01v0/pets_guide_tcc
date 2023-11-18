import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/estabelecimento/tela_select_hist.dart';
import 'package:flutter_application_1/screens/func_est/estabelecimento/ver_agendamentos.dart';
import 'package:flutter_application_1/screens/func_est/estabelecimento/ver_solicitacoes.dart';
import 'package:flutter_application_1/screens/func_est/estabelecimento/telaDiasFuncionamento.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaAgenda extends StatefulWidget {
  final String typeService;

  const TelaAgenda({super.key, required this.typeService});

  @override
  _TelaAgendaState createState() => _TelaAgendaState();
}

class _TelaAgendaState extends State<TelaAgenda> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool banhoTosa = false;
  bool veterinario = false;
  bool hotelPet = false;
  String uid = '';
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
    if (_user != null) {
      uid = _user!.uid;
      typeService = widget.typeService;

      QuerySnapshot querySnapshot = await _firestore
          .collection('estabelecimentos/$uid/$typeService')
          .where('nomeAgenda', isNull: false)
          .get();

      setState(() {
        _mySchedule = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione a agenda'),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(fixedSize: Size(125, 30)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TelaDiasFuncionamento(
                                      typeService: widget.typeService)));
                        },
                        child: const Text('Criar Agenda'),
                      ),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              fixedSize: Size(125, 30)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TelaSelectHist(typeService: typeService),
                                ));
                          },
                          child: Text('Histórico')),
                    ],
                  ),
                  const SizedBox(height: 20),
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

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 4.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(nomeAgenda,
                                style: const TextStyle(fontSize: 20)),
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
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30.0))),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TelaVerSolicitacoes(
                                                        typeService:
                                                            typeService,
                                                        nomeAgenda: nomeAgenda),
                                              ));
                                        },
                                        child: const Text('Solicitações')),
                                    OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30.0))),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TelaVerAgenda(
                                                        typeService:
                                                            typeService,
                                                        nomeAgenda: nomeAgenda),
                                              ));
                                        },
                                        child: const Text('Agendamentos')),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit),
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
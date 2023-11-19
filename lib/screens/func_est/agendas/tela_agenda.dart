import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/func_est/agendas/ver_agendamentos_hotel.dart';
import 'package:flutter_application_1/screens/func_est/agendas/ver_solicitacoes_hotel.dart';
import 'package:flutter_application_1/screens/func_est/agendas/telaDiasFuncionamento.dart';
import 'package:flutter_application_1/screens/func_est/agendas/ver_agendamentos.dart';
import 'package:flutter_application_1/screens/func_est/agendas/ver_solicitacoes.dart';
import 'package:flutter_application_1/screens/func_est/historicos/tela_select_hist.dart';

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
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: const Text('Selecionar agenda'),
        backgroundColor: const Color(0xFF10428B),
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
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            fixedSize: const Size(150, 30),
                            backgroundColor:
                                const Color.fromARGB(255, 255, 149, 0)),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TelaDiasFuncionamento(
                                      typeService: widget.typeService)));
                        },
                        child: const Text(
                          'Criar Agenda',
                          style: TextStyle(
                            fontSize: 14, // Tamanho do texto
                            color: Colors.white, // Cor do texto
                          ),
                        ),
                      ),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            textStyle: const TextStyle(
                                color: Color.fromARGB(255, 255, 149, 0)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            fixedSize: const Size(150, 30),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TelaSelectHist(typeService: typeService),
                                ));
                          },
                          child: const Text('Histórico',
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 149, 0),
                                fontWeight: FontWeight.bold, // Negrito
                              ))),
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
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 149, 0)),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30.0))),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              widget.typeService != 'hotelPet'
                                                  ? MaterialPageRoute(
                                                      builder: (context) =>
                                                          TelaVerSolicitacoes(
                                                              typeService:
                                                                  typeService,
                                                              nomeAgenda:
                                                                  nomeAgenda),
                                                    )
                                                  : MaterialPageRoute(
                                                      builder: (context) =>
                                                          TelaVerSolicitacoesHotel(
                                                              typeService:
                                                                  typeService,
                                                              nomeAgenda:
                                                                  nomeAgenda),
                                                    ));
                                        },
                                        child: const Text('Solicitações',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 149, 0)))),
                                    OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                            textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 149, 0)),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30.0))),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              typeService != 'hotelPet'
                                                  ? MaterialPageRoute(
                                                      builder: (context) =>
                                                          TelaVerAgenda(
                                                              typeService:
                                                                  typeService,
                                                              nomeAgenda:
                                                                  nomeAgenda),
                                                    )
                                                  : MaterialPageRoute(
                                                      builder: (context) =>
                                                          TelaVerAgendaHotel(
                                                              typeService:
                                                                  typeService,
                                                              nomeAgenda:
                                                                  nomeAgenda),
                                                    ));
                                        },
                                        child: const Text('Agendamentos',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 149, 0)))),
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

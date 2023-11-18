import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/historicos/tela_historico.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/func_est/historicos/tela_historico_hotel.dart';

class TelaSelectHist extends StatefulWidget {
  final String typeService;

  const TelaSelectHist({super.key, required this.typeService});

  @override
  _TelaSelectHistState createState() => _TelaSelectHistState();
}

class _TelaSelectHistState extends State<TelaSelectHist> {
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
        title: const Text('Selecione o Histórico'),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  const SizedBox(height: 35),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _mySchedule.length,
                      itemBuilder: (context, index) {
                        final String nomeAgenda =
                            _mySchedule[index]['nomeAgenda'].toString();

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          elevation: 4.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(nomeAgenda,
                                style: const TextStyle(fontSize: 16)),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  widget.typeService != 'hotelPet'
                                      ? MaterialPageRoute(
                                          builder: (context) => TelaHistorico(
                                              typeService: typeService,
                                              nomeAgenda: nomeAgenda),
                                        )
                                      : MaterialPageRoute(
                                          builder: (context) =>
                                              TelaHistoricoHotel(
                                                  typeService: typeService,
                                                  nomeAgenda: nomeAgenda),
                                        ));
                            },
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

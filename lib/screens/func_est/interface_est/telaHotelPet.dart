import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_serv_est.dart';
import 'package:flutter_application_1/screens/func_est/estabelecimento/tela_agenda.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaHotelPet extends StatefulWidget {
  @override
  _TelaHotelPetState createState() => _TelaHotelPetState();
}

class _TelaHotelPetState extends State<TelaHotelPet> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _providers = [];
  String typeService = 'hotelPet';

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
      await _fetchProviders(user.uid);
    }
  }

  Future<void> _fetchProviders(String uid) async {
    final estabelecimentoReference =
        _firestore.collection('estabelecimentos').doc(uid);

    estabelecimentoReference
        .get()
        .then((DocumentSnapshot estabelecimentoSnapshot) {
      if (estabelecimentoSnapshot.exists) {
        final estabelecimentoData =
            estabelecimentoSnapshot.data() as Map<String, dynamic>?;

        if (estabelecimentoData != null &&
            estabelecimentoData['servico'] == true) {
          final hotelPetReference = estabelecimentoReference
              .collection('hotelPet')
              .where('nomeServico', isNull: false);

          hotelPetReference.get().then((QuerySnapshot hotelPetQuerySnapshot) {
            if (hotelPetQuerySnapshot.docs.isNotEmpty) {
              setState(() {
                _providers = hotelPetQuerySnapshot.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
              });
              print('A subcoleção "hotelPet" existe para o usuário $uid.');
            } else {
              print('A subcoleção "hotelPet" não existe para o usuário $uid.');
            }
          }).catchError((error) {
            print('Erro ao consultar a subcoleção "hotelPet": $error');
          });
        } else {
          print('O campo "servico" não é verdadeiro para o usuário $uid.');
        }
      } else {
        print('O documento de estabelecimento não existe para o usuário $uid.');
      }
    }).catchError((error) {
      print('Erro ao consultar o documento de estabelecimento: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 243, 236),
        appBar: AppBar(
          backgroundColor: const Color(0xFF10428B),
          title: const Text('Serviços de Hospedagens'),
        ),
        body: Center(
          child: _user != null
              ? Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TelaAgenda(typeService: typeService)));
                      },
                      child: const Text('Checar Agenda'),
                    ),
                    Text('ID do usuário autenticado: ${_user!.uid}'),
                    const Text(' disponíveis:'),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _providers.length,
                        itemBuilder: (context, index) {
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 2.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: ListTile(
                              title:
                                  Text('${_providers[index]['nomeServico']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Duração ${_providers[index]['duracao']} Horas'),
                                  Text('Diária  ${_providers[index]['preco']}'),
                                ],
                              ),
                              trailing: const Icon(Icons.more_vert),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const Text('Nenhum usuário autenticado'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const telaAddServ()));
          },
          backgroundColor: const Color(0xFF10428B),
          child: const Icon(Icons.add),
        ));
  }
}

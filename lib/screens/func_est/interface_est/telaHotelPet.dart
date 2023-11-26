// ignore_for_file: avoid_print, unnecessary_cast

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_serv_est.dart';
import 'package:flutter_application_1/screens/func_est/agendas/tela_agenda.dart';
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
    final estabelecimentoCollection =
        _firestore.collection('estabelecimentos').where('UID', isEqualTo: uid);

    try {
      final estabelecimentoSnapshot = await estabelecimentoCollection.get();

      if (estabelecimentoSnapshot.docs.isNotEmpty) {
        final document = estabelecimentoSnapshot.docs.first;

        final hotelPetReference = document.reference.collection('hotelPet');

        try {
          final petHotelSnapshot = await hotelPetReference.get();

          if (petHotelSnapshot.docs.isNotEmpty) {
            setState(() {
              _providers = petHotelSnapshot.docs
                  .where((doc) => doc.data().containsKey('nomeServico'))
                  .map((doc) => doc.data() as Map<String, dynamic>)
                  .toList();
            });
            print('A subcoleção "hotelPet" existe neste documento.');
          } else {
            setState(() {
              _providers = [];
            });
            print('A subcoleção "hotelPet" está vazia.');
          }
        } catch (error) {
          print('Erro ao consultar a subcoleção "hotelPet": $error');
        }
      } else {
        setState(() {
          _providers = [];
        });
        print('O usuário logado não possui estabelecimentos.');
      }
    } catch (error) {
      print('Erro ao consultar a coleção "estabelecimentos": $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: const Text('Alocação de Hotel Pet'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Center(
        child: _user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 20.0), // espaçamento para app bar e o botão
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10428B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        fixedSize: const Size(200, 32),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TelaAgenda(typeService: typeService),
                          ),
                        );
                      },
                      child: const Text(
                        'Checar Agenda',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  const Text('Serviços de hospedagens:'),
                  const SizedBox(
                    height: 12,
                  ),
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
                            title: Text('${_providers[index]['nomeServico']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Duração ${_providers[index]['duracao']} Horas'),
                                Text('Diária ${_providers[index]['preco']}'),
                              ],
                            ),
                            trailing: const Icon(Icons.edit),
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
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

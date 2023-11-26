// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_serv_est.dart';
import 'package:flutter_application_1/screens/func_est/agendas/tela_agenda.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaVeterinario extends StatefulWidget {
  @override
  _TelaVeterinarioState createState() => _TelaVeterinarioState();
}

class _TelaVeterinarioState extends State<TelaVeterinario> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _providers = [];
  String typeService = 'veterinario';

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
          final veterinarioReference = estabelecimentoReference
              .collection('veterinario')
              .where('nomeServico', isNull: false);

          veterinarioReference
              .get()
              .then((QuerySnapshot veterinarioQuerySnapshot) {
            if (veterinarioQuerySnapshot.docs.isNotEmpty) {
              setState(() {
                _providers = veterinarioQuerySnapshot.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
              });
              print('A subcoleção "veterinario" existe para o usuário $uid.');
            } else {
              print(
                  'A subcoleção "veterinario" não existe para o usuário $uid.');
            }
          }).catchError((error) {
            print('Erro ao consultar a subcoleção "veterinario": $error');
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
        title: const Text('Serviços Veterinarios'),
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
                  const Text('Serviços vetrinários:'),
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
                                Text('Preço ${_providers[index]['preco']}'),
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

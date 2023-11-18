import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_select_agenda.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaSelectServico extends StatefulWidget {
  final String estabelecimentoId;

  const TelaSelectServico({super.key, required this.estabelecimentoId});

  @override
  _TelaSelectServicoState createState() => _TelaSelectServicoState();
}

class _TelaSelectServicoState extends State<TelaSelectServico> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool banhoTosa = false;
  bool veterinario = false;
  bool hotelPet = false;
  String estabelecimentoId = '';

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
      await _fetchservices(user.uid);
    }
  }

  Future<void> _fetchservices(String uid) async {
    estabelecimentoId = widget.estabelecimentoId;
    
    final estabelecimentoCollection = _firestore
        .collection('estabelecimentos')
        .where('UID', isEqualTo: estabelecimentoId);

    estabelecimentoCollection.get().then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          final banhoETosaReference =
              document.reference.collection('banhoETosa');

          final veterinarioReference =
              document.reference.collection('veterinario');

          final hotelPetReference = document.reference.collection('hotelPet');

          banhoETosaReference
              .get()
              .then((QuerySnapshot banhoETosaQuerySnapshot) {
            if (banhoETosaQuerySnapshot.docs.isNotEmpty) {
              // A subcoleção "banhoETosa" existe neste documento de "estabelecimento"
              setState(() {
                banhoTosa = true;
              });
              print('A subcoleção "banhoETosa" existe neste documento.');
            } else {
              // A subcoleção "banhoETosa" não existe neste documento de "estabelecimento"
              print('A subcoleção "banhoETosa" não existe neste documento.');
            }
          }).catchError((error) {
            print('Erro ao consultar a subcoleção "banhoETosa": $error');
          });

          veterinarioReference
              .get()
              .then((QuerySnapshot veterinarioQuerySnapshot) {
            if (veterinarioQuerySnapshot.docs.isNotEmpty) {
              // A subcoleção "veterinario" existe neste documento de "estabelecimento"
              setState(() {
                veterinario = true;
              });
              print('A subcoleção "veterinario" existe neste documento.');
            } else {
              // A subcoleção "veterinario" não existe neste documento de "estabelecimento"
              print('A subcoleção "veterinario" não existe neste documento.');
            }
          }).catchError((error) {
            print('Erro ao consultar a subcoleção "veterinario": $error');
          });

          hotelPetReference.get().then((QuerySnapshot hotelPetQuerySnapshot) {
            if (hotelPetQuerySnapshot.docs.isNotEmpty) {
              // A subcoleção "hotelPet" existe neste documento de "estabelecimento"
              setState(() {
                hotelPet = true;
              });
              print('A subcoleção "hotelPet" existe neste documento.');
            } else {
              // A subcoleção "hotelPet" não existe neste documento de "estabelecimento"
              print('A subcoleção "hotelPet" não existe neste documento.');
            }
          }).catchError((error) {
            print('Erro ao consultar a subcoleção "hotelPet": $error');
          });
        }
      } else {
        print('A coleção "estabelecimento" está vazia ou não existe.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Selecione o tipo de serviço'),
      ),
      body: Center(
        child: _user != null
            ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        banhoTosa
                            ? GestureDetector(
                                onTap: () {
                                  String typeService = 'banhoETosa';
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              TelaSelectAgenda(
                                                  widget.estabelecimentoId,
                                                  typeService))));
                                },
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    elevation: 2.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: const ListTile(
                                      leading: Icon(Icons.shower),
                                      title: Text('Banho e Tosa'),
                                    )))
                            : const Text(''),
                        veterinario
                            ? GestureDetector(
                                onTap: () {
                                  String typeService = 'veterinario';
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              TelaSelectAgenda(
                                                  widget.estabelecimentoId,
                                                  typeService))));
                                },
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    elevation: 2.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: const ListTile(
                                      leading: Icon(Icons.medical_services),
                                      title: Text('Veterinario'),
                                    )))
                            : const Text(''),
                        hotelPet
                            ? GestureDetector(
                                onTap: () {
                                  String typeService = 'hotelPet';
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              TelaSelectAgenda(
                                                  widget.estabelecimentoId,
                                                  typeService))));
                                },
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    elevation: 2.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: const ListTile(
                                      leading:
                                          Icon(Icons.other_houses_outlined),
                                      title: Text('Hotel Pet'),
                                    )))
                            : const Text(''),
                        banhoTosa == false &&
                                veterinario == false &&
                                hotelPet == false
                            ? const Text('Nenhum serviço cadastrado')
                            : const Text('')
                      ],
                    ),
                  ),
                ],
              )
            : const Text('Nenhum usuário autenticado'),
      ),  
    );
  }
}
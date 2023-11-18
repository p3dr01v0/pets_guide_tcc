// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/atividades_user/ver_avaliacoes.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_user.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_info_est.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_serv_est.dart';
import 'package:flutter_application_1/screens/func_est/interface_est/telaBanhoETosa.dart';
import 'package:flutter_application_1/screens/func_est/interface_est/telaHotelPet.dart';
import 'package:flutter_application_1/screens/func_est/interface_est/telaVeterianrio.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:flutter_application_1/servicos/img_padrao.dart';

class perfilEst extends StatefulWidget {
  @override
  _perfilEstState createState() => _perfilEstState();
}

class _perfilEstState extends State<perfilEst> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  // ignore: unused_field
  List<Map<String, dynamic>> _services = [];
  bool banhoTosa = false;
  bool veterinario = false;
  bool hotelPet = false;
  String? username;
  String? email;
  String? Contato;
  String? imagemEst;

  @override
  void initState() {
    super.initState();
    // Verifique se há um usuário autenticado quando o widget é iniciado
    _checkCurrentUser();
    loadEstData();
  }

  void loadEstData() async {
    String? userUid = _auth.currentUser?.uid;

    if (userUid != null && mounted) {
      DocumentSnapshot userData =
          await _firestore.collection('estabelecimentos').doc(userUid).get();

      setState(() {
        username = userData['username'];
        email = userData['emailProv'];
        Contato = userData['Contato'];
      });

      // Verifica se a subcoleção "info" existe
      var infoCollection =
          _firestore.collection('estabelecimentos/$userUid/info');
      var infoSnapshot = await infoCollection.get();

      if (infoSnapshot.docs.isNotEmpty) {
        print("sub coleção info existe no documento");
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const telaAddInfo()),
        );
        print("sub coleção não existe no documento");
      }
    }
  }

  Future<void> _checkCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _user = user;
      });

      //consulta os serviços do usuario
      await _fetchservices(user.uid);
    }
  }

  Future<void> _fetchservices(String uid) async {
    final estabelecimentoCollection = _firestore
        .collection('estabelecimentos')
        .where('UID', isEqualTo: _user!.uid);

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
        title: const Text('Perfil do Estabelecimento'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 34, 96, 190),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15.0),
                  Text('Nome: $username'),
                ],
              ),
            ),
            ListTile(
              title: const Text('acrescentar Informações'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const telaAddInfo()),
                );
              },
            ),
            ListTile(
              title: const Text('Add serviço'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const telaAddServ()),
                );
              },
            ),
            ListTile(
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => perfilEst()),
                );
              },
            ),
            ListTile(
              title: const Text('Deslogar'),
              onTap: () {
                autenticacaoServico().deslogar();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AutentiacacaoTela()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  Card(
                    elevation: 5.0,
                    margin: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12.0), // Ajuste o valor conforme necessário
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment
                            .center, // Alinhe verticalmente ao centro
                        children: [
                          imgEst(), // Componente para exibir a imagem do usuário
                          const SizedBox(
                              width:
                                  16.0), // Espaçamento entre a imagem e os textos
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // Alinhe verticalmente ao centro
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nome: $username',
                                    style: const TextStyle(fontSize: 16)),
                                Text(
                                  'Email: ${email != null ? (email!.length > 20 ?
                                      // ignore: prefer_interpolation_to_compose_strings
                                      email!.substring(0, 20) + '...' : email) : ''}',
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text('Telefone: $Contato',
                                    style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  const Text('Meus Servicos'),
                  Expanded(
                    child: ListView(
                      children: [
                        banhoTosa
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              TelaBanhoETosa())));
                                },
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    elevation: 2.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    child: const ListTile(
                                      leading: Icon(Icons.shower),
                                      title: Text('Banho e Tosa'),
                                    )))
                            : const Text(''),
                        veterinario
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              TelaVeterinario())));
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: ((context) =>
                                              TelaHotelPet())));
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
                            ? const Text(
                                'Nenhum serviço cadastrado',
                                textAlign: TextAlign.center,
                              )
                            : const Text('')
                      ],
                    ),
                  ),
                  FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 255, 153, 0),
                          fixedSize: const Size(200, 32)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelaVerAvaliacoes(
                                  estabelecimentoId: _user!.uid),
                            ));
                      },
                      child: const Text('Ver Avaliações')),
                  const SizedBox(
                    height: 12,
                  )
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

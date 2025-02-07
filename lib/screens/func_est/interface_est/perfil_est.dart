// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/atividades_user/ver_avaliacoes.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_user.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_info_est.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_serv_est.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/editar_est.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/tela_config_est.dart';
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
  String? contatoInfo;
  String? nomeInfo;
  String? fundacao;

  @override
  void initState() {
    super.initState();
    // Verifique se há um usuário autenticado quando o widget é iniciado
    _checkCurrentUser();
    if (mounted) {
      loadEstData();
    }
  }

  void loadEstData() async {
    String? userUid = _auth.currentUser?.uid;

    if (userUid != null && mounted) {
      // Verifica se o UID está na coleção "estabelecimentos"
      var estabelecimentoDoc =
          await _firestore.collection('estabelecimentos').doc(userUid).get();

      if (estabelecimentoDoc.exists) {
        DocumentSnapshot estabelecimentoData = estabelecimentoDoc;

        // Verifica se a subcoleção "info" existe
        var infoCollection =
            _firestore.collection('estabelecimentos/$userUid/info');
        var infoSnapshot = await infoCollection.get();

        if (infoSnapshot.docs.isNotEmpty) {
          print("Subcoleção info existe no documento");

          // Recupera os dados da subcoleção "info" e armazena em uma variável
          var infoData = infoSnapshot.docs.first.data();

          setState(() {
            // Armazena os dados na variável ou utilize conforme necessário
            username = estabelecimentoData['username'];
            email = estabelecimentoData['emailProv'];
            Contato = estabelecimentoData['Contato'];
            imagemEst = infoData['imageEstabelecimento'];
            contatoInfo = infoData['contato'];
            fundacao = infoData['fundacao'];
            nomeInfo = infoData['nome'];
          });
        } else {
          // Subcoleção "info" está vazia
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const telaAddInfo()),
          );
          print("Subcoleção não existe no documento");
        }
      } else {
        // UID não está na coleção "estabelecimentos"
        print("O UID não está na coleção de estabelecimentos");
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

  Widget _buildUserImage() {
    if (imagemEst != null && imagemEst!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(imagemEst!),
      );
    } else {
      return const CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage('imagens/estabelecimento.png'),
      );
    }
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
                  _buildUserImage(),
                  const SizedBox(height: 14.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Text(
                      '$username',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Adicionar serviço'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const telaAddServ()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
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
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configurações"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TelaConfiguracoesEstabelecimento()));
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
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              ClipOval(
                                child: imagemEst != null
                                    ? Image.network(
                                        imagemEst!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : imgEst(), // Imagem padrão caso "imagemEst" seja nulo
                              ),
                              Positioned.fill(
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Container(
                                    width: 30.0,
                                    height: 30.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.black,
                                      ),
                                      iconSize: 15.0,
                                      onPressed: () {
                                        print(
                                            "Editar estabelecimento - UID: ${_user?.uid}");
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditarInfoEstabelecimento(
                                              userUID: _user!.uid,
                                              username: username!,
                                              email: email!,
                                              contato: Contato!,
                                              imageEst: imagemEst!,
                                              contatoInfo: contatoInfo!,
                                              nomeInfo: nomeInfo!,
                                              fundacao: fundacao!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Nome: $username',
                                    style: const TextStyle(fontSize: 16)),
                                Text(
                                  'Email: ${email != null ? (email!.length > 20 ? email!.substring(0, 20) + '...' : email) : ''}',
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

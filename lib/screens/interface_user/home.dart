// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_hist_user.dart';
import 'package:flutter_application_1/screens/interface_user/tela_estabelecimento.dart';
import 'package:flutter_application_1/screens/interface_user/favoritos.dart';
import 'package:flutter_application_1/screens/perfis/perfil_user.dart';
import 'package:flutter_application_1/screens/pesquisa/pesquisa.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import '../cad_log/cad_log_user.dart';
import '../../servicos/img_padrao.dart';
import '../pets/add_pet.dart';

class homeUser extends StatefulWidget {
  const homeUser({Key? key}) : super(key: key);

  @override
  _homeUserState createState() => _homeUserState();
}

class _homeUserState extends State<homeUser> {
  final bool _isVisible = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? nome;
  String? email;
  String? telefone;
  User? _user;
  int _currentIndex = 0;

  List<Map<String, dynamic>> _providers = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    _checkCurrentUser();
  }

  //logica para trocar as telas na barra de navegação
  void navegar(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const homeUser()),
      );
      print("Home");
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pesquisaTeste()),
      );
      print("Pesquisa");
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TelaFavoritos()),
      );
      print("Favoritos");
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const perfilUser()),
      );
      print("Perfil");
    }
  }

  void loadUserData() async {
    String? userUid = _auth.currentUser?.uid;

    if (userUid != null && mounted) {
      DocumentSnapshot userData =
          await _firestore.collection('user').doc(userUid).get();

      setState(() {
        nome = userData['nome'];
        email = userData['email'];
        telefone = userData['telefone'];
      });
    }
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
    final estabelecimentoCollection = _firestore
        .collection('estabelecimentos')
        .where('servico', isEqualTo: true);

    estabelecimentoCollection.get().then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> tempProviders = [];

        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          final informacoesReference = document.reference.collection('info');
          informacoesReference
              .get()
              .then((QuerySnapshot informacoesQuerySnapshot) {
            if (informacoesQuerySnapshot.docs.isNotEmpty) {
              // A subcoleção "info" existe neste documento de "estabelecimentos"
              for (QueryDocumentSnapshot infoDoc
                  in informacoesQuerySnapshot.docs) {
                Map<String, dynamic> data =
                    infoDoc.data() as Map<String, dynamic>;
                data['dono'] = document[
                    'dono']; // Adicionando o campo 'dono' da coleção pai
                data['UID'] =
                    document.id; // Adicionando o campo 'UID' da coleção pai
                tempProviders.add(data);
              }
            } else {
              // A subcoleção "info" não existe neste documento de "estabelecimentos"
              print('A subcoleção "info" não existe neste documento.');
            }

            setState(() {
              _providers = List.from(tempProviders);
            });
          }).catchError((error) {
            print('Erro ao consultar a subcoleção "info": $error');
          });
        }
      } else {
        print('A coleção "estabelecimentos" está vazia ou não existe.');
      }
    }).catchError((error) {
      print('Erro ao consultar a coleção "estabelecimentos": $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('HOME'),
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
                  imgUser(), // Componente para exibir a imagem do usuário
                  const SizedBox(height: 15.0),
                  Text('Nome: $nome'),
                ],
              ),
            ),
            ListTile(
              title: const Text('Add pet'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaAddPet()),
                );
              },
            ),
            ListTile(
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const perfilUser()),
                );
              },
            ),
            ListTile(
              title: const Text('Histórico'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaHistoricoUser()),
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
                  //Text('ID do usuário autenticado: ${_user!.uid}'),
                  const Text('Estabelecimentos disponíveis:'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _providers.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            final estabelecimentoId = _providers[index]['UID'];
                            // Navegue para a tela do estabelecimento com base no ID.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TelaEstabelecimento(
                                    estabelecimentoId: estabelecimentoId),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 5.0,
                            margin: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: ListTile(
                              title: Text('Nome: ${_providers[index]['nome']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Telefone: ${_providers[index]['contato']}'),
                                  Text('dono: ${_providers[index]['dono']}'),
                                ],
                              ),
                              leading: SizedBox(
                                width: 50.0,
                                height: 50.0,
                                child: _providers[index]
                                            ['imageEstabelecimento'] !=
                                        null
                                    ? ClipOval(
                                        child: Image.network(
                                          _providers[index]
                                              ['imageEstabelecimento'],
                                          alignment: Alignment.center,
                                          width: 72.0,
                                          height: 72.0,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : imgEst(), // Use imgEst aqui
                              ),
                              trailing: const Icon(Icons.more_vert),
                              isThreeLine: true,
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
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isVisible ? 60.0 : 0.0,
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 255, 251, 248),
          currentIndex: _currentIndex,
          unselectedItemColor: const Color.fromARGB(
              255, 3, 22, 50), // Cor dos itens não selecionados
          selectedItemColor: const Color(
              0xFF10428B), // Cor do item selecionado. azul mais claro Color.fromARGB(255, 44, 104, 255)
          onTap: navegar,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Pesquisa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_config.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_hist_user.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_user.dart';
import 'package:flutter_application_1/screens/interface_user/home.dart';
import 'package:flutter_application_1/screens/interface_user/perfil_user.dart';
import 'package:flutter_application_1/screens/pesquisa/pesquisa.dart';
import 'package:flutter_application_1/screens/pets/add_pet.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class TelaFavoritos extends StatefulWidget {
  @override
  _TelaFavoritosState createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  final bool _isVisible = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? nome;
  String? email;
  String? telefone;
  String? imageUser;
  String? imageEstab;
  String? ramoPrincipal;
  User? _user;
  int _currentIndex = 2;

  get cidadeSelecionada => null;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _checkCurrentUser();
  }

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

  Widget _buildUserImage() {
    if (imageUser != null && imageUser!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(imageUser!),
      );
    } else {
      // Se a imagem for nula, exibe uma imagem padrão ou qualquer outra lógica desejada.
      return const CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage('imagens/user.png'),
      );
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
        imageUser = userData['imageUser'];
      });
    }
  }

  Future<void> _checkCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
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
                  _buildUserImage(), // Usando o método para exibir a imagem do usuário
                  const SizedBox(height: 14.0),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 18.0), // avança o texto para a direita
                    child: Text(
                      '$nome',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Meu perfil"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const perfilUser()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Adicionar Pet"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaAddPet()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("Histórico"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaHistoricoUser()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rounded),
              title: const Text("Favoritos"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaFavoritos()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Deslogar'),
              onTap: () {
                print("deslogando");
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaConfig()));
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _getFavoritos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Center(
              // ignore: unnecessary_const
              child: const Text('Erro ao carregar favoritos'),
            );
          } else {
            List<Map<String, dynamic>> favoritos =
                snapshot.data as List<Map<String, dynamic>>;

            if (favoritos.isEmpty) {
              return const Center(
                child: Text('Nenhum estabelecimento favoritado.'),
              );
            }

            return Container(
              padding: const EdgeInsets.only(top: 16.0),
              child: ListView.builder(
                itemCount: favoritos.length,
                itemBuilder: (context, index) {
                  final num notaMedia = favoritos[index]['notaMedia'];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5.0,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${favoritos[index]['nome'] ?? ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                            ],
                          ),
                          StreamBuilder<Map<String, dynamic>>(
                            stream: _isFavoriteStream(favoritos[index]['UID']),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text(
                                    'Erro ao verificar favorito: ${snapshot.error}');
                              } else {
                                bool isFavorite =
                                    snapshot.data?['isFavorite'] ?? false;
                                bool isChanging =
                                    snapshot.data?['isChanging'] ?? false;

                                return IconButton(
                                  onPressed: () {
                                    _selecionarFavoritos(
                                        favoritos[index]['UID']);
                                  },
                                  icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isChanging
                                        ? Colors.grey
                                        : (isFavorite
                                            ? Colors.orange
                                            : Colors.grey),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('serv. principal:'),
                              const SizedBox(
                                width: 8,
                              ),
                              _getIconForRamo(
                                  favoritos[index]['ramoPrincipal']),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                  'serv. concluídos: ${favoritos[index]['servicosConcluidos']}'),
                              const SizedBox(
                                width: 16,
                              ),
                              RatingBarIndicator(
                                itemSize: 15,
                                rating: notaMedia.toDouble(),
                                itemBuilder: (context, index) => const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      leading: SizedBox(
                        width: 50.0,
                        height: 50.0,
                        child: favoritos[index]['imageEstab'] != null
                            ? ClipOval(
                                child: Image.network(
                                  favoritos[index]['imageEstab'],
                                  alignment: Alignment.center,
                                  width: 72.0,
                                  height: 72.0,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    AssetImage('imagens/estabelecimento.png'),
                              ),
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            );
          }
        },
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
          selectedItemColor: const Color(0xFF10428B), // Remova o 'const' aqui
          unselectedItemColor: const Color.fromARGB(255, 3, 22, 50),
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            navegar(index);
            print("valor do navegar $index");
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0
                    ? const Color(0xFF10428B)
                    : const Color.fromARGB(255, 3, 22, 50),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1
                    ? const Color(0xFF10428B)
                    : const Color.fromARGB(255, 3, 22, 50),
              ),
              label: 'Pesquisa',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: _currentIndex == 2
                    ? const Color(0xFF10428B)
                    : const Color.fromARGB(255, 3, 22, 50),
              ),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: _currentIndex == 3
                    ? const Color(0xFF10428B)
                    : const Color.fromARGB(255, 3, 22, 50),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarFavoritos(String idEstabelecimento) async {
    logger.d(_user!.uid);
    if (idEstabelecimento.isNotEmpty && _user != null) {
      final String uid = _user!.uid;
      try {
        QuerySnapshot favoritoExistente = await _firestore
            .collection('user/$uid/favoritos')
            .where("estabelecimento", isEqualTo: idEstabelecimento)
            .get();

        if (favoritoExistente.docs.isNotEmpty) {
          // O favorito já existe, então remova
          var favoritoId = favoritoExistente.docs.first.id;
          await _firestore
              .collection('user/$uid/favoritos')
              .doc(favoritoId)
              .delete();

          logger.d('Favorito removido com sucesso.');
        } else {
          await _firestore
              .collection('user/$uid/favoritos')
              .add({"estabelecimento": idEstabelecimento}).then(
                  (DocumentReference doc) {
            logger.d('Favorito adicionado com ID: $doc');
            // ignore: invalid_return_type_for_catch_error
          }).catchError((error) => logger.e(error));
        }
      } on FirebaseException catch (e) {
        logger.e(e);
      }
    }
  }

  Stream<Map<String, dynamic>> _isFavoriteStream(String estabelecimentoId) {
    if (_user == null) {
      return Stream.value({'isFavorite': false, 'isChanging': false});
    }

    final String uid = _user!.uid;

    return _firestore
        .collection('user/$uid/favoritos')
        .where(
          "estabelecimento",
          isEqualTo: estabelecimentoId,
        )
        .snapshots()
        .map((QuerySnapshot snapshot) {
      bool isFavorite = snapshot.docs.isNotEmpty;
      return {'isFavorite': isFavorite, 'isChanging': false};
    });
  }

  Future<List<Map<String, dynamic>>> _getFavoritos() async {
    User? user = _auth.currentUser;

    if (user != null) {
      String uid = user.uid;

      try {
        QuerySnapshot favoritosSnapshot =
            await _firestore.collection('user/$uid/favoritos').get();

        List<Map<String, dynamic>> favoritos = [];

        for (QueryDocumentSnapshot document in favoritosSnapshot.docs) {
          String estabelecimentoId = document['estabelecimento'];

          // Buscar documentos na subcoleção "info" para o estabelecimento
          QuerySnapshot infoSnapshot = await _firestore
              .collection('estabelecimentos/$estabelecimentoId/info')
              .get();

          if (infoSnapshot.docs.isNotEmpty) {
            DocumentSnapshot infoDoc = infoSnapshot.docs.first;

            Map<String, dynamic> favoritoData = {
              'UID': estabelecimentoId,
              'nome': infoDoc['nome'] ?? 'Nome Indisponível',
              'ramoPrincipal': infoDoc['ramoPrincipal'] ?? '',
              'servicosConcluidos': infoDoc['servicosConcluidos'] ?? 0,
              'notaMedia': infoDoc['notaMedia'] ?? 0.0,
              'imageEstab': infoDoc['imageEstabelecimento'] ?? '',
            };

            favoritos.add(favoritoData);
          } else {
            print(
                'Nenhum documento encontrado na subcoleção "info" para o estabelecimento com ID: $estabelecimentoId');
          }
        }

        return favoritos;
      } catch (e) {
        print('Erro ao obter favoritos: $e');
        return [];
      }
    } else {
      return [];
    }
  }

  Widget _getIconForRamo(String ramoPrincipal) {
    switch (ramoPrincipal) {
      case "Banho e tosa":
        return const Icon(Icons.shower, color: Colors.orange);
      case "Veterinária":
        return const Icon(Icons.medical_services, color: Colors.orange);
      case "Hotel pet":
        return const Icon(Icons.other_houses_rounded, color: Colors.orange);
      default:
        return const SizedBox();
    }
  }
}

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_config.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_hist_user.dart';
import 'package:flutter_application_1/screens/interface_user/tela_estabelecimento.dart';
import 'package:flutter_application_1/screens/interface_user/favoritos.dart';
import 'package:flutter_application_1/screens/interface_user/perfil_user.dart';
import 'package:flutter_application_1/screens/pesquisa/pesquisa.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:logger/logger.dart';
import '../cad_log/cad_log_user.dart';
import '../pets/add_pet.dart';

var logger = Logger();

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
  String? imageUser;
  String? imageEstab;
  String? ramoPrincipal;
  User? _user;
  int _currentIndex = 0;

  List<Map<String, dynamic>> _providers = [];
  List<String> cidades = <String>[
    "Americana",
    "São Paulo",
    "Campinas",
    "Santa Barbara D'Oeste",
    "Nova Odessa",
    "Santos",
    "Ribeirão Preto",
    "Limeira",
    "Sumaré",
    "São Carlos",
    "Hortolândia",
    "Monte Mor",
  ];

  String cidadeSelecionada = "Americana";

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

      // Consulta os pets do usuário com base no UID
      await _fetchProviders(user.uid);
    }
  }

  Future<void> _fetchProviders(String uid) async {
    _providers.clear();

    try {
      final estabelecimentoCollection = _firestore
          .collection('estabelecimentos')
          .where('servico', isEqualTo: true);

      QuerySnapshot estabelecimentoSnapshot =
          await estabelecimentoCollection.get();

      for (QueryDocumentSnapshot document in estabelecimentoSnapshot.docs) {
        final infoReference = document.reference
            .collection('info')
            .where("cidade", isEqualTo: cidadeSelecionada);

        QuerySnapshot infoQuerySnapshot = await infoReference.get();

        if (infoQuerySnapshot.docs.isNotEmpty) {
          setState(() {
            _providers.addAll(infoQuerySnapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;

              final nome = data['nome'] as String? ?? 'Nome Indisponível';
              final servicosConcluidos =
                  data['servicosConcluidos'] as int? ?? 0;
              final notaMedia = data['notaMedia'] as num? ?? 0.0;
              final ramoPrincipal = data['ramoPrincipal'] as String?;
              imageEstab = data['imageEstabelecimento'] as String? ?? '';

              print('Image URL: $imageEstab');
              return {
                'UID': document.id,
                'nome': nome,
                'servicosConcluidos': servicosConcluidos,
                'notaMedia': notaMedia,
                'ramoPrincipal': ramoPrincipal,
                'imageEstab': imageEstab,
              };
            }).toList());
          });
          print('A subcoleção "info" existe neste documento.');
        } else {
          _providers.clear();
          print('A subcoleção "info" não existe neste documento.');
        }
      }
    } catch (error) {
      print('Erro ao consultar estabelecimentos: $error');
    }
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

  Stream<bool> _isFavoriteStream(String estabelecimentoId) {
    if (_user == null) {
      return Stream.value(false);
    }

    final String uid = _user!.uid;

    Stream<QuerySnapshot> querySnapshots = _firestore
        .collection('user/$uid/favoritos')
        .where("estabelecimento", isEqualTo: estabelecimentoId)
        .snapshots();

    return querySnapshots.map((QuerySnapshot snapshot) {
      return snapshot.docs.isNotEmpty;
    });
  }

  Widget _getIconForRamo(String ramoPrincipal) {
    print("Valor de ramoPrincipal antes do switch case: $ramoPrincipal");
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
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  DropdownButton<String>(
                    padding: const EdgeInsets.only(bottom: 0),
                    menuMaxHeight: 272,
                    value: cidadeSelecionada,
                    items: cidades
                        .map((cidade) => DropdownMenuItem(
                              value: cidade,
                              child: Text(cidade),
                            ))
                        .toList(),
                    onChanged: (cidade) {
                      setState(() {
                        cidadeSelecionada = cidade!;
                      });
                      _fetchProviders(_user!.uid);
                    },
                  ),
                  //Text('ID do usuário autenticado: ${_user!.uid}'),
                  //const Text('Estabelecimentos disponíveis:'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _providers.length,
                      itemBuilder: (context, index) {
                        final num notaMedia = _providers[index]['notaMedia'];
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
                              title: Text(
                                '${_providers[index]['nome'] ?? ''}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('serv. principal:'),
                                      const SizedBox(
                                          width:
                                              8), // Adiciona um espaço entre o texto e o ícone
                                      _getIconForRamo(
                                          _providers[index]['ramoPrincipal']),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'serv. concluídos: ${_providers[index]['servicosConcluidos']}',
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      RatingBarIndicator(
                                        itemSize: 15,
                                        rating: notaMedia.toDouble(),
                                        itemBuilder: (context, index) =>
                                            const Icon(
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
                                child: _providers[index]['imageEstab'] != null
                                    ? ClipOval(
                                        child: Image.network(
                                          _providers[index]['imageEstab'],
                                          alignment: Alignment.center,
                                          width: 72.0,
                                          height: 72.0,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const CircleAvatar(
                                        radius: 40,
                                        backgroundImage: AssetImage(
                                            'imagens/estabelecimento.png'),
                                      ),
                              ),
                              trailing: GestureDetector(
                                onTap: () {
                                  _selecionarFavoritos(
                                      _providers[index]['UID']);
                                },
                                child: StreamBuilder<bool>(
                                  stream: _isFavoriteStream(
                                      _providers[index]['UID']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return const Icon(Icons.favorite_border,
                                          color: Colors.grey);
                                    } else {
                                      bool isFavorite = snapshot.data ?? false;

                                      return Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? const Color.fromARGB(
                                                255, 255, 168, 7)
                                            : Colors.grey,
                                      );
                                    }
                                  },
                                ),
                              ),
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

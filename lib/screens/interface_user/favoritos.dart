// ignore_for_file: body_might_complete_normally_nullable, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/interface_user/tela_estabelecimento.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var logger = Logger();

class TelaFavoritos extends StatefulWidget {
  @override
  _TelaFavoritosState createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _providers = [];

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
    }
  }

  Future<List<String>> _fetchFavoritos() async {
    List<String> favoritos = [];

    if (_user != null) {
      String uid = _user!.uid;

      try {
        // Suponha que você tenha uma coleção chamada 'favoritos' que contém os IDs dos estabelecimentos favoritos
        QuerySnapshot favoritosSnapshot =
            await _firestore.collection('usuario/$uid/favoritos').get();

        favoritosSnapshot.docs.forEach((DocumentSnapshot doc) {
          favoritos.add(doc['estabelecimento']);
        });
      } on FirebaseException catch (e) {
        print("Erro ao buscar estabelecimentos favoritos: $e");
      }
    }
    return favoritos;
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>?>
      _getEstabelecimentoStream(String uid) async {
    if (_user != null) {
      final List<String> favoritos = await _fetchFavoritos();
      uid = _user!.uid;
      if (favoritos.isNotEmpty) {
        try {
          return _firestore
              .collectionGroup('informacoes')
              .where('UID', whereIn: favoritos)
              .snapshots();
        } on FirebaseException catch (e) {
          logger.e(e.message);
        }
      }
    } else {
      return null;
    }
  }

  Future<void> _selecionarFavoritos(String idEstabelecimento) async {
    logger.d(_user!.uid);
    if (idEstabelecimento.isNotEmpty && _user != null) {
      final String uid = _user!.uid;
      try {
        QuerySnapshot favoritoExistente = await _firestore
            .collection('usuario/$uid/favoritos')
            .where("estabelecimento", isEqualTo: idEstabelecimento)
            .get();

        if (favoritoExistente.docs.isNotEmpty) {
          // O favorito já existe, então remova
          var favoritoId = favoritoExistente.docs.first.id;
          await _firestore
              .collection('usuario/$uid/favoritos')
              .doc(favoritoId)
              .delete();

          logger.d('Favorito removido com sucesso.');
        } else {
          await _firestore
              .collection('usuario/$uid/favoritos')
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
      return Stream.value(
          false); // Se o usuário não estiver autenticado, o estabelecimento não é favorito
    }

    final String uid = _user!.uid;

    Stream<QuerySnapshot> querySnapshots = _firestore
        .collection('usuario/$uid/favoritos')
        .where(
          "estabelecimento",
        )
        .snapshots();

    return querySnapshots.map((QuerySnapshot snapshot) {
      return snapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Center(
        child: FutureBuilder<Stream<QuerySnapshot<Map<String, dynamic>>>?>(
            future: _getEstabelecimentoStream(_user!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Text('Sem dados disponíveis.');
              } else {
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: snapshot.data,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Erro: ${snapshot.error}');
                    } else if (!snapshot.hasData ||
                        snapshot.data == null ||
                        snapshot.data!.docs.isEmpty) {
                      return Text('Sem dados disponíveis.');
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data!.docs[index];
                          // Aqui você pode usar os dados do documento para construir o widget desejado.
                          // Por exemplo, para acessar o valor de um campo 'nome':
                          final num notaMedia = doc['notaMedia'];

                          return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              elevation: 2.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                onTap: () {
                                  final estabelecimentoId = doc['UID'];

                                  // Navegue para a tela do estabelecimento com base no ID.
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelaEstabelecimento(
                                          estabelecimentoId: estabelecimentoId),
                                    ),
                                  );
                                },
                                title: Text('${doc['nome']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${doc['telefone']}'),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${doc['servicosConcluidos']} Serviços Concluidos',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        RatingBarIndicator(
                                          itemSize: 15,
                                          rating: notaMedia.toDouble(),
                                          itemBuilder: (context, index) =>
                                              const Icon(
                                            Icons.star_rounded,
                                            color: Colors.amber,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    doc['imageEstabelecimento'] == null
                                        ? const Icon(
                                            Icons.store,
                                            size: 36,
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(90),
                                            child: Image.network(
                                              doc['imageEstabelecimento'],
                                              width: 72,
                                              height: 72,
                                            ),
                                          ),
                                  ],
                                ),
                                trailing: StreamBuilder<bool>(
                                  stream: _isFavoriteStream(doc['UID']),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // Indicador de carregamento, se necessário
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      // Trate o erro, se ocorrer
                                      return Text(
                                          'Erro ao verificar favorito: ${snapshot.error}');
                                    } else {
                                      // Use o resultado para determinar se é um favorito
                                      bool isFavorite = snapshot.data ?? false;

                                      return IconButton(
                                        onPressed: () {
                                          _selecionarFavoritos(doc['UID']);
                                        },
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: const Color.fromARGB(
                                              255, 255, 168, 7),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                isThreeLine: true,
                              ));
                        },
                      );
                    }
                  },
                );
              }
            }),
      ),
    );
  }
}

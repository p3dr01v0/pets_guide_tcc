import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/interface_user/tela_estabelecimento.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

var logger = Logger();

class TelaInicial extends StatefulWidget {
  @override
  _TelaInicialState createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _providers = [];

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _user = user;
      });

      await _fetchProviders(user.uid);
    }
  }

  Future<void> _fetchProviders(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('estabelecimentos')
          .where('servico', isEqualTo: true)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        List<Map<String, dynamic>> providers = [];

        for (QueryDocumentSnapshot document in querySnapshot.docs) {
          final infoReference = document.reference.collection('info');
          QuerySnapshot infoQuerySnapshot = await infoReference.get();

          if (infoQuerySnapshot.docs.isNotEmpty) {
            providers.add(
                infoQuerySnapshot.docs.first.data() as Map<String, dynamic>);
          }
        }

        setState(() {
          _providers = providers;
        });
      } else {
        print('A coleção "estabelecimento" está vazia ou não existe.');
      }
    } catch (error) {
      print('Erro ao consultar a coleção "estabelecimento": $error');
    }
  }

  Future<void> _selecionarFavoritos(String? idEstabelecimento) async {
    logger.d(_user!.uid);
    if (idEstabelecimento != null &&
        idEstabelecimento.isNotEmpty &&
        _user != null) {
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

  Stream<bool> _isFavoriteStream(String? estabelecimentoId) {
    if (_user == null || estabelecimentoId == null) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () => _atualizarPagina(),
        child: Center(
          child: _user != null
              ? ListView(
                  children: [
                    Text('ID do usuário autenticado: ${_user!.uid}'),
                    const Text('Estabelecimentos disponíveis:'),
                    Column(
                      children: _providers.map((provider) {
                        final num notaMedia =
                            provider['notaMedia'] as num? ?? 0;

                        return Container(
                          height: 120, // Ajuste o valor conforme necessário
                          margin: const EdgeInsets.all(
                              8.0), // Ajuste as margens internas conforme necessário
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2.0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              onTap: () {
                                final estabelecimentoId =
                                    provider['UID'] as String?;
                                if (estabelecimentoId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TelaEstabelecimento(
                                        estabelecimentoId: estabelecimentoId,
                                      ),
                                    ),
                                  );
                                }
                              },
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text('Nome: ${provider['nome']}'),
                                  ),
                                  StreamBuilder<bool>(
                                    stream: _isFavoriteStream(
                                        provider['UID'] as String?),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else if (snapshot.hasError) {
                                        return Text(
                                          'Erro ao verificar favorito: ${snapshot.error}',
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        );
                                      } else {
                                        bool isFavorite =
                                            snapshot.data ?? false;

                                        return IconButton(
                                          onPressed: () {
                                            _selecionarFavoritos(
                                                provider['UID'] as String?);
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
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Telefone: ${provider['contato']}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          '${provider['servicosConcluidos']} Serviços Concluídos',
                                          style: const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
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
                              leading: Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    provider['imageEstabelecimento'] == null
                                        ? const Icon(
                                            Icons.store,
                                            size: 36,
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                top: 10.0),
                                            child: ClipOval(
                                              child: Image.network(
                                                provider[
                                                    'imageEstabelecimento'],
                                                width: 55,
                                                height: 55,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              isThreeLine: true,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              : const Text('Nenhum usuário autenticado'),
        ),
      ),
    );
  }

  Future<void> _atualizarPagina() async {
    await Future.delayed(const Duration(seconds: 3));
    await _fetchProviders(_user!.uid);
  }
}

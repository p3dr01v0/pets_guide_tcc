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
    // Verifique se há um usuário autenticado quando o widget é iniciado
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _user = user;
      });

      // Consulta os estabelecimentos do usuário com base no UID
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
            // A subcoleção "info" existe neste documento de "estabelecimento"
            providers.add(
                infoQuerySnapshot.docs.first.data() as Map<String, dynamic>);
            // ignore: avoid_print
            print('A subcoleção "info" existe neste documento.');
          } else {
            // A subcoleção "info" não existe neste documento de "estabelecimento"
            print('A subcoleção "info" não existe neste documento.');
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

  Stream<bool> _isFavoriteStream(String? estabelecimentoId) {
    if (_user == null || estabelecimentoId == null) {
      return Stream.value(
          false); // Se o usuário não estiver autenticado, o estabelecimento não é favorito
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

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            onTap: () {
                              final estabelecimentoId =
                                  provider['UID'] as String?;
                              // Navegue para a tela do estabelecimento com base no ID.
                              if (estabelecimentoId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TelaEstabelecimento(
                                        estabelecimentoId: estabelecimentoId),
                                  ),
                                );
                              }
                            },
                            title: Text('Nome: ${provider['nome']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Telefone: ${provider['telefone']}'),
                                const SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${provider['servicosConcluidos']} Serviços Concluídos',
                                      style: const TextStyle(fontSize: 12),
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
                                provider['imageEstabelecimento'] == null
                                    ? const Icon(
                                        Icons.store,
                                        size: 36,
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(90),
                                        child: Image.network(
                                          provider['imageEstabelecimento'],
                                          width: 72,
                                          height: 72,
                                        ),
                                      ),
                              ],
                            ),
                            trailing: StreamBuilder<bool>(
                              stream:
                                  _isFavoriteStream(provider['UID'] as String?),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Indicador de carregamento, se necessário
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  // Trate o erro, se ocorrer
                                  return Text(
                                      'Erro ao verificar favorito: ${snapshot.error}');
                                } else {
                                  // Use o resultado para determinar se é um favorito
                                  bool isFavorite = snapshot.data ?? false;

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
                            isThreeLine: true,
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';

var logger = Logger();

class TelaVerAvaliacoes extends StatefulWidget {
  final String estabelecimentoId;

  const TelaVerAvaliacoes({super.key, required this.estabelecimentoId});

  @override
  _TelaVerAvaliacoesState createState() => _TelaVerAvaliacoesState();
}

class _TelaVerAvaliacoesState extends State<TelaVerAvaliacoes> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool banhoTosa = false;
  bool veterinario = false;
  bool hotelPet = false;
  String uid = '';

  late bool isAccept;
  int i = 0;

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

  Stream<QuerySnapshot> _getScheduleStream(String uid) {
    uid = _user!.uid;
    return _firestore
        .collectionGroup('avaliacoes')
        .where('estabelecimentoId', isEqualTo: widget.estabelecimentoId)
        .orderBy('dataUtc', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: const Text('Avaliações'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  const SizedBox(height: 35),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _getScheduleStream(uid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Erro: ${snapshot.error}');
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Text('Nenhum dado disponível.');
                          }

                          final documents = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: documents.length,
                            itemBuilder: (context, index) {
                              final String comentario =
                                  documents[index]['conteudo'];
                              final String servico =
                                  documents[index]['servico'].toString();
                              final horarioEntrada =
                                  documents[index]['horarioEntrada'].toString();
                              final dataEntrada =
                                  documents[index]['dataEntrada'].toString();
                              final horarioSaida =
                                  documents[index]['horarioSaida'].toString();
                              final dataSaida =
                                  documents[index]['dataSaida'].toString();
                              final nomeUser =
                                  documents[index]['nomeUser'].toString();
                              final nota = documents[index]['nota'];
                              final String imageUser =
                                  documents[index]['imageUser'].toString();

                              // ignore: unused_local_variable
                              final idAvaliacao = documents[index]
                                  .id; // Use .id para obter o ID do documento

                              final num showNota = nota;
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 4.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16.0),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(nomeUser),
                                      RatingBarIndicator(
                                        itemSize: 18,
                                        rating: showNota.toDouble(),
                                        itemBuilder: (context, index) =>
                                            const Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber,
                                        ),
                                      )
                                    ],
                                  ),
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      imageUser.isEmpty
                                          ? const Icon(
                                              Icons.person,
                                              size: 36,
                                            )
                                          : ClipOval(
                                              child: Image.network(
                                                imageUser,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                          height:
                                              8), // Ajuste o espaçamento conforme necessário
                                      Text(servico),
                                      const SizedBox(height: 8),
                                      Text(
                                          'Check-In: $dataEntrada às $horarioEntrada'),
                                      dataSaida.isNotEmpty &&
                                              horarioSaida.isNotEmpty
                                          ? Text(
                                              'Check-Out: $dataSaida às $horarioSaida')
                                          : const SizedBox(height: 24),
                                      const SizedBox(height: 18),
                                      if (comentario.isNotEmpty)
                                        Text('Comentário:\n$comentario'),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                  ),
                ],
              )
            : const Text('Nenhum usuário autenticado'),
      ),
    );
  }
}

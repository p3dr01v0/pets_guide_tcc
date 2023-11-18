// ignore_for_file: unused_local_variable

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
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Avaliacoes'),
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

                          if (!snapshot.hasData) {
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
                              final horario =
                                  documents[index]['horario'].toString();
                              final data = documents[index]['data'].toString();
                              final nomeUser =
                                  documents[index]['nomeUser'].toString();
                              final nota = documents[index]['nota'];
                              final String imageUser =
                                  documents[index]['imageUser'].toString();

                              final idAvaliacao = documents[index]
                                  .id; // Use .id para obter o ID do documento

                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
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
                                        rating: nota,
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      imageUser.isEmpty
                                          ? const Icon(Icons.person, size: 36,)
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(90),
                                              child: Image.network(
                                                imageUser,
                                                width: 72,
                                                height: 72,
                                              ),
                                            ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      Text('$data às $horario'),
                                      const SizedBox(height: 18),
                                      if (comentario.isEmpty)
                                        const SizedBox(height: 28)
                                      else
                                        Text('comentario:\n$comentario'),
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
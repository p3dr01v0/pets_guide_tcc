import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/atividades_user/ver_avaliacoes.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:flutter_application_1/style/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class TelaAvaliacao extends StatefulWidget {
  final String estabelecimentoId;
  final String agendamentoId;

  const TelaAvaliacao(
      {super.key,
      required this.estabelecimentoId,
      required this.agendamentoId});

  @override
  TelaAvaliacaoState createState() => TelaAvaliacaoState();
}

class TelaAvaliacaoState extends State<TelaAvaliacao> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _conteudoController = TextEditingController();
  double rating = 0;

  autenticacaoServico authSvc = autenticacaoServico();

  void _submitAvaliacao() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String conteudo = _conteudoController.text;

      FirebaseFirestore db = FirebaseFirestore.instance;

      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        // listener para receber

        if (user != null) {
          print('ID de user${user.uid}');
          String uid = user.uid;
          final docUser = await db.collection('user').doc(uid).get();
          final String nomeUser = docUser['nome'];
          final imageUser = docUser['imageUser'];
          if (widget.agendamentoId.isEmpty ||
              widget.estabelecimentoId.isEmpty) {
            print(
                'Algum dos ID está faltando: Agendamento(${widget.agendamentoId}) ou Estabelecimento(${widget.estabelecimentoId})');
          } else {
            print('prosseguindo na função');
            final docAgendamento = await db
                .collection('user/$uid/agendamentos')
                .doc(widget.agendamentoId)
                .get();
            final datetimeEnt = docAgendamento['dataEntrada'];
            final horarioEnt = docAgendamento['horarioEntrada'];
            final datetimeSaida = docAgendamento['dataSaida'];
            final horarioSaida = docAgendamento['horarioSaida'];
            final agenda = docAgendamento['agenda'];
            final servico = docAgendamento['servico'];
            final dateUtc = ['dataAgendamento'];

            final avaliacao = <String, dynamic>{
              'uid': uid,
              'nomeUser': nomeUser,
              'estabelecimentoId': widget.estabelecimentoId,
              'agendamentoId': widget.agendamentoId,
              'conteudo': conteudo,
              'nota': rating,
              'dataAvaliacao': DateTime.now(),
              'servico': servico,
              'dataEntrada': datetimeEnt,
              'horarioEntrada': horarioEnt,
              'dataSaida': datetimeSaida,
              'horarioSaida': horarioSaida,
              'agenda': agenda,
              'dataUtc': dateUtc,
              'imageUser': imageUser
            };
            db
                .collection('user/$uid/avaliacoes')
                .add(avaliacao)
                .then((DocumentReference doc) {
                  print('Documento salvo com ID:${doc.id}');

                  db
                      .collection('user/$uid/agendamentos')
                      .doc(widget.agendamentoId)
                      .update({'avaliado': true});
                })
                .then((_) async {
                  logger.d('entrou na função');
                  final infoCol = await db
                      .collection(
                          'estabelecimentos/${widget.estabelecimentoId}/info')
                      .get();
                  final infoDoc = infoCol.docs.first;
                  final infoId = infoDoc.id;

                  logger.d(infoId);
                  logger.d(rating.toString());

                  var avaliacoes = infoDoc['avaliacoes'];

                  var notaAcumulada = infoDoc['notaAcumulada'];

                  logger.d(notaAcumulada);
                  logger.d(avaliacoes);
                  logger.d(rating);

                  await db
                      .collection(
                          'estabelecimentos/${widget.estabelecimentoId}/info')
                      .doc(infoId)
                      .update({
                    "avaliacoes": avaliacoes + 1,
                    "notaAcumulada": notaAcumulada + rating,
                  });
                })
                .then((_) async {
                  final infoCol = await db
                      .collection(
                          'estabelecimentos/${widget.estabelecimentoId}/info')
                      .get();
                  final infoDoc = infoCol.docs.first;
                  final infoId = infoDoc.id;

                  var avaliacoes = infoDoc['avaliacoes'];

                  var notaAcumulada = infoDoc['notaAcumulada'];

                  var notaMedia = notaAcumulada / avaliacoes;

                  await db
                      .collection(
                          'estabelecimentos/${widget.estabelecimentoId}/info')
                      .doc(infoId)
                      .update({"notaMedia": notaMedia});
                })
                // ignore: invalid_return_type_for_catch_error, avoid_print
                .catchError((error) => print(error))
                .then((_) {
                  Navigator.of(context).pop;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaVerAvaliacoes(
                            estabelecimentoId: widget.estabelecimentoId),
                      ));
                });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        leading: null,
        title: const Text('Avaliando Serviço'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              /*Text('''${widget.agendamentoId}
              ${widget.estabelecimentoId}'''),*/
              const SizedBox(height: 35),
              RatingBar(
                initialRating: 3, // Classificação inicial
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false, // Permite meias estrelas
                itemCount: 5, // Número total de estrelas
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                ratingWidget: RatingWidget(
                    full: const Icon(Icons.star_rounded, color: Colors.amber),
                    half: const Icon(Icons.star_half_rounded,
                        color: Colors.amber),
                    empty: const Icon(Icons.star_outline_rounded,
                        color: Colors.amber)),
                onRatingUpdate: (newRating) {
                  setState(() {
                    rating = newRating;
                  });
                },
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _conteudoController,
                  decoration: caixaTxt("Comentário"),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Preencha o campo de comentário";
                    }
                    return null;
                  },
                ),
              ),
              FilledButton(
                style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all(const Size(112, 18)),
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF10428B)),
                ),
                onPressed: _submitAvaliacao,
                child: const Text('Enviar'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

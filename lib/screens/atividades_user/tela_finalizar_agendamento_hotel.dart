import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_hist_user_hotel.dart';
import 'package:flutter_application_1/screens/interface_user/home.dart';
import 'package:logger/logger.dart';

var logger = Logger();

// ignore: must_be_immutable
class TelaConcluirAgendamentoHotel extends StatefulWidget {
  final String estabelecimentoId;
  final String nomeAgenda;
  final String typeService;
  final String servico;
  final String horarioEntrada;
  final String horarioSaida;
  final String dataEntrada;
  final String dataSaida;
  final DateTime dataOfcEntrada;
  final DateTime dataOfcSaida;
  final String preco;

  TelaConcluirAgendamentoHotel(
      {required this.estabelecimentoId,
      required this.nomeAgenda,
      required this.typeService,
      required this.servico,
      required this.horarioEntrada,
      required this.horarioSaida,
      required this.dataOfcEntrada,
      required this.preco,
      required this.dataEntrada,
      required this.dataSaida,
      required this.dataOfcSaida});

  @override
  _TelaFinalizarAgendamentoState createState() =>
      _TelaFinalizarAgendamentoState();
}

class _TelaFinalizarAgendamentoState
    extends State<TelaConcluirAgendamentoHotel> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  String teste = '';
  String? selectedPet;
  int duracao = 0;

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
    duracao = calcularDuracao(widget.dataOfcSaida, widget.dataOfcEntrada);
  }

  void _submitAgendamento() async {
    String uid;

    FirebaseFirestore db = FirebaseFirestore.instance;

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      // listener para receber

      if (user != null && widget.estabelecimentoId.isNotEmpty) {
        logger.d('ID de user${user.uid}');
        uid = user.uid;

        final userDoc = await db.collection('user').doc(uid).get();
        final petDoc =
            await db.collection('user/$uid/pets').doc(selectedPet).get();

        String userName = userDoc['nome'];
        String petName = petDoc['nome'];
        String petImage = petDoc['imagePet'];
        String petAge = petDoc['idade'];
        String petRace = petDoc['raca'];
        final agendamento = <String, dynamic>{
          "estabelecimentoId": widget.estabelecimentoId,
          "UID": uid,
          "isAccept": false,
          "status": 0,
          "horarioEntrada": widget.horarioEntrada,
          "horarioSaida": widget.horarioSaida,
          "dataEntrada": widget.dataEntrada,
          "dataSaida": widget.dataSaida,
          "dataOfcEntrada": widget.dataOfcEntrada,
          "dataOfcSaida": widget.dataOfcSaida,
          "dataAgendamento": DateTime.now(),
          "servico": widget.servico,
          "petId": selectedPet,
          "agenda": widget.nomeAgenda,
          "typeService": widget.typeService,
          "userName": userName,
          "petName": petName,
          "petImage": petImage,
          "petAge": petAge,
          "petRace": petRace
        };

// Add a new document with a generated ID with image

        db
            .collection(
                "estabelecimentos/${widget.estabelecimentoId}/${widget.typeService}/${widget.nomeAgenda}/agendamentosHotelPet")
            .add(agendamento)
            .then((DocumentReference doc) {
          db
              .collection("user/$uid/agendamentosHotelPet")
              .doc(doc.id)
              .set(agendamento);
          logger.d('DocumentSnapshot added with ID: ${doc.id}');
        }).then((_) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const homeUser()),
              (route) => false);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaHistoricoUserHotel(),
              ));
          // ignore: invalid_return_type_for_catch_error
        }).catchError((error) => logger.d(error));
      }
    });
  }

  int calcularDuracao(DateTime data1, DateTime data2) {
    Duration difference = data1.difference(data2);
    int daysDifference = difference.inDays;
    return daysDifference;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
        appBar: AppBar(
          title: const Text('Finalizar Agendamento'),
          backgroundColor: const Color(0xFF10428B),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: _user != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 70),
                          const Text(
                            "Última checagem de condições \nantes de agendar",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 30),
                          DefaultTextStyle.merge(
                            style: const TextStyle(fontSize: 15),
                            child: Column(
                              children: [
                                Text(widget.servico),
                                Text(
                                    "check-In: ${widget.dataEntrada} às ${widget.horarioEntrada}"),
                                Text(
                                    "check_Out: ${widget.dataSaida} às ${widget.horarioSaida}"),
                                const SizedBox(
                                  height: 32,
                                ),
                                Text(
                                  "valor Final: ${widget.preco} x $duracao",
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 15,
                                )
                              ],
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('user/${_user!.uid}/pets')
                                .snapshots(), // Stream dos horários disponíveis
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Erro: ${snapshot.error}');
                              } else if (!snapshot.hasData) {
                                return const Text('Nenhum dado encontrado.');
                              } else {
                                final pets = snapshot.data!.docs;

                                List<DropdownMenuItem<String>> dropdownItems =
                                    [];
                                for (var pet in pets) {
                                  final petData =
                                      pet.data() as Map<String, dynamic>;
                                  final id = pet.id;
                                  final petName = petData['nome'] as String;

                                  dropdownItems.add(
                                    DropdownMenuItem(
                                      value: id,
                                      child: Text(petName),
                                    ),
                                  );
                                }

                                return DropdownButton(
                                    value: selectedPet,
                                    items: dropdownItems,
                                    onChanged: (newValue) {
                                      setState(() {
                                        selectedPet = newValue;
                                      });
                                    });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _submitAgendamento,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                              fixedSize: MaterialStateProperty.all<Size>(
                                  const Size(250.0, 40.0)),
                            ),
                            child: const Text('Finalizar',
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    )
                  : const Text('Nenhum usuário cadastrado')),
        ));
  }
}

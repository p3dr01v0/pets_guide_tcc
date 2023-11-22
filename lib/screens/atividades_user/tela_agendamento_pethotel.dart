import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_finalizar_agendamento_hotel.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class TelaAgendamentoPetHotel extends StatefulWidget {
  final String estabelecimentoId;
  final String typeService;
  final String nomeAgenda;

  const TelaAgendamentoPetHotel(
      {super.key,
      required this.estabelecimentoId,
      required this.typeService,
      required this.nomeAgenda});

  @override
  // ignore: library_private_types_in_public_api
  _TelaAgendamentoPetHotelState createState() =>
      _TelaAgendamentoPetHotelState();
}

class _TelaAgendamentoPetHotelState extends State<TelaAgendamentoPetHotel> {
//instaciamentos do firebase (firestore e autentication)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//Var para guardar dados de usuario, para checagem e comunicação com o firestore
  User? _user;

//Inicialização de var que serão utilizadas
  bool banhoTosa = false;
  String horario1 = '';
  String horario2 = '';
  String servico = '';
  List<dynamic> diasFuncionamento = [];

  String typeService = '';
  String nomeAgenda = '';
  String estabelecimentoId = '';

  String desc = '';
  String preco = '';

//variáveis para debug e mensagens de erro
  String teste = '';
  String teste2 = '';

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
        getDiasFuncionamento();
      }
    });
  }

  void getDiasFuncionamento() async {
    if (_user != null) {
      // ignore: unused_local_variable
      final String uid = _user!.uid;

      final doc = await _firestore
          .collection(
              'estabelecimentos/${widget.estabelecimentoId}/${widget.typeService}')
          .doc(widget.nomeAgenda)
          .get();

      if (doc.exists) {
        setState(() {
          diasFuncionamento = doc['diasFuncionamento'];
        });
        print(diasFuncionamento);
      }
    } else {}
  }

//variavel para receber data
  DateTime _dateTime1 = DateTime.now().subtract(Duration(
    hours: DateTime.now().hour,
    minutes: DateTime.now().minute,
    seconds: DateTime.now().second,
    milliseconds: DateTime.now().millisecond,
    microseconds: DateTime.now().microsecond,
  ));

  DateTime _dateTime2 = DateTime.now().subtract(Duration(
    hours: DateTime.now().hour,
    minutes: DateTime.now().minute,
    seconds: DateTime.now().second,
    milliseconds: DateTime.now().millisecond,
    microseconds: DateTime.now().microsecond,
  ));
  String showDateEntrada =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
  String showDateSaida =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

//método paga pegar data
  void _showDatePickerEntrada() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDatePickerMode: DatePickerMode.day,
      selectableDayPredicate: (day) {
        return diasFuncionamento[day.weekday - 1];
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _dateTime1 = value;
          showDateEntrada =
              '${_dateTime1.day}/${_dateTime1.month}/${_dateTime1.year}';
          horario1 = '';
        });
      }
    });
  }

  void _showDatePickerSaida() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      initialDatePickerMode: DatePickerMode.day,
      selectableDayPredicate: (day) {
        return diasFuncionamento[day.weekday - 1];
      },
    ).then((value) {
      if (value != null) {
        setState(() {
          _dateTime2 = value;
          showDateSaida =
              '${_dateTime2.day}/${_dateTime2.month}/${_dateTime2.year}';
          horario2 = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: const Text('Tela Realizar Agendamento'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Center(
        child: Column(
          children: [
            Text(widget.nomeAgenda),
            Text(widget.typeService),
            Text(widget.estabelecimentoId),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  style:
                      OutlinedButton.styleFrom(fixedSize: const Size(190, 32)),
                  onPressed: _showDatePickerEntrada,
                  child: const Text('Escolher data de entrada'),
                ),
                Text(showDateEntrada, style: const TextStyle(fontSize: 16)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  style:
                      OutlinedButton.styleFrom(fixedSize: const Size(190, 32)),
                  onPressed: _showDatePickerSaida,
                  child: const Text('Escolher data de sáida'),
                ),
                Text(showDateSaida, style: const TextStyle(fontSize: 16)),
              ],
            ),
            StreamBuilder<List<String>>(
              // LISTA DE HORARIOS 1
              stream:
                  fetchTimeFromFirestore(), // Stream dos horários disponíveis
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum dado encontrado.');
                } else {
                  List<String> data = snapshot.data!;
                  horario1 == ''
                      ? horario1 = data[0]
                      : teste = 'Erro desconhecido em time';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Horario de Check-In'),
                      const SizedBox(
                        width: 12,
                      ),
                      DropdownButton<String>(
                        value: horario1, // Valor selecionado
                        items: data.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            horario1 = newValue!;
                          });
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            StreamBuilder<List<String>>(
              // LISTA DE HORARIOS 2
              stream:
                  fetchTimeFromFirestore(), // Stream dos horários disponíveis
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum dado encontrado.');
                } else {
                  List<String> data = snapshot.data!;
                  horario2 == ''
                      ? horario2 = data[0]
                      : teste = 'Erro desconhecido em time';
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Horário de check-Out'),
                      const SizedBox(
                        width: 12,
                      ),
                      DropdownButton<String>(
                        value: horario2, // Valor selecionado
                        items: data.map((item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            horario2 = newValue!;
                          });
                        },
                      ),
                    ],
                  );
                }
              },
            ),
            StreamBuilder<List<String>>(
              stream: fetchServicesFromFirestore(), // Stream dos serviços
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhum dado encontrado.');
                } else {
                  List<String> data = snapshot.data!;
                  servico == ''
                      ? servico = data[0]
                      : teste2 = 'Erro desconhecido em svc';

                  return DropdownButton<String>(
                    value: servico, // Valor selecionado
                    items: data.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        servico = newValue!;
                        logger.d(servico);
                      });
                      _fetchServiceInfo();
                    },
                  );
                }
              },
            ),
            FilledButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TelaConcluirAgendamentoHotel(
                              estabelecimentoId: estabelecimentoId,
                              nomeAgenda: nomeAgenda,
                              typeService: typeService,
                              servico: servico,
                              horarioEntrada: horario1,
                              horarioSaida: horario2,
                              dataEntrada: showDateEntrada,
                              dataSaida: showDateSaida,
                              dataOfcEntrada: _dateTime1,
                              dataOfcSaida: _dateTime2,
                              preco: preco)));
                },
                child: const Text('Solicitar Agendamento')),
            const SizedBox(height: 30),
            Text(
              "Valor:  R\$$preco ",
              style: const TextStyle(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Text(
                textAlign: TextAlign.center,
                desc,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Stream<List<String>> fetchTimeFromFirestore() {
    typeService = widget.typeService;
    nomeAgenda = widget.nomeAgenda;

    if (_user != null) {
      String estabelecimentoId = widget.estabelecimentoId;
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('estabelecimentos/$estabelecimentoId/$typeService')
          .where('nomeAgenda', isEqualTo: nomeAgenda)
          .snapshots()
          .asyncMap((querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final List<dynamic> firestoreList = doc['horarios'] ?? [];
          List<String> timesList = firestoreList.cast<String>().toList();

          return timesList;
        } else {
          return [];
        }
      });
    } else {
      return Stream.value([]);
    }
  }

  Stream<List<String>> fetchServicesFromFirestore() {
    typeService = widget.typeService;
    nomeAgenda = widget.nomeAgenda;

    if (_user != null) {
      String estabelecimentoId = widget.estabelecimentoId;
      final firestore = FirebaseFirestore.instance;
      return firestore
          .collection('estabelecimentos/$estabelecimentoId/$typeService')
          .where('nomeAgenda', isEqualTo: nomeAgenda)
          .snapshots()
          .map((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final List<dynamic> firestoreList = doc['servicos'] ?? [];
          List<String> servicesList = firestoreList.cast<String>().toList();

          return servicesList;
        } else {
          return [];
        }
      });
    } else {
      return Stream.value([]);
    }
  }

  Future<void> _fetchServiceInfo() async {
    estabelecimentoId = widget.estabelecimentoId;
    typeService = widget.typeService;

    logger.d('$typeService, $estabelecimentoId, função chamada, $servico');

    QuerySnapshot infoQuerySnapshot = await _firestore
        .collection('estabelecimentos/$estabelecimentoId/$typeService')
        .where('nomeServico', isEqualTo: servico)
        .get();

    if (infoQuerySnapshot.docs.isNotEmpty) {
      logger.d('consulta bem sucedida');

      final doc = infoQuerySnapshot.docs.first;

      if (mounted) {
        setState(() {
          desc = doc['observacoes'];
          preco = doc['preco'];
        });
      }
    }
  }
}

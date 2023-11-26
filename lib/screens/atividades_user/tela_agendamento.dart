import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_finalizar_agendamento_hotel.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class TelaAgendamento extends StatefulWidget {
  final String estabelecimentoId;
  final String typeService;
  final String nomeAgenda;

  const TelaAgendamento(
      {super.key,
      required this.estabelecimentoId,
      required this.typeService,
      required this.nomeAgenda});

  @override
  // ignore: library_private_types_in_public_api
  _TelaAgendamento createState() => _TelaAgendamento();
}

class _TelaAgendamento extends State<TelaAgendamento> {
//instaciamentos do firebase (firestore e autentication)
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//Var para guardar dados de usuario, para checagem e comunicação com o firestore
  User? _user;

//Inicialização de var que serão utilizadas
  bool banhoTosa = false;
  String horario = '';
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
      setState(() {
        _user = user;
      });
      getDiasFuncionamento();
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
  DateTime _dateTime = DateTime.now();
  String showDate =
      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';

//método paga pegar data
  Future<void> _showDatePicker() async {
    DateTime currentDate = DateTime.now();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: currentDate,
      lastDate: currentDate.add(const Duration(days: 30)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF10428B), // Cor da data selecionada
            hintColor: const Color(0xFF10428B), // Cor do seletor
            colorScheme: const ColorScheme.light(primary: Color(0xFF10428B)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && diasFuncionamento[pickedDate.weekday - 1]) {
      setState(() {
        _dateTime = pickedDate;
        showDate = '${_dateTime.day}/${_dateTime.month}/${_dateTime.year}';
        horario = '';
      });
    }
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
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _showDatePicker,
                  child: const Text('Escolher data',
                      style: TextStyle(color: Colors.orange)),
                ),
                Text(showDate, style: const TextStyle(fontSize: 16)),
              ],
            ),
            StreamBuilder<List<String>>(
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
                  horario == ''
                      ? horario = data[0]
                      : teste = 'Erro desconhecido em time';
                  return DropdownButton<String>(
                    value: horario, // Valor selecionado
                    items: data.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        horario = newValue!;
                      });
                    },
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
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF10428B)),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TelaConcluirAgendamentoHotel(
                              estabelecimentoId: estabelecimentoId,
                              nomeAgenda: nomeAgenda,
                              typeService: typeService,
                              servico: servico,
                              horarioEntrada: horario,
                              dataEntrada: showDate,
                              dataOfcEntrada: _dateTime,
                              dataSaida: '',
                              horarioSaida: '',
                              dataOfcSaida: _dateTime,
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

          final agendamentosCollection = firestore.collection(
              'estabelecimentos/$estabelecimentoId/$typeService/$nomeAgenda/agendamentos');

          // Consulta o Firestore para obter os agendamentos na data selecionada

          final timeQuerySnapshot = await agendamentosCollection
              .where('data', isEqualTo: showDate)
              .where('isAccept',
                  isEqualTo: true) // Considera apenas agendamentos aceitos
              .get();

          // Cria uma lista de horários que já foram agendados e aceitos
          final horariosAgendados = timeQuerySnapshot.docs
              .map((doc) => doc['horario'] as String)
              .toList();

          // Cria uma lista de horários que já foram agendados e aceitos

          timesList = timesList
              .where((horario) => !horariosAgendados.contains(horario))
              .toList();

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

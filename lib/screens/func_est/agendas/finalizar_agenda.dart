// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/style/style.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class TelaFinalizarAgendamento extends StatefulWidget {
  final List<bool> diasFuncionamento;
  final List<String> horarios;
  final String typeService;
  final List<String> selectedServices;

  const TelaFinalizarAgendamento(
      {super.key,
      required this.diasFuncionamento,
      required this.horarios,
      required this.typeService,
      required this.selectedServices});

  @override
  _TelaFinalizarAgendamentoState createState() =>
      _TelaFinalizarAgendamentoState();
}

class _TelaFinalizarAgendamentoState extends State<TelaFinalizarAgendamento> {
  final _formKey = GlobalKey<FormState>();
  List<String> selectedServices = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool banhoTosa = false;
  late Query<Map<String, dynamic>> servicesQuery =
      FirebaseFirestore.instance.collection('estabelecimentos');
  late String repetido = '';

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  List<String> nomesDias = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  final TextEditingController _nomeAgendaController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      logger.i('caraio');

      String nomeAgenda = _nomeAgendaController.text;

      FirebaseFirestore db = FirebaseFirestore.instance;

      final isRepeat = await FirebaseFirestore.instance
          .collection('estabelecimentos/${_user!.uid}/${widget.typeService}')
          .doc(nomeAgenda)
          .get();

      if (isRepeat.exists) {
        setState(() {
          repetido = 'Já existe uma agenda com esse nome';
        });
      } else {
        setState(() {
          repetido = '';
        });
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          // listener para receber

          if (user != null) {
            print('ID de usuario${user.uid}');

            if (_user!.uid.isNotEmpty) {
              final modelAgenda = <String, dynamic>{
                "nomeAgenda": nomeAgenda,
                "servicos": widget.selectedServices,
                "horarios": widget.horarios,
                "diasFuncionamento": widget.diasFuncionamento
              }; // Informações do Estabelecimento
              db
                  .collection(
                      "estabelecimentos/${_user!.uid}/${widget.typeService}")
                  .doc(nomeAgenda)
                  .set(modelAgenda)
                  .then((_) => logger.d(
                      'DocumentSnapshot added with ID: $nomeAgenda modelAgenda'))
                  .then((value) => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const RoteadorTelaEstabelecimento())))
                  .catchError((error) => logger.d(error));
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
        appBar: AppBar(
          title: const Text('Criação de agenda'),
          backgroundColor: const Color(0xFF10428B),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _user != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                alignment: Alignment.topCenter,
                                width: 125,
                                height: 200, // Defina a altura desejada
                                child: Column(
                                  children: [
                                    const Text(
                                      'Funcionamento:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    for (int i = 0; i < 7; i++)
                                      if (widget.diasFuncionamento[i])
                                        SizedBox(
                                          height: 24,
                                          child: Text(
                                            nomesDias[i],
                                            style: const TextStyle(),
                                          ),
                                        )
                                  ],
                                ),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                width: 125,
                                height: 200, // Defina a altura desejada
                                child: Column(
                                  children: [
                                    const Text(
                                      'Horários:',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (widget.horarios.isNotEmpty)
                                      Expanded(
                                        child: GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing:
                                                20.0, // Ajuste conforme necessário
                                            mainAxisSpacing:
                                                1.0, // Ajuste conforme necessário
                                          ),
                                          itemCount: widget.horarios.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return Text(widget.horarios[index]);
                                          },
                                        ),
                                      )
                                    else
                                      const Text('Nenhum horário gerado.'),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const Text('Nenhum Usuário cadastrado'),
                    const SizedBox(height: 16.0),
                    const Divider(
                      thickness: 1.0,
                      indent: 45,
                      endIndent: 45,
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      '''Serviços selecionados
                      ''',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    if (widget.selectedServices.isNotEmpty)
                      Column(
                          children: widget.selectedServices.map((servicos) {
                        return Text(servicos);
                      }).toList()),
                    const SizedBox(
                      height: 16,
                    ),
                    const Divider(
                      thickness: 1.0,
                      indent: 45,
                      endIndent: 45,
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical:
                              10.0), // Adicione margem vertical conforme necessário
                      width: 300.0,
                      height: 45.0, // Defina a largura desejada
                      child: TextFormField(
                        controller: _nomeAgendaController,
                        decoration: caixaTxt("Nome da agenda"),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Digite o nome da sua agenda';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10428B),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            fixedSize: const Size(200, 32)),
                        onPressed: _submit,
                        child: const Text(
                          'Salvar Agenda',
                          style: TextStyle(color: Colors.white),
                        )),
                    Text(repetido),
                  ],
                )),
          ),
        ));
  }
}

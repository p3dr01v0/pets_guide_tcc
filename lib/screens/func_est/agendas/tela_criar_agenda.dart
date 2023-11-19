import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/agendas/finalizar_agenda.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaCriarAgenda extends StatefulWidget {
  final List<bool> diasFuncionamento;
  final List<String> horarios;
  final String typeService;

  TelaCriarAgenda(
      {required this.diasFuncionamento,
      required this.horarios,
      required this.typeService});

  @override
  _TelaCriarAgendaState createState() => _TelaCriarAgendaState();
}

class _TelaCriarAgendaState extends State<TelaCriarAgenda> {
  List<String> selectedServices = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool banhoTosa = false;
  late List<bool> diasFuncionamento;
  late List<String> horarios;
  late Query<Map<String, dynamic>> servicesQuery =
      FirebaseFirestore.instance.collection('estabelecimentos');

  @override
  void initState() {
    super.initState();
    diasFuncionamento = widget.diasFuncionamento;
    horarios = widget.horarios;
    _auth.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
      if (_user != null) {
        _fetchServices(_user!.uid);
      }
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

  Map<String, bool> checkboxValues = {};

  void _fetchServices(String uid) {
    if (uid.isNotEmpty) {
      setState(() {
        servicesQuery = _firestore
            .collection('estabelecimentos/${_user!.uid}/${widget.typeService}')
            .where('nomeServico', isNull: false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 243, 236),
        appBar: AppBar(
          title: const Text('Criação de agenda'),
          backgroundColor: const Color(0xFF10428B),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
                alignment: Alignment.topCenter,
                width: 400,
                height: 200,
                child: StreamBuilder<QuerySnapshot>(
                  stream: servicesQuery
                      .snapshots(), // Use servicesQuery em vez de servicesCollection
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final services = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service =
                            services[index].data() as Map<String, dynamic>;
                        final serviceName =
                            service['nomeServico'] as String? ?? '';

                        return ListTile(
                          title: Text(serviceName),
                          trailing: Checkbox(
                            checkColor: Colors.white, // Cor do ícone de seleção
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors
                                      .orange; // Cor de fundo quando selecionado
                                } else {
                                  return Colors
                                      .transparent; // Sem cor de fundo quando não selecionado
                                }
                              },
                            ),
                            value: checkboxValues[serviceName] ?? false,
                            onChanged: (bool? newValue) {
                              setState(() {
                                checkboxValues[serviceName] = newValue!;
                                if (newValue == true) {
                                  selectedServices.add(serviceName);
                                } else {
                                  selectedServices.remove(serviceName);
                                }
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10428B),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      fixedSize: const Size(200, 32)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TelaFinalizarAgendamento(
                                  diasFuncionamento: widget.diasFuncionamento,
                                  horarios: widget.horarios,
                                  selectedServices: selectedServices,
                                  typeService: widget.typeService,
                                )));
                  },
                  child: const Text(
                    'Avançar',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ));
  }
}

// ignore_for_file: avoid_print, unnecessary_brace_in_string_interps

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/style/btn_cadastro.dart';
import 'package:flutter_application_1/style/drop_down.dart';
import 'package:flutter_application_1/style/style.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';

class telaAddServ extends StatefulWidget {
  const telaAddServ({Key? key}) : super(key: key);

  @override
  _telaAddServState createState() => _telaAddServState();
}

class _telaAddServState extends State<telaAddServ> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseStorage storage = FirebaseStorage.instance;

  final TextEditingController _duracaoController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  autenticacaoServico authSvc = autenticacaoServico();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String tipo = radioValue;
      String servico = selectedOption!;
      String duracao = _duracaoController.text;
      String preco = _precoController.text;
      String observacoes = _observacoesController.text;

      String UID;
      FirebaseFirestore db = FirebaseFirestore.instance;

      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        // listener para receber

        if (user != null) {
          print('ID de usuario${user.uid}');
          UID = user.uid;

          final queryInfo =
              await db.collection('estabelecimentos/$UID/info').get();
          final infoId = queryInfo.docs.first.id;

          if (tipo == 'Veterinário') {
            final vet = <String, dynamic>{
              "nomeServico": servico,
              "duracao": duracao,
              "preco": preco,
              "observacoes": observacoes,
            }; // Informações do Estabelecimento
            db
                .collection("estabelecimentos/$UID/veterinario")
                .doc(servico)
                .set(vet)
                .then((_) => print(
                    'DocumentSnapshot added with ID: ${servico} General Info'))
                .then((_) {
                  final isService = <String, dynamic>{"servico": true};
                  db.collection('estabelecimentos').doc(UID).update(isService);
                  db
                      .collection('estabelecimentos/$UID/info')
                      .doc(infoId)
                      .update({'vet': true});
                })
                .then((value) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const RoteadorTelaEstabelecimento())))
                .catchError((error) => print(error));
          }
          if (tipo == 'Banho e Tosa') {
            final banho = <String, dynamic>{
              "nomeServico": servico,
              "duracao": duracao,
              "preco": preco,
              "observacoes": observacoes,
            }; // Informações do Estabelecimento
            db
                .collection("estabelecimentos/$UID/banhoETosa")
                .doc(servico)
                .set(banho)
                .then((_) => print(
                    'DocumentSnapshot added with ID: ${servico} General Info'))
                .then((_) {
                  final isService = <String, dynamic>{"servico": true};
                  db.collection('estabelecimentos').doc(UID).update(isService);
                  db
                      .collection('estabelecimentos/$UID/info')
                      .doc(infoId)
                      .update({'banhoTosa': true});
                })
                .then((value) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const RoteadorTelaEstabelecimento())))
                .catchError((error) => print(error));
          }
          if (tipo == 'Hotel Pet') {
            final hotelPet = <String, dynamic>{
              "nomeServico": servico,
              "duracao": duracao,
              "preco": preco,
              "observacoes": observacoes,
            }; // Informações do Estabelecimento
            db
                .collection("estabelecimentos/$UID/hotelPet")
                .doc(servico)
                .set(hotelPet)
                .then((_) => print(
                    'DocumentSnapshot added with ID: ${servico} General Info'))
                .then((_) {
                  final isService = <String, dynamic>{"servico": true};
                  db.collection('estabelecimentos').doc(UID).update(isService);
                  db
                      .collection('estabelecimentos/$UID/info')
                      .doc(infoId)
                      .update({'hotelPet': true});
                })
                .then((value) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const RoteadorTelaEstabelecimento())))
                .catchError((error) => print(error));
          }
        }
      });
    }
  }

  String radioValue = '';
  String? selectedOption = 'Selecione um tipo de Serviço';

  Map<String, List<String>> dropdownOptions = {
    'Veterinário': [
      'Exame de Rotina',
      'Consulta Veterinária',
      'Cardiologia Veterinária',
      'Dermatologia Veterinária',
      'Endocrinologia Veterinária',
      'Gastroenterologia Veterinária',
      'Ortopedia Veterinária',
      'Oftalmologia Veterinária',
      'Oncologia Veterinária',
      'Nefrologia Veterinária',
      'Nutrição Veterinária',
      'Neurologia Veterinária'
    ],
    'Banho e Tosa': [
      'Banho',
      'Banho e tosa higiênica',
      'Banho e tosa na máquina',
      'Banho e tosa na tesoura',
      'Banho e tosa da raça',
    ],
    'Hotel Pet': [
      'Hospedagem comum',
      'Hospedagem com banho incluso',
      'Hospedagem com Alimentação Nutricional'
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        leading: null,
        title: const Text('Adicionar serviço'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Image.asset(
                  'imagens/logo.png',
                  width: 150,
                  height: 150,
                ),
                const Text(
                  "PET'S GUIDE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10428B),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Column(
                  children: [
                    dropStyle.sizedDropdownContainer(
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: radioValue.isNotEmpty ? radioValue : null,
                          hint: const Text('Selecione um tipo de Serviço'),
                          onChanged: (String? value) {
                            setState(() {
                              radioValue = value!;
                              selectedOption = null;
                            });
                          },
                          items: dropdownOptions.keys.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    if (radioValue.isNotEmpty)
                      dropStyle.sizedDropdownContainer(
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedOption,
                            hint: const Text('Selecione um serviço'),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedOption = newValue!;
                              });
                            },
                            items: dropdownOptions[radioValue]!
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _duracaoController,
                    decoration: caixaTxt('Duração Média em horas'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _precoController,
                    decoration: caixaTxt('Preço'),
                    keyboardType: const TextInputType.numberWithOptions(),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo Obrigatório';
                      }

                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _observacoesController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: caixaTxt('Observações'),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: btnPersonalizado(
                    onPressed: () async {
                      _submit();
                    },
                    text: 'Adicionar serviço',
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/pets/cat.dart';
import '../../style/sty_alt.dart';
import '../../style/btn_cadastro.dart';

class editarCat extends StatefulWidget {
  final String petId;
  final String nome;
  final String raca;
  final String idade;
  final String peso;
  final String observacoes;

  editarCat({
    required this.petId,
    required this.nome,
    required this.raca,
    required this.idade,
    required this.peso,
    required this.observacoes,
  });

  @override
  _editarCatState createState() => _editarCatState();
}

class _editarCatState extends State<editarCat> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _racaController;
  late TextEditingController _idadeController;
  late TextEditingController _pesoController;
  late TextEditingController _observacoesController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nome);
    _racaController = TextEditingController(text: widget.raca);
    _idadeController = TextEditingController(text: widget.idade);
    _pesoController = TextEditingController(text: widget.peso);
    _observacoesController = TextEditingController(text: widget.observacoes);
  }

  void alterarCat() async {
    String novoNome = _nomeController.text;
    String novaRaca = _racaController.text;
    String novaIdade = _idadeController.text;
    String novoPeso = _pesoController.text;
    String novasObservacoes = _observacoesController.text;

    if (novoNome.isNotEmpty && novaRaca.isNotEmpty && novaIdade.isNotEmpty && novoPeso.isNotEmpty && novasObservacoes.isNotEmpty) {
      String? userUid = _auth.currentUser?.uid;

      if (userUid != null && mounted) {
        _firestore.collection('user').doc(userUid).collection('pets').doc(widget.petId).update({
          'nome': novoNome,
          'raca': novaRaca,
          'idade': novaIdade,
          'peso': novoPeso,
          'observacoes': novasObservacoes,
        }).then((value) {
          print('Alterações salvas com sucesso.');
        Navigator.pop(context); // Fecha a tela atual
        Navigator.pushReplacement(
          context,
          // ignore: prefer_const_constructors
          MaterialPageRoute(builder: (context) => InfoGatos()),
        );
        }).catchError((error) {
          print('Erro ao salvar alterações: $error');
        });
      }
    } else {
      print('Por favor, preencha todos os campos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Alterar Gato'),
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _nomeController,
                    decoration: caixaTxt('Nome', widget.nome),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _racaController,
                    decoration: caixaTxt('Raça', widget.raca),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _idadeController,
                    decoration: caixaTxt('Idade', widget.idade),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _pesoController,
                    decoration: caixaTxt('Peso', "${widget.peso}kg"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _observacoesController,
                    decoration: caixaTxt('Observações', widget.observacoes),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: btnPersonalizado(
                    onPressed: alterarCat,
                    text: 'Salvar Alterações',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

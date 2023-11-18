// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/style/btn_cadastro.dart';
import 'package:flutter_application_1/style/btn_img.dart';
import 'package:flutter_application_1/style/checkbox.dart';
import 'package:flutter_application_1/style/style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
//import 'package:google_fonts/google_fonts.dart';

class telaAddInfo extends StatefulWidget {
  const telaAddInfo({super.key});

  @override
  _telaAddInfo createState() => _telaAddInfo();
}

class _telaAddInfo extends State<telaAddInfo> {
  bool atendimentoVeterinario = false;
  bool banhoETosa = false;
  bool hotelPet = false;
  final _formKey = GlobalKey<FormState>();

  final FirebaseStorage storage = FirebaseStorage.instance;
  String? imageUrl;
  XFile? _selectedImage; // Armazena a imagem selecionada

  Future<XFile?> getImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _selectedImage = image;
    });

    return image;
  }

  Future<void> _upload() async {
    if (_selectedImage == null) {
      // Caso o usuário não tenha selecionado uma imagem, você pode tratar isso aqui.
      print('Nenhuma imagem selecionada.');
      return;
    }

    try {
      File file = File(_selectedImage!.path);
      String ref = 'images/img-${DateTime.now().toString()}.jpg';
      // ignore: unused_local_variable
      UploadTask task = storage.ref(ref).putFile(file);

      await storage.ref(ref).putFile(file);
      imageUrl = await storage.ref(ref).getDownloadURL();
      print("Upload de imagem concluído. URL da imagem:$imageUrl");
    } on FirebaseException catch (e) {
      print('Erro no upload de imagem: ${e.code}');
    }
  }

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _ruaController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _dataFundacaoController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();

  autenticacaoServico authSvc = autenticacaoServico();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String UID;

      String nome = _nomeController.text;
      String telefone = _telefoneController.text;
      String rua = _ruaController.text;
      String bairro = _bairroController.text;
      String cidade = _cidadeController.text;
      String estado = _estadoController.text;
      String numero = _numeroController.text;
      String data = _dataFundacaoController.text;
      String cep = _cepController.text;

      DateTime now = DateTime.now();
      DateTime dataAtual = DateTime(now.year, now.month, now.day);

      FirebaseFirestore db = FirebaseFirestore.instance;

      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        // listener para receber

        if (user != null) {
          print('a coleção sera criada no usuario: ${user.uid}');
          UID = user.uid;

          final localizacao = <String, dynamic>{
            "rua": rua,
            "bairro": bairro,
            "cidade": cidade,
            "estado": estado,
            "numero": numero,
            "cep": cep
          }; // Informações de endereço
          db
              .collection("estabelecimentos")
              .doc(UID)
              .collection("localizacao")
              .add(localizacao)
              .then((_) =>
                  print('documento da localização adicionado com sucesso'))
              .catchError((error) => print(error));

          if (imageUrl != null) {
            final infoEstabelecimento = <String, dynamic>{
              "nome": nome,
              "imageEstabelecimento": imageUrl,
              "contato": telefone,
              "fundacao": data,
              "dataCadastro": dataAtual,
              "servicosConcluidos": 0,
              "notaMedia": 0,
              "notaAcumulada": 0,
              "avaliacoes": 0
            }; // Informações do Estabelecimento
            db
                .collection("estabelecimentos")
                .doc(UID)
                .collection("info")
                .add(infoEstabelecimento)
                .then((_) =>
                    print('Documento das informações adicionado com sucesso'))
                .then((value) => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const RoteadorTelaEstabelecimento())))
                .catchError((error) => print(error));
          } else {
            final infoEstabelecimento = <String, dynamic>{
              "nome": nome,
              "imageEstabelecimento": "imagens/estabelecimento.png",
              "contato": telefone,
              "fundacao": data,
              "dataCadastro": dataAtual,
              "servicosConcluidos": 0,
              "notaMedia": 0,
              "notaAcumulada": 0,
              "avaliacoes": 0
            }; // Informações do Estabelecimento
            db
                .collection("estabelecimentos")
                .doc(UID)
                .collection("info")
                .add(infoEstabelecimento)
                .then((_) =>
                    print('Documento das informações adicionado com sucesso'))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        leading: null,
        title: const Text('Criar Estabelecimento'),
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
                    const Text(
                      "quais serviços seu estabelecimento atende",
                      style: TextStyle(
                        fontSize: 17,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    CustomCheckbox(
                      text: 'Atendimento Veterinario',
                      value: atendimentoVeterinario,
                      onChanged: (newValue) {
                        setState(() {
                          atendimentoVeterinario = newValue!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomCheckbox(
                      text: 'Banho e Tosa',
                      value: banhoETosa,
                      onChanged: (newValue) {
                        setState(() {
                          banhoETosa = newValue!;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    CustomCheckbox(
                      text: 'Hotel Pet',
                      value: hotelPet,
                      onChanged: (newValue) {
                        setState(() {
                          hotelPet = newValue!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _nomeController,
                    decoration: caixaTxt('Nome do estabelecimento'),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Digite o nome do seu Estabelecimento';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _telefoneController,
                    decoration: caixaTxt('Telefone'),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Digite seu telefone corretamente';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _dataFundacaoController,
                    decoration: caixaTxt('Data da fundação'),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),

                /*const Row(
                  children: [Text('Localização')],
                ),*/
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _estadoController,
                    decoration: caixaTxt('Estado'),
                    keyboardType: TextInputType.name,
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
                    controller: _cidadeController,
                    decoration: caixaTxt('Cidade'),
                    keyboardType: TextInputType.name,
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
                    controller: _cepController,
                    decoration: caixaTxt('CEP'),
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
                    controller: _bairroController,
                    decoration: caixaTxt('Bairro'),
                    keyboardType: TextInputType.name,
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
                    controller: _ruaController,
                    decoration: caixaTxt('Rua'),
                    keyboardType: TextInputType.name,
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
                    controller: _numeroController,
                    decoration: caixaTxt('Número'),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Campo Obrigatório';
                      }
                      return null;
                    },
                  ),
                ),
                if (_selectedImage != null)
                  Image.file(File(_selectedImage!.path)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: btnImg(
                    onPressed: () {
                      getImage();
                    },
                    text: 'Selecionar Imagem',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: btnPersonalizado(
                    onPressed: () async {
                      await _upload();
                      _submit();
                    },
                    text: ('Salvar informações'),
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

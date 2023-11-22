// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/screens/perfis/perfil_user.dart';
import 'package:image_picker/image_picker.dart';
import '../../style/sty_alt.dart';
import '../../style/btn_cadastro.dart';
import '../../style/btn_img.dart';

class editarInfoUser extends StatefulWidget {
  final String userUID;
  final String user;
  final String email;
  final String telefone;
  final String imageUser;

  editarInfoUser({
    required this.userUID,
    required this.user,
    required this.email,
    required this.telefone,
    required this.imageUser,
  });

  @override
  _editarInfoUserState createState() => _editarInfoUserState();
}

class _editarInfoUserState extends State<editarInfoUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _userController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;

  XFile? _selectedImage;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(text: widget.user);
    _emailController = TextEditingController(text: widget.email);
    _telefoneController = TextEditingController(text: widget.telefone);
  }

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
      print('Nenhuma imagem selecionada.');
      return;
    }

    try {
      File file = File(_selectedImage!.path);
      String ref = 'images/img-${DateTime.now().toString()}.jpg';
      await storage.ref(ref).putFile(file);
      imageUrl = await storage.ref(ref).getDownloadURL();
      print("Upload de imagem concluído. URL da imagem: $imageUrl");
    } on FirebaseException catch (e) {
      print('Erro no upload de imagem: ${e.code}');
    }
  }

  void alterarUser() async {
    String novoUser = _userController.text;
    // ignore: unused_local_variable
    String novoEmail = _emailController.text;
    String novoTelefone = _telefoneController.text;

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Atualizar e-mail na autenticação do Firebase
        // await user.updateEmail(novoEmail);
      }

      String? userUid = _auth.currentUser?.uid;

      if (userUid != null && mounted) {
        // Atualizar dados no Firestore
        await _firestore.collection('user').doc(userUid).update({
          'nome': novoUser.isNotEmpty ? novoUser : widget.user,
          // 'email': novoEmail.isNotEmpty ? novoEmail : widget.email,
          'telefone': novoTelefone.isNotEmpty ? novoTelefone : widget.telefone,
          'imageUser': imageUrl ?? widget.imageUser,
        });

        print('Alterações salvas com sucesso.');
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const perfilUser()),
        );
      }
    } catch (e) {
      print('Erro ao salvar alterações: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Alterar informações'),
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
                    controller: _userController,
                    decoration: caixaTxt('Nome', widget.user),
                  ),
                ),
                /*Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: caixaTxt('Email', widget.email),
                  ),
                ),*/
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _telefoneController,
                    decoration: caixaTxt('Telefone', widget.telefone),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      btnImg(
                        onPressed: () {
                          getImage();
                        },
                        text: 'Selecionar Imagem',
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: btnPersonalizado(
                    onPressed: () async {
                      await _upload();
                      alterarUser();
                    },
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

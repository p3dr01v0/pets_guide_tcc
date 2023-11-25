// ignore_for_file: unused_field

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//simport 'package:image_picker/image_picker.dart';

class EditarInfoEstabelecimento extends StatefulWidget {
  final String userUID;
  final String username;
  final String email;
  final String contato;
  final String imageEst;
  final String contatoInfo;
  final String nomeInfo;
  final String fundacao;

  const EditarInfoEstabelecimento({
    required this.userUID,
    required this.username,
    required this.email,
    required this.contato,
    required this.imageEst,
    required this.contatoInfo,
    required this.nomeInfo,
    required this.fundacao,
  });

  @override
  _EditarInfoEstabelecimentoState createState() =>
      _EditarInfoEstabelecimentoState();
}

class _EditarInfoEstabelecimentoState extends State<EditarInfoEstabelecimento> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _contatoController = TextEditingController();
  final TextEditingController _fundacaoController = TextEditingController();
  String? _novaImagemEstabelecimento;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadEstData();
  }

  void _loadEstData() async {
    String? userUid = widget.userUID;

    // ignore: unnecessary_null_comparison
    if (userUid != null && mounted) {
      var estabelecimentoDoc =
          await _firestore.collection('estabelecimentos').doc(userUid).get();

      if (estabelecimentoDoc.exists) {
        var estabelecimentoData = estabelecimentoDoc;

        var infoCollection =
            _firestore.collection('estabelecimentos/$userUid/info');
        var infoSnapshot = await infoCollection.get();

        if (infoSnapshot.docs.isNotEmpty) {
          var infoData = infoSnapshot.docs.first.data();

          setState(() {
            _nomeController.text = estabelecimentoData['username'] ?? '';
            _contatoController.text = estabelecimentoData['Contato'] ?? '';
            _fundacaoController.text = infoData['fundacao'] ?? '';
          });
        }
      }
    }
  }

  /* Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _novaImagemEstabelecimento = pickedFile.path;
      });
    }
  }*/

  Future<void> _uploadImage() async {
    if (_novaImagemEstabelecimento == null) {
      print('Nenhuma imagem selecionada.');
      return;
    }

    try {
      File file = File(_novaImagemEstabelecimento!);

      // Substitua 'images/' por seu caminho específico no Firebase Storage
      String ref = 'images/img-${DateTime.now().toString()}.jpg';

      // Substitua 'your-storage-bucket-name' pelo nome do seu bucket no Firebase Storage
      await FirebaseStorage.instance.ref(ref).putFile(file);

      String imageUrl =
          await FirebaseStorage.instance.ref(ref).getDownloadURL();

      print("Upload de imagem concluído. URL da imagem: $imageUrl");

      // Agora você pode salvar a URL da imagem no Firestore ou onde for necessário
    } catch (e) {
      print('Erro no upload de imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Informações'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _contatoController,
              decoration: const InputDecoration(labelText: 'Contato'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _fundacaoController,
              decoration: const InputDecoration(labelText: 'Fundação'),
            ),
            const SizedBox(height: 16.0),
            /*ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Escolher Nova Imagem'),
            ),*/
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Upload de Imagem'),
            ),
            const SizedBox(height: 16.0),
            // Não exibe a imagem aqui
          ],
        ),
      ),
    );
  }
}

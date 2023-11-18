import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_hist_user.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_user.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:flutter_application_1/servicos/img_padrao.dart';
import '../perfis/perfil_user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../style/btn_cadastro.dart';
import '../../style/btn_img.dart';
import '../../style/btn_drop.dart';
import '../../style/style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: Scaffold(
      body: TelaAddPet(),
    ),
  ));
}

class TelaAddPet extends StatefulWidget {
  const TelaAddPet({Key? key});
  @override
  _TelaAddPet createState() => _TelaAddPet();
}

class _TelaAddPet extends State<TelaAddPet> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseStorage storage = FirebaseStorage.instance;
  String? imageUrl;
  XFile? _selectedImage; 
  
  // Armazena a imagem selecionada

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
      print("Upload de imagem concluído. URL da imagem:$imageUrl");
    } on FirebaseException catch (e) {
      print('Erro no upload de imagem: ${e.code}');
    }
  }

  final TextEditingController _nomePetController = TextEditingController();
  final TextEditingController _racaPetController = TextEditingController();
  final TextEditingController _idadePetController = TextEditingController();
  final TextEditingController _pesoPetController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();

  autenticacaoServico autenServico = autenticacaoServico();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? nome;

void _adicionarPet() async {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        String UID = user.uid;

        String nome = _nomePetController.text;
        String raca = _racaPetController.text;
        String idade = _idadePetController.text;
        String peso = _pesoPetController.text;
        String observacoes = _observacoesController.text;

        final pet = <String, dynamic>{
          "UID": UID,
          "tipo": selectedType,
          "nome": nome,
          "raca": raca,
          "idade": idade,
          "peso": peso,
          "sexo": selectedSex!,
          "porte": selectedSize!,
          "observacoes": observacoes,
          "imagePet": imageUrl,
        };

        await FirebaseFirestore.instance
            .collection("user")
            .doc(UID)
            .collection("pets")
            .add(pet)
            .then((DocumentReference doc) =>
                print('DocumentSnapshot added with ID: ${doc.id} with image'))
            .catchError((error) => print(error));

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const perfilUser()),
          );
        }
      }
    } catch (e) {
      print("Erro ao adicionar pet: $e");
    }
  }
}



  void loadUserData() async {
    String? userUid = _auth.currentUser?.uid;

    if (userUid != null && mounted) {
      DocumentSnapshot userData =
          await _firestore.collection('user').doc(userUid).get();

      setState(() {
        nome = userData['nome'];
      });
    }
  }
   List<String> dogSizes = ['Pequeno', 'Médio', 'Grande'];
  List<String> petTypes = ['Cachorro', 'Gato'];

  String? selectedType = 'Cachorro';
  String? selectedSex = 'Macho';
  String? selectedSize = 'Pequeno';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Adicionar Pet'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 34, 96, 190),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imgUser(),
                  const SizedBox(height: 15.0),
                  Text('Nome: $nome'),
                ],
              ),
            ),
            ListTile(
              title: const Text('Add pet'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaAddPet()),
                );
              },
            ),
            ListTile(
              title: const Text('Perfil'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const perfilUser()),
                );
              },
            ),
            ListTile(
              title: const Text('Histórico'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaHistoricoUser()),
                );
              },
            ),
            ListTile(
              title: const Text('Deslogar'),
              onTap: () {
                autenticacaoServico().deslogar();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AutentiacacaoTela()),
                );
              },
            ),
          ],
        ),
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
                Row(
                  children: petTypes.map((String type) {
                    return Expanded(
                      child: RadioListTile<String>(
                        title: Text(type),
                        value: type,
                        groupValue: selectedType,
                        onChanged: (String? value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: btnDrop(selectedSize!, dogSizes, (String? newValue) {
                          setState(() {
                            selectedSize = newValue!;
                          });
                        }),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: btnDrop(selectedSex!, ['Macho', 'Fêmea'], (String? newValue) {
                          setState(() {
                            selectedSex = newValue!;
                          });
                        }),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _nomePetController,
                    decoration: caixaTxt("Nome"),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Digite o nome do seu Pet';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _racaPetController,
                    decoration: caixaTxt("Raça"),
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Digite a raça do seu Pet';
                      }
                      return null;
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _idadePetController,
                          decoration: caixaTxt("Idade"),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Digite apenas números';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _pesoPetController,
                          decoration: caixaTxt("Peso"),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Digite apenas números';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    maxLines: 4,
                    controller: _observacoesController,
                    decoration: caixaTxt("Observações"),
                    keyboardType: TextInputType.text,
                  ),
                ),
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
                      _adicionarPet();
                    },
                    text: ('Cadastrar Pet'),
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

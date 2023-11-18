import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/interface_user/favoritos.dart';
import 'package:flutter_application_1/screens/interface_user/home.dart';
import 'package:flutter_application_1/screens/pesquisa/pesquisa.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import '../cad_log/cad_log_user.dart';
import '../pets/dog.dart';
import '../pets/cat.dart';
import '../../servicos/img_padrao.dart';
import '../pets/add_pet.dart';
import '../../style/btn_pet.dart';

class perfilUser extends StatefulWidget {
  const perfilUser({Key? key}) : super(key: key);

  @override
  _perfilUserState createState() => _perfilUserState();
}

class _perfilUserState extends State<perfilUser> {
  final bool _isVisible = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? nome;
  String? email;
  String? telefone;

  int _currentIndex = 0;

//logica para trocar as telas na barra de navegação
  void navegar(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const homeUser()),
      );
      print("Home");
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => pesquisaTeste()),
      );
      print("Pesquisa");
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  const telaFavoritos()),
      );
      print("Favoritos");
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const perfilUser()),
      );
      print("Perfil");
    }
  }
//fim da logica

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    String? userUid = _auth.currentUser?.uid;

    if (userUid != null && mounted) {
      DocumentSnapshot userData =
          await _firestore.collection('user').doc(userUid).get();

      setState(() {
        nome = userData['nome'];
        email = userData['email'];
        telefone = userData['telefone'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEAD9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Perfil do Usuário'),
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
                  imgUser(), // Componente para exibir a imagem do usuário
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
        child: Column(
          children: [
            Card(
              elevation: 5.0,
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Ajuste o valor conforme necessário
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Alinhe verticalmente ao centro
                  children: [
                    imgUser(), // Componente para exibir a imagem do usuário
                    const SizedBox(width: 16.0), // Espaçamento entre a imagem e os textos
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // Alinhe verticalmente ao centro
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nome: $nome', style: const TextStyle(fontSize: 16)),
                          Text('Email: $email', style: const TextStyle(fontSize: 16)),
                          Text('Telefone: $telefone', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InfoCachorros()),
                    );
                  },
                  style: btnPet.imageButtonStyle,
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: btnPet.imageBoxDecoration('imagens/cachorro.png'),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Cachorros",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InfoGatos()),
                    );
                  },
                  style: btnPet.imageButtonStyle,
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: btnPet.imageBoxDecoration('imagens/gato.png'),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Gatos",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      //barra de navegação inferior
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isVisible ? 60.0 : 0.0,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF10428B),
            currentIndex: _currentIndex,
            unselectedItemColor: const Color.fromARGB(255, 3, 22, 50), // Cor dos itens não selecionados
            selectedItemColor: const Color.fromARGB(255, 255, 255, 255), // Cor do item selecionado. azul mais claro Color.fromARGB(255, 44, 104, 255)
            onTap: navegar,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Pesquisa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favoritos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        //fim da barra de navegação inferior

        ),
    );
  }
}
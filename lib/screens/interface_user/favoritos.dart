import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_hist_user.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_user.dart';
import 'package:flutter_application_1/screens/interface_user/home.dart';
import 'package:flutter_application_1/screens/perfis/perfil_user.dart';
import 'package:flutter_application_1/screens/pesquisa/pesquisa.dart';
import 'package:flutter_application_1/screens/pets/add_pet.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:flutter_application_1/servicos/img_padrao.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Flutter Stateful Clicker Counter';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const telaFavoritos(),
    );
  }
}

class telaFavoritos extends StatefulWidget {
  const telaFavoritos({super.key});
  @override
  _telaFavoritosState createState() => _telaFavoritosState();
}

class _telaFavoritosState extends State<telaFavoritos> {
  final bool _isVisible = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? nome;
  String? email;
  String? telefone;
  int _currentIndex = 0;



  @override
  void initState() {
    super.initState();
    loadUserData();
  }

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
        MaterialPageRoute(builder: (context) => const telaFavoritos()),
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
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Favoritos'),
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              'legal',
              style: TextStyle(fontSize: 25),
            ),
          ],
        ),
      ),
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
            backgroundColor: const Color.fromARGB(255, 255, 251, 248),
            currentIndex: _currentIndex,
            unselectedItemColor: const Color.fromARGB(255, 3, 22, 50), // Cor dos itens não selecionados
            selectedItemColor: const Color(0xFF10428B), // Cor do item selecionado. azul mais claro Color.fromARGB(255, 44, 104, 255)
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
      ),
    );
  }
}
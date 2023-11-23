// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/interface_user/favoritos.dart';
import 'package:flutter_application_1/screens/interface_user/home.dart';
import 'package:flutter_application_1/screens/interface_user/perfil_user.dart';
import 'package:flutter_application_1/screens/pesquisa/pesquisa.dart';
import 'package:flutter_application_1/screens/pets/add_pet.dart';
import 'package:flutter_application_1/screens/pets/alterar_cat.dart';

class InfoGatos extends StatefulWidget {
  const InfoGatos({Key? key}) : super(key: key);

  @override
  _InfoGatosState createState() => _InfoGatosState();
}

class _InfoGatosState extends State<InfoGatos> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> gatos = [];

  @override
  void initState() {
    super.initState();
    pegarDados();
  }

  // logica para trocar as telas na barra de navegação
  final bool _isVisible = true;
  int _currentIndex = 0;

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
        MaterialPageRoute(builder: (context) => TelaFavoritos()),
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

  void pegarDados() async {
    String? userUid = _auth.currentUser?.uid;

    if (userUid != null && mounted) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('user')
          .doc(userUid)
          .collection('pets')
          .where('tipo', isEqualTo: 'Gato')
          .get();

      setState(() {
        gatos = querySnapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'nome': data['nome'] ?? 'N/A',
            'idade': data['idade'] ?? 'N/A',
            'raca': data['raca'] ?? 'N/A',
            'peso': data['peso'] ?? 'N/A',
            'porte': data['porte'] ?? 'N/A',
            'sexo': data['sexo'] ?? 'N/A',
            'observacoes': data['observacoes'] ?? 'N/A',
            'image': data['imagePet'] ?? '',
          };
        }).toList();
      });
    }
  }

  void editarPet(String petId, String nome, String raca, String idade,
      String peso, String observacoes) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => editarCat(
          petId: petId,
          nome: nome,
          raca: raca,
          idade: idade,
          peso: peso,
          observacoes: observacoes,
        ),
      ),
    );

    // Atualizar a lista após a edição
    pegarDados();
  }

  void excluirCat(String petId) {
    String? userUid = _auth.currentUser?.uid;
    if (userUid != null) {
      _firestore
          .collection('user')
          .doc(userUid)
          .collection('pets')
          .doc(petId)
          .delete()
          .then((value) {
        print('Pet excluído com sucesso.');
        pegarDados();
      }).catchError((error) {
        print('Erro ao excluir pet: $error');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Seus gatos'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: gatos.map((gato) {
            return Card(
              elevation: 5.0,
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                height: 220, // Ajuste a altura conforme necessário
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        child: ClipOval(
                          child: gato['image'] != ''
                              ? Image.network(
                                  gato['image'],
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'imagens/gato.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nome: ${gato['nome']}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      iconSize: 24,
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        editarPet(
                                          gato['id'],
                                          gato['nome'],
                                          gato['raca'],
                                          gato['idade'],
                                          gato['peso'],
                                          gato['observacoes'],
                                        );
                                      },
                                    ),
                                    IconButton(
                                      iconSize: 24,
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        excluirCat(gato['id']);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text('Raça: ${gato['raca']}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Porte: ${gato['porte']}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Sexo: ${gato['sexo']}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Idade: ${gato['idade']}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Peso: ${gato['peso']}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Observações: ${gato['observacoes']}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaAddPet()),
          );
        },
        backgroundColor: const Color(0xFF10428B),
        child: const Icon(
          Icons.add,
          color: Colors.white,
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
          unselectedItemColor: const Color.fromARGB(255, 3, 22, 50),
          selectedItemColor: const Color(0xFF10428B),
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

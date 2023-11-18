// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/interface_user/favoritos.dart';
import 'package:flutter_application_1/screens/interface_user/home.dart';
import 'package:flutter_application_1/screens/perfis/perfil_user.dart';
import 'package:flutter_application_1/screens/pesquisa/pesquisa.dart';
import 'package:flutter_application_1/screens/pets/alterar_dog.dart';

import 'add_pet.dart';

class InfoCachorros extends StatefulWidget {
  const InfoCachorros({Key? key}) : super(key: key);

  @override
  _InfoCachorrosState createState() => _InfoCachorrosState();
}

class _InfoCachorrosState extends State<InfoCachorros> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> cachorros = [];

  //logica para trocar as telas na barra de navegação
  final bool _isVisible = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    pegarDados();
  }
    
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

void pegarDados() async {
  String? userUid = _auth.currentUser?.uid;

  if (userUid != null && mounted) {
    QuerySnapshot querySnapshot = await _firestore
        .collection('user')
        .doc(userUid)
        .collection('pets') // Alteração para 'pets' em vez de 'cachorros'
        .get();

    setState(() {
      cachorros = querySnapshot.docs
          .where((doc) => doc['tipo'] == 'Cachorro') // Filtro por tipo 'cachorro'
          .map((doc) {
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
          'tipo': data['tipo'] ?? 'N/A', // Adicionado campo 'tipo'
        };
      }).toList();
    });
  }
}

  void editarPet(String petId, String nome, String raca, String idade, String peso, String observacoes) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarPet(
          petId: petId,
          nome: nome,
          raca: raca,
          idade: idade,
          peso: peso,
          observacoes: observacoes,
        ),
      ),
    );
  }

void excluirDog(String petId) {
  String? userUid = _auth.currentUser?.uid;

  if (userUid != null) {
    _firestore
        .collection('user')
        .doc(userUid)
        .collection('pets') // Subcoleção 'pets' em vez de 'cachorros'
        .doc(petId)
        .delete()
        .then((value) {
        print('Pet excluído com sucesso.');
        pegarDados();
        })
        .catchError((error) {
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
        title: const Text('Seus cachorros'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: cachorros.map((cachorro) {
            return Card(
              elevation: 5.0,
              margin: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      child: ClipOval(
                        child: cachorro['image'] != ''
                          ? Image.network(cachorro['image'], fit: BoxFit.cover) // Use a imagem do URL se estiver disponível
                          : Image.asset('imagens/cachorro.png', fit: BoxFit.cover), // Use a imagem local padrão se o URL estiver vazio
                      ),
                    ),
                    const SizedBox(width: 16), // Espaçamento entre a imagem e os detalhes do cachorro
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nome: ${cachorro['nome']}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Raça: ${cachorro['raca']}', style: const TextStyle(fontSize: 16)),
                          Text('Porte: ${cachorro['porte']}', style: const TextStyle(fontSize: 16)),
                          Text('Sexo: ${cachorro['sexo']}', style: const TextStyle(fontSize: 16)),
                          Text('Idade: ${cachorro['idade']}', style: const TextStyle(fontSize: 16)),
                          Text('Peso: ${cachorro['peso']}', style: const TextStyle(fontSize: 16)),
                          Text('Observações: ${cachorro['observacoes']}', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          iconSize: 24,
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            editarPet(cachorro['id'], cachorro['nome'], cachorro['raca'], cachorro['idade'], cachorro['peso'], cachorro['observacoes']);
                          },
                        ),
                        IconButton(
                          iconSize: 24,
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            excluirDog(cachorro['id']);

                          },
                        ),
                      ],
                    ),
                  ],
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
          MaterialPageRoute(builder: (context) => const TelaAddPet())
        );
      },
      child: const Icon(Icons.add),
      backgroundColor: const Color(0xFF10428B),
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

//sistema de pesquisa funcional
// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_config.dart';
import 'package:flutter_application_1/screens/atividades_user/tela_hist_user.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_user.dart';
import 'package:flutter_application_1/screens/interface_user/favoritos.dart';
import 'package:flutter_application_1/screens/interface_user/home.dart';
import 'package:flutter_application_1/screens/interface_user/perfil_user.dart';
import 'package:flutter_application_1/screens/interface_user/tela_estabelecimento.dart';
import 'package:flutter_application_1/screens/pets/add_pet.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:flutter_application_1/style/card_pesquisa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(pesquisaTeste());
}

class pesquisaTeste extends StatefulWidget {
  @override
  _pesquisaTesteState createState() => _pesquisaTesteState();
}

class _pesquisaTesteState extends State<pesquisaTeste> {
  final bool _isVisible = true;
  bool pesquisa = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _buscacontrole = TextEditingController();

  List<Map<String, dynamic>> _filteredProviders = [];

  String searchStatus = '';
  String? nome;
  String? email;
  String? telefone;
  String? imageUser;

  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    loadUserData();
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

  Widget _buildUserImage() {
    if (imageUser != null && imageUser!.isNotEmpty) {
      return CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(imageUser!),
      );
    } else {
      // Se a imagem for nula, exibe uma imagem padrão ou qualquer outra lógica desejada.
      return const CircleAvatar(
        radius: 40,
        backgroundImage: AssetImage('imagens/user.png'),
      );
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
        imageUser = userData['imageUser'];
      });
    }
  }

  List<Widget> resultadoBuscaNome = [];

  Future<void> buscaNome(String query) async {
    print("Chamando buscaNome com query: $query");
    List<Map<String, dynamic>> nomeList = [];

    // Chame seu próprio método para recuperar os dados de provedores
    List<Map<String, dynamic>> providersData = await getProvidersData();

    for (var provider in providersData) {
      if (provider['username'] != null &&
          provider['username']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())) {
        nomeList.add(provider);
      }
    }

    setState(() {
      _filteredProviders = List.from(nomeList);
      resultadoBuscaNome =
          _filteredProviders.map((provider) => cardNome(provider)).toList();
      print("Lista de provedores filtrada: $_filteredProviders");
      if (query.isEmpty) {
        searchStatus = '';
      } else if (nomeList.isEmpty) {
        searchStatus = 'Nenhum resultado encontrado.';
      } else {
        searchStatus = 'Resultados encontrados: ${nomeList.length}';
      }
    });
  }

  Future<List<Map<String, dynamic>>> getProvidersData() async {
    List<Map<String, dynamic>> providersData = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('estabelecimentos').get();

      print("Tamanho da consulta de estabelecimentos: ${querySnapshot.size}");

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Acessando a subcoleção 'info' e obtendo os dados necessários
        QuerySnapshot infoQuerySnapshot =
            await doc.reference.collection('info').get();

        if (infoQuerySnapshot.size > 0) {
          for (QueryDocumentSnapshot infoDoc in infoQuerySnapshot.docs) {
            Map<String, dynamic> infoData =
                infoDoc.data() as Map<String, dynamic>;

            data['nomeEstabelecimento'] = infoData['nome'];
            data['imageEstabelecimento'] = infoData['imageEstabelecimento'];

            providersData.add(data);
          }
        } else {
          print(
              "A subcoleção de informações está vazia para o documento ${doc.id}");
        }
      }
    } catch (e) {
      print('Erro ao recuperar os dados dos provedores: $e');
    }

    print("Tamanho dos dados de provedores: ${providersData.length}");

    return providersData;
  }

  Widget cardNome(Map<String, dynamic> provider) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        onTap: () {
          // Adicione aqui a navegação ou ação desejada quando o card for tocado
          print('Provedor ${provider['UID']} tocado!');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaEstabelecimento(
                estabelecimentoId: provider['UID'],
              ),
            ),
          );
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration:
              CardStyle.circleDecoration(provider['imageEstabelecimento']),
        ),
        title: Text(provider['username'] ?? 'Nome do Provedor'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${provider['emailProv'] ?? 'Não disponível'}"),
            Text("Contato: ${provider['Contato'] ?? 'Não disponível'}"),
          ],
        ),
      ),
    );
  }

  List<Widget> resultadoBanhoETosa = [];
  List<Widget> resultadoHotelPet = [];
  List<Widget> resultadoVeterinario = [];
  List<Map<String, dynamic>> _filteredServicos = [];

  Future<List<Map<String, dynamic>>> getServicosData() async {
    List<Map<String, dynamic>> servicosData = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('estabelecimentos').get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        QuerySnapshot subQuerySnapshotBanhoETosa =
            await doc.reference.collection('banhoETosa').get();
        for (QueryDocumentSnapshot subDoc in subQuerySnapshotBanhoETosa.docs) {
          Map<String, dynamic>? data = subDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            data['subcolecao'] = 'banhoETosa';
            QuerySnapshot infoQuerySnapshot =
                await doc.reference.collection('info').get();
            for (QueryDocumentSnapshot infoDoc in infoQuerySnapshot.docs) {
              Map<String, dynamic> infoData =
                  infoDoc.data() as Map<String, dynamic>;
              data['nomeEstabelecimento'] = infoData['nome'];
              data['imageEstabelecimento'] = infoData['imageEstabelecimento'];
              servicosData.add(data);
            }
          }
        }

        QuerySnapshot subQuerySnapshotHotelPet =
            await doc.reference.collection('hotelPet').get();
        for (QueryDocumentSnapshot subDoc in subQuerySnapshotHotelPet.docs) {
          Map<String, dynamic>? data = subDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            data['subcolecao'] = 'hotelPet';
            QuerySnapshot infoQuerySnapshot =
                await doc.reference.collection('info').get();
            for (QueryDocumentSnapshot infoDoc in infoQuerySnapshot.docs) {
              Map<String, dynamic> infoData =
                  infoDoc.data() as Map<String, dynamic>;
              data['nomeEstabelecimento'] = infoData['nome'];
              data['imageEstabelecimento'] = infoData['imageEstabelecimento'];
              servicosData.add(data);
            }
          }
        }

        QuerySnapshot subQuerySnapshotVeterinario =
            await doc.reference.collection('veterinario').get();
        for (QueryDocumentSnapshot subDoc in subQuerySnapshotVeterinario.docs) {
          Map<String, dynamic>? data = subDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            data['subcolecao'] = 'veterinario';
            QuerySnapshot infoQuerySnapshot =
                await doc.reference.collection('info').get();
            for (QueryDocumentSnapshot infoDoc in infoQuerySnapshot.docs) {
              Map<String, dynamic> infoData =
                  infoDoc.data() as Map<String, dynamic>;
              data['nomeEstabelecimento'] = infoData['nome'];
              data['imageEstabelecimento'] = infoData['imageEstabelecimento'];
              servicosData.add(data);
            }
          }
        }
      }
    } catch (e) {
      print('Erro ao recuperar os dados de serviços: $e');
    }

    return servicosData;
  }

  Future<void> buscaServico(String query) async {
    print("Chamando buscaServico com query: $query");
    List<Map<String, dynamic>> servicosList = [];

    List<Map<String, dynamic>> servicosData = await getServicosData();

    for (var servico in servicosData) {
      if (servico['nomeServico'] != null &&
          servico['nomeServico']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase())) {
        DocumentSnapshot infoSnapshot = await FirebaseFirestore.instance
            .collection('estabelecimentos')
            .doc(servico['doc_id'])
            .collection('info')
            .doc('info_doc_id')
            .get();

        if (infoSnapshot.exists) {
          Map<String, dynamic> infoData =
              infoSnapshot.data() as Map<String, dynamic>;
          servico['nomeEstabelecimento'] = infoData['nome'];
          servico['imageEstabelecimento'] = infoData['imageEstabelecimento'];
        }

        servicosList.add(servico);
      }
    }

    setState(() {
      _filteredServicos = List.from(servicosList);
      resultadoBuscaNome =
          _filteredServicos.map((servico) => cardServico(servico)).toList();
      resultadoBanhoETosa = _filteredServicos
          .where((servico) => servico['subcolecao'] == 'banhoETosa')
          .map((servico) => cardBanhoETosa(servico))
          .toList();
      resultadoHotelPet = _filteredServicos
          .where((servico) => servico['subcolecao'] == 'hotelPet')
          .map((servico) => cardHotelPet(servico))
          .toList();
      resultadoVeterinario = _filteredServicos
          .where((servico) => servico['subcolecao'] == 'veterinario')
          .map((servico) => cardVeterinario(servico))
          .toList();
      print("Lista de serviços filtrada: $_filteredServicos");
      if (query.isEmpty) {
        searchStatus = '';
      } else if (servicosList.isEmpty) {
        searchStatus = 'Nenhum resultado encontrado.';
      } else {
        searchStatus = 'Resultados encontrados: ${servicosList.length}';
      }
    });
  }

  Future<List<String>> getEstabelecimentoUIDs() async {
    List<String> estabelecimentoUIDs = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('estabelecimentos').get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        estabelecimentoUIDs.add(doc.id);
      }
    } catch (e) {
      print('Erro ao recuperar os UIDs dos estabelecimentos: $e');
    }

    return estabelecimentoUIDs;
  }

  Widget cardServico(Map<String, dynamic> servico) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        onTap: () async {
          // Recupere a referência do estabelecimento associado ao serviço
          DocumentReference? estabelecimentoRef = servico['estabelecimentoRef'];

          if (estabelecimentoRef != null) {
            // Obtenha o ID do documento do estabelecimento a partir da referência
            String estabelecimentoUID = estabelecimentoRef.id;

            print('Estabelecimento UID: $estabelecimentoUID');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaEstabelecimento(
                  estabelecimentoId: estabelecimentoUID,
                ),
              ),
            );
          } else {
            print(
                'Referência do estabelecimento não disponível para este serviço.');
          }
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration:
              CardStyle.circleDecoration(servico['imageEstabelecimento']),
        ),
        title: Text(servico['nomeServico'] ?? 'serviço'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Duração: ${servico['duracao'] ?? 'Não disponível'}"),
            Text("Preço: ${servico['preco'] ?? 'Não disponível'}"),
            Text(
                "Estabelecimento: ${servico['nomeEstabelecimento'] ?? 'Não disponível'}"),
          ],
        ),
      ),
    );
  }

  Widget cardBanhoETosa(Map<String, dynamic> servico) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        onTap: () async {
          // Recupere o UID do estabelecimento associado ao serviço
          String? estabelecimentoUID = servico['estabelecimentoUID'];

          if (estabelecimentoUID != null) {
            print('Estabelecimento UID: $estabelecimentoUID');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaEstabelecimento(
                  estabelecimentoId: estabelecimentoUID,
                ),
              ),
            );
          } else {
            print('UID do estabelecimento não disponível para este serviço.');
          }
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration:
              CardStyle.circleDecoration(servico['imageEstabelecimento']),
        ),
        title: Text(servico['nomeServico'] ?? 'serviço'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Duração: ${servico['duracao'] ?? 'Não disponível'}"),
            Text("Preço: ${servico['preco'] ?? 'Não disponível'}"),
            Text(
                "Estabelecimento: ${servico['nomeEstabelecimento'] ?? 'Não disponível'}"),
          ],
        ),
      ),
    );
  }

  Widget cardHotelPet(Map<String, dynamic> servico) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        onTap: () async {
          // Recupere o UID do estabelecimento associado ao serviço
          String? estabelecimentoUID = servico['estabelecimentoUID'];

          if (estabelecimentoUID != null) {
            print('Estabelecimento UID: $estabelecimentoUID');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaEstabelecimento(
                  estabelecimentoId: estabelecimentoUID,
                ),
              ),
            );
          } else {
            print('UID do estabelecimento não disponível para este serviço.');
          }
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration:
              CardStyle.circleDecoration(servico['imageEstabelecimento']),
        ),
        title: Text(servico['nomeServico'] ?? 'serviço'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Duração: ${servico['duracao'] ?? 'Não disponível'}"),
            Text("Preço: ${servico['preco'] ?? 'Não disponível'}"),
            Text(
                "Estabelecimento: ${servico['nomeEstabelecimento'] ?? 'Não disponível'}"),
          ],
        ),
      ),
    );
  }

  Widget cardVeterinario(Map<String, dynamic> servico) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        onTap: () async {
          // Recupere o UID do estabelecimento associado ao serviço
          String? estabelecimentoUID;

          // Verifique se a subcoleção 'estabelecimento' existe no serviço
          if (servico['estabelecimento'] != null &&
              servico['estabelecimento']['UID'] != null) {
            estabelecimentoUID = servico['estabelecimento']['UID'];
          }

          if (estabelecimentoUID != null) {
            print('Estabelecimento UID: $estabelecimentoUID');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TelaEstabelecimento(
                  estabelecimentoId: estabelecimentoUID!,
                ),
              ),
            );
          } else {
            print('UID do estabelecimento não disponível para este serviço.');
          }
        },
        leading: Container(
          width: 50,
          height: 50,
          decoration:
              CardStyle.circleDecoration(servico['imageEstabelecimento']),
        ),
        title: Text(servico['nomeServico'] ?? 'serviço'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Duração: ${servico['duracao'] ?? 'Não disponível'}"),
            Text("Preço: ${servico['preco'] ?? 'Não disponível'}"),
            Text(
                "Estabelecimento: ${servico['nomeEstabelecimento'] ?? 'Não disponível'}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Pesquisa'),
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
                  _buildUserImage(), // Usando o método para exibir a imagem do usuário
                  const SizedBox(height: 14.0),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 18.0), // avança o texto para a direita
                    child: Text(
                      '$nome',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Meu perfil"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const perfilUser()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Adicionar Pet"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TelaAddPet()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text("Histórico"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaHistoricoUser()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rounded),
              title: const Text("Favoritos"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaFavoritos()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Deslogar'),
              onTap: () {
                print("deslogando");
                autenticacaoServico().deslogar();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AutentiacacaoTela()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Configurações"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TelaConfig()));
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscacontrole,
                    decoration: const InputDecoration(
                      labelText: 'Pesquisar',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (pesquisa == true) {
                      buscaNome(_buscacontrole.text);
                    } else {
                      buscaServico(_buscacontrole.text);
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                pesquisa = !pesquisa;
              });
            },
            child: Text(
                (pesquisa) ? "pesquisar serviço" : "pesquisar estabelecimento"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: resultadoBuscaNome.length,
              itemBuilder: (context, index) {
                return resultadoBuscaNome[index];
              },
            ),
          ),
        ],
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
          unselectedItemColor: const Color.fromARGB(
              255, 3, 22, 50), // Cor dos itens não selecionados
          selectedItemColor: const Color(
              0xFF10428B), // Cor do item selecionado. azul mais claro Color.fromARGB(255, 44, 104, 255)
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            navegar(index);
            print("valor do navegar $index");
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                color: _currentIndex == 0
                    ? const Color(0xFF10428B)
                    : const Color.fromARGB(255, 3, 22, 50),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.search,
                color: _currentIndex == 1
                    ? const Color(0xFF10428B)
                    : const Color.fromARGB(255, 3, 22, 50),
              ),
              label: 'Pesquisa',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                color: _currentIndex == 2
                    ? const Color(0xFF10428B)
                    : const Color.fromARGB(255, 3, 22, 50),
              ),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
                color: _currentIndex == 3
                    ? const Color(0xFF10428B)
                    : const Color.fromARGB(255, 3, 22, 50),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

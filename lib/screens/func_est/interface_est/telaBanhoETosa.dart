import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/atividade_est/add_serv_est.dart';
import 'package:flutter_application_1/screens/func_est/estabelecimento/tela_agenda.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaBanhoETosa extends StatefulWidget {
  @override
  _TelaBanhoETosaState createState() => _TelaBanhoETosaState();
}

class _TelaBanhoETosaState extends State<TelaBanhoETosa> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> _providers = [];
  String typeService = 'banhoETosa';

  @override
  void initState() {
    super.initState();
    // Verifique se há um usuário autenticado quando o widget é iniciado
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _user = user;
      });

      // Consulta os pets do usuário com base no UID
      await _fetchProviders(user.uid);
    }
  }

  Future<void> _fetchProviders(String uid) async {
    final estabelecimentoReference = _firestore.collection('estabelecimentos').doc(uid);

    estabelecimentoReference.get().then((DocumentSnapshot estabelecimentoSnapshot) {
      if (estabelecimentoSnapshot.exists) {
        final estabelecimentoData = estabelecimentoSnapshot.data() as Map<String, dynamic>?;

        if (estabelecimentoData != null && estabelecimentoData['servico'] == true) {
          final banhoETosaReference = estabelecimentoReference
          .collection('banhoETosa')
          .where('nomeServico', isNull: false);

          banhoETosaReference.get().then((QuerySnapshot banhoETosaQuerySnapshot) {
            if (banhoETosaQuerySnapshot.docs.isNotEmpty) {
              setState(() {
                _providers = banhoETosaQuerySnapshot.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();
              });
              print('A subcoleção "banhoETosa" existe para o usuário $uid.');
            } else {
              print('A subcoleção "banhoETosa" não existe para o usuário $uid.');
            }
          }).catchError((error) {
            print('Erro ao consultar a subcoleção "banhoETosa": $error');
          });
        } else {
          print('O campo "servico" não é verdadeiro para o usuário $uid.');
        }
      } else {
        print('O documento de estabelecimento não existe para o usuário $uid.');
      }
    }).catchError((error) {
      print('Erro ao consultar o documento de estabelecimento: $error');
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10428B),
        title: const Text('Serviços de Banho e Tosa'),
      ),
      body: Center(
        child: _user != null
            ? Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TelaAgenda(typeService: typeService)));
                    },
                    child: const Text('Checar Agenda'),
                  ),
                  Text('ID do usuário autenticado: ${_user!.uid}'),
                  const Text(' disponíveis:'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _providers.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 2.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text('${_providers[index]['nomeServico']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Duração ${_providers[index]['duracao']} Horas'),
                                Text('Preço ${_providers[index]['preco']}'),
                              ],
                            ),
                            trailing: const Icon(Icons.more_vert),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Text('Nenhum usuário autenticado'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const telaAddServ())
          );
        },
        backgroundColor: const Color(0xFF10428B),
        child: const Icon(Icons.add),
      )
    );
  }
}
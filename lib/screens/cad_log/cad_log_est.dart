// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_user.dart';
import 'package:flutter_application_1/servicos/firebase_options.dart';
import 'package:flutter_application_1/snackbar/snack_bar.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:flutter_application_1/style/style.dart';

void main() async {
  runApp(TelaRegistroProv());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class TelaRegistroProv extends StatefulWidget {
  @override
  _TelaRegistroProvState createState() => _TelaRegistroProvState();
}

class _TelaRegistroProvState extends State<TelaRegistroProv> {
  bool estabelecimento = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailProvController = TextEditingController();
  final TextEditingController _passwordProvController = TextEditingController();
  final TextEditingController _confirmPasswordProvController =
      TextEditingController();
  final TextEditingController _usernameProvController = TextEditingController();
  final TextEditingController _cnpjProvController = TextEditingController();
  final TextEditingController _telProvController = TextEditingController();
  final TextEditingController _donoProvController = TextEditingController();

  autenticacaoServico authSvc = autenticacaoServico();
  FirebaseFirestore db = FirebaseFirestore.instance;

  void _submitCadastroEst() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String dono = _donoProvController.text;
      String email = _emailProvController.text;
      String senha = _passwordProvController.text;
      String nome = _usernameProvController.text;
      String cnpj = _cnpjProvController.text;
      String telefone = _telProvController.text;

      authSvc
          .cadastrarEstabelecimento(
              nomeEstabelecimento: nome,
              senhaEstabelecimento: senha,
              emailEstabelecimento: email,
              cnpj: cnpj,
              telefoneEstabelecimento: telefone,
              dono: dono)
          .then((String? erro) {
        if (erro != null) {
          mostrarSnackBar(
            cor: Colors.redAccent,
            context: context,
            texto: erro,
          );
        } else {
          Navigator.of(context).pop();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => TelaRegistroProv()));

          mostrarSnackBar(
            cor: Colors.greenAccent,
            context: context,
            texto: 'Cadastro efetuado com êxito aguarde sua Validação',
          );
        }
      });
    }
  }

  void _submitLoginEst() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String email = _emailProvController.text;
      String senha = _passwordProvController.text;
      String cnpj = _cnpjProvController.text;

      authSvc
          .logarEstabelecimento(
        senha: senha,
        email: email,
        cnpj: cnpj,
      )
          .then((String? erro) {
        if (erro != null) {
          mostrarSnackBar(
            cor: Colors.redAccent,
            context: context,
            texto: erro,
          );
        } else {
          mostrarSnackBar(
            cor: Colors.greenAccent,
            context: context,
            texto: 'Login efetuado com êxito',
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RoteadorTelaEstabelecimento(),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  // sizedbox para seprar a logo e o texto das caixas de texto
                  height: 32,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _emailProvController,
                    decoration: caixaTxt("Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'Digite um email válido';
                      }
                      return null;
                    },
                  ),
                ),
                Visibility(
                  //visivel somente quando "estabelecimento" está como "False"
                  visible: !estabelecimento,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _donoProvController,
                          decoration: caixaTxt("Dono do estabelecimento"),
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value!.isEmpty || value.length <= 5) {
                              return 'Digite seu nome Corretamente';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  //visivel somente quando "estabelecimento" está como "False"
                  visible: !estabelecimento,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _usernameProvController,
                          decoration: caixaTxt('Nome do Estabelecimento'),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Digite um nome de usuário';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  //visivel somente quando "estabelecimento" está como "False"
                  visible: !estabelecimento,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _telProvController,
                          decoration: caixaTxt("Telefone"),
                          /*validator: (value) {
                      if (value!.isEmpty || value.length <= 13) {
                        return 'Digite um Telefone válido (13 caracteres)';
                      }
                      return null;
                    },*/
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _cnpjProvController,
                    decoration: caixaTxt('CNPJ'),
                    /*validator: (value) {
              if (value!.isEmpty || value.length < 18) {
                return 'Digite um CNPJ válido (18 caracteres)';
              }
              return null;
            },*/
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _passwordProvController,
                    decoration: caixaTxt('Senha'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null) {
                        return "Preencha o campo da senha";
                      }
                      /*if (value!.isEmpty || value.length < 12) {
                  return 'A senha deve conter pelo menos 12 caracteres';
                } 
                // Pelo menos uma letra maiúscula
                if (!value.contains(RegExp(r'[A-Z]'))) {
                  return 'A senha deve conter pelo menos um caracter maiusculo';
                }

                // Pelo menos uma letra minúscula
                if (!value.contains(RegExp(r'[a-z]'))) {
                  return 'A senha deve conter pelo menos um caracter minusculo';
                }

                // Pelo menos um caractere especial (por exemplo, !, @, #, $, etc.)
                if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                  return 'A senha deve conter pelo menos um caracter especial';
                }

                // Pelo menos um número
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'A senha deve conter pelo menos um número';
                }*/
                      return null;
                    },
                  ),
                ),
                Visibility(
                  //visivel somente quando "estabelecimento" está como "False"
                  visible: !estabelecimento,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _confirmPasswordProvController,
                          decoration: caixaTxt('Confirmar Senha'),
                          obscureText: true,
                          /*validator: (value) {
                  if (value!.isEmpty) {
                    return 'Confirme sua senha';
                  }
                  if (value != _passwordProvController.text) {
                    return 'As senhas não correspondem';
                  }
                  return null;
                },*/
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (estabelecimento == false) {
                      _submitCadastroEst();
                    } else {
                      _submitLoginEst();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10428B),
                  ),
                  child: Text((estabelecimento) ? "Entrar" : "Cadastrar-se",
                      style: const TextStyle(color: Colors.white)),
                ),
                const Divider(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      estabelecimento = !estabelecimento;
                    });
                  },
                  child: Text(
                      (estabelecimento)
                          ? "Não tem conta do estabelecimento? Cadastre-se  aqui!"
                          : "Já tem conta de estabelecimento? Entre  aqui!",
                      textAlign: TextAlign.center),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AutentiacacaoTela()));
                  },
                  child: const Text("Voltar ao login de usuário"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

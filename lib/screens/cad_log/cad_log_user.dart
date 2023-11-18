import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/cad_log/cad_log_est.dart';
import 'package:flutter_application_1/servicos/auth_svc.dart';
import 'package:flutter_application_1/servicos/firebase_options.dart';
import '../../style/style.dart';
import '../../main.dart';
import '../../snackbar/snack_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AutentiacacaoTela();
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class AutentiacacaoTela extends StatefulWidget {
  const AutentiacacaoTela({Key? key}) : super(key: key);
  @override
  State<AutentiacacaoTela> createState() => _AutentiacacaoTelaState();
}

class _AutentiacacaoTelaState extends State<AutentiacacaoTela> {
  bool queroEntrar = true;
  bool Estabelecimento = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  autenticacaoServico authSvc = autenticacaoServico();

  void _submitCadastro() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String email = _emailController.text;
      String senha = _passwordController.text;
      String nome = _userController.text;
      String telefone = _phoneController.text;

      authSvc
          .cadastrarUsuario(
              nome: nome, senha: senha, email: email, telefone: telefone)
          .then((String? erro) {
        if (erro != null) {
          mostrarSnackBar(
            cor: Colors.redAccent,
            context: context,
            texto: erro,
          );
        } else {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: ((context) => const RoteadorTela())),
          );

          mostrarSnackBar(
            cor: Colors.greenAccent,
            context: context,
            texto: 'Cadastro efetuado com êxito',
          );
        }
      });
    }
  }

  void submitLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String email = _emailController.text;
      String password = _passwordController.text;

      authSvc.logarUsuario(senha: password, email: email).then((String? erro) {
        if (erro != null) {
          mostrarSnackBar(
            cor: Colors.redAccent,
            context: context,
            texto: erro,
          );
        } else {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RoteadorTela()),
          );
          mostrarSnackBar(
            cor: Colors.greenAccent,
            context: context,
            texto: 'Login efetuado com êxito',
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
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
                    height: 32,
                  ),
                  Visibility(
                    visible: !queroEntrar,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _userController,
                            decoration: caixaTxt("Usuário"),
                            validator: (String? value) {
                              if (value == null) {
                                return "Preencha o campo do usuario";
                              }
                              if (value.length < 2) {
                                return "nome muito curto";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _emailController,
                      decoration: caixaTxt("Email"),
                      validator: (String? value) {
                        if (value == null) {
                          return "Preencha o campo do email";
                        }
                        if (!value.contains("@")) {
                          return "o email não é valido";
                        }
                        return null;
                      },
                    ),
                  ),
                  Visibility(
                    visible: !queroEntrar,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: caixaTxt("Telefone"),
                            validator: (String? value) {
                              if (value == null) {
                                return "Preencha o campo da senha";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: caixaTxt("Senha"),
                      validator: (String? value) {
                        if (value == null) {
                          return "Preencha o campo da senha";
                        }
                        if (value.length < 3) {
                          return "senha muito curta";
                        }
                        return null;
                      },
                    ),
                  ),
                  Visibility(
                    visible: !queroEntrar,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: caixaTxt("Confirmar Senha"),
                            validator: (String? value) {
                              if (value == null) {
                                return "Preencha o campo da senha";
                              }
                              if (value.length < 3) {
                                return "senha muito curta";
                              }
                              return null;
                            },
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
                      if (queroEntrar == false) {
                        _submitCadastro();
                      } else {
                        submitLogin();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10428B),
                    ),
                    child: Text((queroEntrar) ? "Entrar" : "Cadastrar-se",
                        style: const TextStyle(color: Colors.white)),
                  ),
                  const Divider(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        queroEntrar = !queroEntrar;
                      });
                    },
                    child: Text((queroEntrar)
                        ? "Ainda não tem uma conta? Cadastre-se aqui!"
                        : "Já tem uma conta? Entre aqui!"),
                  ),
                  TextButton(
                    onPressed: () {
                      if (Estabelecimento == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TelaRegistroProv()),
                        );
                      }
                      setState(() {
                        Estabelecimento = !Estabelecimento;
                      });
                    },
                    child: Text((Estabelecimento)
                        ? "Estabelecimento? Entre aqui!"
                        : "Não tem uma conta? Cadastra-se aqui!"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

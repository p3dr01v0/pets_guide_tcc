import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';

class autenticacaoServico {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserCredential? userCredential;

  Future<String?> cadastrarUsuario({
    required String nome,
    required String senha,
    required String email,
    required String telefone,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: senha);
      userCredential.user!.updateDisplayName(nome);

      FirebaseFirestore db =
          FirebaseFirestore.instance; //instancia do firestore

      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        // listener para recebera

        if (user != null) {
          // se identificar usuario criar a coleção dele
          print('ID de usuario${user.uid}');
          String UID = user.uid;

          final usuario = <String, dynamic>{
            "nome": nome,
            "UID": UID,
            "email": email,
            "telefone": telefone,
            "userType": "user", // tipo de usuario sendo usuario normal
            "banned": false,
            "imageUser": ""
          };

// Add a new document with a generated ID with image

          db
              .collection("user")
              .doc(UID)
              .set(usuario)
              .then((String) => print(
                  'User type user DocumentSnapshot added with ID: $UID with image'))
              .catchError((error) => print(error));
        }
      });
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "O usuário já se encontra cadastrado";
      } else {
        return "Erro desconhecido";
      }
    }
  }

  Future<String?> cadastrarEstabelecimento(
      {required String nomeEstabelecimento,
      required String senhaEstabelecimento,
      required String emailEstabelecimento,
      required String cnpj,
      required String telefoneEstabelecimento,
      required String dono}) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: emailEstabelecimento, password: senhaEstabelecimento);

      //await userCredential.user!.sendEmailVerification();

      userCredential.user!.updateDisplayName(nomeEstabelecimento);

      FirebaseFirestore db =
          FirebaseFirestore.instance; //instancia do firestore

      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        // listener para receber

        if (user != null) {
          // se identificar usuario criar a coleção dele
          print('ID de usuario${user.uid}');
          String UID = user.uid;

          final estabelecimento = <String, dynamic>{
            "emailProv": emailEstabelecimento,
            "username": nomeEstabelecimento,
            "dono": dono,
            "UID": UID,
            "CNPJ": cnpj,
            "Contato": telefoneEstabelecimento,
            "userType":
                "provider", // tipo de usuario sendo Provedor de serviços
            "approval": false
          };

          db
              .collection("estabelecimentos")
              .doc(UID)
              .set(estabelecimento)
              .then((String) => print(
                  'User type provider DocumentSnapshot added with ID: $UID awaiting for approval'))
              .catchError((error) => print(error));
        }
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        return "O usuário já se encontra cadastrado";
      } else {
        return "Erro desconhecido";
      }
    }
  }

  Future<String?> logarUsuario({
    required String email,
    required String senha,
  }) async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: senha);

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> logarEstabelecimento({
    required String email,
    required String senha,
    required String cnpj,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: senha);

      if (userCredential.user != null) {
        // verifica se o email foi validado
        //if (!userCredential.user!.emailVerified) {
        // Se o email não estiver verificado, retorne uma mensagem de erro
        //return 'Por favor, verifique seu email antes de fazer login.';
        //}

        return null;
      } else {
        return 'erro desconhecido ao fazer login';
      }
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> deslogar() {
    return _firebaseAuth.signOut();
  }

  Future<void> resetarSenha({required String email, uid}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Erro ao redefinir a senha: $e');
      rethrow;
    }
  }

  Future<void> resetarSenhaEstabelecimento(
      {required String email,
      required String cnpj,
      required String uid}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print('Erro ao redefinir a senha: $e');
      rethrow;
    }
  }

  Future<void> deslogarEstabelecimento() {
    return _firebaseAuth.signOut();
  }

  checarUsuario() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print(user.uid);
      }
    });
    return null;
  }
}

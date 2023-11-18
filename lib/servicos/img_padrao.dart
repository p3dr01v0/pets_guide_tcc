import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class imgUser extends StatelessWidget {
  Future<String?> loadUserImage() async {
    final imageName = 'user.png';
    final imagePath = 'imagens/$imageName'; // Caminho relativo da imagem

    // Verifique se a imagem está presente no pacote de ativos
    bool imageExists = await imageExistsInAssets(imagePath);
    if (!imageExists) {
      debugPrint('A imagem não está presente no diretório de ativos. Utilizando uma imagem padrão.');
      return null;
    }

    return imagePath;
  }

  Future<bool> imageExistsInAssets(String imagePath) async {
    try {
      await rootBundle.load(imagePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: loadUserImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar a imagem');
        } else {
          final imageUrl = snapshot.data;
          if (imageUrl != null) {
            return Image.asset(
              imageUrl,
              width: 80,
              height: 80,
            );
          } else {
            return Image.asset(
              'imagens/user.png', // Caminho relativo da imagem padrão
              width: 100,
              height: 100,
            );
          }
        }
      },
    );
  }
}

class imgCachorro extends StatelessWidget {
  Future<String?> loadUserImage() async {
    final imageName = 'cachoro.png';
    final imagePath = 'imagens/$imageName'; // Caminho relativo da imagem

    // Verifique se a imagem está presente no pacote de ativos
    bool imageExists = await imageExistsInAssets(imagePath);
    if (!imageExists) {
      debugPrint('A imagem não está presente no diretório de ativos. Utilizando uma imagem padrão.');
      return null;
    }

    return imagePath;
  }

  Future<bool> imageExistsInAssets(String imagePath) async {
    try {
      await rootBundle.load(imagePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: loadUserImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar a imagem');
        } else {
          final imagePet = snapshot.data;
          if (imagePet != null) {
            return Image.asset(
              imagePet,
              width: 80,
              height: 80,
            );
          } else {
            return Image.asset(
              'imagens/cachorro.png', // Caminho relativo da imagem padrão
              width: 100,
              height: 100,
            );
          }
        }
      },
    );
  }
}

class imgGato extends StatelessWidget {
  Future<String?> loadUserImage() async {
    final imageName = 'estabelecimento.png';
    final imagePath = 'imagens/$imageName'; // Caminho relativo da imagem

    // Verifique se a imagem está presente no pacote de ativos
    bool imageExists = await imageExistsInAssets(imagePath);
    if (!imageExists) {
      debugPrint('A imagem não está presente no diretório de ativos. Utilizando uma imagem padrão.');
      return null;
    }

    return imagePath;
  }

  Future<bool> imageExistsInAssets(String imagePath) async {
    try {
      await rootBundle.load(imagePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: loadUserImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar a imagem');
        } else {
          final imageUrl = snapshot.data;
          if (imageUrl != null) {
            return Image.asset(
              imageUrl,
              width: 80,
              height: 80,
            );
          } else {
            return Image.asset(
              'imagens/gato.png', // Caminho relativo da imagem padrão
              width: 100,
              height: 100,
            );
          }
        }
      },
    );
  }
}

class imgEst extends StatelessWidget {
  Future<String?> loadUserImage() async {
    final imageName = 'estabelecimento.png';
    final imagePath = 'imagens/$imageName'; // Caminho relativo da imagem

    // Verifique se a imagem está presente no pacote de ativos
    bool imageExists = await imageExistsInAssets(imagePath);
    if (!imageExists) {
      debugPrint('A imagem não está presente no diretório de ativos. Utilizando uma imagem padrão.');
      return null;
    }

    return imagePath;
  }

  Future<bool> imageExistsInAssets(String imagePath) async {
    try {
      await rootBundle.load(imagePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: loadUserImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erro ao carregar a imagem');
        } else {
          final imageUrl = snapshot.data;
          if (imageUrl != null) {
            return Image.asset(
              imageUrl,
              width: 80,
              height: 80,
            );
          } else {
            return Image.asset(
              'imagens/gato.png', // Caminho relativo da imagem padrão
              width: 100,
              height: 100,
            );
          }
        }
      },
    );
  }
}
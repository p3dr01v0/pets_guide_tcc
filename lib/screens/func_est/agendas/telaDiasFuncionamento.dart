import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/agendas/telaHorarios.dart';

class TelaDiasFuncionamento extends StatefulWidget {
  final String typeService;

  TelaDiasFuncionamento({super.key, required this.typeService});

  @override
  _TelaDiasFuncionamentoState createState() => _TelaDiasFuncionamentoState();
}

class _TelaDiasFuncionamentoState extends State<TelaDiasFuncionamento> {
  List<bool> diasFuncionamento = [
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<String> nomesDias = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 255, 243, 236), // cor de fundo da tela
      appBar: AppBar(
        title: const Text('Dias Funcionais'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Column(
        children: <Widget>[
          for (int i = 0; i < 7; i++)
            ListTile(
              title: Text(nomesDias[i]),
              leading: Checkbox(
                fillColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return const Color.fromARGB(255, 255, 243, 236);
                    }
                    return diasFuncionamento[i]
                        ? Colors.orange
                        : Colors.transparent;
                  },
                ),
                value: diasFuncionamento[i],
                onChanged: (value) {
                  setState(() {
                    diasFuncionamento[i] = value!;
                  });
                },
              ),
            ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              fixedSize: const Size(100, 30),
              backgroundColor: const Color.fromARGB(255, 255, 149, 0),
            ),
            onPressed: () {
              // A variável diasFuncionamento agora contém os estados das checkboxes.
              // ignore: avoid_print
              print('Dias de Funcionamento: $diasFuncionamento');

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaHorarios(
                    diasFuncionamento: diasFuncionamento,
                    typeService: widget.typeService,
                  ),
                ),
              );
            },
            child: const Text(
              'Salvar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

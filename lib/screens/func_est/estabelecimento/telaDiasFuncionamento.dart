import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/estabelecimento/telaHorarios.dart';


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
      appBar: AppBar(
        title: Text('Formulário de Horário de Funcionamento'),
      ),
      body: Column(
        children: <Widget>[
          for (int i = 0; i < 7; i++)
            ListTile(
              title: Text(nomesDias[i]),
              leading: Checkbox(
                value: diasFuncionamento[i],
                onChanged: (value) {
                  setState(() {
                    diasFuncionamento[i] = value!;
                  });
                },
              ),
            ),
          ElevatedButton(
            onPressed: () {
              // A variável diasFuncionamento agora contém os estados das checkboxes.
              print('Dias de Funcionamento: $diasFuncionamento');

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TelaHorarios(
                          diasFuncionamento: diasFuncionamento, typeService: widget.typeService))); 
            },
            child: Text('Salvar'),
          ),
          const Text(
            'Dias de Funcionamento Selecionados:',
            style: TextStyle(fontSize: 18),
          ),
          for (int i = 0; i < 7; i++)
            if (diasFuncionamento[i])
              Text(nomesDias[i],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }
}
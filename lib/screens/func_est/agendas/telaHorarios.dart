import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/func_est/agendas/tela_criar_agenda.dart';
import 'package:intl/intl.dart';

class TelaHorarios extends StatefulWidget {
  final List<bool> diasFuncionamento;
  final String typeService;

  TelaHorarios({required this.diasFuncionamento, required this.typeService});

  @override
  _TelaHorariosState createState() => _TelaHorariosState();
}

class _TelaHorariosState extends State<TelaHorarios> {
  List<String> nomesDias = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  TimeOfDay horaAbertura = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay horaFechamento = const TimeOfDay(hour: 17, minute: 00);

  void _showStartTimePicker() {
    showTimePicker(context: context, initialTime: horaAbertura)
        .then((selectedTime) {
      setState(() {
        if (selectedTime != null) {
          horaAbertura = selectedTime;
        }
      });
    });
  }

  void _showEndTimePicker() {
    showTimePicker(context: context, initialTime: horaFechamento)
        .then((selectedTime) {
      setState(() {
        if (selectedTime != null) {
          horaFechamento = selectedTime;
        }
      });
    });
  }

  final List<int> intervalHours = [
    0,
    1,
    2,
    3,
    4,
  ];

  final List<int> intervalMinutes = [
    00,
    15,
    30,
    45,
  ];

  int selectedIntervalHours = 0;
  int selectedIntervalMin = 30;

  List<String> generatedTimes = [];

  void generateTimes() {
    generatedTimes.clear();
    // ignore: unnecessary_null_comparison
    if (horaAbertura != null && horaFechamento != null) {
      var currentTime =
          DateTime(2023, 1, 1, horaAbertura.hour, horaAbertura.minute);
      final endTime =
          DateTime(2023, 1, 1, horaFechamento.hour, horaFechamento.minute);

      while (currentTime.isBefore(endTime)) {
        var nextTime = currentTime.add(
          Duration(hours: selectedIntervalHours, minutes: selectedIntervalMin),
        );

        if (nextTime.isAfter(endTime)) {
          break; // Parar o loop se o próximo horário ultrapassar o horário de fechamento
        }

        generatedTimes.add(DateFormat('HH:mm').format(currentTime));
        currentTime = nextTime;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 243, 236),
      appBar: AppBar(
        title: const Text('Seleção de horários'),
        backgroundColor: const Color(0xFF10428B),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            Text(
                'Horario atual selecionado ${horaAbertura.format(context).toString()}'),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 149, 0)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  fixedSize: const Size(210, 30),
                ),
                onPressed: _showStartTimePicker,
                child: const Text(
                  'Selecionar Horario inicial',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 149, 0)),
                )),
            const SizedBox(
              height: 20,
            ),
            Text(
                'Horario atual selecionado ${horaFechamento.format(context).toString()}'),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 149, 0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    fixedSize: const Size(210, 30)),
                onPressed: _showEndTimePicker,
                child: const Text('Selecionar Horario final',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 149, 0)))),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Selecione o Intervalo entre cada horario:',
            ),
            DropdownButton<int>(
              // seleção de intervalo em Horas
              value: selectedIntervalHours,
              onChanged: (int? newValue) {
                setState(() {
                  selectedIntervalHours = newValue!;
                });
              },
              items: intervalHours.map((int intervalH) {
                return DropdownMenuItem<int>(
                  value: intervalH,
                  child: Text('$intervalH hora(s)'),
                );
              }).toList(),
            ),
            const SizedBox(height: 5),
            DropdownButton<int>(
              // seleção de intervalo em Minutos
              value: selectedIntervalMin,
              onChanged: (int? newValue) {
                setState(() {
                  selectedIntervalMin = newValue!;
                });
              },
              items: intervalMinutes.map((int intervalM) {
                return DropdownMenuItem<int>(
                  value: intervalM,
                  child: Text('$intervalM minutos'),
                );
              }).toList(),
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  fixedSize: const Size(150, 30),
                  backgroundColor: const Color.fromARGB(255, 255, 149, 0)),
              onPressed: generateTimes,
              child: const Text('Gerar Horários',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            const Text('Horários Gerados:'),
            if (generatedTimes.isNotEmpty)
              Column(
                children: generatedTimes.map((time) {
                  return Text(time);
                }).toList(),
              )
            else
              const Text('Nenhum horário gerado.'),
            const SizedBox(height: 30),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10428B),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    fixedSize: const Size(200, 32)),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TelaCriarAgenda(
                                horarios: generatedTimes,
                                diasFuncionamento: widget.diasFuncionamento,
                                typeService: widget.typeService,
                              )));
                },
                child: const Text(
                  'Avançar',
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      )),
    );
  }
}

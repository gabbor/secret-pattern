import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MastermindGame());
}

class MastermindGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mastermind',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Color> secretCode = [];
  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
  ];
  List<Color?> currentAttempt = [null, null, null, null];
  List<List<Color?>> attempts = [];
  List<Map<String, int>> feedbacks = [];
  int maxAttempts = 10;

  @override
  void initState() {
    super.initState();
    generateSecretCode();
  }

  void generateSecretCode() {
    secretCode = List.from(colors)..shuffle();
    secretCode = secretCode.sublist(0, 4);
  }

  Map<String, int> evaluateAttempt(List<Color?> secret, List<Color?> attempt) {
    int correctPositions = 0;
    int correctColors = 0;

    List<Color?> remainingSecret = List.from(secret);
    List<Color?> remainingAttempt = List.from(attempt);

    for (int i = 0; i < attempt.length; i++) {
      if (attempt[i] == secret[i]) {
        correctPositions++;
        remainingSecret[i] = null;
        remainingAttempt[i] = null;
      }
    }

    for (int i = 0; i < remainingAttempt.length; i++) {
      if (remainingAttempt[i] != null && remainingSecret.contains(remainingAttempt[i])) {
        correctColors++;
        remainingSecret[remainingSecret.indexOf(remainingAttempt[i])] = null;
      }
    }

    return {"correctPositions": correctPositions, "correctColors": correctColors};
  }

  void submitAttempt() {
    if (currentAttempt.contains(null)) return;

    setState(() {
      attempts.add(List.from(currentAttempt));
      feedbacks.add(evaluateAttempt(secretCode, currentAttempt));
      currentAttempt = [null, null, null, null];
    });

    if (attempts.last.map((e) => e.toString()).toList().toString() ==
        secretCode.map((e) => e.toString()).toList().toString()) {
      showGameOverDialog("Hai Vinto!");
    } else if (attempts.length >= maxAttempts) {
      showGameOverDialog("Hai Perso! Codice segreto: ${secretCode.map((c) => c.toString()).join(", ")}");
    }
  }

  void showGameOverDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            child: Text("Nuova Partita"),
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      attempts = [];
      feedbacks = [];
      currentAttempt = [null, null, null, null];
      generateSecretCode();
    });
  }

  void addColorToFirstEmptySlot(Color color) {
    setState(() {
      int firstEmptyIndex = currentAttempt.indexOf(null);
      if (firstEmptyIndex != -1) {
        currentAttempt[firstEmptyIndex] = color;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mastermind'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: Column(
          children: [
            Text(
              'Tentativi rimasti: ${maxAttempts - attempts.length}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: attempts.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...attempts[index].map((color) => Container(
                        margin: EdgeInsets.all(4),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: color ?? Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                      )),
                      SizedBox(width: 10),
                      Text(
                        '✔: ${feedbacks[index]["correctPositions"]}, ✖: ${feedbacks[index]["correctColors"]}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...currentAttempt.asMap().entries.map((entry) {
                  int index = entry.key;
                  Color? color = entry.value;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentAttempt[index] = null;
                      });
                    },
                    child: DragTarget<Color>(
                      onAccept: (receivedColor) {
                        setState(() {
                          currentAttempt[index] = receivedColor;
                        });
                      },
                      builder: (context, candidateData, rejectedData) => Container(
                        margin: EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color ?? Colors.grey[300],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                if (!currentAttempt.contains(null))
                  ElevatedButton(
                    onPressed: submitAttempt,
                    child: Text('Conferma'),
                  ),
              ],
            ),
            SizedBox(height: 20),
            Wrap(
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    addColorToFirstEmptySlot(color); // Aggiunge il colore alla prima palla libera
                  },
                  child: Draggable<Color>(
                    data: color,
                    feedback: Container(), // Nessun feedback visivo durante il trascinamento
                    child: Container(
                      margin: EdgeInsets.all(8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

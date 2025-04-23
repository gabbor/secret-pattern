import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';


void main() {
  runApp(MastermindGame());
}

class MastermindGame extends StatelessWidget {
  const MastermindGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mastermind',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.deepPurple,
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
          onPrimary: Colors.white,
          secondary: Colors.amber,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  GameScreenState createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
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
  int maxAttempts = 8;
  bool isSecretCodeRevealed = false;
  bool isGameOver = false;

  static final Map<Color, String> colorNames = {
    Colors.red: "Red",
    Colors.blue: "Blue",
    Colors.green: "Green",
    Colors.yellow: "Yellow",
    Colors.orange: "Orange",
    Colors.purple: "Purple",
  };

  @override
  void initState() {
    super.initState();
    generateSecretCode();
  }

  void showGameOverDialog(String message) {
    setState(() {
      isSecretCodeRevealed = true;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        backgroundColor: Colors.grey[900],
        contentTextStyle: TextStyle(color: Colors.white70),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          TextButton(
            child: Text("Nuova Partita", style: TextStyle(color: Colors.amber)),
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
          ),
        ],
      ),
    );
  }

  void generateSecretCode() {
    Random random = Random();
    secretCode = List.generate(4, (_) => colors[random.nextInt(colors.length)]);
    if (kDebugMode) {
      print("Codice segreto finale: ${secretCode.map((color) => colorNames[color]).join(', ')}");
    }
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
      if (remainingAttempt[i] != null &&
          remainingSecret.contains(remainingAttempt[i])) {
        correctColors++;
        remainingSecret[remainingSecret.indexOf(remainingAttempt[i])] = null;
      }
    }

    return {
      "correctPositions": correctPositions,
      "correctColors": correctColors
    };
  }

  void submitAttempt() {
    if (isGameOver || currentAttempt.contains(null)) return;

    setState(() {
      attempts.add(List.from(currentAttempt));
      feedbacks.add(evaluateAttempt(secretCode, currentAttempt));
      currentAttempt = [null, null, null, null];
    });

    if (attempts.last.map((e) => e.toString()).toList().toString() ==
        secretCode.map((e) => e.toString()).toList().toString()) {
      showGameOverDialog("Hai Vinto!");
      isGameOver = true;
    } else if (attempts.length >= maxAttempts) {
      showGameOverDialog("Hai Perso!");
      isGameOver = true;
    }
  }


  void resetGame() {
    setState(() {
      attempts = [];
      feedbacks = [];
      currentAttempt = [null, null, null, null];
      isSecretCodeRevealed = false;
      isGameOver = false; // Ripristina lo stato del gioco
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
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Riavvia') {
                resetGame();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'Riavvia',
                child: Text('Riavvia Partita'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: secretCode.map((color) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSecretCodeRevealed ? color : Colors.grey[800],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white),
                  ),
                  child: isSecretCodeRevealed
                      ? null
                      : Center(
                          child: Text(
                            '?',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
            Text(
              'Tentativi rimasti: ${maxAttempts - attempts.length}',
              style: TextStyle(color: Colors.white, fontSize: 20),
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
                              color: color ?? Colors.grey[800],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white),
                            ),
                          )),
                      SizedBox(width: 10),
                      Row(
                        children: List.generate(currentAttempt.length, (i) {
                          Color feedbackColor;
                          if (i < feedbacks[index]["correctPositions"]!) {
                            feedbackColor = Colors.green; // Posizione corretta
                          } else if (i <
                              feedbacks[index]["correctPositions"]! +
                                  feedbacks[index]["correctColors"]!) {
                            feedbackColor = Colors.amber; // Colore corretto
                          } else {
                            feedbackColor = Colors.white; // Nulla
                          }
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: feedbackColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          );
                        }),
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
                      onAcceptWithDetails: (receivedColor) {
                        setState(() {
                          currentAttempt[index] = receivedColor.data;
                        });
                      },
                      builder: (context, candidateData, rejectedData) =>
                          Container(
                        margin: EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color ?? Colors.grey[800],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(width: 10),
                Visibility(
                  visible: !currentAttempt.contains(null),
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: submitAttempt,
                    child: Icon(Icons.check, size: 24, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth =
                      constraints.maxWidth > 500 ? 500 : constraints.maxWidth;
                  return SizedBox(
                    width: maxWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: colors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            addColorToFirstEmptySlot(color);
                          },
                          child: Draggable<Color>(
                            data: color,
                            feedback: Container(),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

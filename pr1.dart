import 'dart:io';
import 'dart:math';

const String reset = '\x1B[0m';
const String red = '\x1B[31m';
const String green = '\x1B[32m';
const String yellow = '\x1B[33m';
const String cyan = '\x1B[36m';
const String bold = '\x1B[1m';

const int championshipWins = 3;
final File logFile = File('tictactoe_log.txt');

void playSound(String filename) {
  if (Platform.isLinux) {
    Process.run('aplay', [filename]);
  } else if (Platform.isMacOS) {
    Process.run('afplay', [filename]);
  }
}

void log(String message) {
  logFile.writeAsStringSync('${DateTime.now()}: $message\n', mode: FileMode.append);
}

List<List<String>> createMatrix(int size) {
  return List.generate(size, (_) => List.generate(size, (_) => ' '));
}

void printMatrix(List<List<String>> matrix) {
  for (int i = 0; i < matrix.length; i++) {
    String row = '';
    for (int j = 0; j < matrix.length; j++) {
      String cell = matrix[i][j];
      row += cell == 'X'
          ? red + bold + 'X' + reset
          : cell == 'O'
              ? cyan + bold + 'O' + reset
              : ' ';
      if (j < matrix.length - 1) row += ' | ';
    }
    print(row);
    if (i < matrix.length - 1) print(List.filled(matrix.length * 4 - 3, '-').join());
  }
  print('');
}

bool makeMove(List<List<String>> matrix, int row, int col, String symbol) {
  if (row < 0 || row >= matrix.length || col < 0 || col >= matrix.length) {
    print(yellow + "Координаты вне диапазона." + reset);
    return false;
  }
  if (matrix[row][col] != ' ') {
    print(yellow + "Клетка уже занята!" + reset);
    return false;
  }
  matrix[row][col] = symbol;
  playSound('move.wav');
  return true;
}

bool checkWin(List<List<String>> matrix, String symbol) {
  int size = matrix.length;

  for (int i = 0; i < size; i++) {
    if (matrix[i].every((c) => c == symbol)) return true;
    if (List.generate(size, (j) => matrix[j][i]).every((c) => c == symbol)) return true;
  }

  if (List.generate(size, (i) => matrix[i][i]).every((c) => c == symbol)) return true;
  if (List.generate(size, (i) => matrix[i][size - 1 - i]).every((c) => c == symbol)) return true;

  return false;
}

bool checkDraw(List<List<String>> matrix) {
  for (var row in matrix) {
    if (row.contains(' ')) return false;
  }
  return true;
}

String getRandomPlayer() => Random().nextBool() ? 'X' : 'O';

void robotMove(List<List<String>> matrix, String symbol) {
  Random r = Random();
  while (true) {
    int row = r.nextInt(matrix.length);
    int col = r.nextInt(matrix.length);
    if (makeMove(matrix, row, col, symbol)) {
      print(cyan + "\nРобот делает ход: ${row + 1} ${col + 1}" + reset);
      break;
    }
  }
}

void startGame(int size, bool vsRobot, Map<String, int> score) {
  List<List<String>> matrix = createMatrix(size);
  String currentPlayer = getRandomPlayer();
  print(green + bold + "Первым ходит '$currentPlayer'" + reset);

  bool gameEnded = false;

  while (!gameEnded) {
    printMatrix(matrix);
    if (!vsRobot || currentPlayer == 'X') {
      print("Ход '$currentPlayer'. Введите строку и столбец:");
      String? moveInput = stdin.readLineSync();

      if (moveInput == null || moveInput.isEmpty) continue;

      List<String> parts = moveInput.trim().split(RegExp(r'\s+'));
      if (parts.length != 2) continue;

      int? row = int.tryParse(parts[0]);
      int? col = int.tryParse(parts[1]);

      if (row == null || col == null) continue;

      if (makeMove(matrix, row - 1, col - 1, currentPlayer)) {
        if (checkWin(matrix, currentPlayer)) {
          playSound('win.wav');
          printMatrix(matrix);
          print(green + bold + "🎉 Победил '$currentPlayer'!" + reset);
          log("Победа: $currentPlayer");
          score[currentPlayer] = (score[currentPlayer] ?? 0) + 1;
          gameEnded = true;
        } else if (checkDraw(matrix)) {
          playSound('draw.wav');
          printMatrix(matrix);
          print(yellow + bold + "😤 Ничья." + reset);
          log("Ничья.");
          gameEnded = true;
        } else {
          currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
        }
      }
    } else {
      robotMove(matrix, currentPlayer);
      if (checkWin(matrix, currentPlayer)) {
        playSound('win.wav');
        printMatrix(matrix);
        print(red + bold + "🤖 Робот '$currentPlayer' победил!" + reset);
        log("Победа: Робот ($currentPlayer)");
        score[currentPlayer] = (score[currentPlayer] ?? 0) + 1;
        gameEnded = true;
      } else if (checkDraw(matrix)) {
        playSound('draw.wav');
        printMatrix(matrix);
        print(yellow + bold + "😤 Ничья." + reset);
        log("Ничья.");
        gameEnded = true;
      } else {
        currentPlayer = 'X';
      }
    }
  }
}

void main() {
  print(magenta + "🏆 Чемпионат по Крестикам-ноликам!" + reset);
  print("Введите размер поля (3–9): ");
  int? size = int.tryParse(stdin.readLineSync() ?? '');
  if (size == null || size < 3 || size > 9) {
    print("Неверный размер. По умолчанию 3x3.");
    size = 3;
  }

  print("\nРежим: 1 – Игрок против игрока, 2 – Против робота");
  bool vsRobot = (stdin.readLineSync() == '2');

  Map<String, int> score = {'X': 0, 'O': 0};

  while (score.values.every((s) => s < championshipWins)) {
    startGame(size, vsRobot, score);
    print("\n$boldСчёт: X=${score['X']} | O=${score['O']}$reset\n");
  }

  String winner = score.entries.firstWhere((e) => e.value == championshipWins).key;
  print(green + bold + "\n🏆 Победитель чемпионата: '$winner'! Поздравляем!" + reset);
  log("Чемпионат выиграл: $winner");
}

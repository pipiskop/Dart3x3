import 'dart:io';
import 'dart:math';

List<List<String>> createMatrix(int size) {
  return List.generate(
    size,
    (_) => List.generate(size, (_) => ' '),
  );
}

void printMatrix(List<List<String>> matrix) {
  int size = matrix.length;

  for (int i = 0; i < size; i++) {
    String row = '';
    for (int j = 0; j < size; j++) {
      row += matrix[i][j];
      if (j < size - 1) row += ' | ';
    }
    print(row);
    if (i < size - 1) {
      print(List.filled(size * 4 - 3, '-').join());
    }
  }
  print('');
}

bool makeMove(List<List<String>> matrix, int row, int col, String symbol) {
  if (row < 0 || row >= matrix.length || col < 0 || col >= matrix.length) {
    print("Координаты вне диапазона. Попробуйте снова.\n");
    return false;
  }
  if (matrix[row][col] != ' ') {
    print("Эта клетка уже занята, выберите другую.\n");
    return false;
  }
  matrix[row][col] = symbol;
  return true;
}

bool checkWin(List<List<String>> matrix, String symbol) {
  int size = matrix.length;

  for (int i = 0; i < size; i++) {
    bool rowWin = true;
    for (int j = 0; j < size; j++) {
      if (matrix[i][j] != symbol) {
        rowWin = false;
        break;
      }
    }
    if (rowWin) return true;
  }

  for (int j = 0; j < size; j++) {
    bool colWin = true;
    for (int i = 0; i < size; i++) {
      if (matrix[i][j] != symbol) {
        colWin = false;
        break;
      }
    }
    if (colWin) return true;
  }

  bool diagWin1 = true;
  for (int i = 0; i < size; i++) {
    if (matrix[i][i] != symbol) {
      diagWin1 = false;
      break;
    }
  }
  if (diagWin1) return true;

  bool diagWin2 = true;
  for (int i = 0; i < size; i++) {
    if (matrix[i][size - 1 - i] != symbol) {
      diagWin2 = false;
      break;
    }
  }
  if (diagWin2) return true;

  return false;
}

bool checkDraw(List<List<String>> matrix) {
  for (var row in matrix) {
    if (row.contains(' ')) {
      return false;
    }
  }
  return true;
}

String getRandomPlayer() {
  Random random = Random();
  return random.nextBool() ? 'X' : 'O';
}

void robotMove(List<List<String>> matrix, String symbol) {
  Random random = Random();
  while (true) {
    int row = random.nextInt(matrix.length);
    int col = random.nextInt(matrix.length);
    if (makeMove(matrix, row, col, symbol)) {
      print("Робот делает ход: ${row + 1} ${col + 1}\n");
      break;
    }
  }
}

void main() {
  while (true) {
    print("Введите размер матрицы (от 3 до 9) для игры 'Крестики-нолики':\n");

    String? input = stdin.readLineSync();

    if (input == null || input.isEmpty) {
      print("Ввод не может быть пустым. Попробуйте снова.\n");
      continue; 
    }

    int? size = int.tryParse(input);

    if (size == null) {
      print("Некорректный ввод. Пожалуйста, введите целое число.\n");
      continue;
    }

    if (3 <= size && size <= 9) {
      List<List<String>> matrix = createMatrix(size);

      print("\nВыберите режим игры:");
      print("1. Игрок против игрока");
      print("2. Игрок против робота");
      String? modeInput = stdin.readLineSync();
      
      String currentPlayer = getRandomPlayer();
      if (modeInput == '1') {
        print("Игрок '$currentPlayer' начинает первым.\n");
      } else if (modeInput == '2') {
        print("Игрок '$currentPlayer' начинает против робота.\n");
      } else {
        print("Некорректный ввод. Начнём игру против игрока.\n");
      }

      bool gameEnded = false;

      while (!gameEnded) {
        printMatrix(matrix);
        if (currentPlayer == 'X') {
          print("Ход игрока '$currentPlayer'. Введите номер строки и столбца через пробел (например, 1 2): ");
          String? moveInput = stdin.readLineSync();

          if (moveInput == null || moveInput.isEmpty) {
            print("Ввод не может быть пустым. Попробуйте снова.\n");
            continue;
          }

          List<String> parts = moveInput.trim().split(RegExp(r'\s+'));
          if (parts.length != 2) {
            print("Неверный формат ввода. Введите два числа через пробел.\n");
            continue;
          }

          int? row = int.tryParse(parts[0])?.toInt() ?? 0;
          int? col = int.tryParse(parts[1])?.toInt() ?? 0;

          if (row == null || col == null) {
            print("Некорректный ввод. Пожалуйста, введите целые числа.\n");
            continue;
          }

          if (makeMove(matrix, row - 1, col - 1, currentPlayer)) {
            if (checkWin(matrix, currentPlayer)) {
              printMatrix(matrix);
              print("Поздравляем! Игрок '$currentPlayer' выиграл!\n");
              gameEnded = true;
              continue;
            }

            if (checkDraw(matrix)) {
              printMatrix(matrix);
              print("Ничья! Все клетки заняты.\n");
              gameEnded = true;
              continue;
            }

            currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
          }
        } else {
          robotMove(matrix, currentPlayer);

          if (checkWin(matrix, currentPlayer)) {
            printMatrix(matrix);
            print("Поздравляем! Робот '$currentPlayer' выиграл!\n");
            gameEnded = true;
            continue;
          }

          if (checkDraw(matrix)) {
            printMatrix(matrix);
            print("Ничья! Все клетки заняты.\n");
            gameEnded = true;
            continue;
          }

          currentPlayer = (currentPlayer == 'X') ? 'O' : 'X';
        }
      }

      while (true) {
        print("Хотите сыграть ещё раз? (1 - да, 0 - нет): ");
        String? restart = stdin.readLineSync()?.trim();

        if (restart == '1') {
          print("\n---------------------------------\n");
          break;
        } else if (restart == '0') {
          print("Спасибо за игру!");
          exit(0);
        } else {
          print("Некорректный ввод. Пожалуйста, ответьте '1' или '0'.\n");
        }
      }

    } else {
      print("Неправильно! Введите число от 3 до 9.\n");
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

List<List<int>> matrix = List.generate(9, (_) => List<int>.filled(9, 0));

class _HomePageState extends State<HomePage> {
  List<List<TextEditingController>> controllers = List.generate(
    9,
    (_) => List.generate(9, (_) => TextEditingController()),
  );

  @override
  void dispose() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void clearAllTextFields() {
    for (var row in controllers) {
      for (var controller in row) {
        controller.clear();
        controller.text = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sudoku Solver"),
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                height: 400,
                width: 380,
                padding: EdgeInsets.all(7.3),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: 81,
                  itemBuilder: (context, index) {
                    int row = index ~/ 9;
                    int col = index % 9;
                    return Padding(
                      padding: const EdgeInsets.all(0.5),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        controller: controllers[row][col],
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[1-9]$')),
                        ],
                        onChanged: (number) {
                          if (number.isEmpty) {
                            matrix[row][col] = 0;
                          } else {
                            matrix[row][col] = int.tryParse(number)!;
                          }
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        if (Solution.solveSudoku(matrix)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SolutionPage()),
                          );
                        }
                      },
                      child: Text("SOLVE"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    width: 80,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        matrix =
                            List.generate(9, (_) => List<int>.filled(9, 0));
                        clearAllTextFields();
                      },
                      child: Text("CLEAR"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SolutionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solved'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 9; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 0; j < 9; j++)
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: Text(matrix[i][j].toString()),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class Solution {
  static int getBox(int x, int y) {
    if (x < 3) {
      if (y < 3) return 0;
      if (y < 6) return 1;
      return 2;
    }
    if (x < 6) {
      if (y < 3) return 3;
      if (y < 6) return 4;
      return 5;
    }
    if (y < 3) return 6;
    if (y < 6) return 7;
    return 8;
  }

  static bool checkIfValid(List<List<bool>> row, List<List<bool>> col,
      List<List<bool>> box, int x, int y, int num) {
    if (!row[x][num - 1] && !col[y][num - 1] && !box[getBox(x, y)][num - 1]) {
      return true;
    }
    return false;
  }

  static bool solve(List<List<int>> board, List<List<bool>> row,
      List<List<bool>> col, List<List<bool>> box) {
    int n = 9;
    for (int x = 0; x < n; x++) {
      for (int y = 0; y < n; y++) {
        int curCell = board[x][y];
        if (curCell == 0) {
          for (int num = 1; num <= 9; num++) {
            if (checkIfValid(row, col, box, x, y, num)) {
              curCell = num;
              row[x][num - 1] = true;
              col[y][num - 1] = true;
              box[getBox(x, y)][num - 1] = true;
              board[x][y] = curCell;
              if (solve(board, row, col, box)) {
                return true;
              } else {
                board[x][y] = 0;
              }
              row[x][num - 1] = false;
              col[y][num - 1] = false;
              box[getBox(x, y)][num - 1] = false;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static bool solveSudoku(List<List<int>> board) {
    int n = 9;

    List<List<bool>> row = List.generate(n, (_) => List<bool>.filled(n, false));
    List<List<bool>> col = List.generate(n, (_) => List<bool>.filled(n, false));
    List<List<bool>> box = List.generate(n, (_) => List<bool>.filled(n, false));

    bool problem = false;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        int curCell = board[i][j];
        if (curCell != 0) {
          problem = true;
          row[i][curCell - 1] = true;
          col[j][curCell - 1] = true;
          box[getBox(i, j)][curCell - 1] = true;
        }
      }
    }

    if (!problem) return false;

    print(matrix);
    bool result = solve(board, row, col, box);
    print(result);
    return result;
  }
}

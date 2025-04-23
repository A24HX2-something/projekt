int rows;
int columns;
int barHeight = 40;
int cellSize = 30;
int numberOfMines = 99;
int numberOfFlags = 0;

int startTime;
int timeSpent;
boolean timerRunning = false;

boolean gameLost = false;
boolean gameWon = false;

Cell[][] grid;

void setup() {
  size(900, 520);
  background(255);
  columns = width/cellSize;
  rows = (height - barHeight) / cellSize;
  grid = new Cell[columns][rows];
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j] = new Cell( i*cellSize, (j * cellSize) + barHeight);
    }
  }
  placeMines();
  countAround();
}

void draw() {

  fill(220);
  rect(0, 0, width, barHeight);

  if (timerRunning && !gameLost && !gameWon) {
    timeSpent = (millis() - startTime) / 1000;
  }
  fill(0);
  textSize(24);
  textAlign(LEFT, TOP);
  text(timeSpent, 10, 10);

  textAlign(RIGHT, TOP);
  text(numberOfMines - numberOfFlags, width - 10, 10);

  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].display();
      grid[i][j].mouseOver = grid[i][j].mouseOver(mouseX, mouseY);
    }
  }
}

void placeMines() {
  int minesPlaced = 0;
  while (minesPlaced < numberOfMines) {
    int i = int(random(columns));
    int j = int(random(rows));

    if (!grid[i][j].mine) {
      grid[i][j].mine = true;
      minesPlaced++;
    }
  }
}

void countAround() {

  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      int mineCount = 0;
      int flagCount = 0;
      for (int di = -1; di <= 1; di++) {
        for (int dj = -1; dj <= 1; dj++) {
          if (di == 0 && dj == 0) continue;
          if (i + di >= 0 && i + di < columns && j + dj >= 0 && j + dj < rows) {
            if (grid[i+di][j+dj].mine) {
              grid[i][j].minesAround++;
              mineCount++;
            }
            if (grid[i+di][j+dj].flag) {
              grid[i][j].flagsAround++;
              flagCount++;
            }
          }
        }
      }
      grid[i][j].minesAround = mineCount;
      grid[i][j].flagsAround = flagCount;
    }
  }
}





void mousePressed() {

  if (!timerRunning) {
    timerRunning = true;
    startTime = millis();
  }

  if (gameLost || gameWon) return;

  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      if (grid[i][j].mouseOver) {
        if (mouseButton == LEFT && !grid[i][j].flag && !grid[i][j].revealed) {
          revealCell(i, j);
          if (grid[i][j].mine) {
            gameLost = true;
          } else {
            checkWin();
          }
        } else if (mouseButton == RIGHT && !grid[i][j].revealed) {
          grid[i][j].flag = !grid[i][j].flag;
          countAround();
          numberOfFlags++;
        } else if (mouseButton == LEFT && grid[i][j].revealed && grid[i][j].flagsAround == grid[i][j].minesAround) {
          for (int di = -1; di <= 1; di++) {
            for (int dj = -1; dj <= 1; dj++) {
              if (di == 0 && dj == 0) continue;
              if (i + di >= 0 && i + di < columns && j + dj >= 0 && j + dj < rows && !grid[i+di][j+dj].flag) {
                revealCell(i+di, j+dj);
                if (grid[i+di][j+dj].mine) {
                  gameLost = true;
                }
              }
            }
          }
          checkWin();
        }
      }
    }
  }
}

void revealCell(int i, int j) {

  if (i < 0 || i >= columns || j < 0 || j >= rows || grid[i][j].revealed || grid[i][j].flag) return;

  grid[i][j].revealed = true;

  if (grid[i][j].minesAround == 0 && !grid[i][j].mine) {
    for (int di = -1; di <= 1; di++) {
      for (int dj = -1; dj <= 1; dj++) {
        if (i + di >= 0 && i + di < columns && j + dj >= 0 && j + dj < rows) {
          revealCell(i + di, j + dj);
        }
      }
    }
  }
}

void checkWin() {
  int revealedCells = 0;
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      if (grid[i][j].revealed) {
        revealedCells++;
      }
    }
  }
  if (revealedCells == rows * columns - numberOfMines) {
    gameWon = true;
  }
}

int rows; // antal celler langs y-aksen
int columns; // antal celler langs x-aksen
int barHeight = 40; // højden af den menu-barren
int cellSize = 30; // cellernes højde/bredde
int numberOfMines = 99; // antal miner på pladen
int numberOfFlags = 0; // antal flag på pladen

int startTime; // hvor lang tid der går fra man kører sketchen til man starter spillet
int timeSpent; // den tid man har brugt
boolean timerRunning = false; //timeren

boolean gameLost = false; // om spillet er tabt
boolean gameWon = false; // om spillet er vundet

Cell[][] grid; // dekleration af spillepladen som et 2D array

void setup() {
  size(900, 520);
  columns = width/cellSize;
  rows = (height - barHeight) / cellSize; // vi skal tage højde (ha ha) for menu-barren
  grid = new Cell[columns][rows]; // initering af spillepladen med antal kolloner og rækker
  for (int i = 0; i < columns; i++) { // ved at bruge et nested forloop går vi gennem alle 'pladser' på pladen
    for (int j = 0; j < rows; j++) {
      grid[i][j] = new Cell( i*cellSize, (j * cellSize) + barHeight); // vi opretter cellerne. Deres y-værdi tager højde for menu-barren
    }
  }
  placeMines(); // kalder funktionen der placerer minerne på pladen
  countAround(); // kalder funktionen der tæller hvor mange miner og hvor mange flag der er omkring cellen
}

void draw() {
  // menu-barrens farve og størrelse
  fill(220);
  rect(0, 0, width, barHeight);
  // timeren tager antal millisekunder fra man kører sketchen og trækker antal millisekunder fra man starter spillet, så dividerer vi det med 1000 for at få det i sekunder
  if (timerRunning && !gameLost && !gameWon) { // den skal kun køre når spillet kører
    timeSpent = (millis() - startTime) / 1000;
  }
  fill(0);
  textSize(24);
  // viser timeren i venstre øverste hjørne af menu-barren
  textAlign(LEFT, TOP);
  text(timeSpent, 10, 10);
  // viser i højre øverste hjørne af menu-barren hvor mange miner man ikke har sat et flag på
  textAlign(RIGHT, TOP);
  text(numberOfMines - numberOfFlags, width - 10, 10);
  // viser at man har vundet i midten af menu-barren
  if (gameWon) {
    textAlign(CENTER, CENTER);
    text("WINNER!", width/2, 10);
  }
  // viser at man har tabt i midten af menu-barren
  if (gameLost) {
    textAlign(CENTER, CENTER);
    text("GAME OVER!", width/2, barHeight/2);
  }


  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) {
      grid[i][j].display(); // viser spillepladen
      grid[i][j].mouseOver = grid[i][j].mouseOver(mouseX, mouseY); // tjekker om musen er over den enkelte celle
    }
  }
}
// funktion der placerer miner på pladen
void placeMines() {
  int minesPlaced = 0; // variabel for hvor mange miner der er sat
  while (minesPlaced < numberOfMines) {
    int i = int(random(columns));
    int j = int(random(rows)); // mens der er miner der ikke er sat finder den et tilfældigt sted på pladen

    if (!grid[i][j].mine) {
      grid[i][j].mine = true;
      minesPlaced++; // hvis det sted ikke allerede har en mine placerer den en og tæller op
    }
  }
}
// funktion til at tælle hvor mange miner/flag der er omkring den enkelte celle
void countAround() {

  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) { // går gennem alle mulige placeringer for cellerne via et nested forloop
      int mineCount = 0; // hvor mange miner der er omkring netop den celle
      int flagCount = 0; // hvor mange flag der er omkring netop den celle
      for (int di = -1; di <= 1; di++) {
        for (int dj = -1; dj <= 1; dj++) { // finder alle cellerne omkring den valgte celle
          if (di == 0 && dj == 0) continue; // den skal ikke tælle sig selv med
          if (i + di >= 0 && i + di < columns && j + dj >= 0 && j + dj < rows) { // sørger får at den ikke prøver at finde en celle uden for pladen
            if (grid[i+di][j+dj].mine) {
              mineCount++; // fortæller løkken at der er fundet en mine omkring den
            }
            if (grid[i+di][j+dj].flag) {
              flagCount++; // fortæller løkken at der er fundet et flag omkring den
            }
          }
        }
      }
      grid[i][j].minesAround = mineCount; // fortæller cellen hvor mange miner der er omkring den
      grid[i][j].flagsAround = flagCount; // fortæller cellen hvor mange flag der er omkring den
    }
  }
}
// indbygget funktion der er aktiveret når man trykker på musen
void mousePressed() {

  if (!timerRunning) {
    timerRunning = true; // hvis timeren ikke kører når man trykker på musen skal den køre
    startTime = millis();
  }

  if (gameLost || gameWon) return; // hvis man har vundet/tabt virker musen ikke

  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) { // finder hver enkelt celle
      if (grid[i][j].mouseOver) { // hvis musen er over den celle
        if (mouseButton == LEFT && !grid[i][j].flag && !grid[i][j].revealed) { // hvis man venstreklikker på en uafsløret celle uden flag skal dne celle afsløres
          revealCell(i, j); // bruger vores funktion til at afdække cellen
          if (grid[i][j].mine) {
            gameLost = true; // hvis man trykker på en mine taber man
          } else {
            checkWin(); // hvis man ikke trykker på en mine skal programmet tjekke om man har vundet
          }
        } else if (mouseButton == RIGHT && !grid[i][j].revealed) { // hvis man højreklikker på en uafsløret celle sætter man et flag eller fjerne det som allerede er der
          grid[i][j].flag = !grid[i][j].flag; // fortæller cellen at den har et flag
          countAround();  // alle celler skal gentælle hvor mange flag (og bomber) der nu er omkring dem
          if (grid[i][j].flag) {
            numberOfFlags++; // hvis der sættes et flag skal programmet vide at der nu er et flag mere på pladen
          }
          if (!grid[i][j].flag) {
            numberOfFlags--; // hvis der fjernes et flag skal programmet vide at der er et flag mindre på pladen
          }
        } else if (mouseButton == LEFT && grid[i][j].revealed && grid[i][j].flagsAround == grid[i][j].minesAround) { // hvis man venstreklikker på en afsløret celle med lige så mange miner som flag omkring sig, skal cellerne omkring den afsløres
          for (int di = -1; di <= 1; di++) { // her har vi bare kopiret vores tidligere kode
            for (int dj = -1; dj <= 1; dj++) {
              if (di == 0 && dj == 0) continue;
              if (i + di >= 0 && i + di < columns && j + dj >= 0 && j + dj < rows && !grid[i+di][j+dj].flag) { //
                revealCell(i+di, j+dj); // dog skal afsløre de omkringliggende celler i stedet for sig selv
                if (grid[i+di][j+dj].mine) {
                  gameLost = true;
                }
              }
            }
          }
          checkWin(); // hver gang man har afsløret en celle skal programmet tjekke om man har vundet
        }
      }
    }
  }
}
// vores funktion til at afsløre en celle
void revealCell(int i, int j) { //den skal vide hvilken celle den skal afsløre

  if (i < 0 || i >= columns || j < 0 || j >= rows || grid[i][j].revealed || grid[i][j].flag) return; // sørger for at at den ikke prøver at afsløre celler uden for spillepladen eller celler der allerede er afsløret

  grid[i][j].revealed = true; // fortæller cellen at den er afsløret

  if (grid[i][j].minesAround == 0 && !grid[i][j].mine) { // hvis cellen ikke har miner omkring sig og ikke selv er en mine skal alle celler omkring den afsløres
    for (int di = -1; di <= 1; di++) {
      for (int dj = -1; dj <= 1; dj++) {
        if (i + di >= 0 && i + di < columns && j + dj >= 0 && j + dj < rows) { // sørger for at den ikke prøver at afsløre celler uden for pladen
          revealCell(i + di, j + dj); // afslører de omkringliggende celler
        }
      }
    }
  }
}
// vores funktion til at tjekke om man har vundet
void checkWin() {
  int revealedCells = 0; // antal celler der er afsløret
  for (int i = 0; i < columns; i++) {
    for (int j = 0; j < rows; j++) { // går alle celler igennem
      if (grid[i][j].revealed) { // hvis cellen er afsløret
        revealedCells++; // antal afsløret celler på pladen skal stige med en
      }
    }
  }
  if (revealedCells == rows * columns - numberOfMines) { // hvis antal afsløret celler er lig med antal celler uden miner
    gameWon = true; // er spillet vundet
  }
}

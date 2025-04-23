class Cell { // klassen for cellerne
  // alle atributter ud over dens position sættes som udgangspunkt til 0 eller false
  int x; // x-værdien for cellen venstre øverste hjørne
  int y; // y-værdien for cellen venstre øverste hjørne
  boolean revealed = false; // om den er afsløret
  boolean mouseOver = false; // om muser er over den
  boolean mine = false; // om den har en mine
  int minesAround = 0; // antal miner rund om den
  boolean flag = false; // om den har et flag
  int flagsAround = 0; // antal flag rundt om den

  // vores celle constructor
  Cell( int x, int y) { // den skal vide hvor den skal placeres
    this.x = x;
    this.y = y;
  }
  // funktion til at vise cellen
  void display() {
    if (revealed) {
      if (mine) {
        fill(0); // hvis den er afsløret og er en mine, bliver den farvet sort
      } else {
        fill(255); // hvis den er afsløret men ikke er en mine bliver den farvet hvis
      }
    } else {
      if (mouseOver) {
        fill(175); // hvis den ikke er afsløret og musen er over cellen bliver den highlightet
      } else {
        fill(200); // hvis den ikke er afsløret men musen ikke er over den er den lysegrå
      }
    }
    rect(x, y, cellSize, cellSize); // tegner cellen
    // hvis cellen ikke er afsløret og har et flag tegnes der en rød trekant
    if (!revealed && flag) {
      fill(255, 0, 0);
      triangle(x, y+cellSize, x+cellSize, y+cellSize, x+cellSize/2, y);
    }
    // hvis der er miner omkring den viser den hvor mange
    if (revealed && !mine && minesAround > 0) {
      textAlign(CENTER, CENTER);
      textSize(20);
      fill(0);
      text(minesAround, x + cellSize / 2, y + cellSize / 2);
    }
  }
  // funktion for om musen er over cellen
  boolean mouseOver(int mx, int my) {
    if (mx >= x && mx < x + cellSize && my >= y && my < y + cellSize) {
      return true; // hvis musen inden for cellen er den true
    } else {
      return false; // ellers er den false
    }
  }
}

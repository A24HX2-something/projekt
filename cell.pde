class Cell {
  int x;
  int y;
  boolean mine = false;
  boolean revealed = false;
  boolean mouseOver = false;
  int minesAround = 0;
  boolean flag = false;
  int flagsAround = 0;

  Cell( int x, int y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    if (revealed) {
      if (mine) {
        fill(0);
      } else {
        fill(255);
      }
    } else {
      if (mouseOver) {
        fill(175);
      } else {
        fill(200); 
      }
    }
    rect(x, y, cellSize, cellSize); 

    if (!revealed && flag) {
      if (flag) {
        fill(255, 0, 0);
        triangle(x, y+cellSize, x+cellSize, y+cellSize, x+cellSize/2, y);
      }
    }

    if (revealed && !mine && minesAround > 0) {
      textAlign(CENTER, CENTER);
      textSize(20);
      fill(0);
      text(minesAround, x + cellSize / 2, y + cellSize / 2);
    }
  }

  boolean mouseOver(int mx, int my) {
    return mx >= x && mx < x + cellSize && my >= y && my < y + cellSize;
  }
}

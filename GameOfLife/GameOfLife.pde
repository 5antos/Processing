/* ======================= VARIABLES ======================= */

final int horizontalSide = 800;
final int verticalSide = 500;
int invertedSpeed = 7;

/* ======================== CLASSES ======================== */

class Cell {
  GoL parent;
  
  int x;
  int y;
  int size;
  boolean isAlive = false;
  
  Cell[] neighbors = new Cell[8];
  int aliveNeighbors = 0;

  Cell(GoL parent, int x, int y) {
    this.parent = parent;
    this.x = x;
    this.y = y;
    this.size = parent.cellSize;
  }

  void lazyKill() { // Only marks the cell as dead
    this.isAlive = false;
  }

  void lazySpawn() { // Only marks the cell as alive
    this.isAlive = true;
  }

  void loadNeighbors() {
    neighbors = new Cell[8];

    int index = 0;
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++) {
        int currCellX = x + (j-1);
        int currCellY = y + (i-1);

        // Only consider cells that are around the current cell and not the current cell itself
        if (currCellX != x || currCellY != y) {

          int indexOfLoadedCell = parent.indexOfLoadedCell(currCellX, currCellY);
          
          // Only assign it if the game has that neighbor cell already loaded
          if (indexOfLoadedCell != -1)
            neighbors[index++] = parent.loadedCells[indexOfLoadedCell];
        }
      }
  }
  
  void reCountAliveNeighbors() {
    aliveNeighbors = 0;
    
    for(int i = 0; i < neighbors.length; i++)
      if(neighbors[i] != null)
        if(neighbors[i].isAlive)
          aliveNeighbors++;
  }

  // Update the cell according to the rules
  void update() {
    if (!isAlive && aliveNeighbors == 3) {
      lazySpawn();
      parent.pushCells(x, y);
    } else if (isAlive && (aliveNeighbors < 2 || aliveNeighbors > 3)) lazyKill();
  }
}

class GoL {
  boolean running = false;
  Cell[] loadedCells = new Cell[0];

  int cellSize = 20;

  boolean toggleGrid = true;
  int offsetX = 0;
  int offsetY = 0;

  GoL() {
  } // Useless Constructor
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  void pushCell(Cell c) {
    loadedCells = (Cell[]) append(loadedCells, c);
  }
  
  int indexOfLoadedCell(int cellX, int cellY) {
    for (int i = 0; i < loadedCells.length; i++)
      if (loadedCells[i].x == cellX && loadedCells[i].y == cellY) // Found the cell, return its index
        return i;
    return -1; // Otherwise return -1, meaning the cell is not loaded in the game
  }

  void pushCells(int cellX, int cellY) {
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++) {
        int currCellX = cellX + (j-1);
        int currCellY = cellY + (i-1);
        
        // If there is no loaded cell in the current position, a new one is created and spawned if it was the clicked cell.
        // Finally, it's pushed into the loadedCells array
        if (indexOfLoadedCell(currCellX, currCellY) == -1) {
          Cell newCell = new Cell(this, currCellX, currCellY);

          if (currCellX == cellX && currCellY == cellY) newCell.lazySpawn(); // The cell where the user clicked

          pushCell(newCell);
        }
      }
      
    // After handling all the needed cells, handle their neighbours
    for(int i = 0; i < 3; i++)
      for(int j = 0; j < 3; j++)
        loadedCells[indexOfLoadedCell(cellX+(j-1), cellY+(i-1))].loadNeighbors();
  }
  
  Cell[] removeCell(int cellIndex) {
    Cell[] result = new Cell[loadedCells.length-1]; // Length-1 because one cell will be removed
    
    int index = 0;
    for(int i = 0; i < loadedCells.length; i++)
      if(i != cellIndex) // Add every cell to the result, except the one in the provided index
        result[index++] = loadedCells[i];
      
    return result;
  }
  
  void unloadUselessCells() {
    for(int i = 0; i < loadedCells.length; i++) {
      if(!loadedCells[i].isAlive && loadedCells[i].aliveNeighbors == 0)
        loadedCells = removeCell(i--);
    }
  }
  
  void generateNextTurn() {
    unloadUselessCells(); // We only care about cells that are near our alive cells
    
    for(int i = 0; i < loadedCells.length; i++)
      loadedCells[i].reCountAliveNeighbors(); // Get the new amount of alive neighbours for each cell
      
    for(int i = 0; i < loadedCells.length; i++)
      loadedCells[i].update(); // Update each cell according to the rules
  }

  void update() {
    if (running) generateNextTurn();
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                                                                                                  //
  //                                                     FILE HANDLING                                                //
  //                                                                                                                  //
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  void readFile(String filename) {
    String[] lines = loadStrings(filename);
    
    pushCellsFromFile(lines);
  }
  
  void pushCellsFromFile(String[] fileLines) {
    for(int i = 0; i < fileLines.length; i++) {
      String[] coords = split(fileLines[i], " ");
      
      int x = int(coords[0]), y = int(coords[1]);
      
      if(indexOfLoadedCell(x, y) == -1) pushCells(x, y);    // If the coordinates from the file do not overwrite previously loaded cells
      else onTouchedCell(x, y);                             // Otherwise, it's overwritting a loaded cell
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                                                                                                  //
  //                                                         DRAW                                                     //
  //                                                                                                                  //
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  void drawGrid() {

    // Draw vertical lines
    for (int i = 0 - offsetY/cellSize; i <= (height - offsetY)/cellSize; i++)
      line(0, i*cellSize + offsetY, width, i*cellSize + offsetY);

    // Draw horizontal lines
    for (int i = 0 - offsetX/cellSize; i <= (width - offsetX)/cellSize; i++)
      line(i*cellSize + offsetX, 0, i*cellSize + offsetX, height);
  }

  void draw() {
    if (toggleGrid) drawGrid();
    
    fill(0);

    for (int i = 0; i < loadedCells.length; i++) {
      Cell currCell = loadedCells[i];
      
      currCell.reCountAliveNeighbors();
      
      if (currCell.isAlive) // Draw cell
        square(currCell.x*cellSize + offsetX, currCell.y*cellSize + offsetY, cellSize);
    }
  }
  
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //                                                                                                                  //
  //                                                    EVENT HANDLERS                                                //
  //                                                                                                                  //
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  void onTouchedCell(int cellX, int cellY) {
    // The touched cell needs to be in the loadedCells array to be handled, otherwise the loadAliveCellsAround method should be called instead
    for (int i = 0; i < loadedCells.length; i++) {
      Cell currCell = loadedCells[i];

      // Only "touch" the cell clicked by the user
      if (currCell.x == cellX && currCell.y == cellY) {
        currCell.isAlive = !currCell.isAlive;

        // We need to check if the touched cell has spawned, so we can add the neighbors to the loadedCells
        if (currCell.isAlive) pushCells(cellX, cellY);
      }
    }
  }
  
  void onMouseClick(int MOUSE_X, int MOUSE_Y) {
    MOUSE_X -= offsetX;
    MOUSE_Y -= offsetY;
        
    // We need to subtract 1 from the position to handle clicks on the left side of the x=0 line
    int row = MOUSE_X > 0 ? MOUSE_X/cellSize : (MOUSE_X/cellSize)-1;
    int col = MOUSE_Y > 0 ? MOUSE_Y/cellSize : (MOUSE_Y/cellSize)-1;
    
    if (indexOfLoadedCell(row, col) == -1) pushCells(row, col);     // If the touched cell was not loaded
    else onTouchedCell(row, col);                                   // Otherwise, change it's state
  }
  
  void onFileOpen(String fileName) {
    String[] fileLines = loadStrings(fileName);
    
    pushCellsFromFile(fileLines);
  }
  
  void onMouseDragged(int dx, int dy) {
    offsetX += dx;
    offsetY += dy;
  }
  
  void onMouseWheel(int value) {
    cellSize = cellSize >= 5 ? cellSize - value : 5;
  }
}

/* ========================= SETUP ========================= */

GoL game;

void readFile(File f) {
  try {
    game.readFile(f.getAbsolutePath());
  } catch(Exception e) {
    println("File opening canceled by user"); 
  }
}

void mouseClicked() {
  if (mouseButton == LEFT) game.onMouseClick(mouseX, mouseY);
}

void mouseDragged() {
  // pmouseX and pmouseY get the old coordinates of the mouse
  if(mouseButton == RIGHT) game.onMouseDragged(mouseX - pmouseX, mouseY - pmouseY);
}

void mouseWheel(MouseEvent event) {
  // https://processing.github.io/processing-javadocs/core/processing/event/MouseEvent.html
  game.onMouseWheel(event.getCount());
}

void keyPressed() {
  if (key == 'r') game.running = !game.running;
  else if (key == 'g') game.toggleGrid = !game.toggleGrid;
  else if (key == 'o') selectInput("Load Cells from File:", "readFile");
  else if (key == '+' && invertedSpeed > 1) invertedSpeed--;
  else if (key == '-' && invertedSpeed < 10) invertedSpeed++;
}

void settings() {
  size(horizontalSide, verticalSide);
}

void setup() {
  surface.setResizable(true);

  game = new GoL();
}

void draw() {
  if (frameCount % invertedSpeed == 0)
    game.update();

  background(255);
  game.draw();
}

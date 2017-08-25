int WALL_LENGTH_PX = 25;
int MAZE_WIDTH_WALLS = 20;
int MAZE_HEIGHT_WALLS = 20;

int BLEED_UNITS = 5;

int kick_cell = -1;
int kick_limit;

// cell walls of maze
Cell[] walls = new Cell[MAZE_WIDTH_WALLS*MAZE_HEIGHT_WALLS];

// cells of maze plus bleeds on each side
int[] cell_colors = new cell_colors[(MAZE_WIDTH_WALLS+2*BLEED_UNITS)*MAZE_HEIGHT_WALLS];

class Cell() {
    boolean top = false;
    boolean right = false;
    boolean bottom = false;
    boolean left = false;
}

/** Input: cell to add to current set of walls, and cell it came from
*/
void carvePath(int from_cell, int cur_cell) {
    int diff = from_cell - cur_cell;
    if (!walls[cur_cell]) {
        Cell w = new Cell();
        w.top = true; w.right = true; w.bottom = true; w.left = true;
        walls[cur_cell] = w;
    }

    // travel up from_cell -> c
    if (diff == MAZE_WIDTH_WALLS) {
        walls[from_cell].top = false;
        walls[cur_cell].bottom = false;
    } 
    // travel down from_cell -> c
    else if (diff == -MAZE_WIDTH_WALLS) {
        walls[from_cell].bottom = false;
        walls[cur_cell].top = false

    } 
    // travel left from_cell -> c
    else if (diff == 1) {
        walls[from_cell].left = false;
        walls[cur_cell].right = false

    } 
    // travel right from_cell -> c
    else if (diff == -1) {
        walls[from_cell].right = false;
        walls[cur_cell].left = false        

    } 
    // ERROR; should never happen
    else { }
}

/** Input: unvisited cells (in the POV of the algorithm), current cell being examined
*/
void _makeMaze(Set cells, int[] cur_path, int c) {
    while (cells.size > 0) {
        // remove c from unexplored cells
        cells.delete(c);

        int[] possible_neighbors = {};
        if (c + MAZE_WIDTH_WALLS < MAZE_WIDTH_WALLS*MAZE_HEIGHT_WALLS && cells.has(c + MAZE_WIDTH_WALLS)) { 
            possible_neighbors.push(c+MAZE_WIDTH_WALLS); 
        }
        if (c - MAZE_WIDTH_WALLS >= 0 && cells.has(c - MAZE_WIDTH_WALLS)) { 
            possible_neighbors.push(c-MAZE_WIDTH_WALLS); 
        }
        if (c % MAZE_WIDTH_WALLS != 0 && cells.has(c - 1)) { 
            possible_neighbors.push(c-1); 
        }
        if (c % MAZE_WIDTH_WALLS != MAZE_WIDTH_WALLS - 1 && cells.has(c + 1)) { 
            possible_neighbors.push(c+1); 
        }

        int next;
        // no unvisited neighbors
        if (possible_neighbors.length == 0) {
            next = cur_path.pop();
        }
        // choose random neighbor to become c
        else {
            next = possible_neighbors[int(random(possible_neighbors.length))];
            cur_path.push(c);
        }

        // carve path from c to next
        carvePath(c, next);

        c = next;
    }
}

/** 
*/
void makeMaze() {
    int n_cells = MAZE_WIDTH_WALLS*MAZE_HEIGHT_WALLS;

    // init tree growing algorithm 
    // http://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
    Set cells = new Set(); 
    for (int i = 0; i < n_cells; i++) {
        cells.add(i);
    }

    // randomly start with any cell in the maze
    int c = int(random(n_cells));

    // add walls of c
    Cell w = new Cell();
    w.top = true; w.right = true; w.bottom = true; w.left = true;
    walls[c] = w;

    // make maze!
    int[] cur_path = {};
    _makeMaze(cells, cur_path, c);
} 

/** Draw the actual walls finally
*/
void drawWalls() {
    int maze_width_px = WALL_LENGTH_PX * MAZE_WIDTH_WALLS;
    int maze_height_px = WALL_LENGTH_PX * MAZE_HEIGHT_WALLS;
    int x_offset = (width - maze_width_px)/2;
    int y_offset = (height - maze_height_px)/2;

    // to deal with slight whitespace where lines connect
    int offx = 2;
    int offy = 2;

    // because bg cell_colors is wider than maze
    int bg_width_px = maze_width_px + 2*BLEED_UNITS*WALL_LENGTH_PX;
    int bg_x_offset = x_offset - BLEED_UNITS*WALL_LENGTH_PX;

    // draw cells
    noStroke();
    for (int i = 0; i < cell_colors.length; i++) {
        // x, y, width, height
        fill(cell_colors[i]);
        rect(
            WALL_LENGTH_PX * int(i % (MAZE_WIDTH_WALLS + 2*BLEED_UNITS)) + bg_x_offset,
            WALL_LENGTH_PX * int(i / (MAZE_WIDTH_WALLS + 2*BLEED_UNITS)) + y_offset,
            WALL_LENGTH_PX,
            WALL_LENGTH_PX);
    }

    // style
    stroke(85, 85, 85);
    strokeWeight(7);
    strokeCap(SQUARE);
    // draw walls
    for (int c = 0; c < walls.length; c++) {
        if (walls[c].top) {
            int x1 = WALL_LENGTH_PX * int(c % MAZE_WIDTH_WALLS) + x_offset;
            int y1 = WALL_LENGTH_PX * int(c / MAZE_WIDTH_WALLS) + y_offset;
            line(x1 - offx, y1, x1 + WALL_LENGTH_PX + offx, y1);
        }
        if (walls[c].right) {
            int x1 = WALL_LENGTH_PX * (int(c % MAZE_WIDTH_WALLS) + 1) + x_offset;
            int y1 = WALL_LENGTH_PX * int(c / MAZE_WIDTH_WALLS) + y_offset;
            line(x1, y1 - offy, x1, y1 + WALL_LENGTH_PX + offy);
        }
        if (walls[c].bottom) {
            int x1 = WALL_LENGTH_PX * int(c % MAZE_WIDTH_WALLS) + x_offset;
            int y1 = WALL_LENGTH_PX * (int(c / MAZE_WIDTH_WALLS) + 1) + y_offset;
            line(x1 - offx, y1, x1 + WALL_LENGTH_PX + offx, y1);
        }
        if (walls[c].left) {
            int x1 = WALL_LENGTH_PX * int(c % MAZE_WIDTH_WALLS) + x_offset;
            int y1 = WALL_LENGTH_PX * int(c / MAZE_WIDTH_WALLS) + y_offset;
            line(x1, y1 - offy, x1, y1 + WALL_LENGTH_PX + offy);
        }
    }

}

void mouseClicked(e) {
    // wall number to start 
    kick_cell = int(random(MAZE_HEIGHT_WALLS)) * (MAZE_WIDTH_WALLS + 2*BLEED_UNITS);
    kick_limit = kick_cell + MAZE_WIDTH_WALLS + 2*BLEED_UNITS;
}

void setup() {
    // set up window
    size(window.innerWidth, window.innerHeight); 
    background("white");
    smooth();
    frameRate(30);

    // all squares are white first
    cell_colors = cell_colors.map(function(col) {
        return color(255, 255, 255)
    });
    console.log(cell_colors);

    // 
    makeMaze();

    // walls should be filled at this point
    drawWalls();
}


void draw() {
    background("white");

    // fade down colors, or kick color
    for (int i = 0; i < cell_colors.length; i++) {
        if (i === kick_cell) {
            cell_colors[i] = color(220, 20, 60);
        } else {
            int cur_col = cell_colors[i];
            int a = (cur_col >> 24) & 0xFF;
            int r = (cur_col >> 16) & 0xFF;  // Faster way of getting red(argb)
            int g = (cur_col >> 8) & 0xFF;   // Faster way of getting green(argb)
            int b = cur_col & 0xFF;          // Faster way of getting blue(argb)
            cell_colors[i] = color(r, g, b, a*0.9)
        }            
    }

    // kick walls
    if (kick_cell != -1 && kick_cell < kick_limit) {
        // iterate until you find a wall that's still there
        int x = int(kick_cell%(MAZE_WIDTH_WALLS+2*BLEED_UNITS));
        int y = int(kick_cell/(MAZE_WIDTH_WALLS+2*BLEED_UNITS));
        if (x >= BLEED_UNITS && x < BLEED_UNITS+MAZE_WIDTH_WALLS) {
            int w = y*MAZE_WIDTH_WALLS + x - BLEED_UNITS;
            walls[w].left = false; walls[w].right = false;            
        }
        kick_cell++;
    }

    // reset kick cell
    if (kick_cell == kick_limit - 1) {
        kick_cell = -1;
    }


    drawWalls();
}


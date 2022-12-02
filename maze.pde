import java.util.Stack;

class Cell
{
    int x;
    int y;
    boolean passable;
    boolean visited;
    boolean wall;

    Cell(int x, int y)
    {
        this.x = x;
        this.y = y;
        passable = false;
        visited = false;
        wall = false;
    }
}

Cell getCellFromXY(ArrayList<Cell> maze, int x, int y)
{
    for (int i = 0; i < maze.size(); i++) {
        if (maze.get(i).x == x && maze.get(i).y == y) {
            return maze.get(i);
        }
    }
    return null;
}

int getCellIndexFromXY(ArrayList<Cell> maze, int x, int y)
{
    for (int i = 0; i < maze.size(); i++) {
        if (maze.get(i).x == x && maze.get(i).y == y) {
            return i;
        }
    }
    return -1;
}

ArrayList<Cell> constructMaze(ArrayList<Cell> maze, int width, int height)
{
    maze = new ArrayList<Cell>();
    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            Cell cell = new Cell(x, y);
            if (x % 2 == 1 || y % 2 == 1) cell.wall = true;
            maze.add(cell);
        }
    }
    
    Stack<Cell> stack = new Stack<Cell>();
    maze.get(0).visited = true;
    stack.push(maze.get(0));
    while (!stack.isEmpty()) {
        Cell current = stack.pop();
        ArrayList<Cell> unvisited = new ArrayList<Cell>();
        Cell north = getCellFromXY(maze, current.x, current.y - 2);
        if (north != null && !north.visited) unvisited.add(north);
        Cell east = getCellFromXY(maze, current.x + 2, current.y);
        if (east != null && !east.visited) unvisited.add(east);
        Cell south = getCellFromXY(maze, current.x, current.y + 2);
        if (south != null && !south.visited) unvisited.add(south);
        Cell west = getCellFromXY(maze, current.x - 2, current.y);
        if (west != null && !west.visited) unvisited.add(west);
        if (unvisited.size() == 0) continue;
        stack.push(current);
        Cell other = unvisited.get(round(random(0, unvisited.size() - 1)));
        int currentIndex = getCellIndexFromXY(maze, current.x, current.y);
        int otherIndex = getCellIndexFromXY(maze, other.x, other.y);
        int wallIndex = getCellIndexFromXY(maze, current.x + (other.x - current.x)/2, current.y + (other.y - current.y)/2);
        maze.get(wallIndex).wall = false;
        maze.get(otherIndex).visited = true;
        stack.push(other);
    }

    return maze;
}

void goToNextLevel()
{
    if (level < 15) {
        level++;
        PrintWriter writer = createWriter("progress.json");
        writer.println("{\"progress\":\""+level+"\"}");
        writer.flush();
        writer.close();
        setup();
    } else {
        level = 1;
        PrintWriter writer = createWriter("progress.json");
        writer.println("{\"progress\":\""+level+"\"}");
        writer.flush();
        writer.close();
        setup();
    }
}

final int MAZE_HEIGHT_PIXELS = 610;
ArrayList<Cell> maze;
int cellSize;
int playerX;
int playerY;
int levelWidth;
int levelHeight;
int goalX;
int goalY;
boolean inLevelSelect;
int level = 1;

void setup()
{
    size(1245, 660);
    surface.setLocation(10, 10);

    JSONObject json = loadJSONObject("progress.json");
    level = Integer.parseInt(json.getString("progress"));

    levelHeight = level * 10;
    levelWidth = levelHeight * 2;
    maze = constructMaze(maze, levelWidth, levelHeight);
    cellSize = MAZE_HEIGHT_PIXELS / levelHeight;

    playerX = 0;
    playerY = 0;

    if (levelHeight % 2 == 1) {
        goalY = levelHeight - 1;
    } else {
        goalY = levelHeight - 2;
    }
    goalX = levelWidth - 2;
}

void draw()
{
    int red = 0;
    int green = 0;
    int blue = 0;
    switch (level) {
        case 1: red = 122; green = 216; blue = 164; break;
        case 2: red = 84; green = 140; blue = 255; break;
        case 3: red = 246; green = 216; blue = 96; break;
        case 4: red = 255; green = 127; blue = 63; break;
        case 5: red = 166; green = 141; blue = 173; break;
        case 6: red = 64; green = 104; blue = 130; break;
        case 7: red = 242; green = 120; blue = 159; break;
        case 8: red = 163; green = 66; blue = 60; break;
        case 9: red = 240; green = 187; blue = 98; break;
        case 10: red = 142; green = 128; blue = 106; break;
        case 11: red = 114; green = 103; blue = 203; break;
        case 12: red = 253; green = 255; blue = 143; break;
        case 13: red = 242; green = 240; blue = 19; break;
        case 14: red = 255; green = 189; blue = 53; break;
        case 15: red = 20; green = 99; blue = 86; break;
        default: red = 122; green = 216; blue = 164; break;
    }

    background(red*0.8, green*0.8, blue*0.8);
    
    // player step
    float playerScreenX = (playerX + 0.5) * cellSize;
    float playerScreenY = (playerY + 0.5) * cellSize;
    float deltaX = mouseX - playerScreenX;
    float deltaY = mouseY - playerScreenY;
    float distance = sqrt(deltaX*deltaX+deltaY*deltaY);
    if (distance > cellSize) {
        if (abs(deltaX) > abs(deltaY)) {
            int dx = floor(-deltaX / abs(deltaX));
            Cell neighbor = getCellFromXY(maze, playerX - dx, playerY);
            if (neighbor != null && !neighbor.wall) {
                playerX -= dx;
            }
        } else {
            int dy = floor(-deltaY / abs(deltaY));
            Cell neighbor = getCellFromXY(maze, playerX, playerY - dy);
            if (neighbor != null && !neighbor.wall) {
                playerY -= dy;
            }
        }
    }

    noStroke();
    for (int i = 0; i < maze.size(); i++) {
        Cell cell = maze.get(i);
        if (!cell.wall) {    
            fill(red, green, blue);
        } else {
            fill(red*0.8, green*0.8, blue*0.8);
        }
        if (cell.x == playerX && cell.y == playerY) {
            rect(cellSize * cell.x, cellSize * cell.y, cellSize, cellSize);
            stroke(0);
            fill(0, 0, 255);
            circle(cellSize * cell.x + cellSize/2, cellSize * cell.y + cellSize/2, cellSize*0.7);
            noStroke();
        } else {
            rect(cellSize * cell.x, cellSize * cell.y, cellSize, cellSize);
        }
    }

    stroke(0, 0, 255);
    line((playerX + 0.5) * cellSize, (playerY + 0.5) * cellSize, mouseX, mouseY);

    noStroke();
    fill(255, 0, 0);
    rect(goalX * cellSize, goalY * cellSize, cellSize, cellSize);

    if (playerX == goalX && playerY == goalY) {
        goToNextLevel();
    }
}
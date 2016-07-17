import java.util.Vector;
import java.util.List;
import java.util.LinkedList;

int MAX_ELEVATOR_CAPACITY = 9;
int MAX_FLOORS = 30;
int MAX_EMPLOYEES = 600;
int MAX_GUESTS = MAX_EMPLOYEES/2;
int NUM_ELEVATORS = 3;
long DAY_LENGTH = 90000; // 10 seconds per hour of simulation time

//Processing Sketch Functions
Controller cont;

void setup() {
  size(300, 480);
  cont = new Controller();
  rectMode(CENTER);
}

void draw() {
  colorMode(RGB, 255);
  background(80, 0, 250);
  int fheight = (height-20)/MAX_FLOORS;
  for (int i = 0; i < MAX_FLOORS; i++){
    int fy = 20 + (i*fheight);
    fill(100);
    rect(150, fy, 280, fheight);
  }
  for (int i = 0; i < NUM_ELEVATORS; i++){
    int x = 50 + (i*100);
    int y = (height-10) - ((cont.getElevator(i).getLocation()) * fheight);
    fill(255);
    rect(x, y, 20, 20);
  }
}
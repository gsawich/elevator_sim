import java.util.Vector;
import java.util.List;
import java.util.LinkedList;

int MAX_ELEVATOR_CAPACITY = 9;
int MAX_FLOORS = 30;
int MAX_EMPLOYEES = 600;
int MAX_GUESTS = MAX_EMPLOYEES/2;
int NUM_ELEVATORS = 3;
long DAY_LENGTH = 90000; // 10 seconds per hour of simulation time

class Person {
  int floor;
  int dest;
  int idle_time;
  boolean single_trip;
  boolean type;
  
  Person() {
    floor = 0;
    dest = floor(random(MAX_FLOORS+1)); //Person goes to a random floor
    idle_time = 0;
    type = false;
    single_trip = false;
    if (random(2) > 1) type = true; // Either false for employee, true for guest
    if (!type) {
      if (random(2) > 1) single_trip = true; //Employees may go to a different floor
    }
  }
}

class Elevator {
  int location;
  int direction;
  boolean full;
  Vector<Person> passengers = new Vector<Person>(MAX_ELEVATOR_CAPACITY);
  LinkedList<Integer> future_event = new LinkedList<Integer>();
  
  Elevator() {
    location = floor(random(MAX_FLOORS));
    direction = 0;
    full = false;
  }
  
  int getDirection() {
    direction = (location - future_event.peek())/(abs(location-future_event.peek()));
    return direction;
  }
  
  boolean isFull() {
    if (passengers.size() == MAX_ELEVATOR_CAPACITY)
      full = true;
    else
      full = false;
    return full;
  }
  
  int getLocation(){
    return location;
  }
}

class Controller {
  Elevator[] bank;
  
  Controller() {
    bank = new Elevator[NUM_ELEVATORS];
    for (int i=0; i < NUM_ELEVATORS; i++){
      bank[i] = new Elevator();
      print(bank[i]);
    }
  }
  
  void request_elevator(int floor, int dir){
    //Find a non-full elevator going in the right direction, then put the request in the future event list
    int bestDist = MAX_FLOORS; // Worst case
    int bestEle = 0;
    for (int i=0; i < NUM_ELEVATORS; i++) {
      if (!(bank[i].isFull())) { //ignore full elevators
        if ((bank[i].getDirection()*dir) >=0) { //if elevator is going in the right direction or stopped
          int dist = (bank[i].getLocation() - floor);
          if (dist < bestDist) {
            bestDist = dist;
            bestEle = i;
          }
        }
      }
    }
    bank[bestEle].future_event.add(floor);
  }
  
  Elevator getElevator(int i) {
    return bank[i];
  }
}

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
    print('\n',cont, '\n', cont.bank[0]);
    int y = (height-10) - ((cont.getElevator(i).getLocation()) * fheight);
    fill(255);
    rect(x, y, 20, 20);
  }
}
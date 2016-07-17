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
    type = floor(random(2)); // Either 0 for employee, 1 for guest
    if (!type) {
      single_trip = floor(random(2)); //Employees may go to a different floor
    }
    else {
      single_trip = 0; //Guests only have 1 destination
    }
}

class Elevator {
  int location = 0;
  int direction = 0;
  boolean full;
  Vector<Person> passengers = new Vector<Person>(MAX_ELEVATOR_CAPACITY);
  LinkedList<Integer> future_event = new LinkedList<Integer>();
}

class Controller {
  Vector<Elevator> bank = new Vector<Elevator>(NUM_ELEVATORS);
  
  void request_elevator(int floor){
    //Find a non-full elevator going in the right direction, then put the request in the future event list
    for (i=0; i < NUM_ELEVATORS; i++) {
      if (!(bank[i].full)) {
        if (bank[i].future_event.peek()
    
  }
}
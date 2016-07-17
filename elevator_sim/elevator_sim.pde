import java.util.Vector;
import java.util.List;
import java.util.LinkedList;
int MAX_ELEVATOR_CAPACITY = 9;
int MAX_FLOORS = 30;
int MAX_EMPLOYEES = 600;
int MAX_GUESTS = MAX_EMPLOYEES/2;
long DAY_LENGTH = 90000; // 10 seconds per hour of simulation time

class Person {
  int dest;
  int idle_time;
  boolean single_trip;
  boolean type;
}

class Elevator {
  int location;
  boolean empty;
  Vector<Person> passengers = new Vector<Person>(MAX_ELEVATOR_CAPACITY);
  LinkedList<Integer> future_event = new LinkedList<Integer>();
}
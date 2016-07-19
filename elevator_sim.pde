import java.util.Vector;
import java.util.Stack;
import java.util.List;
import java.util.LinkedList;
import java.util.concurrent.*;
import java.io.*;

// Set debugging
final boolean __DEBUG__ = true;

// Global constants
int MAX_ELEVATOR_CAPACITY = 9;
int MAX_FLOORS = 30;
int MAX_EMPLOYEES = 2;
int MAX_GUESTS = MAX_EMPLOYEES/2;
int NUM_ELEVATORS = 3;
long DAY_LENGTH = 90000; // 10 seconds per hour of simulation time
double FPMRATIO = 0.2; // 5 frames per minute of simulation time (30fps)

// Dynamic queue
Vector<Vector<Person>> ELEVATOR_REQUEST_QUEUE = new Vector(MAX_FLOORS);

//Processing Sketch Functions
Controller cont;

void setup() {
  size(300, 480);
  frameRate(5 );
  cont = new Controller();
  rectMode(CENTER);
  // Output debugging to txt file in case of infinite loops
  /*if (__DEBUG__) {
    try {
      PrintStream out = new PrintStream(new FileOutputStream("output.txt"));
      System.setOut(out);
    } catch (FileNotFoundException e) { /* do nothing *//* } 
  }*/
  init_system();
}

void draw() {
  clear();
  colorMode(RGB, 255);
  background(80, 0, 250);
  cont.inc();
  int fheight = (height-15)/MAX_FLOORS;
  for (int i = 0; i < MAX_FLOORS+1; i++){
    int fy = 15 + (i*fheight);
    fill(100);
    rect(150, fy, 280, fheight);
  }
  for (int i = 0; i < NUM_ELEVATORS; i++){
    int x = 50 + (i*100);
    int y = (height-15) - ((cont.getElevator(i).getLocation()) * fheight);
    int n = 0;
    try {
      n = cont.getElevator(i).future_event.peek();
    } catch (NullPointerException e) { /* do nothing */ }
    fill(255);
    rect(x, y, 20, 20);
    fill(0);
    text(n, x, y);
  }
}

void generate_people() {
  int emp_count = 0;
  int guest_count = 0;
  while (emp_count < MAX_EMPLOYEES || guest_count < MAX_GUESTS) {
    final Person p = new Person();
    if (p.type)
      guest_count++;
    else
      emp_count++;
    
    final Controller c = new Controller();
    /*
    final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(1);
    queue_add.schedule (new Runnable () {
      @Override 
      public void run() {*/
        ELEVATOR_REQUEST_QUEUE.get(0).add(p);
        c.request_elevator(0, 1); // request an upward elevator
        /*
      }  
    }, 10000, TimeUnit.MILLISECONDS);*/
  }
}

void init_system() {
  for (int i = 0; i < MAX_FLOORS; i++)
    ELEVATOR_REQUEST_QUEUE.add(new Stack<Person>());
    
  generate_people();
 
  if (__DEBUG__) {
    // Test for working 3D Vector
    for (int i = 0; i < ELEVATOR_REQUEST_QUEUE.get(0).size(); i++) {
      String person_type;
      if (ELEVATOR_REQUEST_QUEUE.get(0).get(i).type)
        person_type = "guest";
      else
        person_type = "employee";
             
      _DEBUG("Person #" + i + " is a(n) " + person_type + " and is going to Floor " + ELEVATOR_REQUEST_QUEUE.get(0).get(i).dest);
    }
  }
}

void _DEBUG(String debug_msg) {
  if (__DEBUG__)
    println(debug_msg);
}
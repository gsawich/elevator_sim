import java.util.*;
import java.io.*;
import java.util.concurrent.*;

// Set debugging
final boolean __DEBUG__ = false;

// Global constants
int MAX_ELEVATOR_CAPACITY = 9;
int MAX_FLOORS = 30;
int MAX_EMPLOYEES = 60;
int MAX_GUESTS = MAX_EMPLOYEES / 2;
int NUM_ELEVATORS = 3;
long DAY_LENGTH = 90000; // 10 seconds per hour of simulation time
long START_TIME = System.currentTimeMillis();
double FPMRATIO = 0.2; // 5 frames per minute of simulation time (30fps)

// Dynamic queue
Vector<Vector<Person>> ELEVATOR_REQUEST_QUEUE = new Vector(MAX_FLOORS);

//Processing Sketch Functions
Controller cont;

void setup() {
  size(300, 480);
  frameRate(5);
  cont = new Controller();
  rectMode(CENTER);
  // Output debugging to txt file for all output to be shown
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
    if (!cont.getElevator(i).future_event.isEmpty())
      n = cont.getElevator(i).future_event.get(0);
    fill(255);
    rect(x, y, 20, 20);
    fill(0);
    text(n, x - 5, y + 3);
  }
  
  long sim_time = System.currentTimeMillis() - START_TIME;
  println("Current simulation time is: " + sim_time);
}

void generate_people() {
  ArrayList<Float> freq = arrival_frequencies(); 
  // freq[0] = emp_freq, freq[1] = guest_freq
  // freq[2] = distribution_of_arrival, freq[3] = refresh_interval
  int emp_count = 0;
  int guest_count = 0;
  float refresh_counter = 1;
  boolean _continue = false;
    
  if (System.currentTimeMillis() - START_TIME <= DAY_LENGTH) {
    while (emp_count < MAX_EMPLOYEES * freq.get(0) || guest_count < MAX_GUESTS * freq.get(1)) {
      freq = arrival_frequencies();
      final Person p = new Person();
      
      if (refresh_counter != freq.get(3)) {
        refresh_counter = freq.get(3);
        emp_count = 0;
        guest_count = 0;
      }
      
      if (p.type && guest_count < MAX_GUESTS * freq.get(1)) {
        guest_count++;
        _continue = true;
      }
      else if (!p.type && emp_count < MAX_EMPLOYEES * freq.get(0)) {
        emp_count++;
        _continue = true;
      }
        
      if (_continue) {
        final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(5);
        queue_add.schedule (new Runnable () {
          @Override 
          public void run() {
            ELEVATOR_REQUEST_QUEUE.get(0).add(p);
            cont.request_elevator(0, 1); // request an upward elevator
          }  
        }, floor(random(freq.get(2))), TimeUnit.MILLISECONDS);
      }
    }
  }
}

ArrayList<Float> arrival_frequencies() {
  /* =================== ARRIVAL FREQUENCY CHART ===================== *
   * 8am - 9am  (0ms to 10000ms)     = 75% of employees, 15% of guests *
   * 9am - 11am (10000ms to 30000ms) = 25% of employees, 40% of guests *
   * 11am - 1pm (30000ms to 50000ms) = 0% of employees,  30% of guests *
   * 1pm - 5pm  (50000ms - 90000ms)  = 0% of employees,  15% of guests */
   
  ArrayList<Float> arrival_frequencies = new ArrayList<Float>(4);
  float emp_frequency = 0;
  float guest_frequency = 0;
  long distribution_of_arrival = 0;
  int refresh_interval = 0;
  long current_time = System.currentTimeMillis() - START_TIME;
  
  if (current_time < 10000) {
    emp_frequency = 0.75;
    guest_frequency = 0.15;
    distribution_of_arrival = 10000 - 0;
    refresh_interval = 1;
  }
  else if (current_time >= 10000 && current_time < 30000) {
    emp_frequency = 0.25;
    guest_frequency = 0.40;
    distribution_of_arrival = 30000 - 10000;
    refresh_interval = 2;
  }
  else if (current_time >= 30000 && current_time < 50000) {
    emp_frequency = 0.0;
    guest_frequency = 0.30;
    distribution_of_arrival = 50000 - 30000;
    refresh_interval = 3;
  }
  else if (current_time >= 50000 && current_time < 90000) {
    emp_frequency = 0.0;
    guest_frequency = 0.15;
    distribution_of_arrival = 90000 - 50000;
    refresh_interval = 4;
  }
    
  arrival_frequencies.add(emp_frequency);
  arrival_frequencies.add(guest_frequency);
  arrival_frequencies.add((float) distribution_of_arrival);
  arrival_frequencies.add((float) refresh_interval);
  return arrival_frequencies;
}

void init_system() {
  for (int i = 0; i < MAX_FLOORS; i++)
    ELEVATOR_REQUEST_QUEUE.add(new Stack<Person>());
    
  //thread("generate_people");
  
  generate_people();
 
  if (__DEBUG__) {
    // Test for working 3D vector
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
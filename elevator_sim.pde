import java.util.*;
import java.io.*;
import java.util.concurrent.*;

// Set debugging
public static final boolean __DEBUG__ = true;
private static final boolean __DEBUGING_TO_FILE__ = true;
private static int __debug__p_count;

// Global constants
public static final int MAX_ELEVATOR_CAPACITY = 9;
public static final int MAX_FLOORS = 30;
public static final int MAX_EMPLOYEES = 60;
public static final int MAX_GUESTS = MAX_EMPLOYEES + (MAX_EMPLOYEES / 3);
public static final int NUM_ELEVATORS = 3;
public static final long DAY_LENGTH = 90000; // 10 seconds per hour of simulation time
public static final long START_TIME = System.currentTimeMillis();

// Required for non-multithreaded frequency-based people generation
private static int emp_count = 0;
private static int guest_count = 0;
private static float refresh_counter = 0;
private static boolean _continue = false;
private static boolean isGenerating = false;

// Dynamic queue
public static Vector<Vector<Person>> ELEVATOR_REQUEST_QUEUE = new Vector(MAX_FLOORS);

//Processing Sketch Functions
public Controller cont = new Controller();

// Statistics
public Statistics STATS = new Statistics();

// Graphics
public static final double FPMRATIO = 0.2; // 5 frames per minute of simulation time (30fps)

public void setup() {
  size(300, 480);
  frameRate(5);
  rectMode(CENTER);
  __debug__p_count = 0;
  for (int i = 0; i < MAX_FLOORS; i++)
    ELEVATOR_REQUEST_QUEUE.add(new Stack<Person>()); 
  
  // Output debugging to txt file for all output to be shown
  if (__DEBUGING_TO_FILE__) {
    try {
      PrintStream out = new PrintStream(new FileOutputStream("output.txt"));
      System.setOut(out);
    } catch (FileNotFoundException e) { /* do nothing */} 
  }
}

public void draw() {
  clear();
  colorMode(RGB, 255);
  background(80, 0, 250);
  generate_people();
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
    text(n, x - 5, y + 3); // if n = 0, in_use = false
  }
  
  // if debugging mode is off, simulation time will be shown
  if (!__DEBUG__) {
    long sim_time = System.currentTimeMillis() - START_TIME;
    println("Current simulation time is: " + sim_time);
  }
}

private void generate_people() {
  ArrayList<Float> freq = arrival_frequencies(); 
  // freq[0] = emp_freq, freq[1] = guest_freq, freq[2] = refresh_interval
  
  if (refresh_counter != freq.get(2) && !isGenerating) {
    isGenerating = true;
    if (System.currentTimeMillis() - START_TIME <= DAY_LENGTH) {
      while ((float) emp_count < (float) MAX_EMPLOYEES * freq.get(0) || 
             (float) guest_count < (float) MAX_GUESTS * freq.get(1)) {
        final Person p = new Person();
        freq = arrival_frequencies();
              
        if (refresh_counter != freq.get(2)) {
          _DEBUG("$$#$#$#$#$#$#$#$ refresh counter updated");
          refresh_counter = freq.get(2);
          emp_count = 0;
          guest_count = 0;
        }
        
        if (p.type && (float) guest_count < (float) MAX_GUESTS * freq.get(1)) {
          guest_count++;
          _continue = true;
        }
        else if (!p.type && (float) emp_count < (float) MAX_EMPLOYEES * freq.get(0)) {
          emp_count++;
          _continue = true;
        }
        
        if (!_continue)
          __debug__p_count--;
          
        if (_continue) {
          p.designation_num = __debug__p_count;
          final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(5);
          queue_add.schedule (new Runnable () {
            @Override 
            public void run() {
              ELEVATOR_REQUEST_QUEUE.get(0).add(p);
              cont.request_elevator(0, 1); // request an upward elevator
              
              if (__DEBUG__) {
                String person_type;
                if (p.type)
                  person_type = "guest";
                else
                  person_type = "employee";
              _DEBUG("*** Person #" + p.designation_num + " is a(n) " + person_type + " and is going to Floor " + p.dest);
              }
            }  
          }, floor(random(50)), TimeUnit.MILLISECONDS);
        }
        
        _continue = false;
      }
    }
    
    isGenerating = false;
  }
}

private ArrayList<Float> arrival_frequencies() {
  /* ================ CURRENT ARRIVAL FREQUENCY CHART ================ *
   * 8am - 9am  (0ms to 10000ms)     = 75% of employees, 15% of guests *
   * 9am - 11am (10000ms to 30000ms) = 25% of employees, 40% of guests *
   * 11am - 1pm (30000ms to 50000ms) = 0% of employees,  30% of guests *
   * 1pm - 5pm  (50000ms to 90000ms) = 0% of employees,  15% of guests */
   
  ArrayList<Float> arrival_frequencies = new ArrayList<Float>(3);
  float emp_frequency = 0;
  float guest_frequency = 0;
  int refresh_interval = 0; // lets generate_people to clear its counters when a new frequency becomes valid
  long current_time = System.currentTimeMillis() - START_TIME;
  
  if (current_time < 10000) {
    emp_frequency = 0.75;
    guest_frequency = 0.15;
    refresh_interval = 1;
  }
  else if (current_time >= 10000 && current_time < 30000) {
    emp_frequency = 0.25;
    guest_frequency = 0.40;
    refresh_interval = 2;
  }
  else if (current_time >= 30000 && current_time < 50000) {
    emp_frequency = 0.0;
    guest_frequency = 0.30;
    refresh_interval = 3;
  }
  else if (current_time >= 50000 && current_time < 90000) {
    emp_frequency = 0.0;
    guest_frequency = 0.15;
    refresh_interval = 4;
  }
    
  arrival_frequencies.add(emp_frequency);
  arrival_frequencies.add(guest_frequency);
  arrival_frequencies.add((float) refresh_interval);
  return arrival_frequencies;
}

public void _DEBUG(String debug_msg) {
  if (__DEBUG__)
      println(debug_msg);
}
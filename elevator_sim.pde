import java.util.*;
import java.io.*;
import java.util.concurrent.*;

// Set debugging
public static final boolean __DEBUG__ = false;
public static final boolean _DEBUG_QUEUE_STATUS_VIEW_ = false;
private static final boolean __DEBUGING_TO_FILE__ = false;
private static int __debug__p_count;

// Global constants
public static final int FRAME_RATE = 30;
public static final int MAX_ELEVATOR_CAPACITY = 9;
public static final int MAX_FLOORS = 30;
public static final int MAX_EMPLOYEES = 60;
public static final int MAX_GUESTS = MAX_EMPLOYEES + (MAX_EMPLOYEES / 3);
public static final int NUM_ELEVATORS = 3;
public static final long DAY_LENGTH = 90000; // 10 seconds per hour of simulation time
public static final long START_TIME = System.currentTimeMillis();
public static final float TIME_RATIO = (DAY_LENGTH/9)/3600; // 2.77 ms per second of sim time

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
public void setup() {
  size(480, 480);
  frameRate(FRAME_RATE);
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
  // initialize data collection
  clear();
  colorMode(RGB, 255);
  background(80, 0, 250);
  
  // get data
  generate_people();
  cont.inc();
  STATS.gather_queue_lengths();
  
  // draw graphics
  textAlign(LEFT);
  fill(0);
  text(current_sim_clock(), 5, 16);
  // draw floors
  int fheight = (height-15)/MAX_FLOORS;
  for (int i = 0; i < MAX_FLOORS; i++){
    int fy = height - (15 + (i*fheight));
    fill(100);
    rect(width/2, fy, width-20, fheight);
    fill(255);
    textAlign(RIGHT);
    text(i+1, width-12, fy+4);
    for (int j = 0; j < ELEVATOR_REQUEST_QUEUE.get(i).size(); j++) {
      Person p = ELEVATOR_REQUEST_QUEUE.get(i).get(j);
      if (!p.type) {
        fill(200, 0, 0);
      }
      else {
        fill(0, 0, 200);
      }
      rect((width-180)-(j*6), fy, 3, 3);
    }
  }
  // draw elevators
  for (int i = 0; i < NUM_ELEVATORS; i++){
    int x = (width-((NUM_ELEVATORS+1)*40)) + (i*40);
    int y = (height-15) - ((cont.getElevator(i).getLocation()) * fheight);
    int n = 0;
    int p = cont.getElevator(i).getPassengers();
    boolean[] passType = cont.getElevator(i).getPassType();

    fill(255);
    rect(x, y, 20, 20);
    
    if (!cont.getElevator(i).future_event.isEmpty()) {
      for (int k = 0; k < cont.getElevator(i).future_event.size(); k++) { 
        n = cont.getElevator(i).future_event.get(k) + 1;
        fill(0);
        textAlign(CENTER);
        text(n, x, (y - 13)-(k*8)); // if n = 0, in_use = false
      }
    }
    for (int j = 0; j < p; j++) {
      if (!passType[j]) {
        fill(200, 0, 0);
      }
      else {
        fill(0, 0, 200);
      }
      rect((x-6) + ((j%3)*6), (y-6) + ((j/3)*6), 3, 3);
    }
  }
    
  // if debugging mode is off, simulation time will be shown 
  if (!__DEBUG__)
    println("Current simulation time is: " + current_sim_time());

  // Stop simulation and run statistics report after DAY_LENGTH when everyone has left the building
  boolean queues_free = true;
  for (Vector v:ELEVATOR_REQUEST_QUEUE) {
    if (v.size() > 0) {
      queues_free = false;
    }
  }
  if (current_sim_time()>= DAY_LENGTH && queues_free) {
    noLoop();
    println("\n\n\n");
    STATS.generate_report();
  }
}

private void generate_people() {
  ArrayList<Float> freq = arrival_frequencies(); 
  // freq[0] = emp_freq, freq[1] = guest_freq, freq[2] = refresh_interval
  
  if (refresh_counter != freq.get(2) && !isGenerating) {
    isGenerating = true;
    if (current_sim_time() <= DAY_LENGTH) {
      while ((float) emp_count < (float) MAX_EMPLOYEES * freq.get(0) || 
             (float) guest_count < (float) MAX_GUESTS * freq.get(1)) {
        final Person p = new Person();
        freq = arrival_frequencies();
              
        if (refresh_counter != freq.get(2)) {
          _DEBUG("           ->  FREQUENCY REFRESH COUTNER UPDATED");
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
              p.queue_arrival_time = current_sim_time();
              
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
  
  if (current_sim_time() < 10000) {
    emp_frequency = 0.75;
    guest_frequency = 0.15;
    refresh_interval = 1;
  }
  else if (current_sim_time() >= 10000 && current_sim_time() < 30000) {
    emp_frequency = 0.25;
    guest_frequency = 0.40;
    refresh_interval = 2;
  }
  else if (current_sim_time() >= 30000 && current_sim_time() < 50000) {
    emp_frequency = 0.0;
    guest_frequency = 0.30;
    refresh_interval = 3;
  }
  else if (current_sim_time() >= 50000 && current_sim_time() < 90000) {
    emp_frequency = 0.0;
    guest_frequency = 0.15;
    refresh_interval = 4;
  }
    
  arrival_frequencies.add(emp_frequency);
  arrival_frequencies.add(guest_frequency);
  arrival_frequencies.add((float) refresh_interval);
  return arrival_frequencies;
}

public float current_sim_time() {
   return System.currentTimeMillis() - START_TIME;
}

public String current_sim_clock() {
   float time = current_sim_time();
   int hours = floor(floor(time/TIME_RATIO)/3600);
   int minutes = floor(floor(time/TIME_RATIO)/60)%60;
   int seconds = floor(time/TIME_RATIO)%60;
   return "" + (hours + 8) + ":" + minutes + ":" + seconds;
}

public void _DEBUG(String debug_msg) {
  if (__DEBUG__)
      println(debug_msg);
}
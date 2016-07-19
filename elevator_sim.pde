import java.util.Vector;
import java.util.List;
import java.util.LinkedList;
import java.util.concurrent.*;

int MAX_ELEVATOR_CAPACITY = 9;
int MAX_FLOORS = 30;
int MAX_EMPLOYEES = 600;
int MAX_GUESTS = MAX_EMPLOYEES/2;
int NUM_ELEVATORS = 3;
long DAY_LENGTH = 90000; // 10 seconds per hour of simulation time
double FPMRATIO = 0.2; // 5 frames per minute of simulation time (30fps)
Vector<Vector<Person>> ELEVATOR_REQUEST_QUEUE = new Vector(MAX_FLOORS);

//Processing Sketch Functions
Controller cont;

void setup() {
  size(300, 480);
  frameRate(5 );
  cont = new Controller();
  rectMode(CENTER);
  
  for (int i = 0; i < MAX_FLOORS; i++)
    ELEVATOR_REQUEST_QUEUE.add(new Vector<Person>());
    
  generate_people();
  /*
  for (int i = 0; i < ELEVATOR_REQUEST_QUEUE.get(0).size(); i++) {
    String person_type;
    if (ELEVATOR_REQUEST_QUEUE.get(0).get(i).type)
      person_type = "guest";
    else
      person_type = "employee";
      
    println("Person #" + i + " is a(n) " + person_type + " and is going to Floor " + ELEVATOR_REQUEST_QUEUE.get(0).get(i).dest);
  }*/
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
    int n = cont.getElevator(i).future_event.peek();
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
    /*
    final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(1);
    queue_add.schedule (new Runnable () {
      @Override 
      public void run() {*/
        ELEVATOR_REQUEST_QUEUE.get(0).add(p);
        /*
      }  
    }, 10000, TimeUnit.MILLISECONDS);*/
  }
}
class Elevator {
  int location;
  int direction;
  boolean full;
  boolean stopped;
  int stopTime;
  int designation_num;
  Vector<Person> passengers = new Vector<Person>(MAX_ELEVATOR_CAPACITY);
  LinkedList<Integer> future_event = new LinkedList<Integer>();
  int speed;
  
  Elevator() {
    location = 0; //floor(random(MAX_FLOORS));
    direction = 0;
    stopped = true;
    full = false;
    speed = 1;
    stopTime = 5;
    designation_num = 0;
  }
  
  int getDirection() {
    if (location-future_event.peek()!=0)
      direction = (future_event.peek() - location)/(abs(location-future_event.peek()));
    else {
      direction = 0;
      stopped = true;
      future_event.pop();
    }
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
  
  void move() {
    if (!stopped){
      int dir = getDirection(); //-1 for down, 0 for stopped, 1 for up
      location += dir*speed;
    }
    else if (stopTime > 0) {
      fill_elevator();
      stopTime--;
      //print(stopTime); 
    }
    else if (stopTime == 0){
      stopped = false;
      //future_event.add(floor(random(MAX_FLOORS)));
      //getDirection();
      stopTime = 5;
    }
  }
  
  void fill_elevator() {
    // first, process departing passengers
    if (passengers.size() != 0) {
      for (int i = 0; i < passengers.size(); i++) {
        if (location == passengers.get(i).dest) {
          if (location != 0)
            SCHEDULE_FLOOR_QUEUE(passengers.get(i), location);
          passengers.remove(i);
        }
      }
    }
    
    // second, actually fill the elevator
    if (stopped == true) {
      for (int i = 0; passengers.size() < MAX_ELEVATOR_CAPACITY; i++) {
        println("Elevator #" + designation_num + " stopped at floor " + location);
        if (ELEVATOR_REQUEST_QUEUE.get(location).size() > 0) {
          Person p = ELEVATOR_REQUEST_QUEUE.get(location).remove(i);
          passengers.add(p);
          future_event.add(p.dest);
        }
      }
    }
  }
  
  void SCHEDULE_FLOOR_QUEUE(final Person p, final int current_floor) {
    final Controller c = new Controller();
    /*
    final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(1);
    queue_add.schedule (new Runnable () {
      @Override 
      public void run() {*/
        ELEVATOR_REQUEST_QUEUE.get(current_floor).add(p);
        c.request_elevator(current_floor, getDirection());/*
      }  
    }, p.idle_time, TimeUnit.MILLISECONDS);*/
  }
}
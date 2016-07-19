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
    future_event.add(0);
  }
  
  int getDirection() {
    if (future_event.isEmpty()) // direction is always up for an elevator at floor 0
      direction = 1;
    else {
      if (location - future_event.peek() != 0)
        direction = (future_event.peek() - location)/(abs(location-future_event.peek()));
      else {
        direction = 0;
        stopped = true;
        future_event.pop();
      }
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
      _DEBUG("Elevator #" + designation_num + " :: stopped == false");
      int dir = getDirection(); //-1 for down, 0 for stopped, 1 for up
      location += dir*speed;
    }
    else if (stopped && stopTime > 0) {
      _DEBUG("Elevator #" + designation_num + " :: stopped && stopTime > 0");
      fill_elevator();
      stopTime--;
      //print(stopTime); 
    }
    else if (stopped && stopTime == 0){
      _DEBUG("Elevator #" + designation_num + " :: stopped && stopTime == 0");
      stopped = false;
      //future_event.add(floor(random(MAX_FLOORS)));
      //getDirection();
      stopTime = 5;
    }
  }
  
  void fill_elevator() {
    // first, process departing passengers
    if (passengers.size() > 0) {
      _DEBUG("Elevator #" + designation_num + " :: fill_elevator() started step 1");
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
      _DEBUG("Elevator #" + designation_num + " :: fill_elevator() started step 2");
      if (passengers.size() < 9) {
        for (int i = 0; i < 9; i++) {
          _DEBUG("Elevator #" + designation_num + " stopped at floor " + location);
          if (ELEVATOR_REQUEST_QUEUE.get(location).size() > 0 && passengers.size() < MAX_ELEVATOR_CAPACITY) {
          // if (i < ELEVATOR_REQUEST_QUEUE.get(location).size()) {
            _DEBUG("i = " + i + " :: ELEVATOR_REQUEST_QUEUE.get(location).size() = " + ELEVATOR_REQUEST_QUEUE.get(location).size());
            Person p = ELEVATOR_REQUEST_QUEUE.get(location).remove(0);
            passengers.add(p);
            //future_event.add(p.dest); // not needed, p.dest should already be on future_event list if SCHEDULE_FLOOR_QUEUE was used to add Person to floor queue
          }
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
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
    if (future_event.isEmpty()) // direction is always up for an elevator at floor 0
      direction = 1;
    else {
      if (location - future_event.peek() != 0)
        direction = (future_event.peek() - location)/(abs(location-future_event.peek()));
      else {
        direction = 0;
        stopped = true;
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
      _DEBUG("Elevator #" + designation_num + " is moving");
      int dir = getDirection(); // -1 for down, 0 for stopped, 1 for up
      location += dir*speed;
    }
    else if (stopped && stopTime > 0) {
      _DEBUG("Elevator #" + designation_num + " is stopped");
      fill_elevator();
      if (stopTime > 0) 
        stopTime--;
    }
    else if (stopped && stopTime == 0){
      _DEBUG("Elevator #" + designation_num + " is closing its doors");
      if (passengers.size() > 0)
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
          if (location > 0) {
            SCHEDULE_FLOOR_QUEUE(passengers.get(i), location);
          }
          for (int j = 0; j < future_event.size(); j++) {
            if (passengers.get(i).dest == future_event.get(j)) {
              _DEBUG("   !!!    " + future_event.get(j) + " removed from Elevator #" + designation_num);
              future_event.remove(j); 
            }
          }
          passengers.remove(i);
        }
      }
    }
    
    // second, actually fill the elevator
    if (stopped == true) {
      _DEBUG("Elevator #" + designation_num + " :: fill_elevator() started step 2");
      _DEBUG("Elevator #" + designation_num + " stopped at floor " + location);
      if (passengers.size() < 9) {
        for (int i = 0; i < 9; i++) {
          if (ELEVATOR_REQUEST_QUEUE.get(location).size() > 0 && passengers.size() < MAX_ELEVATOR_CAPACITY) {
            Person p = ELEVATOR_REQUEST_QUEUE.get(location).remove(0);
            passengers.add(p);
            _DEBUG("Person with destination " + passengers.get(i).dest + " loaded onto Elevator #" + designation_num);
            if (!future_event.contains(p.dest))
              future_event.add(p.dest); 
          }
        }
      }
    }
  }
  
  void SCHEDULE_FLOOR_QUEUE(final Person p, final int current_floor) {
    // Determine if next destination is non-zero
    if (p.single_trip)
      p.dest = 0;
    else {
      if (System.currentTimeMillis() - START_TIME <= DAY_LENGTH)
        p.dest = floor(random(MAX_FLOORS) + 1);
      else
        p.dest = 0;
    }
    final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(1);
    queue_add.schedule (new Runnable () {
      @Override 
      public void run() {
        ELEVATOR_REQUEST_QUEUE.get(current_floor).add(p);
        cont.request_elevator(current_floor, getDirection());
        _DEBUG("Person with destination " + p.dest + " has requested an elevator from floor " + current_floor);
      }  
    }, p.idle_time, TimeUnit.MILLISECONDS);
  }
}
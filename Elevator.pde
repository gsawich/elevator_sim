class Elevator {
  int location;
  int direction;
  int speed;
  int stopTime;
  int designation_num;
  boolean full;
  boolean stopped;
  
  Vector<Person> passengers = new Vector<Person>(MAX_ELEVATOR_CAPACITY); // sort by person's detination attribute
  ArrayList<Integer> future_event = new ArrayList<Integer>();
  
  Elevator() {
    location = 0;
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
      if (location - future_event.get(0) != 0)
        direction = (future_event.get(0) - location)/(abs(location-future_event.get(0)));
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
      _DEBUG("Elevator #" + designation_num + " is stopped at floor " + location);
      fill_elevator();
      if (stopTime > 0) 
        stopTime--;
    }
    else if (stopped && stopTime == 0){
      _DEBUG("Elevator #" + designation_num + " is closing its doors");
      if (future_event.size() > 0)
        stopped = false;
        
      stopTime = 5;
    }
  }
  
  void fill_elevator() {
    // first, process departing passengers  
    if (passengers.size() > 0) {
      boolean fullfillment = false;
      _DEBUG("Elevator #" + designation_num + " :: fill_elevator() started step 1");
      for (int i = 0; i < passengers.size(); i++) {
        if (location == passengers.get(i).dest) {
          fullfillment = true;
          if (location > 0)
            SCHEDULE_FLOOR_QUEUE(passengers.get(i), location);
          passengers.remove(i);
          future_event.remove(new Integer(location));
          Collections.sort(future_event);
          _DEBUG(" !!!! " + location + " removed from Elevator #" + designation_num + "'s event-list");
        }
      }
      if (!fullfillment) {
        future_event.remove(new Integer(location)); // phantom button press, real-world-like
        _DEBUG(" !p!p!p! " + location + " removed from Elevator #" + designation_num + "'s event-list");
      }
    }
    else if (passengers.isEmpty() && ELEVATOR_REQUEST_QUEUE.get(location).isEmpty()) {
      future_event.remove(new Integer(location));
      _DEBUG(" !p!p!p! " + location + " removed from Elevator #" + designation_num + "'s event-list");
    }
        
    // second, actually fill the elevator
    if (stopped == true) {
      _DEBUG("Elevator #" + designation_num + " :: fill_elevator() started step 2");
      if (passengers.size() < 9) {
        for (int i = 0; i < 9; i++) {
          if (ELEVATOR_REQUEST_QUEUE.get(location).size() > 0 && passengers.size() < MAX_ELEVATOR_CAPACITY) {
            Person p = ELEVATOR_REQUEST_QUEUE.get(location).remove(0);
            passengers.add(p);
            _DEBUG("Person with destination " + passengers.get(i).dest + " loaded onto Elevator #" + designation_num);
            if (!future_event.contains(p.dest)) {
              future_event.add(p.dest);
              Collections.sort(future_event);
            }
          }
        }
      }
      if (stopTime == 0)
        stopped = false;
    }
  }
  
  void SCHEDULE_FLOOR_QUEUE(final Person p, final int current_floor) {
    // Determine if next destination is non-zero
    if (p.single_trip)
      p.dest = 0;
    else {
      if (System.currentTimeMillis() - START_TIME <= DAY_LENGTH)
        p.dest = floor(random(MAX_FLOORS - 1));
      else
        p.dest = 0;
    }
    final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(5);
    queue_add.schedule (new Runnable () {
      @Override 
      public void run() {
        ELEVATOR_REQUEST_QUEUE.get(current_floor).add(p);
        Elevator temp = cont.request_elevator(current_floor, getDirection());
        _DEBUG("Person with destination " + p.dest + " has requested Elevator #" + temp.designation_num + " from floor " + current_floor);
        
        // Print the Elevator-Request-Queue for floor(location)
        if (__DEBUG__) {
          print("Person-Destination-List for ERQ" + location + " is: ");
          if (ELEVATOR_REQUEST_QUEUE.get(location).isEmpty())
            print("EMPTY");
          else {
            for (int i = 0; i < ELEVATOR_REQUEST_QUEUE.get(location).size(); i++) 
              print(ELEVATOR_REQUEST_QUEUE.get(location).get(i).dest + " ");
          }  
          _DEBUG(" ");
        }
      }  
    }, p.idle_time, TimeUnit.MILLISECONDS);
  }
}
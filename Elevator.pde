class Elevator {
  public int location;
  public int direction;
  public int speed;
  public int stopTime;
  public int designation_num;
  public boolean sort_reverse;
  public boolean full;
  public boolean stopped;
 
  public Vector<Person> passengers = new Vector<Person>(MAX_ELEVATOR_CAPACITY); 
  public ArrayList<Integer> future_event = new ArrayList<Integer>(); // sorted by increasing destinations
  
  Elevator() {
    location = 0;
    direction = 0;
    stopped = true;
    full = false;
    sort_reverse = false;
    speed = 1;
    stopTime = 5;
    designation_num = 0;
  }
  
  public int getDirection() {
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
  
  public int getPersonDirection(int p_dest) {
    int p_dir = 0; // same values as elevator
    if (p_dest - location > 0)
      p_dir = 1;
    else
      p_dir = -1;
      
    return p_dir;
  }
  
  public boolean isFull() {
    if (passengers.size() == MAX_ELEVATOR_CAPACITY)
      full = true;
    else
      full = false;
    return full;
  }
  
  public int getLocation(){
    return location;
  }
  
  public int getPassengers(){
    return passengers.size();
  }
  
  public boolean[] getPassType(){
   boolean[] passType = new boolean[passengers.size()];
   for (int i = 0; i < passengers.size(); i ++){
     passType[i] = passengers.get(i).type; 
   }
   return passType;
  }
  
  public void move() {
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
  
  public void fill_elevator() {
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
        
        _DEBUG(" !!!! " + location + " removed from Elevator #" + designation_num + "'s event-list");
      }
    }
    else if (passengers.isEmpty() && ELEVATOR_REQUEST_QUEUE.get(location).isEmpty()) {
      future_event.remove(new Integer(location));
      future_event.add(new Integer(0));
      _DEBUG(" !!!! " + location + " removed from Elevator #" + designation_num + "'s event-list");
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
              if ((getDirection() == 1 && p.dest - location > 0) || 
                  (getDirection() == -1 && p.dest - location < 0)) {
                Collections.sort(future_event);
                
                if (getDirection() == -1 && !sort_reverse)
                  Collections.reverse(future_event);
                  
                if (getDirection() == 1 && sort_reverse)
                  sort_reverse = false;
              }
            }
          }
        }
      }
      if (stopTime == 0) {
        stopped = false;
      }
    }
  }
  
  public void SCHEDULE_FLOOR_QUEUE(final Person p, final int current_floor) {
    // Record wait time statistics
    STATS.gather_wait_times(p.queue_arrival_time);
    
    // Determine if next destination is non-zero
    if (p.single_trip)
      p.dest = 0;
    else {
      if (current_sim_time() < DAY_LENGTH) {
        p.dest = floor(random(MAX_FLOORS - 1));
        p.idle_time = floor(random(DAY_LENGTH - current_sim_time()));
        p.queue_arrival_time = 0;
      }
      else
        p.dest = 0;
    }
    final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(5);
    queue_add.schedule (new Runnable () {
      @Override 
      public void run() {
        ELEVATOR_REQUEST_QUEUE.get(current_floor).add(p);
        p.queue_arrival_time = current_sim_time();
        Elevator temp = cont.request_elevator(current_floor, getPersonDirection(p.dest));
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
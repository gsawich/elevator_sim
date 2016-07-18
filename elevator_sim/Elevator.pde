class Elevator {
  int location;
  int direction;
  boolean full;
  boolean stopped;
  int stopTime;
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
    future_event.add(floor(random(MAX_FLOORS)));
    future_event.add(floor(random(MAX_FLOORS)));
    future_event.add(floor(random(MAX_FLOORS)));
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
      print(stopTime); 
    }
    else if (stopTime == 0){
      stopped = false;
      future_event.add(floor(random(MAX_FLOORS)));
      getDirection();
      stopTime = 5;
    }
  }
  
  void fill_elevator() {
    // first, process departing passengers
    if (passengers.size() != 0) {
      for (int i = 0; i < passengers.size(); i++) {
        if (location == passengers.get(i).dest) {
          if (location != 0)
            //SCHEDULE_FLOOR_QUEUE(passengers.get(i), location);
          passengers.remove(i);
        }
      }
    }
    
    // second, actually fill the elevator
    if (stopped == true) {
      while (passengers.size() < MAX_ELEVATOR_CAPACITY) {
        Person newPassenger = new Person();//ELEVATOR_REQUEST_QUEUE[location][getDirection()].remove();
        passengers.add(newPassenger);
        future_event.add(newPassenger.dest);
      }
    }
  }
}
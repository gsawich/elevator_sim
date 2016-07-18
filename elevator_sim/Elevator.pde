
class Elevator {
  int location;
  int direction;
  boolean full;
  boolean stopped;
  Vector<Person> passengers = new Vector<Person>(MAX_ELEVATOR_CAPACITY);
  LinkedList<Integer> future_event = new LinkedList<Integer>();
  
  Elevator() {
    location = 0; //floor(random(MAX_FLOORS));
    direction = 0;
    stopped = true;
    full = false;
  }
  
  int getDirection() {
    direction = (location - future_event.peek())/(abs(location-future_event.peek()));
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

  }
  
  void fill() {
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
    if (isFull() == false) {
      while (passengers.size() < MAX_ELEVATOR_CAPACITY) {
        Person newPassenger = ELEVATOR_REQUEST_QUEUE[location][getDirection()].remove();
        passengers.add(newPassenger);
        future_event.add(newPassenger.dest);
      }
    }
  }
}
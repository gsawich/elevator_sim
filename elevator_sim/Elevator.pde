
class Elevator {
  int location;
  int direction;
  boolean full;
  Vector<Person> passengers = new Vector<Person>(MAX_ELEVATOR_CAPACITY);
  LinkedList<Integer> future_event = new LinkedList<Integer>();
  
  Elevator() {
    location = floor(random(MAX_FLOORS));
    direction = 0;
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
}
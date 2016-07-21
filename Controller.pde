class Controller {
  private Elevator[] bank;
  
  Controller() {
    bank = new Elevator[NUM_ELEVATORS];
    for (int i=0; i < NUM_ELEVATORS; i++){
      bank[i] = new Elevator();
      bank[i].designation_num = i + 1;
    }
  }
  
  public Elevator request_elevator(int floor, int dir){
    //Find a non-full elevator going in the right direction, then put the request in the future event list
    int bestDist = MAX_FLOORS; // Worst case
    int bestEle = 0;
    for (int i=0; i < NUM_ELEVATORS; i++) {
      if (!(bank[i].isFull())) { //ignore full elevators
        if ((bank[i].getDirection()*dir) >=0) { //if elevator is going in the right direction or stopped
          int dist = (bank[i].getLocation() - floor);
          if (dist < bestDist) {
            bestDist = dist;
            bestEle = i;
          }
        }
      }
    }
    if (floor > 0 && !bank[bestEle].future_event.contains(floor)) {
      bank[bestEle].future_event.add(floor);
      if ((bank[bestEle].getDirection() == 1 && floor - bank[bestEle].location > 0) || 
          (bank[bestEle].getDirection() == -1 && floor - bank[bestEle].location < 0))
        Collections.sort(bank[bestEle].future_event);
    }
    
    return bank[bestEle]; // return-type added for debugging purposes only
  }
  
  private Elevator getElevator(int i) {
    return bank[i];
  }
  
  public void inc() {
    for (Elevator e:bank) {
      e.move();
      
      // Debugging future_event and person-destination lists
      if (__DEBUG__) {
        print("Future-Event-List for Elevator #" + e.designation_num + " is: ");
        if (e.future_event.isEmpty())
          print("EMPTY");
        else {
          for (int i = 0; i < e.future_event.size(); i++) 
            print(e.future_event.get(i) + " ");
        }
        _DEBUG(" ");
        
        print("Person-Destination-List for Elevator #" + e.designation_num + " is: ");
        if (e.passengers.isEmpty())
          print("EMPTY");
        else {
          for (int i = 0; i < e.passengers.size(); i++)
            print(e.passengers.get(i).dest + " ");
        }
        _DEBUG(" ");
      }
    }
  }
}
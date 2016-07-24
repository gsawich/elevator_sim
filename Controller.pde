class Controller {
  public Elevator[] bank;
  
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
      //if (!(bank[i].isFull())) { //ignore full elevators
      int eleDir = bank[i].getDirection();
        if ((eleDir*dir) <=0) { //if elevator is going in the right direction or stopped
          if ((bank[i].getLocation() - floor)*eleDir <= 0) {
            int dist = abs(bank[i].getLocation() - floor);
            if (dist < bestDist) {
              bestDist = dist;
              bestEle = i;
          }
          }
        }
      //}
    }
    if (!bank[bestEle].future_event.contains(floor)) {
        bank[bestEle].future_event.add(floor);
        bank[bestEle].sortEvents();
    }
    
    return bank[bestEle]; // return-type added for debugging purposes only
  }
  
  private Elevator getElevator(int i) {
    return bank[i];
  }
  
  public void inc() {
    for (Elevator e:bank) {
     /* if (e.future_event)
        Collections.sort(e.future_event);*/
        
      e.move();
      STATS.gather_elevator_capacity();
      
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
    
    if (_DEBUG_QUEUE_STATUS_VIEW_) {
      for (int i = 0; i < ELEVATOR_REQUEST_QUEUE.size(); i++) {
          print("Person-Destination-List for ERQ" + i + " is: ");
          if (ELEVATOR_REQUEST_QUEUE.get(i).isEmpty())
            print("EMPTY");
          else {
            for (int j = 0; j < ELEVATOR_REQUEST_QUEUE.get(i).size(); j++)
              print(ELEVATOR_REQUEST_QUEUE.get(i).get(j).dest + " ");
          }
          println(" ");
      }
    }
  }
}
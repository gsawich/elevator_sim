class Controller {
  Elevator[] bank;
  
  Controller() {
    bank = new Elevator[NUM_ELEVATORS];
    for (int i=0; i < NUM_ELEVATORS; i++){
      bank[i] = new Elevator();
      bank[i].designation_num = i + 1;
    }
  }
  
  void request_elevator(int floor, int dir){
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
    bank[bestEle].future_event.add(floor);
  }
  
  Elevator getElevator(int i) {
    return bank[i];
  }
  
  void inc() {
    for (Elevator e:bank) {
      e.move();
    }
  }
}
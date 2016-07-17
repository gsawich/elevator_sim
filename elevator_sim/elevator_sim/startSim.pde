import java.util.concurrent.*;

class StartSimulation {

  public void main (String[] args) {
      // Simulation events are directed here
      Elevator elevator = new Elevator();
      //GENERATE_PEOPLE();
      FILL_ELEVATOR(elevator, 0); // start filling the initial elevator-request queue
  }
  
  public void FILL_ELEVATOR(Elevator e, int current_floor) {
    // first, process departimg passengers
    if (e.passengers.size() != 0) {
      for (int i = 0; i < e.passengers.size(); i++) {
        if (current_floor == e.passengers.get(i).dest) {
          if (current_floor != 0)
            SCHEDULE_FLOOR_QUEUE(e.passengers.get(i), current_floor);
          e.passengers.remove(i);
        }
      }
    }
    
    // second, actually fill the elevator
    if (e.in_use == 1) {
      while (e.passengers.size() < MAX_ELEVATOR_CAPACITY) {
        e.passengers.get(e.passengers.size()) = ELEVATOR_REQUEST_QUEUE[current_floor].remove();
        SCHEDULE_ELEVATOR(e.passengers[e.passengers.size()].destination);
      }
    }
  }
  
  public void SCHEDULE_FLOOR_QUEUE(final Person p, final int current_floor) {
    final ScheduledThreadPoolExecutor queue_add = new ScheduledThreadPoolExecutor(1);
    queue_add.schedule (new Runnable () {
      @Override 
      public void run() {
        ELEVATOR_REQUEST_QUEUE[current_floor].add(p);
      }  
    }, p.idle_time, TimeUnit.MILLISECONDS);
  }
}
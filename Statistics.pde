public class Statistics {
  /*
  This class must facilitate the gathering of the following statistics:
    1. Average wait-time for an elevator among all Persons in a given day (simulation run time)
    2. Average and maximum queue lengths for each floor and for the entire system
    3. Elevator usage statistics relating to how the elevators are used during the busiest and slowest times of the day
    4. Maximum, minimum and average number of bodies in an elevator overall and at peak times
    5. Average trip-length for all persons as they ride the elevator to and from their destination(s)
  */
  
  private float call_count;
  private ArrayList<Float> QUEUE_LENGTH_AVG;
  private ArrayList<Float> QUEUE_LENGTH_MAX;
  private int SINGLE_QUEUE_MAX;
    
  Statistics() {
    call_count = 0.0;
    QUEUE_LENGTH_AVG = new ArrayList<Float>();
    QUEUE_LENGTH_MAX = new ArrayList<Float>();
    
    // Change default ArrayList values from "null" to "0"
    for (int i = 0; i < MAX_FLOORS; i++) {
      QUEUE_LENGTH_AVG.add(0.0);
      QUEUE_LENGTH_MAX.add(0.0);
    }
    
    SINGLE_QUEUE_MAX = 0;
  }
  
  // Get the average wait-time for an elevator among all Persons during the simulation run time
  public void gather_wait_times() {}
  
  // Get the average and maximum queue lengths for each floor and for the entire system
  public void gather_queue_lengths() {
    call_count++;
    for (int i = 0; i < MAX_FLOORS; i++) {
      float next_stat = ELEVATOR_REQUEST_QUEUE.get(i).size();
      float current_size = (QUEUE_LENGTH_AVG.get(i) * (call_count - 1)) + next_stat;
      QUEUE_LENGTH_AVG.set(i, current_size / call_count);
      
      if (next_stat > QUEUE_LENGTH_MAX.get(i)) {
        QUEUE_LENGTH_MAX.set(i, next_stat);
        SINGLE_QUEUE_MAX = i;
      }
    }
  }
  
  // Determine the usage statistics for each elevator
  public void gather_elevator_usage() {
    // debugging statements are a good pivot point for this
  }
  
  // Get the minimum, maximum, and average number of bodies in an elevator during simulation run time
  public void gather_body_count() {}
  
  // Get the average trip-length a.k.a the amount of time a person waits on the elevator while going to their destination
  public void gather_trip_length() {}
  
  // Generate a report of the final statistics collected throughout the simulation run-time
  public void generate_report() {
    String f0 = new String(new char[22]).replace("\0", " ");
    String f1 = new String(new char[23]).replace("\0", "+=");
    String f2 = new String(new char[7]).replace("\0", "+=");
    String f3 = new String(new char[83]).replace("\0", "-");
    String f4 = new String(new char[5]).replace("\0", ".");
    String f5 = new String(new char[10]).replace("\0", " ");
    String f6 = "RESULTS (ANALYSIS)";
    String stat_1_0 = "Overall average queue length: " + mean(QUEUE_LENGTH_AVG);
    String stat_1_1 = "Overall maximum queue length: " + Collections.max(QUEUE_LENGTH_MAX) + 
                      " (on floor " + SINGLE_QUEUE_MAX + ")";
    String[] stat_1_2 = gen_arr("Average queue length for Floor ", QUEUE_LENGTH_AVG);
    String[] stat_1_3 = gen_arr("Maximum queue length for Floor ", QUEUE_LENGTH_MAX);
    
    // Report header
    print(f0 + f1 + "\n" + f0 + f2 + f6 + f2 + "\n" + f0 + f1 + "\n\n" + f3 + "\n\n");
    
    // Report data
    print(f0 + stat_1_0 + "\n" + stat_1_1 + "\n" + f5 + f4 + "\n");
    for (String a : stat_1_2)
      println(f0 + a);
    for (String b : stat_1_3)
      println(f0 + b);
  }
  
  // Helper method(s) for the Statistics class
  /*private float seconds_elapsed() {
    return (System.currentTimeMillis() - START_TIME) / 1000;
  }*/
  
  private float mean(ArrayList<Float> l) {
    float sub_mean = 0.0;
    for (int i = 0; i < l.size(); i++)
      sub_mean += l.get(i);
    
    return sub_mean / (float) l.size();
  }
  
  private String[] gen_arr(String msg, ArrayList<Float> l) {
    String [] x = new String[l.size()];
    for (int i = 0; i < l.size(); i++)
      x[i] = msg + i + ": " + l.get(i);

    return x;
  }
}
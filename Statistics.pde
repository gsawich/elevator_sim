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
      
      if (next_stat > QUEUE_LENGTH_MAX.get(i))
        QUEUE_LENGTH_MAX.set(i, next_stat);
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
    String _str_build_ = "\0";
    String _newline_ = "\n";
    String report_style = "+=";
    String section_style = "-";
    String section_break_style = ".";
    String space = " ";
    
    String f0 = new String(new char[25]).replace(_str_build_, space);
    String f1 = new String(new char[24]).replace(_str_build_, report_style);
    String f2 = new String(new char[7]).replace(_str_build_, report_style);
    String f3 = new String(new char[70]).replace(_str_build_, section_style);
    String f4 = new String(new char[20]).replace(_str_build_, section_break_style);
    String f5 = new String(new char[15]).replace(_str_build_, space);
    
    String report_title = " RESULTS (ANALYSIS) ";
    String report_header = f0 + f1 + _newline_ + f0 + f2 + report_title + f2 + _newline_ + f0 + f1;
    String section_header_a = _newline_ + _newline_ + f5 + f3 + _newline_ + f0 + f5;
    String section_header_b = _newline_ + f5 + f3 + _newline_ + _newline_;

    String stat_1 = "  Queue Lengths";
    String stat_1_0 = "Overall average queue length: " + mean(QUEUE_LENGTH_AVG);
    String stat_1_1 = "Overall maximum queue length: " + Collections.max(QUEUE_LENGTH_MAX) + 
                      " (on floor " + QUEUE_LENGTH_MAX.indexOf(Collections.max(QUEUE_LENGTH_MAX)) + ")";
    String[] stat_1_2 = gen_arr("Average queue length for Floor ", QUEUE_LENGTH_AVG);
    String[] stat_1_3 = gen_arr("Maximum queue length for Floor ", QUEUE_LENGTH_MAX);
    
    // Report Header
    print(report_header);
    
    // Header: Queue Lengths
    print(section_header_a + stat_1 + section_header_b);
    
    // Data: Queue Lengths 
    print(f0 + stat_1_0 + _newline_ + f0 + stat_1_1 + _newline_ + f5 + f0 + f4 + _newline_);
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
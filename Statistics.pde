public class Statistics {
  // This class must facilitate the gathering of the following statistics:
  private int STAT0; // Average wait-time for an elevator among all Persons in a given day (simulation run time)
  private int STAT1; // Average and maximum queue lengths for each floor and for the entire system
  private int STAT2; // Maximum and average number of bodies in an elevator overall and at peak times
  private int STAT3; // Average trip-length for all persons as they ride the elevator to and from their destination(s)
  
  private ArrayList<Integer> call_count;
  private ArrayList<Float> QUEUE_LENGTH_AVG;
  private ArrayList<Float> QUEUE_LENGTH_MAX;
  private ArrayList<Float> ELEVATOR_AVG_CAPACITY;
  private ArrayList<Integer> ELEVATOR_MAX_CAPACITY;
  private float PERSON_WAIT_TIME;
  private float MAX_WAIT_TIME;
    
  Statistics() {
    STAT0 = 0;
    STAT1 = 0;
    STAT2 = 0;
    STAT3 = 0;
    
    call_count = new ArrayList<Integer>();
    QUEUE_LENGTH_AVG = new ArrayList<Float>();
    QUEUE_LENGTH_MAX = new ArrayList<Float>();
    ELEVATOR_AVG_CAPACITY = new ArrayList<Float>();
    ELEVATOR_MAX_CAPACITY = new ArrayList<Integer>();
    PERSON_WAIT_TIME = 0.0;
    MAX_WAIT_TIME = 0.0;
    
    // Change default ArrayList values from "null" to "0"
    for (int i = 0; i < 4; i++)
      call_count.add(0); 
    for (int i = 0; i < MAX_FLOORS; i++) {
      QUEUE_LENGTH_AVG.add(0.0);
      QUEUE_LENGTH_MAX.add(0.0);
    }
    for (int i = 0; i < NUM_ELEVATORS; i++) {
      ELEVATOR_AVG_CAPACITY.add(0.0);
      ELEVATOR_MAX_CAPACITY.add(0);
    }
  }
  
  // Get the average wait-time for an elevator among all Persons during the simulation run time
  public void gather_wait_times(float queue_arrival) {
    float new_time = current_sim_time() - queue_arrival;
    call_count.set(STAT0, call_count.get(STAT0) + 1);
    PERSON_WAIT_TIME += new_time;
    
    if (new_time > MAX_WAIT_TIME)
      MAX_WAIT_TIME = new_time;
  }
  
  // Get the average and maximum queue lengths for each floor and for the entire system
  public void gather_queue_lengths() {
    call_count.set(STAT1, call_count.get(STAT1) + 1);
    for (int i = 0; i < MAX_FLOORS; i++) {
      float next_stat = ELEVATOR_REQUEST_QUEUE.get(i).size();
      float current_size = (QUEUE_LENGTH_AVG.get(i) * (call_count.get(STAT1) - 1)) + next_stat;
      QUEUE_LENGTH_AVG.set(i, current_size / call_count.get(STAT1));
      
      if (next_stat > QUEUE_LENGTH_MAX.get(i))
        QUEUE_LENGTH_MAX.set(i, next_stat);
    }
  }
    
  // Get the minimum, maximum, and average number of bodies in an elevator during simulation run time
  public void gather_elevator_capacity() {
    call_count.set(STAT2, call_count.get(STAT2) + 1);
    for (int i = 0; i < cont.bank.length; i++) {
      int next_stat = cont.bank[i].getPassengers();
      float current_size = (ELEVATOR_AVG_CAPACITY.get(i) * (call_count.get(STAT2) - 1)) + next_stat;
      ELEVATOR_AVG_CAPACITY.set(i, current_size / call_count.get(STAT2));
    
      if (next_stat > ELEVATOR_MAX_CAPACITY.get(i))
        ELEVATOR_MAX_CAPACITY.set(i, next_stat);
    }
  }
  
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

    String stat_0 = "  Wait Times   ";
    String stat_0_0 = "Average wait time for an elevator was: " + get_real_time(PERSON_WAIT_TIME / call_count.get(STAT0));
    String stat_0_1 = "Maximum wait time for an elevator was: " + get_real_time(MAX_WAIT_TIME);
    String stat_1 = "  Queue Lengths";
    String stat_1_0 = "Overall average queue length: " + mean(QUEUE_LENGTH_AVG);
    String stat_1_1 = "Overall maximum queue length: " + Collections.max(QUEUE_LENGTH_MAX) + 
                      " (on Floor " + QUEUE_LENGTH_MAX.indexOf(Collections.max(QUEUE_LENGTH_MAX)) + ")";
    String[] stat_1_2 = gen_arr("Average queue length for Floor ", QUEUE_LENGTH_AVG);
    String[] stat_1_3 = gen_arr("Maximum queue length for Floor ", QUEUE_LENGTH_MAX);
    String stat_2 = "  Elevator Capacities  ";
    String stat_2_0 = "Overall average elevator capacity: " + mean(ELEVATOR_AVG_CAPACITY);
    String stat_2_1 = "Overall maximum elevator capacity: " + Collections.max(ELEVATOR_MAX_CAPACITY) + 
                      " (on Elevator " + ELEVATOR_MAX_CAPACITY.indexOf(Collections.max(ELEVATOR_MAX_CAPACITY)) + ")";
    String[] stat_2_2 = gen_arr("Average capacity for Elevator #", ELEVATOR_AVG_CAPACITY);
    String[] stat_2_3 = gen_int_arr("Maximum capacity for Elevator #", ELEVATOR_MAX_CAPACITY);
    
    // Report Header
    print(report_header);
    
    // Header: Wait Times
    print(section_header_a + stat_0 + section_header_b);
    
    // Data: Wait Times
    print(f0 + stat_0_0 + _newline_ + f0 + stat_0_1);
    
    // Header: Queue Lengths
    print(section_header_a + stat_1 + section_header_b);
    
    // Data: Queue Lengths 
    print(f0 + stat_1_0 + _newline_ + f0 + stat_1_1 + _newline_ + f5 + f0 + f4 + _newline_);
    for (String a : stat_1_2)
      println(f0 + a);
    for (String b : stat_1_3)
      println(f0 + b);
      
    // Header: Elevator Capacities
    print(section_header_a + stat_2 + section_header_b);
    
    // Data: Elevator Capacities
    print(f0 + stat_2_0 + _newline_ + f0 + stat_2_1 + _newline_ + f5 + f0 + f4 + _newline_);
    for (String c : stat_2_2)
      println(f0 + c);
    for (String d : stat_2_3)
      println(f0 + d);
  }
  
  // Helper method(s) for the Statistics class  
  private String get_real_time(float ms_time) {
    float x = (ms_time / 2.77) / 60;
    return x + " minutes";
  }
  
  private float mean(ArrayList<Float> l) {
    float sub_mean = 0.0;
    for (int i = 0; i < l.size(); i++)
      sub_mean += l.get(i);
    
    return sub_mean / (float) l.size();
  }
  
  private String[] gen_arr(String msg, ArrayList<Float> l) {
    String[] x = new String[l.size()];
    for (int i = 0; i < l.size(); i++)
      x[i] = msg + i + ": " + l.get(i);

    return x;
  }
  
  private String[] gen_int_arr(String msg, ArrayList<Integer> l) {
    String[] x = new String[l.size()];
    for (int i = 0; i < l.size(); i++)
      x[i] = msg + i + ": " + l.get(i);

    return x;
  }
}
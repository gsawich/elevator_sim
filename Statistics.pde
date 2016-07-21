public class Statistics {
  /*
  This class must facilitate the gathering of the following statistics:
    1. Average wait-time for an elevator among all Persons in a given day (simulation run time)
    2. Average and maximum queue lengths for each floor and for the entire system
    3. Elevator usage statistics relating to how the elevators are used during the busiest and slowest times of the day
    4. Maximum, minimum and average number of bodies in an elevator overall and at peak times
    5. Average trip-length for all persons as they ride the elevator to and from their destination(s)
  */
  
  // Get the average wait-time for an elevator among all Persons during the simulation run time
  void gather_wait_times() {}
  
  // Get the average and maximum queue lengths for each floor and for the entire system
  void gather_queue_lengths() {}
  
  // Determine the usage statistics for each elevator
  void gather_elevator_usage() {
    // debugging statements are a good pivot point for this
  }
  
  // Get the minimum, maximum, and average number of bodies in an elevator during simulation run time
  void gather_body_count() {}
  
  // Get the average trip-length a.k.a the amount of time a person waits on the elevator while going to their destination
  void gather_trip_length() {}
}
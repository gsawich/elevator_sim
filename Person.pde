class Person {
  public int dest;
  public int idle_time;
  public boolean single_trip;
  public boolean type;
  public int designation_num = 0;
  
  Person() {
    dest = floor(random(MAX_FLOORS - 1)); // Person goes to a random floor
    while (dest == 0)
      dest = floor(random(MAX_FLOORS - 1));
    type = false;
    idle_time = 0;
    single_trip = false;
    if (random(2) > 1) type = true; // Either false for employee, true for guest
    if (!type) {
      if (random(2) > 1) single_trip = true; // Employees may go to a different floor
      idle_time = floor(random(DAY_LENGTH - 1000));
    }
    else {
      idle_time = floor(random((DAY_LENGTH - 1000) / 2));
    }
    
    inc_p_count();
  }
  
  
  
  private void inc_p_count() {
    __debug__p_count++;
  }
}
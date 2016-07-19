class Person {
  int floor;
  int dest;
  int idle_time;
  boolean single_trip;
  boolean type;
  
  Person() {
    floor = 0;
    dest = floor(random(MAX_FLOORS)); // Person goes to a random floor
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
  }
}
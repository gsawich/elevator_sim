# Simulation Project: Elevator System
###### _Group Members: Justin Shapiro and Gabriel Sawich_

### Purpose
For this project, we will be simulating an elevator system similar to those that can be found in tall office buildings with multiple floors and multiple elevators. The purpose of such a simulation will be to find the best algorithms/methods for elevator deployment in a given system that serves the most amount of people in the most efficient manner possible, minimizing wait times of people requesting elevators. We will be developing a model such that a process-based approach to a discrete-event simulation can be used to achieve this goal, focusing on the Modeling and Simulation (M&S) aspect of simulation. The simulation will be implemented in Java using the [Processing](https://processing.org/) graphics library. 

### Implementation
The amount of people that an elevator can hold must be considered. Although an `Elevator` in real life is limited to a weight limit, it is more realistic to limit an `Elevator` to a certain number of bodies, since elevators rarely reach their weight limit. The sum of all bodies on an `Elevator` must not exceed the n×n amount of people an Elevator can hold. A global constant `MAX_ELEVATOR_PERSONS` will determine the maximum number of `Person`s that an `Elevator` can hold at any given time.

Each floor of our building will have an _elevator-request queue_. We must have a method `DEPLOY_ELEVATOR` that acts as the elevator `Controller`. It analyses the _elevator-request queue_ s of each floor and determines how to deploy the `Elevator`s available to the system to handle requests. This method will query the `location` attribute of each `Elevator` and find an `Elevator` no closer than two floors away to stop at the requested floor. `direction` of the `Elevator` will also be considered (the `location` attribute will be negative for descending `Elevator`s, and positive for ascending `Elevator`s.)

That being said, an `Elevator` should be treated as an object, having at least the following three attributes:
* `location` (_a numerical value of which floor the elevator is on, or has just passed_)
* `stopped` (_determines if an `Elevator` is stopped such that `FILL_ELEVATOR` should be called_)
* `passengers` (_a `Vector` that stores all `Person`s on an `Elevator` at any given time_)
	
We need a method `GENERATE_PEOPLE` that generates `Person`s to place in the initial _elevator-request queue_ (on floor 0). `Person`s may need to be generated in a frequency that varies depending on the time of day. That is, we may need to determine the amount of `Person`s that get generated per fixed time period. The number of `Person`s generated in the morning (for example) when everybody is arriving for work will be higher than mid-afternoon.

A `Person` should also be treated as an object, having at least the following four attributes:
* `dest` (_the current floor they are going to/coming from_)
* `idle_time` (_the amount of time a Person spends at their destination before getting back on a queue_)
* `single_trip` (_0 if a person will be going in-between floors throughout the day, 1 if the Person is simply going to one floor during the day and leaving via the first floor that same day_)
* `type` (_used to designate the person as an employee or guest, which helps differentiate Persons_)

When a `Person` is accepted by an `Elevator`, there will be a method `SCHEDULE_ELEVATOR` that modifies the `future_event` list (that is, performs interrupts) of the `Elevator` based on a `Person`’s `dest` attribute. The method `FILL_ELEVATOR` will be responsible for taking `Person`s off of the queue and putting them onto an `Elevator`, making sure that the given `Elevator` does not exceed its n×n body limit. There will be a method `SCHEDULE_FLOOR_QUEUE` that maintains an _elevator-request_ queue based on the `idle_time` attribute of each `Person` introduced to the system. This method will determine when and where to add a `Person` to an _elevator-request queue_.

### Data Analysis
The meaningfulness of this simulation will be demonstrated through the analysis of different statistics. Some of these statistics we plan on measuring are as follows:
* Average wait-time for an elevator among all Persons in a given day (simulation run time)
* Average and maximum queue lengths for each floor and for the entire system
* Elevator usage statistics relating to how the elevators are used during the busiest and slowest times of the day
* Maximum, minimum and average number of bodies in an elevator overall and at peak times
* Average trip-length for all persons as they ride the elevator to and from their destination(s)

Additional statistics may be collected as the model is developed and tested. Through the analysis of these various statistics produced by the simulation, the original purpose of finding the most efficient algorithms and methods for elevator deployment will be achieved. The analysis of these particular statistics is useful to both elevator manufacturers and businesses looking to purchase an elevator system. Manufacturers can use these statistics to optimize the efficiency of their elevators and businesses can see how a given elevator system can suit the needs of their building. Given that the model currently being developed has the ability to change the number of floors of a building, the number of people using the elevators, the speed of the elevators, and (possibly) the number of elevators that serve a building, this simulation and its associated statistics from its results can be very useful to all parties involved in the placement of an elevator system within a building. 

### Conceptual Model
![elevator_diagram](http://i.imgur.com/4lNESC9.jpg "Conceptual Model for an elevator system simulation")

### Computational Model (rough-draft / pseudocode)
```
// limiting variables
MAX_ELEVATOR_CAPACITY ? 9 // defines a 3x3 elevator
MAX_FLOORS ? 30 // arbitrary 
MAX_EMPLOYEE ? 600
MAX_GUESTS ? 400
LENGTH_OF_DAY ? 90000 // 10000ms per real-world hour, 8-5 workday
ELEVATOR-REQUEST-QUEUE[MAX_FLOORS]

// These Racket declarations may be used
/*(define future-event-list (make-parameter '()))
(define current-time (make-parameter #f))*/

// the three elevators for the simulation
// explicit declaration may not be needed
/* Elevator ELV1
Elevator ELV2
Elevator ELV3 */

// class declarations for objects
Class: Person
	Public destination 
	Public idle_time
	Public single_trip
	Public person_type
End Class

Class: Elevator
	Public location
	Public in_use // 0 if no, 1 if yes
	Public passengers[MAX_ELEVATOR_CAPACITY] // intended to be a vector
	Public future-event-list 
End Class

// methods
Method INIT_SYSTEM: 
	for i = 0 to MAX_FLOORS - 1 // generate a number of floor queues equal to MAX_FLOORS
		define queue curr_queue
		ELEVATOR-REQUEST-QUEUE[i] ? curr_queue
	// more things may be needed here
End Method

Method GENERATE_PEOPLE:
	emp_count ? 0
	guest_count ? 0 
	while emp_count ? MAX_EMPLOYEE OR guest_count ? MAX_GUEST
		Person p
		p.destination ? RANDOM(1, MAX_FLOORS)
		if emp_count ? MAX_EMPLOYEE
			p.person_type ? 0 
			emp_count ? emp_count + 1
		else
			p.person_type ? 0 
			guest_count ? guest_count + 1
		if person_type = 1
			p.idle_time ? RANDOM(1000, LENGTH_OF_DAY / 2)
			p.single_trip ? RANDOM(0, 1) // 0 if no, 1 if yes
		else
			p.single_trip ? 0
		enqueue ELEVATOR-REQUEST-QUEUE[0] with p
End Method
	
Method FILL_ELEVATOR(elevator, current_floor):
	// first, process departing passengers
	if elevator.passengers,length ? 0
		for i = 0 to elevator.passengers.length
			if current_floor = elevator.passengers[i].destination
				if current_floor ? 0
					SCHEDULE_FLOOR_QUEUE(elevator.passengers[i], current_floor)
				elevator.passengers.pop(i)
	// second, actually fill the elevator		
	if elevator.in_use = 1
		while elevator.passengers.length < MAX_ELEVATOR_CAPACITY
			elevator.passengers[elevator.passengers.size] ? dequeue ELEVATOR-REQUEST-QUEUE[f]
			SCHEDULE_ELEVATOR(elevator.passengers[elevator.passengers.size].destination)
End Method

Method SCHEDULE_FLOOR_QUEUE(person, floor): // psedocode here isn't parallel to implementation
	schedule event:
		event_schedule_time = current-time
		define the event as:
			if current-time >= event_schedule_time + p.idle_time
				 enqueue ELEVATOR-REQUEST-QUEUE[floor] with person
End Method
SC
Method SCHEDULE_ELEVATOR(new_destination): // psedocode here isn't parallel to implementation
	schedule event:
		define the event as:
			if elevator.current_floor = new_destination ± 2 // see comment below
				controller.stop_elevator(elevator)	
/* an elevator will know only which floor they are currently at. The elevator controller will query the location attribute of all elevators to determine which elevator is within two floors of the elevator-request queue that contacted the controller. The controller will interrupt the elevator’s process and modify its future event list */
End Method

/* Implementation of DEPLOY_ELEVATOR will be pursued in the final code */
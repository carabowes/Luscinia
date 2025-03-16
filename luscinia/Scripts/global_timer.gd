extends Node

signal turn_progressed

# Timer variables
@export var cd_minutes: int = 5
@export var cd_seconds: int = 0
var turns: int = 0
var countdown_duration = 0
var current_time_left = 0
var time_step = 60
var game_start: bool = false

# Clock variables
var in_game_hours: int = 0
var in_game_minutes: int = 0
var in_game_days: int = 1
var second_accumulator: float = 0


# Called every frame to handle time progression
func _process(delta):
	if not game_start:
		return
	second_accumulator += delta  # Accumulate time (delta represents seconds per frame)
	# Decrease the countdown every second
	if current_time_left > 0 and second_accumulator >= 1.0 - 0.001:
		second_accumulator -= 1
		current_time_left -= 1
	if current_time_left == 0:  # When the countdown ends, progress to the next turn
		next_turn(time_step)


# Set the countdown time (in minutes and seconds) and reset countdown
func set_time(minutes: int, seconds: int):
	if minutes < 0:
		minutes = 0
	if seconds < 0:
		seconds = 0
	if seconds >= 60:
		minutes += floor(seconds / 60)
		seconds = seconds % 60
	cd_minutes = minutes
	cd_seconds = seconds
	countdown_duration = (cd_minutes * 60) + cd_seconds
	current_time_left = countdown_duration


# Move to the next turn and update in-game time
func next_turn(turn_length: int):
	var skip_time_seconds = turn_length * 60
	current_time_left = countdown_duration
	# Update in-game time
	in_game_minutes += turn_length
	while in_game_minutes >= 60:
		in_game_minutes -= 60
		in_game_hours += 1
		if in_game_hours >= 24:
			in_game_hours -= 24
			in_game_days += 1
	turns += 1
	turn_progressed.emit()
	print("New in-game time: Day %d, %02d:%02d" % [in_game_days, in_game_hours, in_game_minutes])


# Convert turns to a human-readable time string
func turns_to_time_string(turns: int, hour_string: String = "hour",\
	minutes_string: String = "min", multiple_string: String = "s",\
	use_decimal_minutes: bool = false, show_minutes: bool = true):
	return time_to_time_string(turns * time_step, hour_string, minutes_string, multiple_string,\
	use_decimal_minutes, show_minutes)


# Convert total minutes to a human-readable time string (e.g., 2 hours 30 min)
func time_to_time_string(minutes: int, hour_string: String = "hour",\
	minutes_string: String = "min",multiple_string: String = "s",\
	use_decimal_minutes: bool = false, show_minutes: bool = true):
	if minutes < 0:
		minutes = 0
	var hours: int = int(floor(minutes / 60))  # Calculate hours
	var spare_minutes: int = minutes - (hours * 60)  # Remaining minutes
	var time_string: String = ""

	# Construct time string
	if hours != 0 or minutes == 0 or use_decimal_minutes or not show_minutes:
		time_string += str(hours)

		# Handle decimal minutes if applicable
		if use_decimal_minutes and show_minutes:
			var decimal_minutes: String = str(floor((float(spare_minutes) / 60.0) * 100))
			if len(decimal_minutes) == 1:
				decimal_minutes = "0" + decimal_minutes
			if decimal_minutes[-1] == "0":
				decimal_minutes = decimal_minutes[0]
			if decimal_minutes != "0":
				time_string += "." + str(decimal_minutes)

		time_string += " " + hour_string
		if hours != 1 or (use_decimal_minutes and spare_minutes != 0):
			time_string += multiple_string
		if show_minutes and not use_decimal_minutes and spare_minutes != 0:
			time_string += " "

	if show_minutes and not use_decimal_minutes and spare_minutes != 0:
		time_string += str(spare_minutes) + " " + minutes_string
		if spare_minutes != 1:
			time_string += multiple_string

	return time_string


# Start the game by setting the game_start flag to true
func start_game():
	game_start = true


# Pause the game by setting the game_start flag to false
func pause_game():
	game_start = false


# Reset the clock to the starting scenario values
func reset_clock():
	if ScenarioManager.current_scenario:
		cd_minutes = ScenarioManager.current_scenario.starting_hour
		cd_seconds = 0
		time_step = ScenarioManager.current_scenario.time_step

		countdown_duration = (cd_minutes * 60) + cd_seconds
		current_time_left = countdown_duration
		turns = 0
		in_game_hours = ScenarioManager.current_scenario.starting_hour
		in_game_minutes = 0
		in_game_days = 1
		second_accumulator = 0


# Set the in-game hour manually
func set_hour(hour: int):
	in_game_hours = hour


# Set the length of each turn (in minutes)
func set_time_step(step: int):
	time_step = step

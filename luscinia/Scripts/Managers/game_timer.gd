class_name GameTimer
extends Node

signal game_finished

# Timer variables
var max_turns : int = 0
var cd_minutes: int = 5
var cd_seconds: int = 0
var current_turn: int = 0
var countdown_duration = 0
var current_time_left = 0
var time_step = 60  #Measured in minutes
var paused: bool = false

# Clock variables
var in_game_hours: int = 0
var in_game_minutes: int = 0
var in_game_days: int = 1
var second_accumulator: float = 0


func _init(cd_minutes : int, cd_seconds : int, time_step : int, start_hour : int, max_turns : int):
	set_time(cd_minutes, cd_seconds)
	self.time_step = time_step
	self.in_game_hours = start_hour
	self.max_turns = max_turns
	GameManager.game_paused.connect(func(): paused = true)
	GameManager.game_resumed.connect(func(): paused = false)


func _process(delta : float):
	if paused:
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
	if paused:
		return
	var skip_time_seconds = turn_length * 60
	current_time_left = countdown_duration
	second_accumulator = 0
	# Update in-game time
	in_game_minutes += turn_length
	while in_game_minutes >= 60:
		in_game_minutes -= 60
		in_game_hours += 1
		if in_game_hours >= 24:
			in_game_hours -= 24
			in_game_days += 1
	current_turn+= 1
	GameManager.turn_progressed.emit(current_turn)
	if current_turn >= max_turns:
		game_finished.emit()


# Convert total minutes to a human-readable time string (e.g., 2 hours 30 min)
static func turns_to_time_string(
	timer : GameTimer,
	turns : int,
	hour_string : String = "hour",
	minutes_string : String = "min",
	multiple_string: String = "s",
	use_decimal_minutes : bool = false,
	show_minutes : bool  = true
):
	var time_step = 0 if timer == null else timer.time_step
	return time_to_time_string(
		turns * time_step,
		hour_string,
		minutes_string,
		multiple_string,
		use_decimal_minutes,
		show_minutes
	)


# Don't include an s in the minute or hour string, these will be added by the function
# if applicable
# i.e. 1 hour, 2 hours
static func time_to_time_string(
	minutes : int,
	hour_string : String = "hour",
	minutes_string : String = "min",
	multiple_string: String = "s",
	use_decimal_minutes : bool  = false,
	show_minutes : bool  = true
):
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

extends Node

signal turn_progressed
# Timer variables
#personal = 1min, discussion = 5min
@export var cd_minutes: int = 5
@export var cd_seconds: int = 0
var turns: int = 0
var countdown_duration = 0
var current_time_left = 0
var time_step = 60  #Measured in minutes
var game_start: bool = false

# Clock variables
var in_game_hours: int = 0  # Measured in hours out of 24
var in_game_minutes: int = 0
var in_game_days: int = 1
var second_accumulator: float = 0


func _process(delta):
	if not game_start:
		return
	second_accumulator += delta
	if current_time_left > 0 and second_accumulator >= 1.0 - 0.001:
		second_accumulator -= 1
		current_time_left -= 1
	if current_time_left == 0:
		next_turn(time_step)

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


func next_turn(turn_length: int):
	var skip_time_seconds = turn_length * 60
	current_time_left = countdown_duration

	in_game_minutes += turn_length
	while in_game_minutes >= 60:  # Handle hour overflow
		in_game_minutes -= 60
		in_game_hours += 1
		if in_game_hours >= 24:  # Handle day overflow
			in_game_hours -= 24
			in_game_days += 1
	turns+= 1
	turn_progressed.emit()
	print("New in-game time: Day %d, %02d:%02d" % [in_game_days, in_game_hours, in_game_minutes])  # Debugging line


## Don't include an s in the minute or hour string, these will be added by the function if applicable
## i.e. 1 hour, 2 hours
func turns_to_time_string(
	turns : int, 
	hour_string : String = "hour", 
	minutes_string : String = "min", 
	multiple_string: String = "s",
	use_decimal_minutes : bool = false, 
	show_minutes : bool  = true
):
	return time_to_time_string(
		turns * time_step, 
		hour_string, 
		minutes_string, 
		multiple_string,
		use_decimal_minutes, 
		show_minutes
	)


## Don't include an s in the minute or hour string, these will be added by the function if applicable
## i.e. 1 hour, 2 hours
func time_to_time_string(
	minutes : int, 
	hour_string : String = "hour", 
	minutes_string : String = "min",
	multiple_string: String = "s",
	use_decimal_minutes : bool  = false, 
	show_minutes : bool  = true
):
	if minutes < 0:
		minutes = 0
	var hours : int = int(floor(minutes / 60))
	var spare_minutes : int = minutes - (hours * 60)
	var time_string : String = ""

	if hours != 0 or minutes == 0 or use_decimal_minutes or not show_minutes:
		time_string += str(hours)

		if use_decimal_minutes and show_minutes:
			var decimal_minutes : String = str(floor((float(spare_minutes) / 60.0) * 100))
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


func start_game():
	game_start = true


func pause_game():
	game_start = false


func reset_clock():
	countdown_duration = (cd_minutes * 60) + cd_seconds
	current_time_left = countdown_duration
	turns = 0
	in_game_hours = 0
	in_game_minutes = 0
	in_game_days = 1
	second_accumulator = 0

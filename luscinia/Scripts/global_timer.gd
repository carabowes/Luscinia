extends Node

signal turn_progressed
# Timer variables
@export var cd_minutes: int = 3
@export var cd_seconds: int = 20
var countdown_duration
var current_time_left

# Clock variables
@export var in_game_hours: int = 20  # Measured in horus out of 24
var in_game_minutes = 0
var day_counter = 5
var second_accumulator = 0

func _ready():
	# Initialize timer
	countdown_duration = (cd_minutes * 60) + cd_seconds
	current_time_left = countdown_duration


func _process(delta):
	second_accumulator += delta
	var minutes_left = floor(current_time_left / 60)
		# Countdown timer logic
	if current_time_left > 0 and second_accumulator >= 1:
		second_accumulator -= 1  
		current_time_left -= 1
		
		var minutes_left_after = floor(current_time_left / 60)
		if minutes_left_after != minutes_left:
			in_game_minutes += 1
			
		if in_game_minutes >= 60:
			in_game_minutes -= 60
			in_game_hours += 1
			if in_game_hours >= 24:
				in_game_hours = 0
				day_counter += 1


func skip_time(skip_minutes: int):
	var skip_time_seconds = skip_minutes * 60
	# Adjust the countdown timer
	if current_time_left > 0:
		current_time_left = max(0, current_time_left - skip_time_seconds)
	
	# Adjust the in-game clock
	in_game_minutes += skip_minutes
	while in_game_minutes >= 60:  # Handle hour overflow
		in_game_minutes -= 60
		in_game_hours += 1
		if in_game_hours >= 24:  # Handle day overflow
			in_game_hours -= 24
			day_counter += 1
	turn_progressed.emit()
	print("New in-game time: Day %d, %02d:%02d" % [day_counter, in_game_hours, in_game_minutes])  # Debugging line

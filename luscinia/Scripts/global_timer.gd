extends Node

signal turn_progressed(time_skipped : int)
# Timer variables
#personal = 1min, discussion = 5min
@export var cd_minutes: int = 5
@export var cd_seconds: int = 0
@export var turns: int = 0
var countdown_duration
var current_time_left
var time_step = 60
var game_start: bool = false

# Clock variables
@export var in_game_hours: int = 9  # Measured in horus out of 24
var in_game_minutes = 0
var day_counter = 0
var second_accumulator = 0

func _ready():
	# Initialize timer
	countdown_duration = (cd_minutes * 60) + cd_seconds
	current_time_left = countdown_duration


func _process(delta):
	if(game_start):
		second_accumulator += delta
		var minutes_left = floor(current_time_left / 60)
		# Countdown timer logic
		if current_time_left > 0 and second_accumulator >= 1:
			second_accumulator -= 1  
			current_time_left -= 1
	
		if current_time_left == 0:
			skip_time(time_step)
		
		
		#var minutes_left_after = floor(current_time_left / 60)
		#if minutes_left_after != minutes_left:
		#	in_game_minutes += 1
		#	
		#if in_game_minutes >= 60:
		#	in_game_minutes -= 60
		#	in_game_hours += 1
		#	if in_game_hours >= 24:
		#		in_game_hours = 0
		#		day_counter += 1

func set_time(mins: int, sec: int):
	cd_minutes = mins
	cd_seconds = sec
	countdown_duration = (cd_minutes * 60) + cd_seconds
	current_time_left = countdown_duration

func skip_time(skip_minutes: int):
	var skip_time_seconds = skip_minutes * 60
	# Adjust the countdown timer
	current_time_left = countdown_duration
	
	# Adjust the in-game clock
	in_game_minutes += skip_minutes
	while in_game_minutes >= 60:  # Handle hour overflow
		in_game_minutes -= 60
		in_game_hours += 1
		if in_game_hours >= 24:  # Handle day overflow
			in_game_hours -= 24
			day_counter += 1
	turns+= 1
	turn_progressed.emit(skip_minutes)
	print("New in-game time: Day %d, %02d:%02d" % [day_counter, in_game_hours, in_game_minutes])  # Debugging line
	
func start_game():
	game_start = true

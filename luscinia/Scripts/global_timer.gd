extends Node

signal turn_progressed(time_skipped: int)
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
var in_game_days: int = 0
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

	turns += 1
	turn_progressed.emit(turn_length)


func start_game():
	game_start = true


func pause_game():
	game_start = false


func reset_timer():
	countdown_duration = (cd_minutes * 60) + cd_seconds
	current_time_left = countdown_duration
	turns = 0
	in_game_hours = 0
	in_game_minutes = 0
	in_game_days = 0
	second_accumulator = 0

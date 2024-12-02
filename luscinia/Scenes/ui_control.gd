extends Control

# Timer variables
@export var cd_minutes: int
@export var cd_seconds: int
var countdown_duration
var current_time_left

# Clock variables
@export var in_game_hours: int = 20  # Start at 20:00
var in_game_minutes = 0
var day_counter = 5

# Random earthquake events
var random_events = [
	"the ground shook violently, causing landslides nearby.",
	"you found shelter under a sturdy structure just in time.",
	"a crack opened in the earth, but you managed to avoid it.",
	"tremors subsided, but the aftershocks continue to rattle you.",
	"you discovered an underground cave exposed by the earthquake."
]

var second_accumulator = 0


func _ready():
	
	countdown_duration = (cd_minutes * 60) + cd_seconds
	current_time_left = countdown_duration
	
	var timer_bar = get_node("VBoxContainer/HBoxContainer1/TimerBar")
	var timer_label = get_node("VBoxContainer/HBoxContainer1/TimerLabel")
	var day_label = get_node("VBoxContainer/HBoxContainer2/DayLabel")
	var clock_label = get_node("VBoxContainer/HBoxContainer2/ClockLabel")
	
	# Initialize the UI elements
	timer_bar.max_value = countdown_duration
	timer_bar.value = countdown_duration
	timer_label.text = format_time_with_seconds(current_time_left)
	day_label.text = "Day %d" % day_counter
	clock_label.text = "%02d:%02d" % [in_game_hours, in_game_minutes]
	
	
	var skip_custom_time_button = get_node_or_null("VBoxContainer/HBoxContainer2/SkipCustomTimeButton")
	if skip_custom_time_button:
		print("SkipCustomTimeButton found!")
		if not skip_custom_time_button.is_connected("pressed", Callable(self, "_on_skip_custom_time_button_pressed")):
			skip_custom_time_button.connect("pressed", Callable(self, "_on_skip_custom_time_button_pressed"))

	else:
		print("SkipCustomTimeButton not found!")

	
	var custom_time_input = get_node_or_null("VBoxContainer/CustomTimePopup/LineEdit")
	if custom_time_input:
		print("CustomTimePopup LineEdit found!")
		if not custom_time_input.is_connected("text_submitted", Callable(self, "_on_line_edit_text_submitted")):
			custom_time_input.connect("text_submitted", Callable(self, "_on_line_edit_text_submitted"))
	else:
		print("LineEdit for CustomTimePopup not found!")

	# Event Popup
	var event_popup = get_node_or_null("VBoxContainer/EventPopup")
	if event_popup:
		print("EventPopup found!")
		if not event_popup.is_connected("popup_hide", Callable(self, "_on_event_popup_popup_hide")):
			event_popup.connect("popup_hide", Callable(self, "_on_event_popup_popup_hide"))
	else:
		print("EventPopup not found!")

	# Initialize timer
	countdown_duration = (cd_minutes * 60) + cd_seconds
	current_time_left = countdown_duration
	update_timer_ui()
	
	set_process(true)


func _process(delta):
	var timer_bar = get_node("VBoxContainer/HBoxContainer1/TimerBar")
	var timer_label = get_node("VBoxContainer/HBoxContainer1/TimerLabel")
	var clock_label = get_node("VBoxContainer/HBoxContainer2/ClockLabel")
	var day_label = get_node("VBoxContainer/HBoxContainer2/DayLabel")
	
	second_accumulator += delta
	var minutes_left = floor(current_time_left / 60)
		# Countdown timer logic
	if current_time_left > 0 and second_accumulator >= 1:
		second_accumulator -= 1  
		current_time_left -= 1
		timer_bar.value = int(current_time_left)
		timer_label.text = format_time_with_seconds(int(current_time_left))
		
		var minutes_left_after = floor(current_time_left / 60)
		if minutes_left_after != minutes_left:
			in_game_minutes += 1
			
		if in_game_minutes >= 60:
			in_game_minutes -= 60
			in_game_hours += 1
			if in_game_hours >= 24:
				in_game_hours = 0
				day_counter += 1
				day_label.text = "Day %d" % day_counter

		# Update clock display
		clock_label.text = "%02d:%02d" % [in_game_hours, in_game_minutes]


# Displays the popup for entering a custom time to skip
func _on_skip_custom_time_button_pressed():
	var custom_time_popup = get_node("VBoxContainer/CustomTimePopup")
	if custom_time_popup:
		custom_time_popup.popup_centered(Vector2(400, 300))
	else:
		print("CustomTimePopup node not found!")


# Handle custom time input
func _on_line_edit_text_submitted(new_text: String):
	var custom_time_popup = get_node("VBoxContainer/CustomTimePopup")
	custom_time_popup.hide()

	if new_text.is_valid_int():  # Correct validation
		var minutes = int(new_text)
		if minutes > 0:
			skip_time(minutes)
		else:
			print("Invalid input: Time must be greater than 0")
	else:
		print("Invalid input: Not an integer")


# Perform the time skip
func skip_time(skip_minutes: int):
	print("Skipping time:", skip_minutes, "minutes")
	var skip_time_seconds = skip_minutes * 60
	# Adjust the countdown timer
	if current_time_left > 0:
		current_time_left = max(0, current_time_left - skip_time_seconds)
		var timer_bar = get_node("VBoxContainer/HBoxContainer1/TimerBar")
		var timer_label = get_node("VBoxContainer/HBoxContainer1/TimerLabel")
		timer_bar.value = current_time_left
		timer_label.text = format_time_with_seconds(current_time_left)
		
	# Adjust the in-game clock
	in_game_minutes += skip_minutes
	while in_game_minutes >= 60:  # Handle hour overflow
		in_game_minutes -= 60
		in_game_hours += 1
		if in_game_hours >= 24:  # Handle day overflow
			in_game_hours -= 24
			day_counter += 1
			
	update_timer_ui()
	#Update UI labels
	var day_label = get_node("VBoxContainer/HBoxContainer2/DayLabel")
	var clock_label = get_node("VBoxContainer/HBoxContainer2/ClockLabel")
	day_label.text = "Day %d" % day_counter
	clock_label.text = "%02d:%02d" % [in_game_hours, in_game_minutes]
	print("New in-game time: Day %d, %02d:%02d" % [day_counter, in_game_hours, in_game_minutes])  # Debugging line

	# Trigger random event
	show_random_event(skip_minutes)


# Update UI Elements
func update_timer_ui():
	var timer_bar = get_node_or_null("VBoxContainer/HBoxContainer1/TimerBar")
	var timer_label = get_node_or_null("VBoxContainer/HBoxContainer1/TimerLabel")
	var day_label = get_node_or_null("VBoxContainer/HBoxContainer2/DayLabel")
	var clock_label = get_node_or_null("VBoxContainer/HBoxContainer2/ClockLabel")

	if timer_bar:
		timer_bar.value = current_time_left
	if timer_label:
		timer_label.text = format_time_with_seconds(current_time_left)
	if day_label:
		day_label.text = "Day %d" % day_counter
	if clock_label:
		clock_label.text = "%02d:%02d" % [in_game_hours, in_game_minutes]


# Show a random earthquake-related event
func show_random_event(skip_minutes: int):
	var event_popup = get_node("VBoxContainer/EventPopup")
	if event_popup:
		var label = event_popup.get_node("Label")
		label.text = "You skipped %d minutes.\n%s" % [skip_minutes, random_events[randi() % random_events.size()]]
		event_popup.popup_centered()  # Show the popup at the center of the screen
		print(label.text)
	else:
		print("EventPopup node not found!")


# Handle Event Popup close
func _on_event_popup_popup_hide():
	print("Event popup closed.")


# Format time to display MM:SS
func format_time_with_seconds(seconds: int) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

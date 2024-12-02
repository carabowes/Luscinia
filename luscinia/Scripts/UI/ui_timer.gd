extends Control


# Random earthquake events
var random_events = [
	"the ground shook violently, causing landslides nearby.",
	"you found shelter under a sturdy structure just in time.",
	"a crack opened in the earth, but you managed to avoid it.",
	"tremors subsided, but the aftershocks continue to rattle you.",
	"you discovered an underground cave exposed by the earthquake."
]

@onready var timer_bar = $VBoxContainer/HBoxContainer1/TimerBar
@onready var timer_label = $VBoxContainer/HBoxContainer1/TimerLabel
@onready var day_label = $VBoxContainer/HBoxContainer2/DayLabel
@onready var clock_label = $VBoxContainer/HBoxContainer2/ClockLabel
@onready var skip_custom_time_button = $VBoxContainer/HBoxContainer2/SkipCustomTimeButton
@onready var custom_time_popup = $VBoxContainer/CustomTimePopup
@onready var custom_time_input = $VBoxContainer/CustomTimePopup/LineEdit
@onready var event_popup = $VBoxContainer/EventPopup

func _ready():
	# Initialize the UI elements
	timer_bar.max_value = GlobalTimer.countdown_duration
	timer_bar.value = GlobalTimer.countdown_duration
	timer_label.text = format_time_with_seconds(GlobalTimer.current_time_left)
	day_label.text = "Day %d" % GlobalTimer.day_counter
	clock_label.text = "%02d:%02d" % [GlobalTimer.in_game_hours, GlobalTimer.in_game_minutes]
	
	if skip_custom_time_button:
		if not skip_custom_time_button.is_connected("pressed", Callable(self, "_on_skip_custom_time_button_pressed")):
			skip_custom_time_button.connect("pressed", Callable(self, "_on_skip_custom_time_button_pressed"))
	else:
		print("SkipCustomTimeButton not found!")
	
	if custom_time_input:
		if not custom_time_input.is_connected("text_submitted", Callable(self, "_on_line_edit_text_submitted")):
			custom_time_input.connect("text_submitted", Callable(self, "_on_line_edit_text_submitted"))
	else:
		print("LineEdit for CustomTimePopup not found!")
	
	if event_popup:
		if not event_popup.is_connected("popup_hide", Callable(self, "_on_event_popup_popup_hide")):
			event_popup.connect("popup_hide", Callable(self, "_on_event_popup_popup_hide"))
	else:
		print("EventPopup not found!")
	
	update_timer_ui()
	#set_process(true)


func _process(delta):
	day_label.text = "Day %d" % GlobalTimer.day_counter
	timer_label.text = format_time_with_seconds(int(GlobalTimer.current_time_left))
	clock_label.text = "%02d:%02d" % [GlobalTimer.in_game_hours, GlobalTimer.in_game_minutes]

# Displays the popup for entering a custom time to skip
func _on_skip_custom_time_button_pressed():
	custom_time_popup.popup_centered(Vector2(400, 300))


# Handle custom time input
func _on_line_edit_text_submitted(new_text: String):
	custom_time_popup.hide()
	if new_text.is_valid_int():  # Correct validation
		var minutes = int(new_text)
		if minutes > 0:
			skip_time(minutes)


# Perform the time skip
func skip_time(skip_minutes: int):
	GlobalTimer.skip_time(skip_minutes)
	update_timer_ui()
	#Update UI labels
	day_label.text = "Day %d" % GlobalTimer.day_counter
	clock_label.text = "%02d:%02d" % [GlobalTimer.in_game_hours, GlobalTimer.in_game_minutes]

# Update UI Elements
func update_timer_ui():
	if timer_bar:
		timer_bar.value = GlobalTimer.current_time_left
	if timer_label:
		timer_label.text = format_time_with_seconds(GlobalTimer.current_time_left)
	if day_label:
		day_label.text = "Day %d" % GlobalTimer.day_counter
	if clock_label:
		clock_label.text = "%02d:%02d" % [GlobalTimer.in_game_hours, GlobalTimer.in_game_minutes]


# Show a random earthquake-related event
# Out of scope but will be added back!
func show_random_event(skip_minutes: int):
	if event_popup:
		var label = event_popup.get_node("Label")
		label.text = "You skipped %d minutes.\n%s" % [skip_minutes, random_events[randi() % random_events.size()]]
		event_popup.popup_centered()  # Show the popup at the center of the screen
		print(label.text)
	else:
		print("EventPopup node not found!")


# Format time to display MM:SS
func format_time_with_seconds(seconds: int) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

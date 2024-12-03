extends Button

@onready var custom_time_popup = $CustomTimePopup
@onready var custom_time_input = $CustomTimePopup/LineEdit
@onready var gm = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed", _on_skip_custom_time_button_pressed)
	#custom_time_input.connect("text_submitted", _on_line_edit_text_submitted)


# Displays the popup for entering a custom time to skip
func _on_skip_custom_time_button_pressed():
	#custom_time_popup.popup_centered(Vector2(400, 300))
	GlobalTimer.skip_time(GlobalTimer.time_step) #skip a turn

# Handle custom time input
func _on_line_edit_text_submitted(new_text: String):
	custom_time_popup.hide()
	if new_text.is_valid_int():  # Correct validation
		var minutes = int(new_text)
		if minutes > 0:
			GlobalTimer.skip_time(minutes)

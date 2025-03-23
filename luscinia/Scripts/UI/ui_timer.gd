class_name UITimer
extends Control

var game_timer : GameTimer:
	set(value):
		game_timer = value
		if value != null:
			update_timer_ui()
var resource_manager : ResourceManager:
	set(value):
		resource_manager = value
		if value != null:
			update_resource_ui()
var is_animating : bool = false
var animation_progress : float = 0


func _ready():
	GameManager.resource_updated.connect(update_resource_ui)


# Called every frame to update the UI in real-time
func _process(_delta):
	update_timer_ui()


# Update the main timer UI elements with the latest values
func update_timer_ui():
	if game_timer == null:
		return
	%ClockVisual.pivot_offset = %ClockVisual.size/2
	%ClockVisual.max_value = game_timer.countdown_duration
	%ClockVisual.value = game_timer.current_time_left
	if floor(%ClockVisual.value) == floor(%ClockVisual.max_value/2):
		start_animation()
	if %ClockVisual.value < %ClockVisual.max_value*0.1:
		start_animation()
	%TimerLabel.text = format_time_with_seconds(game_timer.current_time_left)
	%DayLabel.text = "Day %d" % game_timer.in_game_days
	%ClockLabel.text = "%02d:%02d" % [game_timer.in_game_hours, game_timer.in_game_minutes]
	start_animation()


# Update the resource-related UI elements
func update_resource_ui():
	if resource_manager == null:
		return
	var resources = resource_manager.resources
	var available_resources = resource_manager.available_resources
	if resources == {} or available_resources == {}:
		return
	%PersonnelAmt.text = "%s / %s" % [
		ResourceManager.format_resource_value(resources["people"],2),
		ResourceManager.format_resource_value(available_resources["people"],2)
	]
	%SuppliesAmt.text = "%s" % [
		ResourceManager.format_resource_value(resources["supplies"],2)
	]
	%FundsAmt.text = "%s" % [
		ResourceManager.format_resource_value(resources["funds"],2)
	]
	%TransportAmt.text = "%s / %s" % [
		ResourceManager.format_resource_value(resources["vehicles"],2),
		ResourceManager.format_resource_value(available_resources["vehicles"],2)
	]


# Helper function to format time in minutes and seconds
func format_time_with_seconds(seconds: int) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]


func start_animation():
	if is_animating:
		return
	is_animating = true
	var tween = get_tree().create_tween()
	tween.tween_property(%ClockVisual, "scale", Vector2.ONE * 1.05, 0.2)
	tween.parallel().tween_property(%ClockVisual, "modulate", Color.YELLOW, 0.2)
	tween.tween_property(%ClockVisual, "scale", Vector2.ONE, 0.2)
	tween.parallel().tween_property(%ClockVisual, "modulate", Color.WHITE, 0.2)
	tween.tween_interval(0.6)
	tween.tween_callback(func(): is_animating = false)

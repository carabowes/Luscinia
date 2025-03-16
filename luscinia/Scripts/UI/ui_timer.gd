class_name UITimer
extends Control

func _ready():
	%ClockVisual.max_value = GlobalTimer.countdown_duration
	%ClockVisual.value = GlobalTimer.countdown_duration
	%TimerLabel.text = format_time_with_seconds(GlobalTimer.current_time_left)
	%DayLabel.text = "Day %d" % GlobalTimer.in_game_days
	%ClockLabel.text = "%02d:%02d" % [GlobalTimer.in_game_hours, GlobalTimer.in_game_minutes]
	update_timer_ui()


# Called every frame to update the UI in real-time
func _process(_delta):
	update_timer_ui()


# Update the main timer UI elements with the latest values
func update_timer_ui():
	%ClockVisual.value = GlobalTimer.current_time_left
	%TimerLabel.text = format_time_with_seconds(GlobalTimer.current_time_left)
	%DayLabel.text = "Day %d" % GlobalTimer.in_game_days
	%ClockLabel.text = "%02d:%02d" % [GlobalTimer.in_game_hours, GlobalTimer.in_game_minutes]
	update_resource_ui()


# Update the resource-related UI elements
func update_resource_ui():
	%PersonnelAmt.text = "%s / %s" % [ResourceManager.format_resource_value(\
	ResourceManager.resources["people"], 2), ResourceManager.format_resource_value(\
	ResourceManager.available_resources["people"], 2)]
	%SuppliesAmt.text = "%s" % [ResourceManager.format_resource_value(\
	ResourceManager.resources["supplies"], 2)]
	%FundsAmt.text = str(ResourceManager.format_resource_value(ResourceManager.resources["funds"], 2))
	%TransportAmt.text = "%s / %s" % [ResourceManager.format_resource_value(\
	ResourceManager.resources["vehicles"], 2), \
	ResourceManager.format_resource_value(ResourceManager.available_resources["vehicles"], 2)]


# Helper function to format time in minutes and seconds
func format_time_with_seconds(seconds: int) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

class_name UITimer
extends Control

func _ready():
	# Initialize the UI elements
	%ClockVisual.max_value = GlobalTimer.countdown_duration
	%ClockVisual.value = GlobalTimer.countdown_duration
	%TimerLabel.text = format_time_with_seconds(GlobalTimer.current_time_left)
	%DayLabel.text = "Day %d" % GlobalTimer.in_game_days
	%ClockLabel.text = "%02d:%02d" % [GlobalTimer.in_game_hours, GlobalTimer.in_game_minutes]
	update_timer_ui()


func _process(_delta):
	update_timer_ui()


func update_timer_ui():
	%ClockVisual.value = GlobalTimer.current_time_left
	%TimerLabel.text = format_time_with_seconds(GlobalTimer.current_time_left)
	%DayLabel.text = "Day %d" % GlobalTimer.in_game_days
	%ClockLabel.text = "%02d:%02d" % [GlobalTimer.in_game_hours, GlobalTimer.in_game_minutes]
	update_resource_ui()


func update_resource_ui():
	%PersonnelAmt.text = "%s / %s" % [ResourceManager.resources["people"], ResourceManager.available_resources["people"]]
	%SuppliesAmt.text = "%s / %s" % [ResourceManager.resources["supplies"], ResourceManager.available_resources["supplies"]]
	%FundsAmt.text = str(ResourceManager.resources["funds"])
	%TransportAmt.text = "%s / %s" % [ResourceManager.resources["vehicles"], ResourceManager.available_resources["vehicles"]]


func format_time_with_seconds(seconds: int) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

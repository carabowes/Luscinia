extends Control

@export var turns_to_end: int
@export var notifications: Control

@export_group("Ending Screen Text Labels")
@export var days_amt: Label
@export_subgroup("Resources Taken Text Labels")
@export var taken_personnel: Label
@export var taken_supplies: Label
@export var taken_funds: Label
@export var taken_vehicles: Label
@export_subgroup("Resources Remaining Text Labels")
@export var remain_personnel: Label
@export var remain_supplies: Label
@export var remain_funds: Label
@export var remain_vehicles: Label

var personnel_amt: int = 0
var supplies_amt: int = 0
var funds_amt: int = 0
var vehicle_amt: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%RestartButton.connect("pressed", _restart_game)
	%ExitButton.connect("pressed", _exit_game)
	ResourceManager.connect("resource_removed", format_resource_taken)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(GlobalTimer.turns == turns_to_end):
		notifications.visible = false
		format_resource_remaining()
		days_amt.text = "%s Turns" % str(GlobalTimer.turns)
		GlobalTimer.pause_game()
		self.visible = true
	else:
		self.visible = false


func format_resource_taken(resource: String, amt: int):
	match resource:
		"people":
			personnel_amt+=amt
			taken_personnel.text = "%s" % str(personnel_amt)
		"supplies":
			supplies_amt+=amt
			taken_supplies.text = "%s" % str(supplies_amt)
		"funds":
			funds_amt+=amt
			taken_funds.text = "%s" % ResourceManager.format_resource_value(funds_amt,0)
		"vehicles":
			vehicle_amt+=amt
			taken_vehicles.text = "%s" % str(vehicle_amt)


func format_resource_remaining():
	remain_personnel.text = "%s" % ResourceManager.available_resources["people"]
	remain_supplies.text = "%s" % ResourceManager.resources["supplies"]
	remain_funds.text = "%s" % ResourceManager.format_resource_value(ResourceManager.resources["funds"],0)
	remain_vehicles.text = "%s" % ResourceManager.available_resources["vehicles"]


func _restart_game():
	GlobalTimer.reset_clock()
	ResourceManager.reset_resources()
	MessageManager.reset_messages()
	get_tree().reload_current_scene()
	GlobalTimer.start_game()


func _exit_game():
	GlobalTimer.reset_clock()
	ResourceManager.reset_resources()
	MessageManager.reset_messages()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

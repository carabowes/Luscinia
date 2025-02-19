extends Control

@export var message_board : MessageBoard
@export var timer: UITimer
@export var show: bool = false

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
	message_board.connect("resource_spent", format_resource_taken)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(show):
		format_resource_remaining()
		days_amt.text = "%s Days" % str(GlobalTimer.in_game_days)
		self.visible = true
	else:
		self.visible = false


func format_resource_taken(name:String, resource: String, amt: int):
	match resource:
		"people":
			personnel_amt+=amt
			taken_personnel.text = "Personnel: %s" % str(personnel_amt)
		"supplies":
			supplies_amt+=amt
			taken_supplies.text = "Supplies: %s" % str(supplies_amt)
		"funds":
			funds_amt+=amt
			taken_funds.text = "Funds: %s" % str(funds_amt)
		"vehicles":
			vehicle_amt+=amt
			taken_vehicles.text = "Vehicles: %s" % str(vehicle_amt)

func format_resource_remaining():
	remain_personnel.text = "Personnel: %s" % ResourceManager.available_resources["people"]
	remain_supplies.text = "Supplies: %s" % ResourceManager.available_resources["supplies"]
	remain_funds.text = "Funds: %s" % ResourceManager.resources["funds"]
	remain_vehicles.text = "Vehicles: %s" % ResourceManager.available_resources["vehicles"]


func _restart_game():
	GlobalTimer.reset_clock()
	ResourceManager.reset_resources()
	get_tree().reload_current_scene()
	GlobalTimer.start_game()

func _exit_game():
	GlobalTimer.reset_clock()
	ResourceManager.reset_resources()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

extends Node

@onready var widgets = get_tree().get_nodes_in_group("task_widgets")
@onready var message_manager = $message_manager
@onready var resource_manager = $resource_page
var format_string = "widget %s has progress %s"
@export var game_step: int = 0
var step_complete: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in widgets:
		var actual_string = format_string % [i.name, i.get_current_progress()]
		print(actual_string)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	prototype_process()
	

#only to be used for the sprint 1 demo and contains only hardcoding interactions 
#to allow for refactoring
func prototype_process():
	match game_step:
		0:
			if(!step_complete):
				print("no widgets should be showing and new message alert should be turned on")
				for i in widgets:
					i.visible = false
				step_complete = true
		1:
			if(!step_complete):
				widgets[0].visible = true
				widgets[0].set_current_progress(1)
				step_complete = true
		2:
			if(!step_complete):
				widgets[5].visible = false
				widgets[4].set_current_progress(2)
				message_manager.show_alert = true
				step_complete = true
		3:
			if(!step_complete):
				widgets[5].visible = true
				widgets[5].set_current_progress(1)
				step_complete = true
		9:
			if(!step_complete):
				message_manager.show_alert = true
				message_manager.is_reward = true
				step_complete = true
		11:
			if(!step_complete):
				message_manager.show_alert = true
				ResourceManager.add_resources("supplies", 10)
				step_complete = true

func print_task_progress():
	widgets.clear()
	widgets = get_tree().get_nodes_in_group("task_widgets")
	for i in widgets:
		var actual_string = format_string % [i.name, i.get_current_progress()]
		print(actual_string)

func incre_game_step():
	game_step += 1
	step_complete = false
	print("current game step is %s" % [str(game_step)])

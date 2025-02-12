class_name RequisiteGraphNode
extends TaskEditorGraphNode

var prerequisite : Prerequisite

enum OutPortNums
{
	MESSAGE = 0
}

enum InPortNums
{
	TASK = 0
}

func _init(prerequisite : Prerequisite):
	super()
	self.prerequisite = prerequisite
	
	title = "Requisite Node"
	
	var task_labels = Label.new()
	task_labels.text = "Tasks"
	add_child(task_labels)
	set_port(true, task_labels.get_index(), SlotType.TASK_TO_PREQ)
	
	var chance_input = add_slider("Chance", prerequisite.chance, 0, 1)
	chance_input.value_changed.connect(_on_chance_changed)
	
	var min_turn_input = add_input("Minimum Turn", str(prerequisite.min_turn))
	min_turn_input.text_changed.connect(func(value): _on_min_turn_changed(value, min_turn_input))
	
	var max_turn_input = add_input("Maximum Turn", str(prerequisite.max_turn))
	max_turn_input.text_changed.connect(func(value): _on_max_turn_changed(value, max_turn_input))
	
	var output_label = Label.new()
	output_label.text = "Output"
	add_child(output_label)
	set_port(false, output_label.get_index(), SlotType.PREQ_TO_MESSAGE)


func _on_chance_changed(value):
	prerequisite.chance = value


func _on_min_turn_changed(value : String, input : LineEdit):
	if value == "": 
		value = "-1"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	if not value.is_valid_int():
		input.text = str(prerequisite.min_turn)
		return
	prerequisite.min_turn = value.to_int()


func _on_max_turn_changed(value : String, input : LineEdit):
	if value == "": 
		value = "-1"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	if not value.is_valid_int():
		input.text = str(prerequisite.max_turn)
		return
	prerequisite.max_turn = value.to_int()


func assign_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.TASK and in_node is TaskEditorGraphNode:
		prerequisite.task_id.append(in_node.task.task_id)
	else:
		return false
	return true


func remove_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.TASK and in_node is TaskEditorGraphNode:
		prerequisite.task_id.erase(in_node.task.task_id)
	else:
		return false
	return true

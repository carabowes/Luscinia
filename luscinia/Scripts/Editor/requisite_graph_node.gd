class_name RequisiteGraphNode
extends TaskEditorGraphNode

enum OutPortNums
{
	MESSAGE = 0
}

enum InPortNums
{
	TASK = 0
}

var prerequisite : Prerequisite


func _init(prerequisite : Prerequisite):
	super()  # Calls the parent class constructor
	self.prerequisite = prerequisite
	title = "Requisite Node"

	# Adds task input label and port
	var task_labels = Label.new()
	task_labels.text = "Tasks"
	add_child(task_labels)
	set_port(true, task_labels.get_index(), SlotType.TASK_TO_PREQ)

	# Adds chance slider with callback
	var chance_input = add_slider("Chance", prerequisite.chance, 0, 1)
	chance_input.value_changed.connect(_on_chance_changed)

	# Adds minimum turn input with callback
	var min_turn_input = add_input("Minimum Turn", str(prerequisite.min_turn))
	min_turn_input.text_changed.connect(func(value): _on_min_turn_changed(value, min_turn_input))

	# Adds maximum turn input with callback
	var max_turn_input = add_input("Maximum Turn", str(prerequisite.max_turn))
	max_turn_input.text_changed.connect(func(value): _on_max_turn_changed(value, max_turn_input))

	# Adds output label and port
	var output_label = Label.new()
	output_label.text = "Output"
	add_child(output_label)
	set_port(false, output_label.get_index(), SlotType.PREQ_TO_MESSAGE)


# Callback for when the chance value is changed
func _on_chance_changed(value):
	prerequisite.chance = value


# Callback for when the minimum turn value is changed
func _on_min_turn_changed(value : String, input : LineEdit):
	if value == "" or not value.is_valid_int():
		value = "0"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	prerequisite.min_turn = value.to_int()


# Callback for when the maximum turn value is changed
func _on_max_turn_changed(value : String, input : LineEdit):
	if value == "" or not value.is_valid_int():
		value = "-1"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	prerequisite.max_turn = value.to_int()


# Assigns a connection based on the input port and node
func assign_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.TASK and in_node is TaskEditorGraphNode:
		prerequisite.task_id.append(in_node.task.task_id)
	else:
		return false
	return true


# Removes a connection based on the input port and node
func remove_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.TASK and in_node is TaskEditorGraphNode:
		prerequisite.task_id.erase(in_node.task.task_id)
	else:
		return false
	return true


# Creates a node to connect from an empty input port
func create_node_to_connect_from_empty(in_port: int):
	if in_port == InPortNums.TASK:
		return TaskGraphNode.new(TaskData.new())
	return null


# Creates a node to connect to an empty output port
func create_node_to_connect_to_empty(out_port: int):
	if out_port == OutPortNums.MESSAGE:
		return MessageGraphNode.new(Message.new())
	return null

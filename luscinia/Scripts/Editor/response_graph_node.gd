class_name ResponseGraphNode
extends TaskEditorGraphNode

enum OutPortNums
{
	TASK = 0
}

enum InPortNums
{
	MESSAGE = 0
}

var response : Response


func _init(response : Response):
	super()
	self.response = response
	title = "Response Node"

	# Adds task label and port
	var task_label = Label.new()
	task_label.text = "Task"
	add_child(task_label)
	set_port(false, task_label.get_index(), SlotType.RESPONSE_TO_TASK)

	# Adds response name input with callback
	var response_name_input = add_input("Response Name", response.response_name)
	response_name_input.text_changed.connect(_on_response_name_changed)

	# Adds response text input with callback
	var response_text_input = add_large_input("Response Text", response.response_text)
	set_port(true, response_text_input.get_index(), SlotType.MESSAGE_TO_RESPONSE)
	response_text_input.text_changed.connect(func():\
	_on_response_text_changed(response_text_input.text))

	# Adds relationship change input with callback
	var relationship_change = add_input("Relationship Change", str(response.relationship_change))
	relationship_change.text_changed.connect(func(value):\
	_on_relationship_change(value, relationship_change))


# Callback for when the response name is changed
func _on_response_name_changed(new_name : String):
	response.response_name = new_name


# Callback for when the response text is changed
func _on_response_text_changed(contents : String):
	response.response_text = contents


# Callback for when the relationship change value is changed
func _on_relationship_change(value : String, input : LineEdit):
	if value == "" or not value.is_valid_int():
		value = "0"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	response.relationship_change = value.to_int()


# Assigns a connection based on the input port and node
func assign_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.MESSAGE and in_node is MessageGraphNode:
		in_node.message.responses.append(response)
	else:
		return false
	return true


# Removes a connection based on the input port and node
func remove_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.MESSAGE and in_node is MessageGraphNode:
		in_node.message.responses.erase(response)
	else:
		return false
	return true


# Creates a node to connect from an empty input port
func create_node_to_connect_from_empty(in_port: int):
	if in_port == InPortNums.MESSAGE:
		return MessageGraphNode.new(Message.new())
	return null


# Creates a node to connect to an empty output port
func create_node_to_connect_to_empty(out_port: int):
	if out_port == OutPortNums.TASK:
		return TaskGraphNode.new(TaskData.new())
	return null

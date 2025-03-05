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

	var task_label = Label.new()
	task_label.text = "Task"
	add_child(task_label)
	set_port(false, task_label.get_index(), SlotType.RESPONSE_TO_TASK)

	var response_name_input = add_input("Response Name", response.response_name)
	response_name_input.text_changed.connect(_on_response_name_changed)

	var response_text_input = add_large_input("Response Text", response.response_text)
	set_port(true, response_text_input.get_index(), SlotType.MESSAGE_TO_RESPONSE)
	response_text_input.text_changed.connect(func(): _on_response_text_changed(\
	response_text_input.text))

	var relationship_change = add_input("Relationship Change", str(response.relationship_change))
	relationship_change.text_changed.connect(func(value): _on_relationship_change(\
	value, relationship_change))


func _on_response_name_changed(new_name : String):
	response.response_name = new_name


func _on_response_text_changed(contents : String):
	response.response_text = contents


func _on_relationship_change(value : String, input : LineEdit):
	if value == "" or not value.is_valid_int():
		value = "0"
		input.self_modulate = Color.RED
	else:
		input.self_modulate = Color.WHITE
	response.relationship_change = value.to_int()


func assign_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.MESSAGE and in_node is MessageGraphNode:
		in_node.message.responses.append(response)
	else:
		return false
	return true


func remove_connection(in_port : int, in_node : TaskEditorGraphNode) -> bool:
	if in_port == InPortNums.MESSAGE and in_node is MessageGraphNode:
		in_node.message.responses.erase(response)
	else:
		return false
	return true


func create_node_to_connect_from_empty(in_port: int):
	if in_port == InPortNums.MESSAGE:
		return MessageGraphNode.new(Message.new())
	return null


func create_node_to_connect_to_empty(out_port: int):
	if out_port == OutPortNums.TASK:
		return TaskGraphNode.new(TaskData.new())
	return null

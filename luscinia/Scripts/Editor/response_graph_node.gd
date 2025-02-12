class_name ResponseGraphNode
extends TaskEditorGraphNode

var response : Response

enum OutPortNums
{
	TASK = 0
}

enum InPortNums
{
	MESSAGE = 0
}

func _init(response : Response):
	super()
	self.response = response
	
	title = "Response Node"
	
	var response_text_input = add_large_input("Response", response.response_text)
	set_port(true, response_text_input.get_index(), SlotType.MESSAGE_TO_RESPONSE)
	response_text_input.text_changed.connect(func(): _on_response_text_changed(response_text_input.text))
	
	var relationship_change = add_input("Relationship Change", str(response.relationship_change))
	relationship_change.text_changed.connect(func(value): _on_relationship_change(value, relationship_change))
	
	var task_label = Label.new()
	task_label.text = "Task"
	add_child(task_label)
	set_port(false, task_label.get_index(), SlotType.RESPONSE_TO_TASK)


func _on_response_text_changed(contents : String):
	response.response_text = contents


func _on_relationship_change(value : String, input : LineEdit):
	if not value.is_valid_int():
		input.text = str(response.relationship_change)
		return
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

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
	
	var relationship_change = add_input("Relationship Change", str(response.relationship_change))
	
	var task_label = Label.new()
	task_label.text = "Task"
	add_child(task_label)
	set_port(false, task_label.get_index(), SlotType.RESPONSE_TO_TASK)

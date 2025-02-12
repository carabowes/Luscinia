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
	
	var chance = add_slider("Chance", prerequisite.chance, 0, 1)
	chance.value_changed.connect(_on_chance_changed)
	
	add_spacer(40)
	var output_label = Label.new()
	output_label.text = "Output"
	add_child(output_label)
	set_port(false, output_label.get_index(), SlotType.PREQ_TO_MESSAGE)


func _on_chance_changed(value):
	prerequisite.chance = value


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

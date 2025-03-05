class_name SenderGraphNode
extends TaskEditorGraphNode

signal information_updated(node : TaskEditorGraphNode)


enum OutPortNums
{
	MESSAGE = 0
}

var sender : Sender

func _init(sender : Sender):
	super()
	self.sender = sender
	title = "Sender Node"
	_add_elements()


func update():
	for child in get_children():
		if child.get_index() == 0: #delete button
			continue
		child.free()
	_add_elements()


func _add_elements():
	var sender_name_input : LineEdit = add_input("Sender Name", sender.name)
	set_port(false, sender_name_input.get_index(), SlotType.SENDER_TO_MESSAGE)
	sender_name_input.text_changed.connect(_on_sender_name_changed)

	var sender_icon_selector : ImageSelector = add_image_selector("Sender Icon", sender.image)
	sender_icon_selector.image_selected.connect(_on_sender_icon_changed)

	var slider : HSlider = add_slider("Relationship", sender.relationship, -100, 100, 1)
	slider.value_changed.connect(_on_relationship_changed)
	size.y = 0


func _on_sender_name_changed(new_name : String):
	sender.name = new_name
	information_updated.emit(self)


func _on_sender_icon_changed(icon : Texture):
	sender.image = icon
	information_updated.emit(self)


func _on_relationship_changed(new_value : float):
	sender.relationship = new_value
	information_updated.emit(self)


func create_node_to_connect_to_empty(out_port: int):
	if out_port == OutPortNums.MESSAGE:
		return MessageGraphNode.new(Message.new())
	return null

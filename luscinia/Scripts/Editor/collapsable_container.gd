class_name CollapsibleContainer
extends VBoxContainer

signal toggled

var is_expanded : bool = false
var text : String :
	get():
		return %DropdownTitle.text
	set(value):
		%DropdownTitle.text = value


func _draw():
	%Background.size = size


func _ready():
	%LabelBox.gui_input.connect(_on_click)
	set_item_visibility(false)


func set_item_visibility(visibility : bool):
	for child in get_children():
		if child == %LabelBox:
			continue
		child.visible = visibility


func _on_click(event: InputEvent):
	if event.is_action_pressed("interact"):
		is_expanded = !is_expanded
		%Expand.text = "-" if is_expanded else "+"
		set_item_visibility(is_expanded) 
		toggled.emit()

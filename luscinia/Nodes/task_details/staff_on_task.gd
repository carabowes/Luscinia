@tool
class_name StaffOnTask
extends Panel

@export var staff_hbox_holder : HBoxContainer
@export var staff_names : Array[String]:
	set(value):
		staff_names = value
		if(Engine.is_editor_hint()):
			queue_redraw()
var staff_icon_image = "res://Sprites/UI/godotTaskIcon.png"
var staff_icon = "res://Nodes/task_details/staff_icon.tscn"


func _draw() -> void:
	for child in staff_hbox_holder.get_children():
		child.queue_free()
	for name in staff_names:
		var staff_icon_instance : StaffIcon = load(staff_icon).instantiate()
		staff_icon_instance.staff_name = name
		staff_hbox_holder.add_child(staff_icon_instance)

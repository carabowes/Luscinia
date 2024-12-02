@tool
extends Panel
class_name StaffIcon

@export var staff_name : String:
	set(value):
		staff_name = value
		draw_in_editor()
@export var staff_texture : Texture2D:
	set(value):
		staff_texture = value
		draw_in_editor()
@export var staff_name_label : Label:
	set(value):
		staff_name_label = value
		draw_in_editor()
@export var staff_image : TextureRect:
	set(value):
		staff_image = value
		draw_in_editor()


func _draw() -> void:
	staff_name_label.text = staff_name
	staff_image.texture = staff_texture


func draw_in_editor() -> void:
	if !Engine.is_editor_hint():
		return
	queue_redraw()

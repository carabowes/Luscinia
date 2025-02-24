extends Control

func _on_return_button_pressed() -> void:
	var main_parent = $"."
	main_parent.visible = false

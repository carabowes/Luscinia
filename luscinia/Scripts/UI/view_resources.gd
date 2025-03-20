extends Button


func _ready() -> void:
	pressed.connect(func(): GameManager.navbar_resource_button_pressed.emit())

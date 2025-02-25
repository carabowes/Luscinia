extends Button


func _ready() -> void:
	pressed.connect(func(): EventBus.navbar_resource_button_pressed.emit())

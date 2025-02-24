extends Button
#@onready var resource_page = $"../../../pages/resource_page"

func _ready() -> void:
	#self.pressed.connect(self.button_pressed)
	pressed.connect(func(): EventBus.navbar_resource_button_pressed.emit())
#
#func button_pressed():
	#resource_page.visible = !resource_page.visible

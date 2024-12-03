extends Node
@onready var resource_page = $"../../../pages/resource_page"

func _ready() -> void:
	self.pressed.connect(self.button_pressed)


func button_pressed():
	resource_page.visible = !resource_page.visible

extends Node
@onready var resource_page = $"../../../resource_page"

func _ready() -> void:
	self.pressed.connect(self.button_pressed)


func button_pressed():
	resource_page.visible = true

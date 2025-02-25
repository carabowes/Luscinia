extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(self.button_pressed)

func button_pressed():
	if(pressed):
		self.disconnect("pressed",self.button_pressed)
		self.disabled = true
		get_parent().get_parent().get_parent().visible = false

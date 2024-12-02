extends Sprite2D

@export var opacity: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self_modulate.a = opacity

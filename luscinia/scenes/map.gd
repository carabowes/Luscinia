extends Control

var current_scale : float = 1
@export var zoom_speed : float = 0.5
@export var pan_speed : float = 500
@onready var map = $MapTexture


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_EQUAL):
		current_scale += zoom_speed * delta
	if Input.is_key_pressed(KEY_MINUS):
		current_scale -= zoom_speed * delta
	if Input.is_key_pressed(KEY_W):
		map.position.y += pan_speed * delta
	if Input.is_key_pressed(KEY_S):
		map.position.y -= pan_speed * delta
	if Input.is_key_pressed(KEY_A):
		map.position.x += pan_speed * delta
	if Input.is_key_pressed(KEY_D):
		map.position.x -= pan_speed * delta
		
		
	map.scale = Vector2.ONE * current_scale

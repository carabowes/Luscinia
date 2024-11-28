extends Control

var current_scale : float = 1
@export var zoom_speed : float = 0.1
@export var min_zoom : float = 0.5  
@export var max_zoom : float = 2.0
@export var pan_speed : float = 500
@onready var map = $MapTexture

var is_dragging = false
var last_mouse_position = Vector2.ZERO

@export var map_size = Vector2(2500,1866)
@export var viewport_size = Vector2(1054, 933)

func _ready() -> void:
	var initial_position = (viewport_size - map_size * current_scale) / 2
	map.position = initial_position
	clamp_position()
	


func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_W):
		map.position.y += pan_speed * delta
		clamp_position()
	if Input.is_key_pressed(KEY_S):
		map.position.y -= pan_speed * delta
		clamp_position()
	if Input.is_key_pressed(KEY_A):
		map.position.x += pan_speed * delta
		clamp_position()
	if Input.is_key_pressed(KEY_D):
		map.position.x -= pan_speed * delta
		clamp_position()
		
	
func _input(event):
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			handle_wheel_input(zoom_speed, get_global_mouse_position())
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			handle_wheel_input(-zoom_speed, get_global_mouse_position())
			
			
			
func handle_wheel_input(delta_zoom: float, global_mouse_position: Vector2):
	var local_mouse_position = global_mouse_position - map.position
	var prev_scale = current_scale
	current_scale += delta_zoom
	current_scale = clamp(current_scale, min_zoom, max_zoom)
		
	if current_scale == prev_scale:
		return
			
	var scale_ratio = current_scale / prev_scale
	map.scale = Vector2.ONE * current_scale
	var focal_point_delta = local_mouse_position * (scale_ratio - 1)
	map.position -= focal_point_delta
	clamp_position()
		
func clamp_position() -> void:
		var scaled_map_size = map_size * current_scale
		
		var min_x = viewport_size.x - scaled_map_size.x if scaled_map_size.x > viewport_size.x else 0
		var min_y = viewport_size.y - scaled_map_size.y if scaled_map_size.y > viewport_size.y else 0
		var max_x = 0 if scaled_map_size.x > viewport_size.x else viewport_size.x - scaled_map_size.x
		var max_y = 0 if scaled_map_size.y > viewport_size.y else viewport_size.y - scaled_map_size.y
		
		
			
			
			
		map.position.x = clamp(map.position.x, min_x, max_x)
		map.position.y = clamp(map.position.y, min_y, max_y)
			
			
		
		
		

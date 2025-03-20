extends Control

signal zoom_changed

# Exported variables for customizing zoom behavior
@export var zoom_speed : float = 0.1
@export var min_zoom : float = 0.5
@export var max_zoom : float = 2.0
@export var pan_speed : float = 500

# Internal variables to track the map scale and position
var current_scale : float = 1
var is_dragging = false
var last_mouse_position = Vector2.ZERO

@onready var map = $MapTexture
@onready var map_size = map.size
@onready var viewport_size = Vector2(get_viewport().get_visible_rect().size)


func _ready() -> void:
	# Calculate initial position to center the map in the viewport based on the current scale
	var initial_position = (viewport_size - map_size * current_scale) / 2
	map.position = initial_position
	_clamp_position()


# This function is called every frame to update map position (pan) or zoom (mouse wheel)
func _process(delta: float) -> void:
	var directions = {
		KEY_W: Vector2(0, pan_speed),
		KEY_S: Vector2(0, -pan_speed),
		KEY_A: Vector2(pan_speed, 0),
		KEY_D: Vector2(-pan_speed, 0)
	}

	# Loop through directions and pan the map if the corresponding key is pressed
	for key in directions.keys():
		if Input.is_key_pressed(key):
			map.position += directions[key] * delta
			_clamp_position()


# This function handles different input events (mouse, touch gestures, etc.)
func _input(event):
	if event is InputEventMouseButton:
		# Handle zooming in or out based on mouse wheel input
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_handle_wheel_input(zoom_speed, get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_handle_wheel_input(-zoom_speed, get_global_mouse_position())
	elif event is InputEventScreenDrag:
		_handle_touch_drag(event)
	elif event is InputEventMagnifyGesture:
		_handle_touch_pinch(event)


# This function handles zooming when the mouse wheel is used
func _handle_wheel_input(delta_zoom: float, global_mouse_position: Vector2):
	var local_mouse_position = global_mouse_position - map.position
	var prev_scale = current_scale
	current_scale += delta_zoom
	current_scale = clamp(current_scale, min_zoom, max_zoom)

	# Only apply zoom changes if there was a change in the zoom level
	if current_scale != prev_scale:
		var scale_ratio = current_scale / prev_scale
		map.scale = Vector2.ONE * current_scale
		var focal_point_delta = local_mouse_position * (scale_ratio - 1)
		map.position -= focal_point_delta
		zoom_changed.emit()

	_clamp_position()


# This function handles pinch-to-zoom gestures on touch devices (for touch zooming)
func _handle_touch_pinch(event: InputEventMagnifyGesture):
	var delta_zoom = (event.factor - 1.0) * zoom_speed
	_handle_wheel_input(delta_zoom, get_global_mouse_position())


# This function ensures the map is within the boundaries of the viewport after zooming or panning
func _clamp_position() -> void:
	var scaled_map_size = map_size * current_scale
	var min_x = -(scaled_map_size.x - viewport_size.x)
	var max_x = 0
	var min_y = -(scaled_map_size.y - viewport_size.y)
	var max_y = 0

	# Clamp the map's position to ensure it stays within the allowed boundaries
	map.position.x = clamp(map.position.x, min_x, max_x)
	map.position.y = clamp(map.position.y, min_y, max_y)


# This function handles dragging the map with touch gestures
func _handle_touch_drag(event: InputEventScreenDrag) -> void:
	var prev_scale = current_scale
	map.position += event.relative
	_clamp_position()
	current_scale = clamp(current_scale, min_zoom, max_zoom)

	if current_scale != prev_scale:
		var scale_ratio = current_scale / prev_scale
		map.scale = Vector2.ONE * current_scale
		var focal_point_delta = (event.position - map.position) * (scale_ratio - 1)
		map.position -= focal_point_delta
		zoom_changed.emit()

	_clamp_position()

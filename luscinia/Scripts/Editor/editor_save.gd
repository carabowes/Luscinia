class_name EditorSave
extends Resource

@export var scenario : Scenario
@export var node_positions : Dictionary
@export var zoom : float
@export var scroll_offset : Vector2

func _init(
	scenario : Scenario = null,
 	node_positions : Dictionary = {},
	zoom : float = 1,
	scroll_offset = Vector2.ZERO
):
	self.scenario = scenario
	self.node_positions = node_positions
	self.zoom = zoom
	self.scroll_offset = scroll_offset

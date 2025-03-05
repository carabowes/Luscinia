class_name EditorSave
extends Resource

@export var scenario : Scenario
@export var node_info : Array[Array]
@export var zoom : float
@export var scroll_offset : Vector2
@export var connections : Array[Dictionary]

func _init(
	scenario : Scenario = null,
	_node_positions : Array[Array] = [],
	zoom : float = 1,
	scroll_offset : Vector2 = Vector2.ZERO,
	connections : Array[Dictionary] = []
):
	self.scenario = scenario
	self.node_info = node_info
	self.zoom = zoom
	self.scroll_offset = scroll_offset
	self.connections = connections

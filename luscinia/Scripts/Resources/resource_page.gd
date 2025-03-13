extends Control

# Signal emitted when the return button is pressed
signal return_button_pressed

# Resource dictionaries to track total and available resources
@export var resources = {}  # Stores total resources
@export var available_resources = {}  # Stores currently available resources


# Called when the node is added to the scene
func _ready() -> void:
	# Retrieve resources from the ResourceManager
	resources = ResourceManager.resources
	available_resources = ResourceManager.available_resources

	# Connects the visibility change signal to update labels when UI becomes visible
	visibility_changed.connect(update_all_labels)

	# Initial update of all labels
	update_all_labels()

	# Connects the return button's pressed signal to emit the custom return_button_pressed signal
	%ReturnButton.pressed.connect(func(): return_button_pressed.emit())


# Called every frame; updates all resource labels dynamically
func _process(_delta: float) -> void:
	update_all_labels()


# Updates a specific label with resource information
func update_label(label_name: String, resource_name: String, texture_name: String):
	# Get the label node by its name
	var label = get_node(label_name)

	# If the label exists and the resource is tracked
	if label and resource_name in resources:
		# Special formatting for "funds" and "supplies" (only show total value)
		if resource_name != "funds" and resource_name != "supplies":
			label.text = (
				str(ResourceManager.format_resource_value(available_resources.get(resource_name, 0), 2))
				+ " / "
				+ ResourceManager.format_resource_value(resources[resource_name], 2)
			)
		else:
			label.text = ResourceManager.format_resource_value(resources[resource_name], 2)
	else:
		print("Label or resource not found:", label_name, resource_name)

	# Get the corresponding texture node
	var texture_rect = get_node(texture_name)

	# If the texture node exists, update its texture
	if texture_rect:
		var texture = ResourceManager.get_resource_texture(resource_name)
		if texture:
			texture_rect.texture = texture
		else:
			print("Texture not found for resource:", resource_name)
	else:
		print("TextureRect not found:", texture_name)


# Updates all resource labels in the UI
func update_all_labels() -> void:
	# Update personnel label and icon
	update_label(
		"Background/GridContainer/Personel Output",
		"people",
		"Background/GridContainer/Personel Icon"
	)

	# Update funding label and icon
	update_label(
		"Background/GridContainer/Funding Output",
		"funds",
		"Background/GridContainer/Funding Icon"
	)

	# Update vehicles label and icon
	update_label(
		"Background/GridContainer/Vehicles Output",
		"vehicles",
		"Background/GridContainer/Vehicles Icon"
	)

	# Update supplies label and icon
	update_label(
		"Background/GridContainer/Supplies Output",
		"supplies",
		"Background/GridContainer/Supplies Icon"
	)

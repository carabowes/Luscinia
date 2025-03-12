extends GutTest

var ResourceEntry = preload("res://Scenes/UI/resource_entry.tscn")  # Replace with correct path
var resource_entry: ResourceEntry


func before_each():
	resource_entry = ResourceEntry.instantiate()
	add_child_autofree(resource_entry)
	resource_entry.resource_type = "people"
	resource_entry.amount = 100
	resource_entry.increase = 0 


func test_initialisation():
	assert_eq(resource_entry.resource_type, "people", "Resource type should be 'people'")
	assert_eq(resource_entry.amount, 100, "Amount should be 100")
	assert_eq(resource_entry.increase, 0, "Increase should be 0 initially")


func test_draw_no_increase():
	resource_entry.increase = 0
	resource_entry._draw()

	var increase_icon = resource_entry.get_node("%IncreaseIcon")
	var resource_amount = resource_entry.get_node("%ResourceAmount")

	assert_false(increase_icon.visible, "IncreaseIcon should be hidden")

	assert_eq(resource_amount.self_modulate, resource_entry.text_color, "ResourceAmount should be dimmed")


func test_draw_positive_increase():
	resource_entry.increase = 10
	resource_entry._draw()

	var increase_icon = resource_entry.get_node("%IncreaseIcon")
	var increase_color = resource_entry.get_node("%IncreaseColor")
	var resource_amount = resource_entry.get_node("%ResourceAmount")

	assert_not_null(increase_icon, "IncreaseIcon node should exist")
	assert_not_null(resource_amount, "ResourceAmount node should exist")

	assert_true(increase_icon.visible, "IncreaseIcon should be visible")

	assert_eq(increase_color.self_modulate, Color.LIME_GREEN, "IncreaseIcon should be lime green")
	assert_eq(resource_amount.self_modulate, Color.LIME_GREEN, "ResourceAmount should be lime green")


func test_draw_negative_increase():
	resource_entry.increase = -10 
	resource_entry._draw()

	var increase_icon = resource_entry.get_node("%IncreaseIcon")
	var increase_color = resource_entry.get_node("%IncreaseColor")
	var resource_amount = resource_entry.get_node("%ResourceAmount")

	assert_not_null(increase_icon, "IncreaseIcon node should exist")
	assert_not_null(resource_amount, "ResourceAmount node should exist")

	assert_true(increase_icon.visible, "IncreaseIcon should be visible")

	assert_eq(increase_color.self_modulate, Color.RED, "IncreaseIcon should be red")
	assert_eq(resource_amount.self_modulate, Color.RED, "ResourceAmount should be red")

	assert_true(increase_icon.flip_v, "IncreaseIcon should be flipped vertically for negative increases")


func test_change_resource_type():
	resource_entry.resource_type = "funds"
	resource_entry._draw() 

	assert_eq(resource_entry.resource_type, "funds", "Resource type should be updated to 'funds'")

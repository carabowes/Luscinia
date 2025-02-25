extends GutTest

var menu_scene


func before_each():
	menu_scene = load("res://Scenes/main_menu.tscn").instantiate() 
	add_child(menu_scene)


func after_each():
	menu_scene.queue_free()


func test_buttons_are_connected():
	assert_true(menu_scene.get_node("%PlayButton").is_connected("button_down", Callable(menu_scene, "show_modes_button")), "PlayButton not connected")
	assert_true(menu_scene.get_node("%Scenario1Button").is_connected("button_down", Callable(menu_scene, "change_to_scenario1")), "Scenario1Button not connected")
	assert_true(menu_scene.get_node("%BackButton").is_connected("button_down", Callable(menu_scene, "backbutton")), "BackButton not connected")
	assert_true(menu_scene.get_node("%PersonalmodeButton").is_connected("button_down", Callable(menu_scene, "single_mode")), "PersonalmodeButton not connected")
	assert_true(menu_scene.get_node("%DiscussionmodeButton").is_connected("button_down", Callable(menu_scene, "discuss_mode")), "DiscussionmodeButton not connected")


func test_show_modes_button():
	menu_scene.show_modes_button()
	await get_tree().create_timer(0.3).timeout
	assert_eq(menu_scene.get_node("%PlayButton").position.x, -280.0)
	assert_eq(menu_scene.get_node("%PersonalmodeButton").position, Vector2(41, 56))
	assert_eq(menu_scene.get_node("%DiscussionmodeButton").position, Vector2(41, 152))
	assert_eq(menu_scene.get_node("%BackButton").position, Vector2(41, 248))


func test_show_scenarios_button():
	menu_scene.show_scenarios_button()
	await get_tree().create_timer(0.3).timeout
	assert_eq(menu_scene.get_node("%Scenario1Button").position, Vector2(41, 56))
	assert_eq(menu_scene.get_node("%Scenario2Button").position, Vector2(41, 152))


func test_single_mode():
	menu_scene.single_mode()
	await get_tree().create_timer(0.3).timeout
	assert_eq(menu_scene.get_node("%Scenario1Button").position, Vector2(41, 56))
	assert_eq(menu_scene.get_node("%Scenario2Button").position, Vector2(41, 152))


func test_discuss_mode():
	menu_scene.discuss_mode()
	await get_tree().create_timer(0.3).timeout
	assert_eq(menu_scene.get_node("%Scenario1Button").position, Vector2(41, 56))
	assert_eq(menu_scene.get_node("%Scenario2Button").position, Vector2(41, 152))


func test_back_button():
	menu_scene.show_modes_button()
	await get_tree().create_timer(0.3).timeout
	menu_scene.backbutton()
	await get_tree().create_timer(0.3).timeout
	assert_eq(menu_scene.get_node("%PlayButton").position, Vector2(41, 56))
	assert_eq(menu_scene.get_node("%Scenario1Button").position.x, 384.0)
	assert_eq(menu_scene.get_node("%Scenario2Button").position.x, 384.0)
	assert_eq(menu_scene.get_node("%PersonalmodeButton").position.x, 384.0)
	assert_eq(menu_scene.get_node("%DiscussionmodeButton").position.x, 384.0)
	assert_eq(float(menu_scene.get_node("%BackButton").position.x), float(384.0))

extends GutTest

var message_bubble_instance : MessageBubble

func before_each():
	message_bubble_instance = load("res://Scenes/UI/message_bubble.tscn").instantiate()
	add_child_autofree(message_bubble_instance)


func test_set_text():
	message_bubble_instance.set_text("Test text.")
	assert_eq(message_bubble_instance.get_node("%Text").text, "Test text.")


func test_set_player_message_true():
	message_bubble_instance.set_player_message(true)
	var background = message_bubble_instance.get_node("%Background")
	assert_eq(background.self_modulate, message_bubble_instance.player_color)


func test_set_player_message_false():
	message_bubble_instance.set_player_message(false)
	var background = message_bubble_instance.get_node("%Background")
	assert_eq(background.self_modulate, message_bubble_instance.non_player_color)


func test_set_player_offsets():
	message_bubble_instance.set_player_message(true)
	message_bubble_instance.set_player_message_offsets()
	assert_eq(message_bubble_instance.offset_right, 0.0)


func test_set_join_non_player():
	var stylebox : StyleBoxFlat = message_bubble_instance.set_join(false, false)
	var unjoined_radius = message_bubble_instance.unjoined_corner_radius
	var joined_radius = message_bubble_instance.joined_corner_radius
	assert_eq(stylebox.corner_radius_bottom_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_bottom_right, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_right, unjoined_radius)
	
	stylebox = message_bubble_instance.set_join(true, false)
	assert_eq(stylebox.corner_radius_bottom_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_left, joined_radius)
	assert_eq(stylebox.corner_radius_bottom_right, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_right, unjoined_radius)
	
	stylebox = message_bubble_instance.set_join(false, true)
	assert_eq(stylebox.corner_radius_bottom_left, joined_radius)
	assert_eq(stylebox.corner_radius_top_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_bottom_right, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_right, unjoined_radius)
	
	stylebox = message_bubble_instance.set_join(true, true)
	assert_eq(stylebox.corner_radius_bottom_left, joined_radius)
	assert_eq(stylebox.corner_radius_top_left, joined_radius)
	assert_eq(stylebox.corner_radius_bottom_right, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_right, unjoined_radius)


func test_set_join_player():
	message_bubble_instance.set_player_message(true)
	var stylebox : StyleBoxFlat = message_bubble_instance.set_join(false, false)
	var unjoined_radius = message_bubble_instance.unjoined_corner_radius
	var joined_radius = message_bubble_instance.joined_corner_radius
	assert_eq(stylebox.corner_radius_bottom_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_bottom_right, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_right, unjoined_radius)
	
	stylebox = message_bubble_instance.set_join(true, false)
	assert_eq(stylebox.corner_radius_bottom_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_bottom_right, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_right, joined_radius)
	
	stylebox = message_bubble_instance.set_join(false, true)
	assert_eq(stylebox.corner_radius_bottom_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_bottom_right, joined_radius)
	assert_eq(stylebox.corner_radius_top_right, unjoined_radius)
	
	stylebox = message_bubble_instance.set_join(true, true)
	assert_eq(stylebox.corner_radius_bottom_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_top_left, unjoined_radius)
	assert_eq(stylebox.corner_radius_bottom_right, joined_radius)
	assert_eq(stylebox.corner_radius_top_right, joined_radius)

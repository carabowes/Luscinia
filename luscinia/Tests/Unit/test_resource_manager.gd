extends GutTest

var resources = {}
var available_resources = {}
var sender : Sender
var task_instance : TaskInstance
var resource_manager : ResourceManager


func before_each():
	resource_manager = ResourceManager.new(
		{"people": 100, "funds": 1000, "vehicles": 80, "supplies": 10000},
		{"people": 100, "vehicles": 80, "supplies": 10000}
	)
	task_instance = TaskInstance.new()
	sender = Sender.new("Test Sender",null,50)
	task_instance.message.sender = sender
	task_instance.task_data.task_id = "Test"
	add_child_autofree(resource_manager)


func test_add_resources():
	resource_manager.add_resources("funds", 500)
	assert_eq(resource_manager.resources["funds"],1500,"funds should equal 1500")


func test_remove_resources():
	resource_manager.remove_resources("funds", 500)
	assert_eq(resource_manager.resources["funds"],500,"funds should equal 500")


func test_remove_resources_not_negative():
	resource_manager.remove_resources("funds", 1100)
	assert_eq(resource_manager.resources["funds"],0,"funds should equal 0, cannot be negative")


func test_add_available_resources():
	resource_manager.add_available_resources("people", 500)
	assert_eq(resource_manager.available_resources["people"],600,"people should equal 600")


func test_remove_available_resources():
	resource_manager.remove_available_resources("people", 50)
	assert_eq(resource_manager.available_resources["people"],50,"people should equal 50")


func test_apply_start_task_resources():
	task_instance.task_data.resources_required = {"people": 50, "funds": 500, "vehicles": 40, "supplies": 5000}
	resource_manager.apply_start_task_resources(task_instance)
	assert_eq(resource_manager.resources["people"], 50, "'people' should be equal to 50")
	assert_eq(resource_manager.resources["funds"], 500, "'funds' should be equal to 500")
	assert_eq(resource_manager.resources["vehicles"], 40, "'people' should be equal to 40")
	assert_eq(resource_manager.resources["supplies"], 5000, "'supplies' should be equal to 5000")


func test_apply_end_task_resources():
	task_instance.task_data.resources_required = {"people": 50, "funds": 500, "vehicles": 40, "supplies": 5000}
	task_instance.task_data.resources_gained = {"people": 100, "funds": 500, "vehicles": 40, "supplies": 5000}
	resource_manager.apply_start_task_resources(task_instance)
	resource_manager.apply_end_task_resources(task_instance, false)
	assert_eq(resource_manager.resources["people"], 150, "'people' should be equal to 150")
	assert_eq(resource_manager.resources["funds"], 1000, "'funds' should be equal to 1000")
	assert_eq(resource_manager.resources["vehicles"], 80, "'vehicles' should be equal to 40")
	assert_eq(resource_manager.resources["supplies"], 10000, "'supplies' should be equal to 10000")
	assert_eq(resource_manager.available_resources["people"], 150, "'people' available should be equal to 150")
	assert_eq(resource_manager.available_resources["vehicles"], 80, "'vehicles' available should be equal to 40")


func test_apply_end_task_resources_loss_overflow():
	task_instance.task_data.resources_required = { "vehicles": 80}
	task_instance.task_data.resources_gained = { "vehicles": 40}
	resource_manager.apply_start_task_resources(task_instance)
	resource_manager.apply_end_task_resources(task_instance, false)
	assert_eq(resource_manager.available_resources["vehicles"], 40, "'vehicles' available should be equal to 40")
	task_instance.task_data.resources_gained = { "vehicles": 80}
	resource_manager.apply_end_task_resources(task_instance, false)
	assert_eq(resource_manager.available_resources["vehicles"], 40, "'vehicles' available should be equal to 40")
	assert_eq(resource_manager.resources["vehicles"], 40, "'vehicles' should be equal to 40")


func test_apply_end_task_resources_gain_overflow():
	task_instance.task_data.resources_required = { "vehicles": 40}
	task_instance.task_data.resources_gained = { "vehicles": 80}
	resource_manager.apply_start_task_resources(task_instance)
	resource_manager.apply_end_task_resources(task_instance, false)
	assert_eq(resource_manager.available_resources["vehicles"], 120, "'vehicles' available should be equal to 120")
	assert_eq(resource_manager.resources["vehicles"], 120, "'vehicles' should be equal to 40")


func test_get_resource_texture():
	var texture = ResourceManager.get_resource_texture("people")
	assert_eq(texture,preload("res://Sprites/UI/User.png"),"image texture should be User.png")


func test_queue_relationship_change():
	task_instance.relationship_change = 10
	resource_manager.queue_relationship_change(task_instance)
	assert_eq(resource_manager.relationships_to_update["Test"], 10.0, "Task 'Test' should have relationship change of 10")


func test_apply_relationship_change_full_progress():
	task_instance.current_progress = task_instance.task_data.expected_completion_time
	task_instance.relationship_change = 10
	resource_manager.queue_relationship_change(task_instance)
	resource_manager.apply_relationship_change(task_instance, false)
	assert_eq(sender.relationship, 60.0, "Relationship should increase by 10 when task is fully completed")
	assert_false(resource_manager.relationships_to_update.has("Test"), "Task 'Test' should be removed from relationships_to_update")


func test_apply_relationship_change_half_progress():
	task_instance.current_progress = task_instance.task_data.expected_completion_time/2
	task_instance.relationship_change = 10
	resource_manager.queue_relationship_change(task_instance)
	resource_manager.apply_relationship_change(task_instance, false)
	assert_eq(sender.relationship, 50.0, "Relationship should remain unchanged when task progress is 50%")


func test_apply_relationship_change_zero_progress():
	task_instance.current_progress = 0
	task_instance.relationship_change = 10
	resource_manager.queue_relationship_change(task_instance)
	resource_manager.apply_relationship_change(task_instance, false)
	assert_eq(sender.relationship, 40.0, "Relationship should decrease by 10 when task is not completed")


func test_apply_relationship_change_no_task():
	resource_manager.apply_relationship_change(task_instance, false) #Task was never queued
	assert_eq(sender.relationship, 50.0, "Relationship should remain unchanged when task ID is not found")


func test_round_to_dp():
	assert_eq(ResourceManager.round_to_dp(123.4567, 2), 123.46, "Rounding to 2 decimal places failed")
	assert_eq(ResourceManager.round_to_dp(123.4, 1), 123.4, "Rounding to 1 decimal place failed")
	assert_eq(ResourceManager.round_to_dp(123.444, 2), 123.44, "Rounding down failed")
	assert_eq(ResourceManager.round_to_dp(123.445, 2), 123.45, "Rounding up failed")
	assert_eq(ResourceManager.round_to_dp(0.9999, 3), 1.0, "Rounding up across integer boundary failed")


func test_format_resource_value():
	assert_eq(ResourceManager.format_resource_value(999, 1), "999", "Did not return raw number for values below 1K")
	assert_eq(ResourceManager.format_resource_value(1000, 1), "1K", "Formatting to K failed")
	assert_eq(ResourceManager.format_resource_value(1050, 1), "1.1K", "Rounding and formatting to K failed")
	assert_eq(ResourceManager.format_resource_value(1000000, 1), "1M", "Formatting to M failed")
	assert_eq(ResourceManager.format_resource_value(2500000, 1), "2.5M", "Rounding and formatting to M failed")


func test_format_resource_value_with_resource():
	var supplies = resource_manager.resources["supplies"]
	var formatted_resource = ResourceManager.format_resource_value(supplies,2)
	assert_eq(formatted_resource, "10K", "supplies should be 10k")

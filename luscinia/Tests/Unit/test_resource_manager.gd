extends GutTest

var resources = {}
var available_resources = {}
var sender : Sender


func before_each():
	ResourceManager.resources = {"people": 100, "funds": 1000, "vehicles": 80, "supplies": 10000}
	ResourceManager.available_resources = {"people": 100, "vehicles": 80}
	ResourceManager.relationships_to_update.clear()	
	sender = Sender.new("Test Sender",null,50)


func test_add_resources():
	ResourceManager.add_resources("funds", 500)
	assert_eq(ResourceManager.resources["funds"],1500.0,"funds should equal 1500")


func test_remove_resources():
	ResourceManager.remove_resources("funds", 500)
	assert_eq(ResourceManager.resources["funds"],500.0,"funds should equal 500")


func test_remove_resources_not_negative():
	ResourceManager.remove_resources("funds", 1100)
	assert_eq(ResourceManager.resources["funds"],0.0,"funds should equal 0, cannot be negative")


func test_add_available_resources():
	ResourceManager.add_available_resources("people", 500)
	assert_eq(ResourceManager.available_resources["people"],600.0,"people should equal 600")


func test_remove_available_resources():
	ResourceManager.remove_available_resources("people", 50)
	assert_eq(ResourceManager.available_resources["people"],50.0,"people should equal 50")


func test_apply_start_task_resources():
	ResourceManager.apply_start_task_resources({"people": 50, "funds": 500, "vehicles": 40, "supplies": 5000})
	assert_eq(ResourceManager.resources["people"], 50.0, "'people' should be equal to 50")
	assert_eq(ResourceManager.resources["funds"], 500.0, "'funds' should be equal to 500")
	assert_eq(ResourceManager.resources["vehicles"], 40.0, "'people' should be equal to 40")
	assert_eq(ResourceManager.resources["supplies"], 5000.0, "'supplies' should be equal to 5000")


func test_apply_end_task_resources():
	ResourceManager.apply_start_task_resources({"people": 50, "funds": 500, "vehicles": 40, "supplies": 5000})
	ResourceManager.apply_end_task_resources(
		{"people": 100, "funds": 500, "vehicles": 40, "supplies": 5000},
		{"people": 50, "funds": 500, "vehicles": 80, "supplies": 5000},
	)
	assert_eq(ResourceManager.resources["people"], 150, "'people' should be equal to 150")
	assert_eq(ResourceManager.resources["funds"], 1000, "'funds' should be equal to 1000")
	assert_eq(ResourceManager.resources["vehicles"], 40, "'vehicles' should be equal to 40")
	assert_eq(ResourceManager.resources["supplies"], 10000, "'supplies' should be equal to 10000")
	assert_eq(ResourceManager.available_resources["people"], 150, "'people' available should be equal to 150")
	assert_eq(ResourceManager.available_resources["vehicles"], 40, "'vehicles' available should be equal to 40")


func test_apply_end_task_resources_loss_overflow():
	ResourceManager.apply_start_task_resources({"vehicles": 80})
	ResourceManager.apply_end_task_resources(
		{},
		{"vehicles": 40},
	)
	assert_eq(ResourceManager.available_resources["vehicles"], 40, "'vehicles' available should be equal to 40")
	ResourceManager.apply_end_task_resources(
		{"vehicles": 80},
		{"vehicles": 80},
	)
	assert_eq(ResourceManager.available_resources["vehicles"], 40, "'vehicles' available should be equal to 40")
	assert_eq(ResourceManager.resources["vehicles"], 40, "'vehicles' should be equal to 40")


func test_apply_end_task_resources_gain_overflow():
	ResourceManager.apply_start_task_resources({"vehicles": 80})
	ResourceManager.apply_end_task_resources(
		{"vehicles": 40},
		{}
	)
	assert_eq(ResourceManager.available_resources["vehicles"], 120, "'vehicles' available should be equal to 40")
	assert_eq(ResourceManager.resources["vehicles"], 40, "'vehicles' should be equal to 40")
	ResourceManager.apply_end_task_resources(
		{"vehicles": 80},
		{"vehicles": 80},
	)
	assert_eq(ResourceManager.available_resources["vehicles"], 120, "'vehicles' available should be equal to 40")
	assert_eq(ResourceManager.resources["vehicles"], 120, "'vehicles' should be equal to 120")


func test_get_resource_texture():
	var texture = ResourceManager.get_resource_texture("people")
	assert_eq(texture,preload("res://Sprites/UI/User.png"),"image texture should be User.png")


func test_queue_relationship_change():
	ResourceManager.queue_relationship_change(1, 10)
	assert_eq(ResourceManager.relationships_to_update[1], 10.0, "Task 1 should have relationship change of 10")


func test_apply_relationship_change_full_progress():
	ResourceManager.queue_relationship_change(1, 10)
	ResourceManager.apply_relationship_change(1, sender, 1.0)
	assert_eq(sender.relationship, 60.0, "Relationship should increase by 10 when task is fully completed")
	assert_false(ResourceManager.relationships_to_update.has(1), "Task 1 should be removed from relationships_to_update")


func test_apply_relationship_change_half_progress():
	ResourceManager.queue_relationship_change(1, 10)
	ResourceManager.apply_relationship_change(1, sender, 0.5)
	assert_eq(sender.relationship, 50.0, "Relationship should remain unchanged when task progress is 50%")


func test_apply_relationship_change_zero_progress():
	ResourceManager.queue_relationship_change(1, 10)
	ResourceManager.apply_relationship_change(1, sender, 0.0)
	assert_eq(sender.relationship, 40.0, "Relationship should decrease by 10 when task is not completed")


func test_apply_relationship_change_no_task():
	ResourceManager.apply_relationship_change(99, sender, 1.0)  # Task ID 99 was never queued
	assert_eq(sender.relationship, 50.0, "Relationship should remain unchanged when task ID is not found")

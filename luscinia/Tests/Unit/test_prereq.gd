extends GutTest


var prereq_instance


func before_each():
	prereq_instance = Prerequisite.new()


func test_default_initialisation():
	assert_eq(prereq_instance.task_id,[],"Task ID should be empty list")
	assert_eq(prereq_instance.chance,0,"chance should be 0")
	assert_eq(prereq_instance.events,[],"Events should be empty list")


func test_custom_initialisation():
	var custom_prereq_instance = Prerequisite.new([5],0.5,[Event.EventType.AFTERSHOCK])
	assert_eq(custom_prereq_instance.task_id.size(), 1, "Task ID should contain 1 element")
	assert_eq(custom_prereq_instance.task_id[0], 5, "First element should be 5")
	assert_eq(custom_prereq_instance.chance, 0.5, "Chance should equal 0.5")
	assert_eq(custom_prereq_instance.events.size(), 1, "The events size should be 1")
	assert_eq(custom_prereq_instance.events[0], Event.EventType.AFTERSHOCK, "First element should be Aftershock")

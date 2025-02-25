extends GutTest


func before_each():
	TaskManager.active_tasks = []
	TaskManager.completed_tasks = []


func test_positive_relationship_applied_zero_time_task():
	# Task with 0 completion time
	var task : TaskData = TaskData.new("TaskID", "", null, Vector2.ZERO, Vector2.ZERO, {}, {}, 0)
	var response : Response = Response.new("Response", "", 10, task)
	var sender : Sender = Sender.new()
	var message : Message = Message.new("", [response], 0, sender)
	TaskManager._start_task(response, message)
	assert_eq(sender.relationship, 10.0, "Relationship should be 10 after task completion")


func test_negative_relationship_applied_zero_time_task():
	# Task with 0 completion time
	var task : TaskData = TaskData.new("TaskID", "", null, Vector2.ZERO, Vector2.ZERO, {}, {}, 0)
	var response : Response = Response.new("Response", "", -20, task)
	var sender : Sender = Sender.new()
	var message : Message = Message.new("", [response], 0, sender)
	TaskManager._start_task(response, message)
	assert_eq(sender.relationship, -20.0, "Relationship should be -20 after task completion")

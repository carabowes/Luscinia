extends GutTest


var response_instance


func before_each():
	response_instance = Response.new()


func test_default_initialisation():
	assert_eq(response_instance.response_text,"","Response text should be empty string")
	assert_eq(response_instance.relationship_change,0,"relationship change should be 0")
	assert_null(response_instance.task, "tasks should be null")


func test_custom_initialisation():
	var task_data = TaskData.new(1,"Test",null,Vector2(0,0),Vector2(10,10),{"funds":10},{"funds":10},5,[])
	var custom_response_instance = Response.new("test response",5,task_data)
	assert_eq(custom_response_instance.response_text,"test response","Response text should be test response")
	assert_eq(custom_response_instance.relationship_change,5,"relationship change should be 5")
	assert_eq(custom_response_instance.task,task_data,"Tasks should be task data")

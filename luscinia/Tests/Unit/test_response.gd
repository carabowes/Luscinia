extends GutTest

var response_instance

func before_each():
	response_instance = Response.new()


func test_default_initialisation():
	assert_eq(response_instance.response_name,"Response","Response name should be empty string")
	assert_eq(response_instance.response_text,"","Response text should be empty string")
	assert_eq(response_instance.relationship_change,0.0,"relationship change should be 0")
	assert_null(response_instance.task, "tasks should be null")


func test_custom_initialisation():
	var task_data = TaskData.new("TaskID","Test",null,Vector2(0,0),Vector2(10,10),{"funds":10},{"funds":10},5,[])
	var custom_response_instance = Response.new("response name", "test response",5,task_data)
	assert_eq(custom_response_instance.response_name, "response name", "Response name should be 'response name'")
	assert_eq(custom_response_instance.response_text,"test response","Response text should be test response")
	assert_eq(custom_response_instance.relationship_change,5.0,"relationship change should be 5")
	assert_eq(custom_response_instance.task,task_data,"Tasks should be task data")

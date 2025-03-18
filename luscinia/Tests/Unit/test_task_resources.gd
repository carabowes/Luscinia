extends GutTest

var task_resources_instance : TaskResources

var test_add_elements_paramaters = ParameterFactory.named_parameters(
	['resources', 'expected_keys', 'expected_values'],
	[
		[{"funds": 100, "people": 50, "supplies": 50, "vehicles": 1000}, ["funds", "people", "supplies", "vehicles"], [100, 50, 50, 1000]],
		[{}, [], []],
		[{"test": "test", "test2": 10}, ["test2"], [10]],
		[{"test": 0, "test2": 5.5, "test3": 7, "test4": 9}, ["test3", "test4"], [7, 9]]
	]
)

func before_each():
	task_resources_instance = load("res://Scenes/UI/task_resources.tscn").instantiate()
	add_child_autofree(task_resources_instance)


func test_getters_and_setters():
	assert_eq(task_resources_instance.resources, {}, "Resources should be empty initially")
	task_resources_instance.resources = Scenario.default_scenario.resources
	assert_eq(task_resources_instance.get_child_count(), 4)
	assert_eq(task_resources_instance.resources, Scenario.default_scenario.resources)


func test_add_elements_normal_values(params = use_parameters(test_add_elements_paramaters)):
	task_resources_instance.resources = params.resources
	assert_eq(task_resources_instance.get_child_count(), len(params.expected_values))
	for i in range(task_resources_instance.get_child_count()):
		assert_is(task_resources_instance.get_child(i), ResourceEntry)
		var entry : ResourceEntry = task_resources_instance.get_child(i)
		var resource_key = params.expected_keys[i]
		var resource_value = params.expected_values[i]
		assert_eq(entry.amount, resource_value)
		assert_eq(entry.resource_type, resource_key)
		assert_eq(entry.name, resource_key)


func test_set_increments_show_arrow():
	task_resources_instance.resources = {"funds": 1, "people": 1}
	task_resources_instance.set_increments({"funds": 1})
	var entry : ResourceEntry = task_resources_instance.get_child(0)
	assert_eq(entry.increase, 1)
	assert_true(entry.show_arrow)
	entry = task_resources_instance.get_child(1)
	assert_eq(entry.increase, 0)


func test_set_increments_no_arrow():
	task_resources_instance.resources = {"funds": 1, "people": 1}
	task_resources_instance.set_increments({"funds": -1}, false)
	var entry : ResourceEntry = task_resources_instance.get_child(0)
	assert_eq(entry.increase, -1)
	assert_false(entry.show_arrow)
	entry = task_resources_instance.get_child(1)
	assert_eq(entry.increase, 0)

extends GutTest

var event_effect_instance

func before_each():
	event_effect_instance = EventEffect.new()


func test_default_initialisation():
	assert_eq(event_effect_instance.event,0,"Default Event should be 0")
	assert_eq(event_effect_instance.effects,[],"Default Event should be empty list")


func test_custom_initialisation():
	var effect_instance = Effect.new()
	var custom_event_effect_instance = EventEffect.new(Event.EventType.AFTERSHOCK, [effect_instance])
	assert_eq(custom_event_effect_instance.event, Event.EventType.AFTERSHOCK, "Event should be AFTERSHOCK")
	assert_eq(custom_event_effect_instance.effects.size(), 1, "Effects should contain one Effect instance")
	assert_eq(custom_event_effect_instance.effects[0], effect_instance, "The effect instance should match")
	

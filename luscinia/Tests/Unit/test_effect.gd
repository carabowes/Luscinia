extends GutTest


var effect_instance


func before_each():
	effect_instance = Effect.new()


func test_default_initialisation():
	assert_eq(effect_instance.effect_type, Effect.EffectType.RESOURCE, "Default effect type should be RESOURCE")
	assert_eq(effect_instance.resource_type, 0, "Default resource type should be 0")
	assert_eq(effect_instance.change_amount, 0, "Default change amount should be 0")
	assert_eq(effect_instance.chance, 0.0, "Default chance should be 0.0")


func test_custom_initialisation():
	var custom_effect = Effect.new(Effect.EffectType.TIME, 2, -5, 0.5)
	assert_eq(custom_effect.effect_type, Effect.EffectType.TIME, "Effect type should be TIME")
	assert_eq(custom_effect.resource_type, 2, "Resource type should be 2")
	assert_eq(custom_effect.change_amount, -5, "Change amount should be -5")
	assert_eq(custom_effect.chance, 0.5, "Chance should be 0.5")


func test_clamp_chance():
	var custom_effect = Effect.new(Effect.EffectType.TIME, 2, -5, -0.5)
	assert_eq(custom_effect.chance, 0.0, "Chance should be 0.0")


func test_effect_type_assignment():
	effect_instance.effect_type = Effect.EffectType.FAILURE
	assert_eq(effect_instance.effect_type, Effect.EffectType.FAILURE, "Effect type should be FAILURE")


func test_resource_type_assignment():
	effect_instance.resource_type = 3
	assert_eq(effect_instance.resource_type, 3, "Resource type should be 3")


func test_change_amount_assignment():
	effect_instance.change_amount = -10
	assert_eq(effect_instance.change_amount, -10, "Change amount should be -10")
	

func test_chance_bounds():
	effect_instance.chance = 0.5
	assert_eq(effect_instance.chance, 0.5, "Chance should be 0.5")

	

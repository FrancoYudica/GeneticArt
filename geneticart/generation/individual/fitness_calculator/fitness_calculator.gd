class_name FitnessCalculator extends Node

var target_texture: Texture2D:
	set(texture):
		target_texture = texture
		_target_texture_set()

func calculate_fitness(
	individual: Individual,
	source_texture: Texture2D) -> void:
	
	individual.fitness = -1.0

func _target_texture_set():
	pass

extends Node

signal generation_started
signal generation_finished
signal individual_generated(individual: Individual)
signal source_texture_updated
signal target_texture_updated

@export_group("Metric")
@export var metric_scripts: Array[GDScript]

var image_generator: ImageGenerator
var metrics: Array[Metric]

func clear_source_texture():
	image_generator.individual_generator.clear_source_texture()
	source_texture_updated.emit()

func generate() -> void:
	generation_started.emit()
	# Executes the generation in another thread to avoild locking the UI
	WorkerThreadPool.add_task(_begin_image_generation)

func stop():
	image_generator.stop()

func refresh_target_texture():
	image_generator.update_target_texture(
		Globals \
		.settings \
		.image_generator_params \
		.individual_generator_params \
		.target_texture)
	
	target_texture_updated.emit()
	clear_source_texture()

func _ready() -> void:
	_setup_references()
	target_texture_updated.emit()
	
	for metric_script in metric_scripts:
		var metric = metric_script.new() as Metric
		if metric == null:
			push_error("Trying to create a metric with invalid script: %s" % metric_script.resource_path)
			continue
			
		metrics.append(metric)
	
	
func _setup_references():
	# Image generator
	image_generator = ImageGenerator.new()
	image_generator.params = Globals.settings.image_generator_params
	image_generator.individual_generated.connect(
		func(i): 
			call_deferred("_emit_individual_generated_signal", i)
			call_deferred("emit_signal", "source_texture_updated"))
	image_generator.setup()
	clear_source_texture()

func _emit_individual_generated_signal(individual: Individual):
	individual_generated.emit(individual)

func _begin_image_generation():
	image_generator.generate_image()
	call_deferred("emit_signal", "generation_finished")

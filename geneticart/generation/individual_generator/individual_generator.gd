# An algorithm that, given a set of parameters, a target texture, and a source texture, 
# generates the best possible individual. This individual, when added to the source texture, 
# minimizes the error metric relative to the target texture.
class_name IndividualGenerator extends Node

@export_category("Data")

var params: IndividualGeneratorParams

@export_category("Algorithm components")
@export var average_color_sampler: AverageColorSampler
@export var fitness_calculator: FitnessCalculator
@export var individual_renderer: IndividualRenderer
@export var populator: Populator

var source_texture: RendererTexture

var _initialized = false

func initialize(generator_params: IndividualGeneratorParams):
	
	params = generator_params
	
	if not params.target_texture.is_valid():
		printerr("Trying to initialize IndividualGenerator but target_texture is invalid")
		return
		
	fitness_calculator.target_texture = params.target_texture
	average_color_sampler.sample_texture = params.target_texture

	if source_texture == null or not source_texture.is_valid():
		_initialize_src_image()

	_initialized = true


func generate_individual() -> Individual:
	
	if not _initialized:
		printerr("IndividialGenerator not initialized")
		return
	
	_setup()
	return _generate()

func _setup():
	individual_renderer.source_texture = source_texture

func _generate() -> Individual:
	return

func _initialize_src_image():
	
	var img = Image.create(
		params.target_texture.get_width(),
		params.target_texture.get_height(),
		false, 
		Image.FORMAT_RGBA8)
	
	# The initial color of the source texture is the average color of target texture
	var average_color = average_color_sampler.sample_rect(
		Rect2i(
			Vector2i.ZERO, 
			Vector2i(
				params.target_texture.get_width(),
				params.target_texture.get_height()
			)
		)
	)
	img.fill(average_color)
	
	# Creates to image texture and then to RD local texture
	var source_texture_global_rd = ImageTexture.create_from_image(img)
	source_texture = RendererTexture.load_from_texture(source_texture_global_rd)

extends Control

@export var background_texture: RendererTextureLoad
@export var sprite_mask: RendererTextureLoad

@export var sampler_script: GDScript

var average_color_sampler: AverageColorSampler
@export var compare_results: bool

@onready var sample_color_rect := $OutlineColorRect/MarginContainer/SampleTextureRect
@onready var parent_color_rect := $OutlineColorRect


func _ready() -> void:
	
	average_color_sampler = sampler_script.new()

var _textures_initialized = false

func _process(delta: float) -> void:
	
	# Renders background only
	Renderer.begin_frame(size)
	Renderer.render_sprite(
		background_texture.get_size() * 0.5,
		background_texture.get_size(),
		0.0,
		Color.WHITE,
		background_texture
	)
	Renderer.end_frame()
	
	# Gets the clean sample texture
	if not _textures_initialized:
		var color_attachment = Renderer.get_attachment_texture(Renderer.FramebufferAttachment.COLOR)
		average_color_sampler.sample_texture = color_attachment.copy()
	
	# Renders background and sprite with it's ID
	Renderer.begin_frame(size)
	Renderer.render_sprite(
		background_texture.get_size() * 0.5,
		background_texture.get_size(),
		0.0,
		Color.WHITE,
		background_texture
	)
	
	var mouse = get_local_mouse_position()
	
	Renderer.render_sprite(
		mouse,
		sample_color_rect.get_global_rect().size,
		0.0,
		Color.WHITE,
		sprite_mask,
		1.0
	)
	Renderer.end_frame()

	# Gets the clean sample texture
	if not _textures_initialized:
		average_color_sampler.id_texture = Renderer.get_attachment_texture(Renderer.FramebufferAttachment.UID)
		_textures_initialized = true

	var rect: Rect2i
	rect.position = Vector2i(mouse - parent_color_rect.size * 0.5)
	rect.size = Vector2i(
		sample_color_rect.get_global_rect().size.x,
		sample_color_rect.get_global_rect().size.y)
	
		
	var clock = Clock.new()
	var color = average_color_sampler.sample_rect(rect)
	clock.print_elapsed("Sampled average color: %s" % color)
		
	parent_color_rect.position = rect.position
	sample_color_rect.modulate = color
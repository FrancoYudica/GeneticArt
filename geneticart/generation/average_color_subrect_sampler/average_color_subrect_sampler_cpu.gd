extends AverageColorSampler


func sample_rect(rect: Rect2i) -> Color:
	
	var image: Image = sample_texture.get_image()
	
	# Normalization factor
	#var n = 1.0 / (rect.size.x * rect.size.y)
	var accumulated_color = Color(0, 0, 0, 0)
	var sampled_count = 0
	for x in range(rect.position.x, rect.position.x + rect.size.x):
		
		
		# It's out of bounds and will always be
		if x < 0 or x >= image.get_width():
			continue
		
		for y in range(rect.position.y, rect.position.y + rect.size.y):
			
			# It's out of bounds and will always be
			if y < 0 or y >= image.get_height():
				continue
			
			var sample = image.get_pixel(x, y)
			accumulated_color += sample
			sampled_count += 1
			
	var avg_color = accumulated_color / sampled_count
			
	return avg_color
	

extends GPUParticles2D

func setBoxRange(rangeX):
	process_material.emission_box_extents.x = rangeX

func emit():
	emitting = true
	await get_tree().create_timer(5.0).timeout
	queue_free()

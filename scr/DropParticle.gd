extends Particles2D
const mat = preload("res://extras/DropParticle.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	process_material = mat.duplicate()

func setBoxRanges(ranges):
	process_material.emission_box_extents.x = ranges.x
	process_material.emission_box_extents.y = ranges.y
	
func setColor(color: Color):
	process_material.color = color

func setAmountParticles(particles):
	amount = particles
	
func emit():
	emitting = true
	yield(get_tree().create_timer(5.0), "timeout")
	queue_free()

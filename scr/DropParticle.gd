extends Particles2D
var mat = preload("res://extras/DropParticle.tres")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	process_material = mat.duplicate()
	pass # Replace with function body.

func setBoxRanges(ranges):
	process_material.emission_box_extents.x = ranges.x
	process_material.emission_box_extents.y = ranges.y
	
func setColor(color: Color):
	process_material.color = color

func setAmountParticles(particles):
	amount = particles
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

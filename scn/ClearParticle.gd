extends Particles2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func setBoxRange(rangeX):
	process_material.emission_box_extents.x = rangeX

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func emit():
	emitting = true
	yield(get_tree().create_timer(5.0), "timeout")
	queue_free()

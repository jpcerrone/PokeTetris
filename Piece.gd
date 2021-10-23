extends Node2D
var positionInGrid:Vector2
#Shape described by column:
const I_SHAPE = [[1],[1],[1],[1]]
const J_SHAPE = [[2,2],[0,2],[0,2]]
const L_SHAPE = [[0,3],[0,3],[3,3]]
const O_SHAPE = [[4,4],[4,4]]
const T_SHAPE = [[0,5],[5,5],[0,5]]
const Z_SHAPE = [[6,0],[6,6],[0,6]]
const shapes = [I_SHAPE, J_SHAPE, L_SHAPE, O_SHAPE, T_SHAPE, Z_SHAPE]
var shape
func _init():
	shape = shapes[randi() % 5]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

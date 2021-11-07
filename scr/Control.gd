extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Grid_lines_change(score):
	$Lines/LinesNumber.text = str(score)

func _on_Grid_level_change(level):
	$Level/LevelNumber.text = str(level)
	
func _on_Grid_score_change(score):
	$Score/ScoreNumber.text = str(score)

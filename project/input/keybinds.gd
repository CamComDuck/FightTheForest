class_name Keybinds
extends Node2D

var direction := Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var directionH = Input.get_axis("left", "right")
	var directionV = Input.get_axis("down", "up")

	direction = Vector2(directionH, directionV)


func GetDirection() -> Vector2:
	return direction


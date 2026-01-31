class_name Keybinds
extends Node2D

signal onDirectionChosen(direction: Vector2)

func _input(_event: InputEvent):

	var direction := Vector2.ZERO

	if Input.is_action_just_pressed("left"):
		direction.x = -1

	elif Input.is_action_just_pressed("right"):
		direction.x = 1

	if Input.is_action_just_pressed("up"):
		direction.y = 1

	elif Input.is_action_just_pressed("down"):
		direction.y = -1

	onDirectionChosen.emit(direction)
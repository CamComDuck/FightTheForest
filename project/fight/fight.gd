class_name Fight
extends Node2D

@onready var moth: Moth = %Moth as Moth
@onready var threat: Threat = %Threat as Threat
@onready var keybinds: Keybinds = %Keybinds as Keybinds
@onready var stateChart:StateChart = $StateChart as StateChart


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_threat_turn_state_entered() -> void:
	print("threat turn entered")


func _on_player_turn_state_entered() -> void:
	print("player turn entered")



func _on_player_turn_state_processing(_delta: float) -> void:
	var direction = keybinds.GetDirection()

	if direction != Vector2.ZERO and direction != Vector2(0, -1):
		# Player selected a choice
		if direction.x < 0 and direction.y == 0:
			# left
			# print("left")
			stateChart.send_event("OnPlayerPickedMove")
			pass
		elif direction.x > 0 and direction.y == 0:
			# right
			stateChart.send_event("OnPlayerPickedMove")
			pass
		elif direction.x == 0 and direction.y > 0:
			# up
			stateChart.send_event("OnPlayerPickedMove")
			pass
		

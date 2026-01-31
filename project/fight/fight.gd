class_name Fight
extends Node2D

@onready var moth: Moth = %Moth as Moth
@onready var threat: Threat = %Threat as Threat
@onready var keybinds: Keybinds = %Keybinds as Keybinds
@onready var stateChart:StateChart = $StateChart as StateChart

const onMothTurnEnded := "OnMothTurnEnded"
const onThreatTurnEnded := "OnThreatTurnEnded"

var isThreatTurnSkipped := false
var isMothTurnSkipped := false

var isAwaitingInput := false

var isUsingKeyboard := true


func _ready() -> void:
	if isUsingKeyboard:
		keybinds.connect("OnDirectionChosen", OnDirectionChosen)


func OnDirectionChosen(direction: Vector2) -> void:
	if not isAwaitingInput:
		return

	if direction != Vector2.ZERO and direction != Vector2(0, -1):
		# Player selected a choice
		if direction.x < 0 and direction.y == 0: # left -> eat
			stateChart.send_event(onMothTurnEnded)

		elif direction.x > 0 and direction.y == 0: # right -> mask
			stateChart.send_event(onMothTurnEnded)

		elif direction.x == 0 and direction.y > 0: # up -> attack
			stateChart.send_event(onMothTurnEnded)


func _on_threat_turn_state_entered() -> void:
	print("threat turn entered")
	if isThreatTurnSkipped: # no action
		isThreatTurnSkipped = false
		stateChart.send_event(onThreatTurnEnded)

	else: # picks random action
		stateChart.send_event(onThreatTurnEnded)


func _on_moth_turn_state_entered() -> void:
	print("player turn entered")
	if isMothTurnSkipped: # no action
		isMothTurnSkipped = false
		stateChart.send_event(onMothTurnEnded)

	else: # await player choosing action
		isAwaitingInput = true
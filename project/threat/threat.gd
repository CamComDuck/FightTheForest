@icon("res://threat/tree.png")
class_name Threat
extends Sprite2D

signal onThreatDied

var maxHealth := 10
var currentHealth := 10
var burnRoundsLeft := 0

func getHealth() -> int:
	return currentHealth


func incrementHealth(inc: int) -> void:
	currentHealth += inc
	if currentHealth <= 0:
		# die
		print("threat died")
		onThreatDied.emit()


func incrementBurnRounds(inc: int) -> void:
	burnRoundsLeft += inc
	if burnRoundsLeft < 0:
		burnRoundsLeft = 0


func isBurning() -> bool:
	return burnRoundsLeft > 0

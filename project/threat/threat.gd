@icon("res://threat/tree.png")
class_name Threat
extends Sprite2D

const maxHealth := 10
var currentHealth := 10
var burnRoundsLeft := 0

func getHealth() -> int:
	return currentHealth


func getMaxHealth() -> int:
	return maxHealth


func incrementHealth(inc: int) -> void:
	currentHealth += inc


func incrementBurnRounds(inc: int) -> void:
	burnRoundsLeft += inc
	if burnRoundsLeft < 0:
		burnRoundsLeft = 0


func isBurning() -> bool:
	return burnRoundsLeft > 0

@icon("res://threat/tree.png")
class_name Threat
extends Sprite2D

signal onTweenFinished()

const maxHealth := 15
var currentHealth := 15
var burnRoundsLeft := 0

@export var mosses : Array[Sprite2D]

var currentTween : Tween

func _ready():
	for moss in mosses:
		moss.modulate = Color(1.0, 1.0, 1.0, 0.0)


func isTweenRunning() -> bool:
	return currentTween and currentTween.is_running()


func startStompAnim(mothPosition: Vector2) -> void:
	var startPosition := self.position
	var startRotation := self.rotation_degrees

	var rotate1 := 25.0
	var position1 := Vector2(1450, -500.0)

	currentTween = create_tween().set_trans(Tween.TRANS_BACK)
	currentTween.tween_property(self, "rotation_degrees", rotate1, 0.3)
	await currentTween.finished
	
	currentTween = create_tween().set_trans(Tween.TRANS_BACK)
	currentTween.tween_property(self, "position", position1, 0.3)
	await currentTween.finished

	await create_tween().tween_interval(.2).finished

	currentTween = create_tween().set_trans(Tween.TRANS_BACK)
	currentTween.tween_property(self, "position", mothPosition, 0.3)
	await currentTween.finished

	currentTween = create_tween().set_parallel().set_trans(Tween.TRANS_BACK)
	currentTween.tween_property(self, "position", startPosition, 0.3)
	currentTween.tween_property(self, "rotation_degrees", startRotation, 0.3)
	
	await currentTween.finished

	onTweenFinished.emit()


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


func startStuckAnim(isStuck: bool) -> void:
	var unpicked : Array[Sprite2D] = mosses.duplicate()
	var modulateFinal : Color
	if isStuck:
		modulateFinal = Color(1.0, 1.0, 1.0, 1.0)
	else:
		modulateFinal = Color(1.0, 1.0, 1.0, 0.0)

	for i in mosses.size():
		var moss:Sprite2D = unpicked.pick_random()
		unpicked.erase(moss)

		currentTween = create_tween().set_trans(Tween.TRANS_LINEAR)
		currentTween.tween_property(moss, "modulate", modulateFinal, 0.1)
		await currentTween.finished
	
	onTweenFinished.emit()
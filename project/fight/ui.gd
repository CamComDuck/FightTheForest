class_name FightUI
extends Control

signal onTweenFinished()

@onready var leftControl:TextureRect = %LeftControl as TextureRect
@onready var rightControl:TextureRect = %RightControl as TextureRect
@onready var upControl:TextureRect = %UpControl as TextureRect

@onready var leftControlLabel:Label = %LeftControlLabel as Label
@onready var rightControlLabel:Label = %RightControlLabel as Label
@onready var upControlLabel:Label = %UpControlLabel as Label

@onready var healthBarMoth:TextureProgressBar = %HealthBarMoth as TextureProgressBar
@onready var healthBarThreat:TextureProgressBar = %HealthBarThreat as TextureProgressBar

@onready var mothFireTracker:HBoxContainer = %MothFireTracker as HBoxContainer
@onready var threatFireTracker:HBoxContainer = %ThreatFireTracker as HBoxContainer

@onready var fireIcon:PackedScene = preload("res://icons/FireIcon.tscn")
@onready var titleScene:PackedScene = load("res://title/title.tscn")

@onready var labelVertical:Texture2D = preload("res://UI/labelVertical.png")
@onready var attackVertical:Texture2D = preload("res://UI/attackVertical.png")

@onready var endContainer:PanelContainer = %EndContainer as PanelContainer
@onready var endLabel:Label = %EndLabel as Label

const transition := Tween.TRANS_BACK
const moveAmount := 60.0
const normDuration := .5

var leftPositionStart : Vector2
var rightPositionStart : Vector2
var upPositionStart : Vector2

var currentTween : Tween

func _ready():
	endContainer.visible = false
	leftPositionStart = leftControl.position
	rightPositionStart = rightControl.position
	upPositionStart = upControl.position


func isTweenRunning() -> bool:
	return currentTween and currentTween.is_running()


func addFireMoth(inc: int) -> void:
	for i in inc:
		var newFire := fireIcon.instantiate() as TextureRect
		mothFireTracker.add_child(newFire)
	

func removeFireMoth(inc: int) -> void:
	var i := 0
	for child in mothFireTracker.get_children():
		mothFireTracker.remove_child(child)
		i += 1
		if i == inc:
			return


func addFireThreat(inc: int) -> void:
	for i in inc:
		var newFire := fireIcon.instantiate() as TextureRect
		threatFireTracker.add_child(newFire)
	
	
func removeFireThreat(inc: int) -> void:
	var i := 0
	for child in threatFireTracker.get_children():
		threatFireTracker.remove_child(child)
		i += 1
		if i == inc:
			return


func setHealthMoth(health: int, useAnim: bool = true) -> void:
	if useAnim:
		currentTween = create_tween().set_trans(Tween.TRANS_LINEAR)
		currentTween.tween_property(healthBarMoth, "value", health, .5)
		await currentTween.finished
	healthBarMoth.value = health
	if useAnim:
		onTweenFinished.emit()


func setHealthThreat(health: int, useAnim: bool = true) -> void:
	if useAnim:
		currentTween = create_tween().set_trans(Tween.TRANS_LINEAR)
		currentTween.tween_property(healthBarThreat, "value", health, .5)
		await currentTween.finished
	healthBarThreat.value = health
	if useAnim:
		onTweenFinished.emit()


func setMaxHealths(moth: int, threat: int) -> void:
	healthBarMoth.max_value = moth
	healthBarThreat.max_value = threat


func getVerticalText(hText: String) -> String:
	var vText := ""
	for letter in hText:
		vText = vText + letter + "\n"
	
	return vText.left(vText.length() - 1)


func setControlLabels(leftText: String, rightText: String, upText: String, isAttack: bool) -> void:
	leftControlLabel.text = getVerticalText(leftText).to_upper()
	rightControlLabel.text = getVerticalText(rightText).to_upper()
	upControlLabel.text = upText.to_upper()

	if isAttack:
		leftControl.texture = attackVertical
		rightControl.texture = attackVertical
		
	else:
		leftControl.texture = labelVertical
		rightControl.texture = labelVertical


func transitionInLabels() -> void:
	currentTween = create_tween().set_parallel().set_trans(transition)

	var leftFinalPosition := Vector2(
		leftPositionStart.x + moveAmount + leftControl.size.x,
		leftPositionStart.y)
	
	var rightFinalPosition := Vector2(
		rightPositionStart.x - moveAmount - rightControl.size.x,
		rightPositionStart.y)

	var upFinalPosition := Vector2(
		upPositionStart.x,
		upPositionStart.y + moveAmount + upControl.size.y)

	currentTween.tween_property(leftControl, "global_position", leftFinalPosition, normDuration)
	currentTween.tween_property(rightControl, "global_position", rightFinalPosition, normDuration)
	currentTween.tween_property(upControl, "global_position", upFinalPosition, normDuration)

	await currentTween.finished
	onTweenFinished.emit()


func transitionOutLabels(isStart: bool = false) -> void:
	var duration : float
	if isStart:
		duration = 0
	else:
		duration = normDuration
	
	currentTween = create_tween().set_parallel().set_trans(transition)

	var leftFinalPosition := Vector2(
		leftPositionStart.x - moveAmount - leftControl.size.x,
		leftPositionStart.y)
	
	var rightFinalPosition := Vector2(
		rightPositionStart.x + moveAmount + rightControl.size.x,
		rightPositionStart.y)

	var upFinalPosition := Vector2(
		upPositionStart.x,
		upPositionStart.y - moveAmount - upControl.size.y)

	currentTween.tween_property(leftControl, "global_position", leftFinalPosition, duration)
	currentTween.tween_property(rightControl, "global_position", rightFinalPosition, duration)
	currentTween.tween_property(upControl, "global_position", upFinalPosition, duration)

	await currentTween.finished
	onTweenFinished.emit()


func onGameEnd(isWin: bool) -> void:
	if isWin:
		endLabel.text = "You Win!"
	else:
		endLabel.text = "You Lose!"

	endContainer.visible = true


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(titleScene)

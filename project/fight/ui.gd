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

const transition := Tween.TRANS_BACK
const moveAmount := 60.0
const normDuration := .5

var leftPositionStart : Vector2
var rightPositionStart : Vector2
var upPositionStart : Vector2

var tweenControls : Tween

func _ready():
	leftPositionStart = leftControl.position
	rightPositionStart = rightControl.position
	upPositionStart = upControl.position


func isTweenRunning() -> bool:
	return tweenControls and tweenControls.is_running()
	

func setHealthMoth(health: int) -> void:
	healthBarMoth.value = health


func setHealthThreat(health: int) -> void:
	healthBarThreat.value = health


func setMaxHealths(moth: int, threat: int) -> void:
	healthBarMoth.max_value = moth
	healthBarThreat.max_value = threat


func getVerticalText(hText: String) -> String:
	var vText := ""
	for letter in hText:
		vText = vText + letter + "\n"
	
	return vText.left(vText.length() - 1)


func setControlLabels(leftText: String, rightText: String, upText: String) -> void:
	leftControlLabel.text = getVerticalText(leftText).to_upper()
	rightControlLabel.text = getVerticalText(rightText).to_upper()
	upControlLabel.text = upText.to_upper()


func transitionInLabels() -> void:
	tweenControls = create_tween().set_parallel().set_trans(transition)

	var leftFinalPosition := Vector2(
		leftPositionStart.x + moveAmount + leftControl.size.x,
		leftPositionStart.y)
	
	var rightFinalPosition := Vector2(
		rightPositionStart.x - moveAmount - rightControl.size.x,
		rightPositionStart.y)

	var upFinalPosition := Vector2(
		upPositionStart.x,
		upPositionStart.y + moveAmount + upControl.size.y)

	tweenControls.tween_property(leftControl, "global_position", leftFinalPosition, normDuration)
	tweenControls.tween_property(rightControl, "global_position", rightFinalPosition, normDuration)
	tweenControls.tween_property(upControl, "global_position", upFinalPosition, normDuration)

	await tweenControls.finished
	onTweenFinished.emit()


func transitionOutLabels(isStart: bool = false) -> void:
	var duration : float
	if isStart:
		duration = 0
	else:
		duration = normDuration
	
	tweenControls = create_tween().set_parallel().set_trans(transition)

	var leftFinalPosition := Vector2(
		leftPositionStart.x - moveAmount - leftControl.size.x,
		leftPositionStart.y)
	
	var rightFinalPosition := Vector2(
		rightPositionStart.x + moveAmount + rightControl.size.x,
		rightPositionStart.y)

	var upFinalPosition := Vector2(
		upPositionStart.x,
		upPositionStart.y - moveAmount - upControl.size.y)

	tweenControls.tween_property(leftControl, "global_position", leftFinalPosition, duration)
	tweenControls.tween_property(rightControl, "global_position", rightFinalPosition, duration)
	tweenControls.tween_property(upControl, "global_position", upFinalPosition, duration)

	await tweenControls.finished
	onTweenFinished.emit()
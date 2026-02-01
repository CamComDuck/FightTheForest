class_name Title
extends Node2D

@onready var fightScene : PackedScene = preload("res://fight/fight.tscn")
@onready var faceTrackingCheckBox : CheckBox = %FaceTrackingCheckBox as CheckBox
@onready var delaySlider : HSlider = %DelaySlider as HSlider

@onready var inputContainer : PanelContainer = %InputContainer as PanelContainer
@onready var storyContainer : PanelContainer = %StoryContainer as PanelContainer
@onready var creditsContainer : PanelContainer = %CreditsContainer as PanelContainer
@onready var secsLabel : Label = %SecsLabel as Label

@onready var click : AudioStreamPlayer = %Click as AudioStreamPlayer

var currentPanel = null

func _ready():
	inputContainer.visible = false
	storyContainer.visible = false
	creditsContainer.visible = false
	faceTrackingCheckBox.button_pressed = !GlobalInfo.usingKeyboard
	delaySlider.value = GlobalInfo.faceDelaySeconds
	secsLabel.text = str(GlobalInfo.faceDelaySeconds) + " Seconds"


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(fightScene)


func _on_input_button_pressed() -> void:
	click.play()
	currentPanel = inputContainer
	transitionIn(currentPanel)


func transitionIn(obj) -> void:
	obj.modulate = Color(1, 1, 1, 0)
	obj.visible = true

	var currentTween := create_tween().set_trans(Tween.TRANS_LINEAR)
	currentTween.tween_property(obj, "modulate", Color(1, 1, 1, 1), .2)

	await currentTween.finished
	obj.visible = true


func transitionOut(obj) -> void:
	obj.modulate = Color(1, 1, 1, 1)
	obj.visible = true

	var currentTween := create_tween().set_trans(Tween.TRANS_LINEAR)
	currentTween.tween_property(obj, "modulate", Color(1, 1, 1, 0), .2)

	await currentTween.finished
	obj.visible = false


func _on_story_button_pressed() -> void:
	click.play()
	currentPanel = storyContainer
	transitionIn(currentPanel)


func _on_credits_button_pressed() -> void:
	click.play()
	currentPanel = creditsContainer
	transitionIn(currentPanel)


func _on_back_button_pressed() -> void:
	click.play()
	transitionOut(currentPanel)
	currentPanel = null


func _on_delay_slider_value_changed(value: float) -> void:
	click.play()
	secsLabel.text = str(value) + " Seconds"
	GlobalInfo.faceDelaySeconds = value


func _on_face_tracking_check_toggled(toggled_on: bool) -> void:
	click.play()
	GlobalInfo.usingKeyboard = !toggled_on

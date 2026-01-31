class_name Fight
extends Node2D

@onready var moth: Moth = %Moth as Moth
@onready var threat: Threat = %Threat as Threat
@onready var keybinds: Keybinds = %Keybinds as Keybinds
@onready var stateChart:StateChart = %StateChart as StateChart
@onready var fightUI:FightUI = %FightUI as FightUI

@onready var attackFireMothParticles:CPUParticles2D = %AttackFireMoth as CPUParticles2D
@onready var attackFireThreatParticles:CPUParticles2D = %AttackFireThreat as CPUParticles2D

@onready var mothBurnParticles:CPUParticles2D = %MothBurning as CPUParticles2D
@onready var threatBurnParticles:CPUParticles2D = %ThreatBurning as CPUParticles2D

const onMothChoseEat := "OnMothChoseEat"
const onMothChoseMask := "OnMothChoseMask"
const onMothChoseAttack := "OnMothChoseAttack"

const onMothChoseSpin := "OnMothChoseSpin"
const onMothChoseSpit := "OnMothChoseSpit"
const onMothChoseWrap := "OnMothChoseWrap"

const onThreatChoseEat := "OnThreatChoseEat"
const onThreatChoseFire := "OnThreatChoseFire"

const onMothTurnEnded := "OnMothTurnEnded"
const onThreatTurnEnded := "OnThreatTurnEnded"

var isThreatTurnSkipped := false
var isMothTurnSkipped := false

var isUsingKeyboard := true

func _ready() -> void:
	randomize()
	fightUI.setMaxHealths(moth.getMaxHealth(), threat.getMaxHealth())
	fightUI.setHealthMoth(moth.getHealth())
	fightUI.setHealthThreat(threat.getHealth())
	

func onActionChosen(direction: Vector2) -> void:
	if direction != Vector2.ZERO and direction != Vector2(0, -1):
		# Player selected a choice
		if not fightUI.isTweenRunning():
			fightUI.transitionOutLabels()
			await fightUI.onTweenFinished
		else:
			await fightUI.onTweenFinished

		if direction.x < 0 and direction.y == 0: # left -> eat
			stateChart.send_event(onMothChoseEat)

		elif direction.x > 0 and direction.y == 0: # right -> mask
			stateChart.send_event(onMothChoseMask)

		elif direction.x == 0 and direction.y > 0: # up -> attack
			stateChart.send_event(onMothChoseAttack)


func onAttackChosen(direction: Vector2) -> void:
	if direction != Vector2.ZERO and direction != Vector2(0, -1):
		# Player selected a choice
		if not fightUI.isTweenRunning():
			fightUI.transitionOutLabels()
			await fightUI.onTweenFinished
		else:
			await fightUI.onTweenFinished

		if direction.x < 0 and direction.y == 0: # left -> spin
			stateChart.send_event(onMothChoseSpin)

		elif direction.x > 0 and direction.y == 0: # right -> spit
			stateChart.send_event(onMothChoseSpit)

		elif direction.x == 0 and direction.y > 0: # up -> wrap
			stateChart.send_event(onMothChoseWrap)


func incrementThreatHealth(inc: int) -> void:
	threat.incrementHealth(inc)
	fightUI.setHealthThreat(threat.getHealth())


func incrementMothHealth(inc: int) -> void:
	moth.incrementHealth(inc)
	fightUI.setHealthMoth(moth.getHealth())


func _on_moth_turn_state_entered() -> void:
	if moth.isBurning():
		mothBurnParticles.emitting = true
		incrementMothHealth(-1)

	await mothBurnParticles.finished

	moth.incrementBurnRounds(-1)

	moth.setIsMasked(false)

	if isMothTurnSkipped: # no action
		print("moth turn skipped!")
		isMothTurnSkipped = false
		stateChart.send_event(onMothTurnEnded)

	else: # await player choosing action
		pass


func _on_choosing_action_state_entered() -> void:
	fightUI.setControlLabels("Eat", "Mask", "Attack")

	if not fightUI.isTweenRunning():
		fightUI.transitionInLabels()
		await fightUI.onTweenFinished
	else:
		await fightUI.onTweenFinished

	if isUsingKeyboard:
		if not keybinds.is_connected("onDirectionChosen", onActionChosen):
			keybinds.connect("onDirectionChosen", onActionChosen)


func _on_choosing_action_state_exited() -> void:
	if isUsingKeyboard:
		if keybinds.is_connected("onDirectionChosen", onActionChosen):
			keybinds.disconnect("onDirectionChosen", onActionChosen)


func _on_eat_state_entered() -> void:
	print("eat!")
	moth.incrementHealth(2)

	stateChart.send_event(onMothTurnEnded)


func _on_mask_state_entered() -> void:
	moth.setIsMasked(true)

	stateChart.send_event(onMothTurnEnded)


func _on_choosing_attack_state_entered() -> void:
	fightUI.setControlLabels("Spin", "Spit", "Wrap")

	if not fightUI.isTweenRunning():
		fightUI.transitionInLabels()
		await fightUI.onTweenFinished
	else:
		await fightUI.onTweenFinished

	if isUsingKeyboard:
		keybinds.connect("onDirectionChosen", onAttackChosen)


func _on_choosing_attack_state_exited() -> void:
	if isUsingKeyboard:
		keybinds.disconnect("onDirectionChosen", onAttackChosen)


func _on_spin_state_entered() -> void: # one hit
	incrementThreatHealth(-3)

	stateChart.send_event(onMothTurnEnded)


func _on_spit_state_entered() -> void: # burn
	threat.incrementBurnRounds(2)

	attackFireMothParticles.emitting = true
	await attackFireMothParticles.finished

	stateChart.send_event(onMothTurnEnded)


func _on_wrap_state_entered() -> void: # tangle
	isThreatTurnSkipped = true
	incrementThreatHealth(-1)

	stateChart.send_event(onMothTurnEnded)


func _on_threat_turn_state_entered() -> void:
	if threat.isBurning():
		incrementThreatHealth(-1)
	threat.incrementBurnRounds(-1)

	if isThreatTurnSkipped: # no action
		print("threat turn skipped!")
		isThreatTurnSkipped = false
		
		stateChart.send_event(onThreatTurnEnded)


func _on_threat_choosing_attack_state_entered() -> void:
	if threat.isBurning():
		threatBurnParticles.emitting = true
		await threatBurnParticles.finished

	var randomNum = randi_range(1, 10) # 1 to 10 inclusive

	if randomNum <= 6: # chose eat
		stateChart.send_event(onThreatChoseEat)
	
	else: # chose fire
		stateChart.send_event(onThreatChoseFire)


func _on_threat_eat_state_entered() -> void:
	print("threat eats moth!")
	incrementMothHealth(-2)
	stateChart.send_event(onThreatTurnEnded)


func _on_threat_fire_state_entered() -> void:
	moth.incrementBurnRounds(2)

	attackFireThreatParticles.emitting = true
	await attackFireThreatParticles.finished

	stateChart.send_event(onThreatTurnEnded)


func checkGameEnded() -> void:
	if moth.getHealth() <= 0: # lose fight
		print("you lose!")
		get_tree().quit()

	if threat.getHealth() <= 0: # win fight
		print("you win!")
		get_tree().quit()


func _on_moth_turn_state_exited() -> void:
	checkGameEnded()


func _on_threat_turn_state_exited() -> void:
	checkGameEnded()

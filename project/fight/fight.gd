class_name Fight
extends Node2D

@onready var keybinds: Keybinds = %Keybinds as Keybinds
@onready var faceTracking: FaceTracking = %FaceTracking as FaceTracking

@onready var moth: Moth = %Moth as Moth
@onready var threat: Threat = %Threat as Threat
@onready var stateChart:StateChart = %StateChart as StateChart
@onready var fightUI:FightUI = %FightUI as FightUI
@onready var sounds:Sounds = %Sounds as Sounds

@onready var attackFireMothParticles:CPUParticles2D = %AttackFireMoth as CPUParticles2D
@onready var attackFireThreatParticles:CPUParticles2D = %AttackFireThreat as CPUParticles2D

@onready var mothBurnParticles:CPUParticles2D = %MothBurning as CPUParticles2D
@onready var threatBurnParticles:CPUParticles2D = %ThreatBurning as CPUParticles2D

@onready var missOnMothParticles:CPUParticles2D = %MissOnMoth as CPUParticles2D
@onready var missOnThreatParticles:CPUParticles2D = %MissOnThreat as CPUParticles2D

const onMothChoseEat := "OnMothChoseEat"
const onMothChoseMask := "OnMothChoseMask"
const onMothChoseAttack := "OnMothChoseAttack"

const onMothChoseSpin := "OnMothChoseSpin"
const onMothChoseSpit := "OnMothChoseSpit"
const onMothChoseWrap := "OnMothChoseWrap"

const onThreatChoseStomp := "OnThreatChoseStomp"
const onThreatChoseFire := "OnThreatChoseFire"

const onMothTurnEnded := "OnMothTurnEnded"
const onThreatTurnEnded := "OnThreatTurnEnded"

var isThreatTurnSkipped := false
var isMothTurnSkipped := false

const defaultMissChance := .3

var spinMissChance := .3
var spitMissChance := .3
var wrapMissChance := .3

var stompMissChance := .3
var fireMissChance := .3

func _ready() -> void:
	randomize()
	fightUI.setMaxHealths(moth.getMaxHealth(), threat.getMaxHealth())
	fightUI.setHealthMoth(moth.getHealth(), false)
	fightUI.setHealthThreat(threat.getHealth(), false)
	

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

	# else:
	# 	print(str(direction) + " isnt a valid action direction")


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
	
	# else:
	# 	print(str(direction) + " isnt a valid attack direction")


func incrementThreatHealth(inc: int) -> void:
	threat.incrementHealth(inc)
	fightUI.setHealthThreat(threat.getHealth())


func incrementMothHealth(inc: int) -> void:
	moth.incrementHealth(inc)
	fightUI.setHealthMoth(moth.getHealth())


func _on_choosing_action_state_entered() -> void:
	fightUI.setControlLabels("Eat", "Mask", "Attack", false)

	if moth.isBurning():
		sounds.PlaySound("Burning")
		mothBurnParticles.emitting = true
		await mothBurnParticles.finished

		incrementMothHealth(-1)
		await fightUI.onTweenFinished

		checkGameEnded()

	moth.incrementBurnRounds(-1)
	fightUI.removeFireMoth(1)

	if moth.isMasked:
		moth.setIsMasked(false)
		await moth.onTweenFinished

	if not fightUI.isTweenRunning():
		fightUI.transitionInLabels()
		await fightUI.onTweenFinished
	else:
		await fightUI.onTweenFinished

	if GlobalInfo.usingKeyboard:
		if not keybinds.is_connected("onDirectionChosen", onActionChosen):
			keybinds.connect("onDirectionChosen", onActionChosen)
	
	else:
		if not faceTracking.is_connected("onDirectionChosen", onActionChosen):
			faceTracking.connect("onDirectionChosen", onActionChosen)
			faceTracking.isListening = true


func _on_choosing_action_state_exited() -> void:
	if GlobalInfo.usingKeyboard:
		if keybinds.is_connected("onDirectionChosen", onActionChosen):
			keybinds.disconnect("onDirectionChosen", onActionChosen)

	else:
		if faceTracking.is_connected("onDirectionChosen", onActionChosen):
			faceTracking.disconnect("onDirectionChosen", onActionChosen)
			faceTracking.isListening = false


func _on_eat_state_entered() -> void:
	sounds.PlaySound("Eat")
	moth.startEatAnim()
	await moth.onTweenFinished

	
	incrementMothHealth(1)
	await fightUI.onTweenFinished

	stateChart.send_event(onMothTurnEnded)


func _on_mask_state_entered() -> void:
	sounds.PlaySound("Mask")
	moth.setIsMasked(true)
	await moth.onTweenFinished

	stateChart.send_event(onMothTurnEnded)


func _on_choosing_attack_state_entered() -> void:
	fightUI.setControlLabels("Spin", "Spit", "Wrap", true)

	if not fightUI.isTweenRunning():
		fightUI.transitionInLabels()
		await fightUI.onTweenFinished
	else:
		await fightUI.onTweenFinished

	if GlobalInfo.usingKeyboard:
		keybinds.connect("onDirectionChosen", onAttackChosen)
	
	else:
		faceTracking.connect("onDirectionChosen", onAttackChosen)
		faceTracking.isListening = true


func _on_choosing_attack_state_exited() -> void:
	if GlobalInfo.usingKeyboard:
		keybinds.disconnect("onDirectionChosen", onAttackChosen)

	else:
		faceTracking.disconnect("onDirectionChosen", onAttackChosen)
		faceTracking.isListening = false


func _on_spin_state_entered() -> void: # one hit
	sounds.PlaySound("Spin")
	moth.startSpinAnim()
	await moth.onTweenFinished

	var randomNum = randf_range(0, 1) # 0 to 1 inclusive
	if randomNum <= spinMissChance: # missed
		spinMissChance -= .2
		if spinMissChance < defaultMissChance:
			spinMissChance = defaultMissChance

		sounds.PlaySound("Miss")
		missOnThreatParticles.emitting = true
		await missOnThreatParticles.finished

	else: # hit
		spinMissChance += .1
		if spinMissChance > 1:
			spinMissChance = 1

		incrementThreatHealth(-3)
		await fightUI.onTweenFinished

	stateChart.send_event(onMothTurnEnded)


func _on_spit_state_entered() -> void: # burn
	sounds.PlaySound("Spit")
	attackFireMothParticles.emitting = true
	await attackFireMothParticles.finished

	var randomNum = randf_range(0, 1) # 0 to 1 inclusive
	if randomNum <= spitMissChance: # missed
		sounds.PlaySound("Miss")
		spitMissChance -= .2
		if spitMissChance < defaultMissChance:
			spitMissChance = defaultMissChance

		missOnThreatParticles.emitting = true
		await missOnThreatParticles.finished

	else: # hit
		spitMissChance += .1
		if spitMissChance > 1:
			spitMissChance = 1

		threat.incrementBurnRounds(2)
		fightUI.addFireThreat(2)

	stateChart.send_event(onMothTurnEnded)


func _on_wrap_state_entered() -> void: # tangle
	sounds.PlaySound("Wrap")
	moth.startWrapAnim(threat.position)
	await moth.onTweenFinished

	var randomNum = randf_range(0, 1) # 0 to 1 inclusive
	if randomNum <= wrapMissChance: # missed
		sounds.PlaySound("Miss")
		wrapMissChance -= .2
		if wrapMissChance < defaultMissChance:
			wrapMissChance = defaultMissChance

		missOnThreatParticles.emitting = true
		await missOnThreatParticles.finished

	else: # hit
		wrapMissChance += .1
		if wrapMissChance > 1:
			wrapMissChance = 1

		isThreatTurnSkipped = true

		threat.startStuckAnim(true)
		await threat.onTweenFinished

		incrementThreatHealth(-1)
		await fightUI.onTweenFinished

	stateChart.send_event(onMothTurnEnded)


func _on_threat_choosing_attack_state_entered() -> void:
	if threat.isBurning():
		sounds.PlaySound("Burning")
		threat.incrementBurnRounds(-1)
		fightUI.removeFireThreat(1)

		threatBurnParticles.emitting = true
		await threatBurnParticles.finished

		incrementThreatHealth(-2)
		await fightUI.onTweenFinished

		checkGameEnded()


	if isThreatTurnSkipped: # no action
		isThreatTurnSkipped = false

		threat.startStuckAnim(false)
		await threat.onTweenFinished
		
		stateChart.send_event(onThreatTurnEnded)
	
	else:
		var randomNum = randi_range(1, 10) # 1 to 10 inclusive

		if randomNum <= 6: # chose stomp
			stateChart.send_event(onThreatChoseStomp)
		
		else: # chose fire
			stateChart.send_event(onThreatChoseFire)


func _on_threat_stomp_state_entered() -> void:
	sounds.PlaySound("Stomp")
	threat.startStompAnim(moth.position)
	await threat.onReadyForSound
	sounds.PlaySound("Landed")

	await threat.onTweenFinished

	var randomNum = randf_range(0, 1) # 0 to 1 inclusive
	if randomNum <= stompMissChance: # missed
		sounds.PlaySound("Miss")
		stompMissChance -= .2
		if stompMissChance < defaultMissChance:
			stompMissChance = defaultMissChance

		missOnMothParticles.emitting = true
		await missOnMothParticles.finished

	else: # hit
		stompMissChance += .1
		if stompMissChance > 1:
			stompMissChance = 1
		incrementMothHealth(-2)
		await fightUI.onTweenFinished

	stateChart.send_event(onThreatTurnEnded)


func _on_threat_fire_state_entered() -> void:
	sounds.PlaySound("FireAttack")
	attackFireThreatParticles.emitting = true
	await attackFireThreatParticles.finished

	var randomNum = randf_range(0, 1) # 0 to 1 inclusive
	if randomNum <= fireMissChance: # missed
		sounds.PlaySound("Miss")
		fireMissChance -= .2
		if fireMissChance < defaultMissChance:
			fireMissChance = defaultMissChance
		missOnMothParticles.emitting = true
		await missOnMothParticles.finished

	else: # hit
		fireMissChance += .1
		if fireMissChance > 1:
			fireMissChance = 1
		moth.incrementBurnRounds(2)
		fightUI.addFireMoth(2)

	

	stateChart.send_event(onThreatTurnEnded)


func checkGameEnded() -> void:
	if moth.getHealth() <= 0: # lose fight
		sounds.PlaySound("Lose")
		print("you lose!")
		get_tree().quit()

	if threat.getHealth() <= 0: # win fight
		sounds.PlaySound("Win")
		print("you win!")
		get_tree().quit()


func _on_moth_turn_state_exited() -> void:
	checkGameEnded()


func _on_threat_turn_state_exited() -> void:
	checkGameEnded()

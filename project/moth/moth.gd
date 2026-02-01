@icon("res://moth/moth.png")
class_name Moth
extends Node2D

signal onTweenFinished()

@onready var mothSprite:Sprite2D = %Moth as Sprite2D
@onready var foodSprite:Sprite2D = %Food as Sprite2D

const maxHealth := 10
var currentHealth := 10
var isMasked := false
var burnRoundsLeft := 0

var currentTween : Tween


func isTweenRunning() -> bool:
    return currentTween and currentTween.is_running()


func startEatAnim() -> void:
    var start_rotation := mothSprite.rotation_degrees
    var spin_final_position := 45.0

    foodSprite.visible = true

    for i in 2:
        currentTween = create_tween().set_trans(Tween.TRANS_SINE)
        currentTween.tween_property(mothSprite, "rotation_degrees", spin_final_position, 0.2)
        await currentTween.finished

        currentTween = create_tween().set_trans(Tween.TRANS_SINE)
        currentTween.tween_property(mothSprite, "rotation_degrees", start_rotation, 0.2)
        await currentTween.finished

    foodSprite.visible = false

    onTweenFinished.emit()



func startSpinAnim() -> void:
    currentTween = create_tween().set_trans(Tween.TRANS_BACK)
    var startRotation := mothSprite.rotation
    var spinFinalPosition := 360.0
	
    currentTween.tween_property(mothSprite, "rotation_degrees", spinFinalPosition, 1.0)

    await currentTween.finished
    mothSprite.rotation = startRotation

    onTweenFinished.emit()


func startWrapAnim(threatPosition: Vector2) -> void:
    currentTween = create_tween().set_trans(Tween.TRANS_BACK)
    var startRotation := mothSprite.rotation
    var startPosition := mothSprite.global_position
    var spinFinalPosition := 360.0
    var startZ := self.z_index

    self.z_index = 5
	
    currentTween.tween_property(mothSprite, "global_position", threatPosition, 1.0)
    await currentTween.finished

    currentTween = create_tween().set_trans(Tween.TRANS_BACK)
    currentTween.tween_property(mothSprite, "rotation_degrees", spinFinalPosition, 1.0)
    await currentTween.finished
    mothSprite.rotation = startRotation
    mothSprite.flip_h = not mothSprite.flip_h

    currentTween = create_tween().set_trans(Tween.TRANS_BACK)
    currentTween.tween_property(mothSprite, "global_position", startPosition, 1.0)
    await currentTween.finished

    mothSprite.flip_h = not mothSprite.flip_h
    self.z_index = startZ

    onTweenFinished.emit()


func setIsMasked(newMasked: bool) -> void:
    isMasked = newMasked
    currentTween = create_tween().set_trans(Tween.TRANS_LINEAR)
    var modulateFinal : Color

    if isMasked:
        modulateFinal = Color(1.0, 1.0, 1.0, 0.25)
    else:
        modulateFinal = Color(1.0, 1.0, 1.0, 1.0)
        
    currentTween.tween_property(mothSprite, "modulate", modulateFinal, 1.0)
    await currentTween.finished
    onTweenFinished.emit()


func getHealth() -> int:
    return currentHealth


func getMaxHealth() -> int:
    return maxHealth


func incrementHealth(inc: int) -> void:
    if isMasked:
        return

    currentHealth += inc
    
    if currentHealth > maxHealth:
        currentHealth = maxHealth
        

func incrementBurnRounds(inc: int) -> void:
    # print(inc)
    # print(isMasked)
    if isMasked and inc > 0:
        return

    burnRoundsLeft += inc
    if burnRoundsLeft < 0:
        burnRoundsLeft = 0

    # print("Burnrounds: " + str(burnRoundsLeft))


func isBurning() -> bool:
    # print(str(burnRoundsLeft) + " - " + str(isMasked))
    return burnRoundsLeft > 0 and not isMasked

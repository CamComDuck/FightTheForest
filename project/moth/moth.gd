@icon("res://moth/moth.png")
class_name Moth
extends Sprite2D

signal onTweenFinished()

const maxHealth := 10
var currentHealth := 10
var isMasked := false
var burnRoundsLeft := 0

var currentTween : Tween


func isTweenRunning() -> bool:
    return currentTween and currentTween.is_running()


func startSpinAnim() -> void:
    currentTween = create_tween().set_trans(Tween.TRANS_BACK)
    var startRotation := self.rotation
    var spinFinalPosition := 360.0
	
    currentTween.tween_property(self, "rotation_degrees", spinFinalPosition, 1.0)

    await currentTween.finished
    self.rotation = startRotation

    onTweenFinished.emit()


func startWrapAnim(threatPosition: Vector2) -> void:
    currentTween = create_tween().set_trans(Tween.TRANS_BACK)
    var startRotation := self.rotation
    var startPosition := self.position
    var spinFinalPosition := 360.0
	
    currentTween.tween_property(self, "global_position", threatPosition, 1.0)
    await currentTween.finished

    currentTween = create_tween().set_trans(Tween.TRANS_BACK)
    currentTween.tween_property(self, "rotation_degrees", spinFinalPosition, 1.0)
    await currentTween.finished
    self.rotation = startRotation
    self.flip_h = not self.flip_h

    currentTween = create_tween().set_trans(Tween.TRANS_BACK)
    currentTween.tween_property(self, "global_position", startPosition, 1.0)
    await currentTween.finished
    self.flip_h = not self.flip_h

    onTweenFinished.emit()


func setIsMasked(newMasked: bool) -> void:
    isMasked = newMasked
    currentTween = create_tween().set_trans(Tween.TRANS_LINEAR)
    var modulateFinal : Color

    if isMasked:
        modulateFinal = Color(1.0, 1.0, 1.0, 0.25)
    else:
        modulateFinal = Color(1.0, 1.0, 1.0, 1.0)
        
    currentTween.tween_property(self, "modulate", modulateFinal, 1.0)
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
    if isMasked:
        return

    burnRoundsLeft += inc
    if burnRoundsLeft < 0:
        burnRoundsLeft = 0


func isBurning() -> bool:
    return burnRoundsLeft > 0 and not isMasked

@icon("res://moth/moth.png")
class_name Moth
extends Sprite2D

const maxHealth := 10
var currentHealth := 10
var isMasked := false
var burnRoundsLeft := 0

func setIsMasked(newMasked: bool) -> void:
    isMasked = newMasked


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
    burnRoundsLeft += inc
    if burnRoundsLeft < 0:
        burnRoundsLeft = 0


func isBurning() -> bool:
    return burnRoundsLeft > 0

@icon("res://moth/moth.png")
class_name Moth
extends Sprite2D

signal onMothDied

var maxHealth := 10
var currentHealth := 10

var isMasked := false

func setIsMasked(newMasked: bool) -> void:
    isMasked = newMasked


func getHealth() -> int:
    return currentHealth


func incrementHealth(inc: int) -> void:
    if isMasked:
        return
        
    currentHealth += inc
    if currentHealth <= 0:
        # die
        print("moth died")
        onMothDied.emit()
    
    if currentHealth > maxHealth:
        currentHealth = maxHealth
        


@icon("res://moth/moth.png")
class_name Moth
extends Sprite2D

signal OnMothDied

var maxHealth := 10
var currentHealth := 10

func GetHealth() -> int:
    return currentHealth


func IncrementHealth(inc: int) -> void:
    currentHealth += inc
    if currentHealth <= 0:
        # die
        print("moth died")
        OnMothDied.emit()
        


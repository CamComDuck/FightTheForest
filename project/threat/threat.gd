@icon("res://threat/tree.png")
class_name Threat
extends Sprite2D

signal OnThreatDied

var maxHealth := 10
var currentHealth := 10

func GetHealth() -> int:
    return currentHealth


func IncrementHealth(inc: int) -> void:
    currentHealth += inc
    if currentHealth <= 0:
        # die
        print("threat died")
        OnThreatDied.emit()
        
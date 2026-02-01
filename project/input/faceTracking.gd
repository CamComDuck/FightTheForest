class_name FaceTracking
extends Node2D

# uses openTrack and AITrack

signal onDirectionChosen(direction: Vector2)

var IP_SERVER := "127.0.0.1"
var PORT_CLIENT := 3000

var socketUDP : PacketPeerUDP = PacketPeerUDP.new()

@onready var particlesLeft:CPUParticles2D = %ParticlesLeft as CPUParticles2D
@onready var particlesRight:CPUParticles2D = %ParticlesRight as CPUParticles2D
@onready var particlesUp:CPUParticles2D = %ParticlesUp as CPUParticles2D

@onready var timer:Timer = %Timer as Timer

var direction: Vector2 = Vector2.ZERO

var isListening := false

func _ready() -> void:
	start_client()
	

func _physics_process(_delta: float) -> void:
	while socketUDP.get_available_packet_count() > 0:
		var array_bytes : PackedByteArray = socketUDP.get_packet()
		var array_decoded : Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		for i in range(6):
			array_decoded[i] = array_bytes.decode_double(i * 8) # 8 bits in a byte
		var packetInfo : Dictionary[String, float] = {
			"x": array_decoded[0],
			"y": array_decoded[1],
			"z": array_decoded[2],
			"yaw": array_decoded[3],
			"pitch": array_decoded[4],
			"roll": array_decoded[5]
		}
		
		var directionPacket = Vector2(packetInfo["x"], packetInfo["pitch"])
		
		var SENSITIVITY := 10.0

		if isListening:
			if directionPacket.x > SENSITIVITY and direction != Vector2(-1, 0): # left
				stopAllParticles()
				particlesLeft.emitting = true
				direction = Vector2(-1, 0)
				timer.start(GlobalInfo.faceDelaySeconds)

			elif directionPacket.x < -SENSITIVITY and direction != Vector2(1, 0): # right
				stopAllParticles()
				particlesRight.emitting = true
				direction = Vector2(1, 0)
				timer.start(GlobalInfo.faceDelaySeconds)
				
			elif directionPacket.y > SENSITIVITY and direction != Vector2(0, -1): # down
				pass

			elif directionPacket.y < -SENSITIVITY and direction != Vector2(0, 1): # up
				stopAllParticles()
				particlesUp.emitting = true
				direction = Vector2(0, 1)
				timer.start(GlobalInfo.faceDelaySeconds)

			if directionPacket.x < SENSITIVITY and directionPacket.x > -SENSITIVITY:
				if directionPacket.y < SENSITIVITY and directionPacket.y > -SENSITIVITY:
					stopAllParticles()
					timer.stop()
					direction = Vector2.ZERO
		
		else:
			direction = Vector2.ZERO
			timer.stop()
			stopAllParticles()


func stopAllParticles() -> void:
	particlesLeft.emitting = false
	particlesRight.emitting = false
	particlesUp.emitting = false


func start_client():
	var BUFFER_SIZE := 256
	var message := ""
	if (socketUDP.bind(PORT_CLIENT, IP_SERVER, BUFFER_SIZE) != OK):
		message = "Error connecting to port: " + str(PORT_CLIENT) + ", server: " + IP_SERVER
	else:
		message = "Connected to port: " + str(PORT_CLIENT) + ", server: " + IP_SERVER
		
	print(message)


func _exit_tree() -> void:
	socketUDP.close()


func _on_timer_timeout() -> void:
	timer.stop()
	stopAllParticles()

	onDirectionChosen.emit(direction)
	direction = Vector2.ZERO

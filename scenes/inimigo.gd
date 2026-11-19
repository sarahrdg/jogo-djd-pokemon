extends CharacterBody2D

@export var velocidade := 40.0        # mais lento que o jogador
@export var cai_das_bordas := false   # marque no Inspetor se quiser que um inimigo caia

var morto := false
var direcao := -1   # -1 = esquerda, 1 = direita
var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = $AnimatedSprite2D
@onready var detector = $DetectorBorda

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravidade * delta

	velocity.x = direcao * velocidade
	move_and_slide()

	# vira se bater numa parede
	if is_on_wall():
		virar()
	# ou se o raio não encontrar chão (chegou na beirada)
	elif is_on_floor() and not cai_das_bordas and not detector.is_colliding():
		virar()

	if direcao < 0:
		anim.play("andando_esquerda")
	else:
		anim.play("andando_direita")

func virar():
	direcao *= -1
	# leva o raio para a frente do novo lado
	detector.position.x = abs(detector.position.x) * direcao


# alguém entrou na CABEÇA
func _on_hurtbox_body_entered(body):
	#print("entrou na cabeça: ", body.name, " | grupo player: ", body.is_in_group("player"), " | vel y: ", body.velocity.y)
	if morto:
		return
	if morto:
		return
	# só morre se for o jogador E ele estiver caindo (velocity.y > 0)
	if body.is_in_group("player") and body.velocity.y > 0:
		morrer()
		body.quicar()

# alguém encostou no CORPO
func _on_hitbox_body_entered(body):
	if morto:
		return
	if body.is_in_group("player"):
		body.tomar_dano(global_position.x) # na etapa 7B troca por dano de verdade

func morrer():
	morto = true
	set_physics_process(false)   # para de andar
	# desliga as áreas e a colisão (set_deferred = "faz no fim do quadro",
	# porque o Godot não deixa mexer em física no meio de um sinal de física)
	$Hurtbox.set_deferred("monitoring", false)
	$Hitbox.set_deferred("monitoring", false)
	$CollisionShape2D.set_deferred("disabled", true)
	# animação de morte: fica de cabeça para baixo e some
	anim.stop()
	anim.flip_v = true
	var tween = create_tween()
	tween.tween_property(anim, "modulate:a", 0.0, 0.4)
	tween.tween_callback(queue_free)   # depois de sumir, remove da cena

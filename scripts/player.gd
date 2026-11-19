extends CharacterBody2D

const VELOCIDADE = 120.0
const FORCA_PULO = -400.0
const FORCA_QUIQUE = -250.0
const KNOCKBACK = 150.0          #força do empurrão para o lado

var gravidade = ProjectSettings.get_setting("physics/2d/default_gravity")
var invencivel := false          #true = ignora dano
var em_knockback := false        #true = controles travados por um instante

@onready var anim = $AnimatedSprite2D

# as duas opções de animação, carregadas junto com o script
const FRAMES = {
	"red": preload("res://scenes/red_frames.tres"),
	"leaf": preload("res://scenes/leaf_frames.tres"),
}

# _ready roda uma vez, quando o player entra na cena
func _ready():
	anim.sprite_frames = FRAMES[Global.personagem]

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravidade * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = FORCA_PULO

	var direcao = Input.get_axis("ui_left", "ui_right")
	# durante o empurrão, o jogador não controla o movimento lateral
	if not em_knockback:
		velocity.x = direcao * VELOCIDADE

	move_and_slide()
	atualizar_animacao(direcao)

func atualizar_animacao(direcao):
	if direcao != 0:
		anim.flip_h = direcao < 0
	if not is_on_floor():
		anim.play("pulando")
	elif direcao != 0:
		anim.play("andando")
	else:
		anim.play("parado")

func quicar():
	velocity.y = FORCA_QUIQUE

#  chamado pela hitbox da inimiga
func tomar_dano(origem_x):
	if invencivel:
		return
	invencivel = true

	# empurra para o lado oposto ao da inimiga: se ela está à direita, vai para a esquerda
	var lado = sign(global_position.x - origem_x)
	if lado == 0:
		lado = 1
	velocity = Vector2(lado * KNOCKBACK, -150)

	piscar()

	# trava os controles por 0,25 s para o empurrão acontecer
	em_knockback = true
	await get_tree().create_timer(0.25).timeout
	em_knockback = false

	# continua invencível até completar 1 segundo
	await get_tree().create_timer(0.75).timeout
	invencivel = false

# pisca em vermelho 5 vezes (5 x 0,2 s = 1 segundo)
func piscar():
	var tween = create_tween()
	tween.set_loops(5)
	tween.tween_property(anim, "modulate", Color(1, 0.3, 0.3, 0.5), 0.1)
	tween.tween_property(anim, "modulate", Color.WHITE, 0.1)

extends CharacterBody2D

var state_machine
var is_atk: bool = false
var is_dead: bool = false

@export_category("Variables")
@export var move_speed: float = 64.0
@export var acceleration: float = 0.4
@export var friction: float = 0.8

@export_category("Objects")
@export var atk_timer: Timer = null
@export var animation_tree: AnimationTree = null

func _ready():
	animation_tree.active = true
	state_machine = animation_tree["parameters/playback"]

func _physics_process(delta):
	if is_dead:
		return
		
	move()
	atk()
	animate()
	move_and_slide()

func move():
	var direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if direction != Vector2.ZERO:
		animation_tree["parameters/Idle/blend_position"] = direction
		animation_tree["parameters/Walk/blend_position"] = direction
		animation_tree["parameters/Atk/blend_position"] = direction
		
		velocity.x = lerp(velocity.x, direction.normalized().x * move_speed, acceleration)
		velocity.y = lerp(velocity.y, direction.normalized().y * move_speed, acceleration)
		return
		
	velocity.x = lerp(velocity.x, direction.normalized().x * move_speed, friction)
	velocity.y = lerp(velocity.y, direction.normalized().y * move_speed, friction)
	

func atk():
	if Input.is_action_just_pressed("atk") and is_atk == false:
		set_physics_process(false)
		atk_timer.start()
		is_atk = true
		

func animate():
	if is_atk:
		state_machine.travel("Atk")
		return
		
	if velocity.length() > 5:
		state_machine.travel("Walk")
		return
		
	state_machine.travel("Idle")
	


func _on_atk_timer_timeout():
	set_physics_process(true)
	is_atk = false
	


func _on_atk_area_body_entered(body):
	if body.is_in_group("enemy"):
		body.update_health()

func die():
	is_dead = true
	state_machine.travel("Death")
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

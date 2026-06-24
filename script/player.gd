extends CharacterBody3D

# Velocidade que o jogador se mexe em m/s
@export var speed := 14

# Velocidade que o jogador cai quando está no ar em m/s
@export var fall_acceleration := 75

var target_velocity = Vector3.ZERO

# Velocidade vertical aplicada ao jgoador no momento do pulo em m/s
var jump_impulse = 20

# Velocidade vertical aplicada ao esmagar um Mob em m/s
var bounce_impulse = 16

func _physics_process(delta: float) -> void:
	# Adicionando uma variável local para salvar a direção de entrada
	var direction := Vector3.ZERO
	
	# Faz uma checagem para cada direção e atualiza
	
	# Eixo X (Esquerda -1, Direita +1)
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	elif Input.is_action_pressed("move_right"):
		direction.x += 1
	
	# Como é um jogo 3D, os eixos X e Z definem direção em relação ao chão, 
	# o eixo Y define altura.
	# Eixo Z (Frente -1, Trás +1)
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	elif Input.is_action_pressed("move_back"):
		direction.z += 1
	
	# Como a movimentação faz um soma no vetor direção para movimentar o jogador
	# se mover na diagonal faria ele ir mais rapido (de 1 para 1.4, aprox), 
	# para evitar isso, chamados a direção em sua forma normalizada.
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Usar o Basis afeta a rotação do objeto baseada na direção atual.
		$Pivot.basis = Basis.looking_at(direction)
	# Velocidade horizontal
	target_velocity.x = direction.x * speed # Vel Eixo X
	target_velocity.z = direction.z * speed # Vel Eixo Z
	
	# Velocidade vertical
	if not is_on_floor(): # Se estiver no ar, começa a cair
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
		
	# Mover o jogador
	velocity = target_velocity
	
	# Pulo
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	# Quicar
	for index in range(get_slide_collision_count()):
		# Pegamos uma das colisões com o jogador
		var collision = get_slide_collision(index)
		
		# If there are duplicate collisions with a mob in a single frame
		# the mob will be deleted after the first collision, and a second call to
		# get_collider will return null, leading to a null pointer when calling
		# collision.get_collider().is_in_group("mob").
		# This block of code prevents processing duplicate collisions.
		if collision.get_collider() == null:
			continue
		
		# Se o colisor for um Mob
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			# Checamos se estamos colidindo por cima
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# Se sim, esmagamos e mob e quicamos
				mob.squash()
				target_velocity.y = bounce_impulse
				
				# para prevenir chamadas duplicadas chamamos um break
				break
	move_and_slide()

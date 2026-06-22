extends CharacterBody3D

# Velocidade que o jogador se mexe em m/s
@export var speed := 14

# Velocidade que o jogador cai quando está no ar em m/s
@export var fall_acceleration := 75

var target_velocity = Vector3.ZERO

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
	move_and_slide()

extends CharacterBody2D


const GRAVITY : int = 1000 #сила тяжести, определяет, как быстро птица упадёт
const MAX_VEL : int = 600 #максимальная скорость, ограничение скорости падения
const FLAP_SPEED : int = -500 #скорость взмаха крыльев, определяет, как быстро птица подлетит вверх
var flying : bool = false #проверка на полёт, активен до столкновения
var falling : bool = false #проверка на падение, активен при столкновении и падении
const START_POS = Vector2(100, 400) #стартовые координаты


func _ready(): #запуск
	reset()

func reset(): #назначение стартовых параметров
	falling = false
	flying = false
	position = START_POS
	set_rotation(0)
	
	
func _physics_process(delta): #физика, delta-время, прошедшее с момента показа прошлого кадра
	if flying or falling: #если птица летит или падает
		velocity.y += GRAVITY * delta #скорость движения вперёд увеличивается на значение силы тяжести, умноженное на время, прошедшее с момента показа прошлого кадра
		if velocity.y > MAX_VEL: #если скорость движения вперёд превысила максимальную скорость
			velocity.y = MAX_VEL #то присваиваем ей максимальную скорость
		if flying: #если птица взлетает
			set_rotation(deg_to_rad(velocity.y * 0.05)) #то угол поворота птицы равен текущей скорости, умноженной на небольшое значение
			$AnimatedSprite2D.play() #проигрывание анимации
		elif falling: #если птица падает
			set_rotation(PI/2)#то угол поворота птицы равен PI/2
			$AnimatedSprite2D.stop() #остановка анимации
		move_and_collide(velocity * delta) #перемещение птицы
	else:
		$AnimatedSprite2D.stop() #остановка анимации
		
func flap(): #взмах крыльев
	velocity.y = FLAP_SPEED #скорость движения вверх равна скорости взмаха крыльев

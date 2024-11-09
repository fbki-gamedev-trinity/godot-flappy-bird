extends Node

@export var pipe_scene : PackedScene #сцена труб

var game_running : bool #проверка на то, что игра идёт
var game_over : bool #проверка на конец игры
var scroll #прокрутка
var score #счет
const SCROLL_SPEED : int = 4 #скорость прокрутки
var screen_size : Vector2i #размер экрана
var ground_height : int 
var pipes : Array # массив труб на экране
const PIPE_X : int = 100 #
const PIPE_Y : int = 200 

var last_pipe_position_y : int = 0 # последняя высота верхней трубы

func _ready(): #запуск
	screen_size = get_window().size #получение размера окна
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game() 

func new_game(): #новая игра, назначение стартовых параметров
	game_running = false
	game_over = false
	score = 0
	scroll = 0
	$ScoreLabel.text = "SCORE: " + str(score)
	$GameOver.hide()
	get_tree().call_group("pipes", "queue_free") #очищает экран от труб в новой игре
	pipes.clear()#очищает массив от труб в новой игре
	generate_pipes()
	$Bird.reset()#птицу возвращаем

func _input(event): #отлов события
	if game_over == false: #если игра не закончена
		# Обработка кликов мыши
		if Input.is_action_just_pressed("click") or Input.is_action_just_pressed("ui_accept"): # (удалить первое условие) если зажата левая кнопка мыши
				if game_running == false: #если игра не началась
					start_game() #запуск игры
				else:
					if $Bird.flying: #если птица летит (игра идёт)
						$Bird.flap() #вызов взмаха крыльями
						check_top() #проверка на столкновение с верхом
						
func start_game(): #начало игры
	game_running = true #игра считается запущенной
	$Bird.flying = true #птица летит
	$Bird.flap() #вызов взмаха крыльями
	$PipeTimer.start()

func check_top(): #проверка на столкновение с верхом
	if $Bird.position.y < 0+38: #если птица достигла верхнего края экрана
		$Bird.falling = true #считаем, что она упала
		stop_game() #остановка игры
		

func stop_game(): #rjytw buhs
	$PipeTimer.stop() 
	$GameOver.show()
	$Bird.flying = false #птица не летит
	game_running = false #игра не идёт
	game_over = true #игра закончена
	
func _process(delta): 
	if game_running: #если игра идёт
		scroll += SCROLL_SPEED #увеличиваем прокрутку на скорость прокрутки
		
		if scroll >= screen_size.x: #если прокрутка достигла ширины экрана
			scroll = 0 #обнуление прокрутки (для анимации бесконечной земли)
		$Ground.position.x = -scroll #анимация прокрутки земли
		
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED
			if pipe.position.x < -78: # Проверяем, вышла ли труба за левый край экрана
				pipes.erase(pipe) # Удаляем трубу из массива pipes
				pipe.queue_free() # Удаляем трубу из сцены
			
			
func _on_pipe_timer_timeout(): #истекает интервал таймера - создаем трубы
	generate_pipes()
	
func generate_pipes():
	var pipe = pipe_scene.instantiate() # новая труба
	pipe.position.x = screen_size.x + PIPE_X
	pipe.position.y = (screen_size.y - ground_height) / 2  + randi_range(-PIPE_Y, PIPE_Y)
	
	## Генерация случайной высоты для верхней трубы, но с учетом ограничений
	#var new_pipe_y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_Y, PIPE_Y)
	#
	## Устанавливаем минимальное расстояние между трубами по вертикали
	## Если разница слишком велика, генерируем более "плавный" переход
	#while abs(new_pipe_y - last_pipe_position_y) < PIPE_Y * 1.5:
		#new_pipe_y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_Y, PIPE_Y)
#
	#pipe.position.y = new_pipe_y
	#last_pipe_position_y = new_pipe_y # Обновляем последнюю позицию для следующей трубы
	
	pipe.hit.connect(bird_hit)
	pipe.scored.connect(scored)
	add_child(pipe) #добавляем на сцену
	pipes.append(pipe)
	
func bird_hit():
	$Bird.falling = true
	stop_game()
	
func scored():
	score += 1
	$ScoreLabel.text = "SCORE: " + str(score)
	
func _on_ground_hit():
	$Bird.falling = false
	stop_game()


func _on_game_over_restart() -> void:
	new_game()

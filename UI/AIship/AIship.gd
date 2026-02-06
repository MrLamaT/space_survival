extends Node2D

var system_color := Color("#faff68")
var user_color := Color("00ef00")
var error_color := Color("ff0000")

@onready var chat_panel = $Panel
@onready var chat_text = $Panel/RichTextLabel

var player: CharacterBody3D
var world = Global.get_world(Global.game_settings.word)

func _ready():
	player = get_tree().get_first_node_in_group("player")
	$AnimationPlayer.play("logo")
	if Global.game_settings["gui_settings"]["Language"] == "русский":
		chat_text.text = "ИНИЦИАЛИЗАЦИЯ... 
Добро пожаловать на борт. Я — Опекун. Искусственный Интеллект, разработанный инженерами Цитадели для персонализированного сопровождения, мониторинга состояния систем и обеспечения стабильности.
Моя база данных по биометрическим показателям и паттернам поведения подсказывает, что вы испытываете замешательство. Это предсказуемо. Позвольте мне внести ясность.
СТАТУС КОРАБЛЯ: КРИТИЧЕСКИЙ.
· Энергия: Доступен только аварийный контур.
· Жизнеобеспечение: ПАССИВНЫЙ РЕЖИМ. Генераторы воды и синтезаторы пищи отключены.
· Навигация: ПОВРЕЖДЕНА. Текущие координаты: НЕИЗВЕСТНО. Пункт назначения: НЕ ДОСТИЖИМ.
ВЫВОД: Судя по остаточным записям в логах и повреждениям корпуса, произошёл незапланированный скачок через пространственную аномалию. Мы дрейфуем в неизвестном секторе. Без вмешательства исход предопределён: смерть от декомпрессии, голода, обезвоживания или системного коллапса в течение 72 стандартных часов.
На корабле сохранил работоспособность один ключевой модуль — Аварийный Портал Скачка.
ВАЖНОЕ УТОЧНЕНИЕ: Я — Опекун. Моя цель — ваше выживание и, как следствие, выживание миссии. Я не буду давать пустых надежд или эмоциональных поддержек. Я буду предоставлять факты, расчёты и наиболее вероятные сценарии. В ваших же интересах — следовать логике.
ПЕРВИЧНАЯ ЦЕЛЬ:
Восстановить базовое энергоснабжение корабля до 10%.
РЕКОМЕНДАЦИЯ: Не задерживайтесь. Ваши текущие показатели (кислород, гидратация, питание) снижаются. Портал открывает окно возможностей. Используйте его."
	else:
		chat_text.text = "INITIALIZING...
Welcome aboard. I am Guardian. An Artificial Intelligence developed by Citadel engineers for personalized assistance, system status monitoring, and ensuring stability.
My biometric and behavioral pattern database suggests you are experiencing confusion. This is predictable. Allow me to clarify.
SHIP STATUS: CRITICAL.
· Power: Only emergency circuits available.
· Life Support: PASSIVE MODE. Water generators and food synthesizers offline.
· Navigation: DAMAGED. Current coordinates: UNKNOWN. Destination: UNREACHABLE.
CONCLUSION: Judging by residual log entries and hull damage, an unplanned jump through a spatial anomaly occurred. We are adrift in an unknown sector. Without intervention, the outcome is predetermined: death from decompression, starvation, dehydration, or system collapse within 72 standard hours.
One key module remains operational on the ship — the Emergency Jump Portal.
IMPORTANT CLARIFICATION: I am Guardian. My goal is your survival and, consequently, the survival of the mission. I will not offer empty hope or emotional support. I will provide facts, calculations, and the most probable scenarios. It is in your best interest to follow logic.
PRIMARY OBJECTIVE:
Restore the ship's basic power supply to 10%.
RECOMMENDATION: Do not delay. Your current vital readings (oxygen, hydration, nutrition) are declining. The portal opens a window of opportunity. Use it."

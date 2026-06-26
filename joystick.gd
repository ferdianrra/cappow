extends Control

@onready var point = $Point
# Asumsi titik tengah joystick mengikuti ukuran Control node-nya
var output_vector: Vector2 = Vector2.ZERO

# Variabel untuk mengunci ID jari (-1 artinya belum ada yang pegang)
var current_touch_index: int = -1 

func _gui_input(event: InputEvent) -> void:
	# 1. Saat layar disentuh atau dilepas
	if event is InputEventScreenTouch:
		# Jika jari menempel dan joystick sedang nganggur
		if event.pressed and current_touch_index == -1:
			current_touch_index = event.index # Kunci ID jari
			update_joystick(event.position)
			
		# Jika jari diangkat dan itu adalah jari yang mengunci joystick ini
		elif not event.pressed and event.index == current_touch_index:
			current_touch_index = -1 # Lepas kuncian
			output_vector = Vector2.ZERO
			point.position = size / 2 # Kembalikan titik putih ke tengah

	# 2. Saat jari digeser
	elif event is InputEventScreenDrag:
		# Hanya proses pergeseran jika ID jarinya cocok dengan yang dikunci
		if event.index == current_touch_index:
			update_joystick(event.position)

# Fungsi bantuan untuk menghitung pergerakan titik putih
func update_joystick(touch_position: Vector2) -> void:
	var center = size / 2
	var radius = size.x / 2
	
	# Jarak posisi sentuhan dari titik tengah joystick
	var local_pos = touch_position - center
	
	# Cegah titik putih keluar dari batas lingkaran
	if local_pos.length() > radius:
		local_pos = local_pos.normalized() * radius
		
	# Geser titik putih
	point.position = center + local_pos
	
	# Simpan arah untuk dikirim ke capybara (bernilai -1 sampai 1)
	output_vector = local_pos.normalized()

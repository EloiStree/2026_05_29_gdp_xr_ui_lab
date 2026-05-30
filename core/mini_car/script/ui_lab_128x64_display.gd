class_name UiLab128x64Display
extends Node

## I am a signal that give a chance to directly update a material of a MeshInstance3D with the new texture, in case designers want to do it by themselves for some reason, otherwise the system will do it by itself with the default material index 0
signal on_texture_material_updated(index:int, material_surface:Material)
## I am a signal that give the last texture update to designers
signal on_texture_updated(texture: Texture2D)


## What color should be display if true ?
@export var _color_true: Color = Color("#9BBC0F")  
## What color should be display if false ?
@export var _color_false: Color = Color("#0F380F")  

const SCREEN_WIDTH: int = 128
const SCREEN_HEIGHT: int = 64
const SCREEN_SIZE: int = SCREEN_WIDTH * SCREEN_HEIGHT
const SCREEN_SIZE_INDEX_MAX: int = SCREEN_SIZE - 1




@export var use_mipmaps: bool = false
@export var material_to_duplicate: StandardMaterial3D
@export var material_duplicated: StandardMaterial3D

var bool_array_clear: Array[bool] = []
var bool_array_full: Array[bool] = []



@export_group("Debug")
@export var created_and_updated_texture_2d: Texture2D
@export var created_and_updated_texture_2d_image: Image
var last_received_boolean_array: Array[bool] = []


enum ColorStyle {
	INSEPCTOR_VALUE,
	OLED_BLACK_BLUE,
	OLED_BLACK_GREEN,
	OLED_BLACK_WHITE_BLUE,
	E_INK,
	BLACK_TRUE_ON_WHITE_FALSE,
	WHITE_TRUE_ON_BLACK_FALSE,
	GAMEBOY_DARK,
	GAMEBOY_LIGHT,
	FLIPPER_ORANGE,
}

var is_init=false
func _ready() -> void:
	if is_init==false:
		_setup_the_texture_check()


func _setup_the_texture_check():
	if is_init:
		return
	is_init=true
	bool_array_clear.resize(SCREEN_SIZE)
	bool_array_full.resize(SCREEN_SIZE)
	for i in range(SCREEN_SIZE):
		bool_array_clear[i] = false
		bool_array_full[i] = true

	material_duplicated = material_to_duplicate.duplicate() as StandardMaterial3D
	var image = Image.create(SCREEN_WIDTH, SCREEN_HEIGHT, false, Image.FORMAT_RGB8)
	created_and_updated_texture_2d = ImageTexture.create_from_image(image)
	created_and_updated_texture_2d_image = image
	material_duplicated.albedo_texture = created_and_updated_texture_2d

	last_received_boolean_array = bool_array_clear.duplicate()
	set_texture_with_boolean_array(last_received_boolean_array)
	

func inverse_color_true_false():
	_setup_the_texture_check()
	var tmp :Color= _color_true
	_color_true = _color_false
	_color_false = tmp



func set_color_on_off(new_true_color:Color,new_false_color:Color):
		_color_true =new_true_color
		_color_false =new_false_color
		
func set_color_on(new_true_color:Color):
	_color_true =new_true_color
	
func set_color_off(new_false_color:Color):
	_color_false =new_false_color


func set_texture_with_boolean_array(display_as_boolean_array: Array[bool]):
	last_received_boolean_array = display_as_boolean_array
	if display_as_boolean_array==null:
		return 
	if display_as_boolean_array.size()<SCREEN_SIZE:
		return 
	_setup_the_texture_check()
	var image = Image.create(SCREEN_WIDTH, SCREEN_HEIGHT, false, Image.FORMAT_RGB8)
	for i in range(SCREEN_SIZE):
		var pos := index_to_xy(i)
		var is_on: bool = display_as_boolean_array[i]
		var color = _color_true if is_on else _color_false
		image.set_pixel(pos.x, pos.y, color)
	created_and_updated_texture_2d_image = image
	created_and_updated_texture_2d = ImageTexture.create_from_image(image)
	on_texture_updated.emit(created_and_updated_texture_2d)
	on_texture_material_updated.emit(0, material_duplicated)


func set_texture_with_bit_array(bit_pack_as_bytes:PackedByteArray):
	_setup_the_texture_check()

	# expects width * height bits, packed as bytes (8 bits per byte)
	var total_bits = bit_pack_as_bytes.size() * 8
	var max_size = min(total_bits, SCREEN_SIZE)
	var result_array: Array[bool] = []
	
	for i in range(max_size):
		var byte_index = i / 8
		var bit_index = i % 8
		var is_on: bool = (bit_pack_as_bytes[byte_index] & (1 << bit_index)) != 0
		result_array.append(is_on)
	set_texture_with_boolean_array(result_array)
		













static func index_to_xy(index: int) -> Vector2i:
	var x: int = index % SCREEN_WIDTH
	var y: int = index / SCREEN_WIDTH
	return Vector2i(x, y)

static func xy_to_index(x: int, y: int) -> int:
	return y * SCREEN_WIDTH + x



func _set_boolean_array_to_full():
	_setup_the_texture_check()
	for i in range(SCREEN_SIZE):
		bool_array_full[i] = true

func _set_boolean_array_to_clear():
	_setup_the_texture_check()
	for i in range(SCREEN_SIZE):
		bool_array_clear[i] = false

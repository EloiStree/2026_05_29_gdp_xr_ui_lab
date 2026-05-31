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
	if material_duplicated is StandardMaterial3D:
		var mat:StandardMaterial3D = material_duplicated
		mat.albedo_texture = created_and_updated_texture_2d
	
	on_texture_updated.emit(created_and_updated_texture_2d)
	on_texture_material_updated.emit(0, material_duplicated)


## Duplicate to have the same method name in car and display
func set_screen_128x64_to(array:Array[bool]):
	set_texture_with_boolean_array(array)

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
		
		
		
		
		
		
		
		
		
		
		
#region PRINT TEXT  IN THE ARRAY

func print_text(array:Array[bool], text:String, letter_color:bool=true, use_background:bool=true, top_left_text_corner:Vector2i=Vector2i.ZERO):
	print_text_6x8_at_lrtd(array, top_left_text_corner,text,letter_color,use_background)

## Ce code prend un texte et une position et l'affiche sur l'écran
static func print_text_6x8_at_lrtd(array:Array[bool], top_left_text_corner:Vector2i, text:String, letter_color:bool, use_background:bool):
	draw_line_characters_6x8_lrtd(array, top_left_text_corner.x, top_left_text_corner.y, text, letter_color, use_background)

#region BITMAP FONT TO TEXT IMAGE 
static func draw_line_characters_6x8_lrtd(array: Array[bool], x_left_right: int, y_down_top: int, chars: String, is_on: bool = true,use_background: bool = false):
	var right_offset: int = 6
	var down_offset: int = 8
	var line_count: int = 0
	var char_count: int = 0

	for c in chars:
		if c == "\n":
			line_count += 1
			char_count = 0
			continue
		var image :String=get_text_image_of_font_character(c)
		if use_background:
			draw_from_text_image_lrtd_with_background(array, x_left_right + char_count * right_offset, y_down_top + line_count * down_offset, image, is_on)
		else:
			draw_from_text_image_lrtd_without_background(array, x_left_right + char_count * right_offset, y_down_top + line_count * down_offset, image, is_on)

		char_count += 1


static func replace_slash_per_line_return(text:String)->String:
	return text.replace("/","\n").replace("\\","\n").replace("|","\n")

static func keep_only_01(text:String)->String:
	var result: String = ""
	for char in text:
		if char == "0" or char == "1" or char == "\n":
			result += char
	return result

static func set_value_at_index_1d(array: Array[bool], index:int, is_on:bool):
	if index < 0 or index >= array.size():
		return
	array[index] = is_on

static func set_value_at_x_y_lrtd(array: Array[bool] , x_left_right:int,y_top_down:int, is_on:bool):
	if x_left_right < 0 or x_left_right >= SCREEN_WIDTH:
		return
	if y_top_down < 0:
		y_top_down = 0
	if y_top_down >= SCREEN_HEIGHT:
		y_top_down = SCREEN_HEIGHT - 1
	var index: int = y_top_down * SCREEN_WIDTH + x_left_right
	set_value_at_index_1d(array, index, is_on)




static func draw_from_text_image_lrtd_with_background(array: Array[bool], x_left_right: int, y_down_top: int, text_image:String, is_on: bool = true):
	
	var text_cleaned: String = keep_only_01(replace_slash_per_line_return(text_image))
	if is_on==false:
		text_cleaned = text_cleaned.replace("1","c").replace("0","1").replace("c","0")
	var lines:= text_cleaned.split("\n")
	var start_x = x_left_right
	var start_y = y_down_top

	var x_counter: int = 0
	var y_counter: int = 0
	var text_index:int=0
	for line in lines:
		for char in line:
			if char != "0" and char != "1":
				continue
			
			var is_on_char: bool = char == "1"
			set_value_at_x_y_lrtd(array, start_x + x_counter, start_y + y_counter, is_on_char)
			x_counter += 1
			text_index+=1
		y_counter += 1
		x_counter = 0


static func draw_from_text_image_lrtd_without_background(array: Array[bool], x_left_right: int, y_down_top: int, text_image:String, is_on: bool = true):
	
	var text_cleaned: String = keep_only_01(replace_slash_per_line_return(text_image))
	if is_on:
		text_cleaned = text_cleaned.replace("1","o")
	if not is_on:
		text_cleaned = text_cleaned.replace("1","n")
	var lines:= text_cleaned.split("\n")
	var start_x = x_left_right
	var start_y = y_down_top

	var x_counter: int = 0
	var y_counter: int = 0
	var text_index:int=0
	for line in lines:
		for char in line:
			if char != "0" and char != "1" and char != "n" and char != "o":
				continue
			
			if char == "n" or char == "o":
				var is_on_char: bool = char == "o"
				set_value_at_x_y_lrtd(array, start_x + x_counter, start_y + y_counter, is_on_char)
			x_counter += 1
			text_index+=1
		y_counter += 1
		x_counter = 0


	


static func get_text_image_of_font_character(character: String) -> String:
	if FONT_DICO_SSD1306_6X8.has(character):
		var bytes: Array = FONT_DICO_SSD1306_6X8[character]
		var packed_bytes: PackedByteArray = PackedByteArray(bytes)
		return turn_6x8_bitmap_bytes_to_text_image(packed_bytes)
	else:
		return ""


## Take packed of byte array stack vertically and turn it into a text image of 1 and 0, where 1 is a pixel on and 0 is a pixel off
static func turn_6x8_bitmap_bytes_to_text_image(bytes:PackedByteArray)->String:
	var array_8x6:Array[String] = [
		"0","0","0","0","0","0","|",
		"0","0","0","0","0","0","|",
		"0","0","0","0","0","0","|",
		"0","0","0","0","0","0","|",
		"0","0","0","0","0","0","|",
		"0","0","0","0","0","0","|",
		"0","0","0","0","0","0","|",
		"0","0","0","0","0","0",
		]

	for x in range(6):
		var byte_as_int: int = bytes[x]
		for y in range(8):
			var bit_is_on: bool = (byte_as_int & (1 << y)) != 0
			array_8x6[y * 7 + x] = "1" if bit_is_on else "0"
	var text_image: String = "".join(array_8x6)
	return text_image

## Return a dictionary of all the char you can use from the bitmap dictionary
static func get_all_char_in_font_dictionary_6x8() -> Array[String]:
	var characters: Array[String] = []
	for character in FONT_DICO_SSD1306_6X8.keys():
		characters.append(character)
	return characters


const FONT_DICO_SSD1306_6X8 := {
	' ': [0x00,0x00,0x00,0x00,0x00,0x00],
	'!': [0x00,0x00,0x00,0x2f,0x00,0x00],
	'"': [0x00,0x00,0x07,0x00,0x07,0x00],
	'#': [0x00,0x14,0x7f,0x14,0x7f,0x14],
	'$': [0x00,0x24,0x2a,0x7f,0x2a,0x12],
	'%': [0x00,0x23,0x13,0x08,0x64,0x62],
	'&': [0x00,0x36,0x49,0x55,0x22,0x50],
	"'": [0x00,0x00,0x05,0x03,0x00,0x00],
	'(': [0x00,0x00,0x1c,0x22,0x41,0x00],
	')': [0x00,0x00,0x41,0x22,0x1c,0x00],
	'*': [0x00,0x14,0x08,0x3E,0x08,0x14],
	'+': [0x00,0x08,0x08,0x3E,0x08,0x08],
	',': [0x00,0x00,0x00,0xA0,0x60,0x00],
	'-': [0x00,0x08,0x08,0x08,0x08,0x08],
	'.': [0x00,0x00,0x60,0x60,0x00,0x00],
	'/': [0x00,0x20,0x10,0x08,0x04,0x02],
	'0': [0x00,0x3E,0x51,0x49,0x45,0x3E],
	'1': [0x00,0x00,0x42,0x7F,0x40,0x00],
	'2': [0x00,0x42,0x61,0x51,0x49,0x46],
	'3': [0x00,0x21,0x41,0x45,0x4B,0x31],
	'4': [0x00,0x18,0x14,0x12,0x7F,0x10],
	'5': [0x00,0x27,0x45,0x45,0x45,0x39],
	'6': [0x00,0x3C,0x4A,0x49,0x49,0x30],
	'7': [0x00,0x01,0x71,0x09,0x05,0x03],
	'8': [0x00,0x36,0x49,0x49,0x49,0x36],
	'9': [0x00,0x06,0x49,0x49,0x29,0x1E],
	':': [0x00,0x00,0x36,0x36,0x00,0x00],
	';': [0x00,0x00,0x56,0x36,0x00,0x00],
	'<': [0x00,0x08,0x14,0x22,0x41,0x00],
	'=': [0x00,0x14,0x14,0x14,0x14,0x14],
	'>': [0x00,0x00,0x41,0x22,0x14,0x08],
	'?': [0x00,0x02,0x01,0x51,0x09,0x06],
	'@': [0x00,0x32,0x49,0x59,0x51,0x3E],
	'A': [0x00,0x7C,0x12,0x11,0x12,0x7C],
	'B': [0x00,0x7F,0x49,0x49,0x49,0x36],
	'C': [0x00,0x3E,0x41,0x41,0x41,0x22],
	'D': [0x00,0x7F,0x41,0x41,0x22,0x1C],
	'E': [0x00,0x7F,0x49,0x49,0x49,0x41],
	'F': [0x00,0x7F,0x09,0x09,0x09,0x01],
	'G': [0x00,0x3E,0x41,0x49,0x49,0x7A],
	'H': [0x00,0x7F,0x08,0x08,0x08,0x7F],
	'I': [0x00,0x00,0x41,0x7F,0x41,0x00],
	'J': [0x00,0x20,0x40,0x41,0x3F,0x01],
	'K': [0x00,0x7F,0x08,0x14,0x22,0x41],
	'L': [0x00,0x7F,0x40,0x40,0x40,0x40],
	'M': [0x00,0x7F,0x02,0x0C,0x02,0x7F],
	'N': [0x00,0x7F,0x04,0x08,0x10,0x7F],
	'O': [0x00,0x3E,0x41,0x41,0x41,0x3E],
	'P': [0x00,0x7F,0x09,0x09,0x09,0x06],
	'Q': [0x00,0x3E,0x41,0x51,0x21,0x5E],
	'R': [0x00,0x7F,0x09,0x19,0x29,0x46],
	'S': [0x00,0x46,0x49,0x49,0x49,0x31],
	'T': [0x00,0x01,0x01,0x7F,0x01,0x01],
	'U': [0x00,0x3F,0x40,0x40,0x40,0x3F],
	'V': [0x00,0x1F,0x20,0x40,0x20,0x1F],
	'W': [0x00,0x3F,0x40,0x38,0x40,0x3F],
	'X': [0x00,0x63,0x14,0x08,0x14,0x63],
	'Y': [0x00,0x07,0x08,0x70,0x08,0x07],
	'Z': [0x00,0x61,0x51,0x49,0x45,0x43],
	'[': [0x00,0x00,0x7F,0x41,0x41,0x00],
	'\\': [0x02, 0x04, 0x08, 0x10, 0x20, 0x00],
	']': [0x00,0x00,0x41,0x41,0x7F,0x00],
	'^': [0x00,0x04,0x02,0x01,0x02,0x04],
	'_': [0x00,0x40,0x40,0x40,0x40,0x40],
	'`': [0x00,0x00,0x01,0x02,0x04,0x00],
	'a': [0x00,0x20,0x54,0x54,0x54,0x78],
	'b': [0x00,0x7F,0x48,0x44,0x44,0x38],
	'c': [0x00,0x38,0x44,0x44,0x44,0x20],
	'd': [0x00,0x38,0x44,0x44,0x48,0x7F],
	'e': [0x00,0x38,0x54,0x54,0x54,0x18],
	'f': [0x00,0x08,0x7E,0x09,0x01,0x02],
	'g': [0x00,0x18,0xA4,0xA4,0xA4,0x7C],
	'h': [0x00,0x7F,0x08,0x04,0x04,0x78],
	'i': [0x00,0x00,0x44,0x7D,0x40,0x00],
	'j': [0x00,0x40,0x80,0x84,0x7D,0x00],
	'k': [0x00,0x7F,0x10,0x28,0x44,0x00],
	'l': [0x00,0x00,0x41,0x7F,0x40,0x00],
	'm': [0x00,0x7C,0x04,0x18,0x04,0x78],
	'n': [0x00,0x7C,0x08,0x04,0x04,0x78],
	'o': [0x00,0x38,0x44,0x44,0x44,0x38],
	'p': [0x00,0xFC,0x24,0x24,0x24,0x18],
	'q': [0x00,0x18,0x24,0x24,0x18,0xFC],
	'r': [0x00,0x7C,0x08,0x04,0x04,0x08],
	's': [0x00,0x48,0x54,0x54,0x54,0x20],
	't': [0x00,0x04,0x3F,0x44,0x40,0x20],
	'u': [0x00,0x3C,0x40,0x40,0x20,0x7C],
	'v': [0x00,0x1C,0x20,0x40,0x20,0x1C],
	'w': [0x00,0x3C,0x40,0x30,0x40,0x3C],
	'x': [0x00,0x44,0x28,0x10,0x28,0x44],
	'y': [0x00,0x1C,0xA0,0xA0,0xA0,0x7C],
	'z': [0x00,0x44,0x64,0x54,0x4C,0x44],
	'{': [0x00,0x00,0x08,0x77,0x00,0x00],
	'|': [0x00,0x00,0x00,0x7F,0x00,0x00],
	'}': [0x00,0x00,0x77,0x08,0x00,0x00],
	'~': [0x00,0x10,0x08,0x10,0x08,0x00],
	'DEL': [0x14,0x14,0x14,0x14,0x14,0x14]
}
		
		
		
		

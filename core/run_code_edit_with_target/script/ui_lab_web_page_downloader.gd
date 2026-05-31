class_name UiLabWebPageDownloader
extends Node

signal on_text_downloaded(text:String)
signal on_download_failed(code:int)
signal on_download_failed_message(code_text:String)

@export var url:String = ""
@export var load_at_ready:bool=false
@export var use_debug_print:bool=false
@onready var http:HTTPRequest = HTTPRequest.new()

func set_web_page_and_download_directly(url_page:String):
	set_web_page_to_download_from(url_page)
	download()

func set_web_page_to_download_from(url_page:String):
	url=url_page

func _ready():
	add_child(http)
	http.request_completed.connect(_on_done)
	if load_at_ready:
		download()

func download() -> void:
	var final_url:String = _to_raw_url(url)

	if use_debug_print:
		print("Downloading:", final_url)

	var headers:Array[String] = [
		"User-Agent: Mozilla/5.0"
	]
	var err:int = http.request(final_url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		on_download_failed.emit(err)

func _to_raw_url(input_url:String) -> String:
	input_url = input_url.strip_edges()
#
	#if "/raw" in input_url:
		#return input_url
	if "pastebin.com" in input_url:
		var clean:String = input_url.split("?")[0]
		var id:String = clean.get_file()

		if id.is_empty():
			return input_url

		return "https://pastebin.com/raw/" + id

	elif is_permanent_github_file_to_download(input_url):
		input_url = parse_permanent_github_page_to_raw_url(input_url)
	
	elif "gist.github.com" in input_url:
		# format: https://gist.github.com/user/gistid
		var parts:Array = input_url.split("/")
		if parts.size() >= 5:
			var user:String = parts[3]
			var gist_id:String = parts[4]
			return "https://gist.githubusercontent.com/%s/%s/raw" % [user, gist_id]
		return input_url
		

	elif is_github_url(input_url):
		input_url= parse_url_to_github_raw(input_url)
		
	return input_url

# Returns true if URL looks like a GitHub file page
func is_github_url(url: String) -> bool:
	return (
		url.begins_with("https://github.com/")
		or url.begins_with("http://github.com/")
		or url.begins_with("https://www.github.com/")
		or url.begins_with("http://www.github.com/")
	)

func parse_url_to_github_raw(url: String) -> String:
# https://github.com/user/repo/blob/branch/path/file.gd
# https://raw.githubusercontent.com/user/repo/branch/path/file.gd
	if not is_github_url(url):
		return url
	var clean := url
	clean = clean.replace("https://github.com/", "")
	clean = clean.replace("http://github.com/", "")
	clean = clean.replace("https://www.github.com/", "")
	clean = clean.replace("http://www.github.com/", "")

	var parts = clean.split("/")
	if parts.size() < 5:
		return url
	if parts[2] != "blob":
		return url
	var user = parts[0]
	var repo = parts[1]
	var branch = parts[3]
	var file_path := ""
	for i in range(4, parts.size()):
		if i > 4:
			file_path += "/"
		file_path += parts[i]

	return "https://raw.githubusercontent.com/%s/%s/%s/%s" % [
		user,
		repo,
		branch,
		file_path
	]
	
## Example: https://github.com/EloiStree/2026_04_27_gdp_oled_128x64_layer_gist_mod/blob/bf4203fb20dabc80608978a7afcc1ccabef8b732/gist/basic/global_transform.gd
func is_permanent_github_file_to_download(url: String) -> bool:
	var regex := RegEx.new()
	regex.compile(
		"^https://github\\.com/[^/]+/[^/]+/blob/[0-9a-fA-F]{40}/.+$"
	)

	return regex.search(url) != null


func parse_permanent_github_page_to_raw_url(url: String) -> String:
	var regex := RegEx.new()
	regex.compile(
		"^https://github\\.com/([^/]+)/([^/]+)/blob/([0-9a-fA-F]{40})/(.+)$"
	)

	var result := regex.search(url)
	if result == null:
		return ""

	return "https://raw.githubusercontent.com/%s/%s/%s/%s" % [
		result.get_string(1),
		result.get_string(2),
		result.get_string(3),
		result.get_string(4)
	]
func _on_done(
	result:int,
	response_code:int,
	headers:PackedStringArray,
	body:PackedByteArray
) -> void:

	if use_debug_print:
		print("HTTP:", response_code)

	if response_code == 200:
		var text:String = body.get_string_from_utf8()
		on_text_downloaded.emit(text)
	else:
		on_download_failed.emit(response_code)
		on_download_failed_message.emit("ERROR:",response_code )

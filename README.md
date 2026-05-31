# XR UI IDE Lab

> Lab to play with UI in XR to create code IDE in Godot

<img width="1165" height="696" alt="image" src="https://github.com/user-attachments/assets/46266ab2-e2d7-4c74-b3e1-1f9a371c3e12" />

**Required:** [Godot XR Tools](https://godotvr.github.io/godot-xr-tools/) ([Library](https://godotengine.org/asset-library/asset/1698))   

This repository on GitHub is meant to help you learn the Godot UI while experimenting with XR development by creating an IDE in Godot.     

The idea is to get comfortable navigating the Godot UI while iterating on XR interactions, not to ship anything perfect—just to understand how things fit together when you start pushing them around.      

Workshop: [Hello IDE](https://github.com/EloiStree/2026_05_11_workshop_hello_godot_xr/tree/main/week_4/day_01/special) 


**Method you can use to move the car:**
``` gdscript
func set_wheels(left:float,right:float):
func set_left_wheel_percent_power(percent_power11: float) -> void:
func set_right_wheel_percent_power(percent_power11: float) -> void:
func get_front_wheel_left_distance()-> float
func get_front_wheel_right_distance()-> float
func get_left_line_sensor_color()-> Color:
func get_right_line_sensor_color()-> Color:

func set_screen_128x64_to(array_1d_128x64:Array[bool]):
func print_text(array:Array[bool], text:String, letter_color:bool=true, use_background:bool=true, top_left_text_corner:Vector2i=Vector2i.ZERO):

func get_car_id()->int:
func get_car_position()->Vector3:   
func get_car_rotation()->Quaternion:   
func get_car_euler()->Vector3:

```

You have a code editor to run code:   
`UiLabRunCodeEditWithTargetNode` → `prefab_ui_lab_run_code_edit_with_target_node.tscn`   

And a mini car to move:   
`UiLabTwoWheelsMiniCar` → `prefab_two_wheels_car.tscn`   
  
Not that you will most likely need a primitive parse:  
`UiLabPrimitiveToString`   
  
---

### Workshop

Try to create an IDE for building code, for example:  
[<img width="1906" height="814" alt="image" src="https://github.com/user-attachments/assets/043f5507-d3b2-4e6c-919d-055f6142ffc1" />](https://python.microbit.org/v/3)    
[https://python.microbit.org/v/3](https://python.microbit.org/v/3)   

Keep in mind that once you master the 2D part, you need to turn it into 3D with Godot XR Tools.  

---

### Code editor

<img width="511" height="395" alt="image" src="https://github.com/user-attachments/assets/dfc3926e-3900-4984-98ec-eeba6ff25488" />

---

### Mini car

<img width="532" height="958" alt="image" src="https://github.com/user-attachments/assets/843f2bf0-5df2-45d7-b1e8-f02844db7bf1" />



------------------

<img width="1404" height="917" alt="image" src="https://github.com/user-attachments/assets/49860ef9-8e47-43b4-a536-f1f70d034676" />   
<img width="1145" height="643" alt="image" src="https://github.com/user-attachments/assets/a7f2d6ee-7d33-4c9c-941c-26c4916d8849" />   
<img width="640" height="636" alt="image" src="https://github.com/user-attachments/assets/b8fc651d-0c48-4295-939a-376154d3de67" />   










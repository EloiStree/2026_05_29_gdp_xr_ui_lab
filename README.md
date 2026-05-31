# XR UI Lab

> Lab on XR UI Lab

<img width="1165" height="696" alt="image" src="https://github.com/user-attachments/assets/46266ab2-e2d7-4c74-b3e1-1f9a371c3e12" />


You want to learn the Godot UI while learning to code in XR.    
Let's have fun exploring the idea.   

Here, you can find some experiments on the topic.   

My aim is to focus on learning the UI and modding.   

You will find a RunCodeEdit prefab and a MiniTwoWheelsCar prefab here.  

Try to create a game and practice using the UI to control the car.   
You can also experiment with adding, removing, or modifying the controls.  


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
<img width="1404" height="917" alt="image" src="https://github.com/user-attachments/assets/49860ef9-8e47-43b4-a536-f1f70d034676" />
<img width="1145" height="643" alt="image" src="https://github.com/user-attachments/assets/a7f2d6ee-7d33-4c9c-941c-26c4916d8849" />
<img width="640" height="636" alt="image" src="https://github.com/user-attachments/assets/b8fc651d-0c48-4295-939a-376154d3de67" />

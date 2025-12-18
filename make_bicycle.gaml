/**
* Name: makebicycle
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model makebicycle

/* Insert your model definition here */
import "road.gaml"
import "bicycle.gaml"

species make_bicycle{
	//使用する道路
	road first_use_road;
	//道路内のスポーン地点
	point spawn_point;
	//初期ベクトル
	point start_vector;
	//ターゲットベクトル
	point arrival_point;
	//色
	rgb bicycle_color;
	
	init{
		create bicycle number: 1 with:[
			use_road:first_use_road,
			bicycle_point:spawn_point,
			move_vector:start_vector,
			color:bicycle_color,
			target_point:arrival_point
		];
	}
}
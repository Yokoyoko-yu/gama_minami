/**
* Name: Main
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model Main

/* Insert your model definition here */

import "bicycle.gaml"
import "road.gaml"

global{
	float step<-0.1#s;
}

experiment mi type:gui{
	init{
		create road;
//		write("使用道路:"+one_of(road).shape);
		write("道路の地形"+one_of(road).shape);
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{0,60},
//			move_vector:{5,5}*step,//0.1s
//			color:#yellow,
//			target_point:{100,60}
//		];
//		//道路の斥力をテスト
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{100,51},
//			move_vector:{-5,0}*step,//0.1s
//			color:#green,
//			target_point:{0,58}
//		];
		//両側から
		//0
		create bicycle number: 1 with:[
			use_road:one_of(road),
			bicycle_point:{0,60},
			move_vector:{1,0}*5*(1000/3600)*step,//0.1s
			color:#red,
			target_point:{100,60}
		];
//		//1
		create bicycle number: 1 with:[
			use_road:one_of(road),
			bicycle_point:{100,60},
			move_vector:{-5,0}*step,//0.1s
			color:#green,
			target_point:{0,60}
		];
////		
////
////		//2
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{0,55},
//			move_vector:{5,0}*step,//0.1s
//			color:#black,
//			target_point:{100,55}
//		];
//		//3
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{100,55},
//			move_vector:{-5,0}*step,//0.1s
//			color:#yellow,
//			target_point:{0,55}
//		];
//		
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{0,65},
//			move_vector:{1,0}*5*(1000/3600)*step,//0.1s
//			color:#red,
//			target_point:{100,65}
//		];
//		
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{100,65},
//			move_vector:{1,0}*5*(1000/3600)*step,//0.1s
//			color:#red,
//			target_point:{0,65}
//		];
	}
	
//	reflex when:every (180#cycle) {
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{0,60},
//			move_vector:{5,0}*step,//0.1s
//			color:#red,
//			target_point:{100,60}
//		];
//		//1
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{100,60},
//			move_vector:{-5,0}*step,//0.1s
//			color:#green,
//			target_point:{0,60}
//		];
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{0,55},
//			move_vector:{5,0}*step,//0.1s
//			color:#black,
//			target_point:{100,55}
//		];
////		//3
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{100,55},
//			move_vector:{-5,0}*step,//0.1s
//			color:#yellow,
//			target_point:{0,55}
//		];
//	}
	
//	reflex when:every (60#cycle) {
//		create bicycle number: 1 with:[
//			use_road:one_of(road),
//			bicycle_point:{100,67},
//			move_vector:{-0.1,0}*step,//0.1s
//			color:#green,
//			target_point:{0,73}
//		];
//		}
	
	//ランダムな高さにスポーン
//	reflex when:every (30#cycle) {
//		float left_start<-rnd(0.0,1.0);
//		float deep<-rnd(52.0,68.0);
//		if(left_start>0.5){
//			create bicycle number:1 with:[
//				use_road:one_of(road),
//				bicycle_point:{0,deep},
//				move_vector:{0,0}*step,//0.1s
//				color:#red,
//				target_point:{100,deep}
//			];
//		}else{
//				create bicycle number:1 with:[
//				use_road:one_of(road),
//				bicycle_point:{100,deep},
//				move_vector:{0,0}*step,//0.1s
//				color:#blue,
//				target_point:{0,deep}
//			];
//		}
//		
//	}
	
	//ランダムな高さ、ランダムな速さでスポーン
	reflex when:every (30#cycle) {
		float left_start<-rnd(0.0,1.0);
		float deep<-rnd(52.0,68.0);
		if(left_start>0.5){
			create bicycle number:1 with:[
				use_road:one_of(road),
				bicycle_point:{0,deep},
				move_vector:{1,0}*step*rnd(0.0,5.0),//0.1s
				color:#red,
				target_point:{100,deep}
			];
		}else{
				create bicycle number:1 with:[
				use_road:one_of(road),
				bicycle_point:{100,deep},
				move_vector:{0,1}*step*rnd(0.0,15.0),//0.1s
				color:#blue,
				target_point:{0,deep}
			];
		}
		
	}

	//同じ高さにスポーン
//		reflex when:every (30#cycle) {
//		float left_start<-rnd(0.0,1.0);
//		float deep<-rnd(52.0,68.0);
//			create bicycle number:1 with:[
//				use_road:one_of(road),
//				bicycle_point:{0,deep},
//				move_vector:{0,0}*step,//0.1s
//				color:#red,
//				target_point:{100,deep}
//			];
//		
//				create bicycle number:1 with:[
//				use_road:one_of(road),
//				bicycle_point:{100,deep},
//				move_vector:{0,0}*step,//0.1s
//				color:#blue,
//				target_point:{0,deep}
//			];
//		
//		
//	}
	
	output{
		display main type:opengl background:#cornsilk{
			species road aspect:base;
			species bicycle aspect:base;
		}
	}
}
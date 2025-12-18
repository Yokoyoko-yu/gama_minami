/**
* Name: road
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model road

/* Insert your model definition here */


global{
//	float road_length<-100#m;
//	float road_width<-20#m;
//	point road_start_point<-{0,50};
}

species road{
	point road_start_point<-{0,50};
	float length<-100#m;
	float width<-20#m;
	float angle;
	rgb color<-#gray;
	init{
		shape<- polygon([road_start_point,road_start_point+{length,0},road_start_point+{length,width},road_start_point+{0,width}]);
	}
	aspect base{
		draw shape color:self.color;
	}
}




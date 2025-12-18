/**
* Name: curveroad
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model curveroad

/* Insert your model definition here */

global{
}

species road{
	int split_point<-50;
	list<point> noad_list<-[{20,0},{10,10},{20,20}];
	list<map> edge_list<-[
		["start"::0,"end"::1,"angle"::45,"width"::10#m],
		["start"::1,"end"::2,"angle"::45,"width"::10#m]
	];
	list<point> draw_lines;
	
	for(map e in edge_list){
		point start_p <- noad_list[e.start];
	}
	
	
	
}


/**
* Name: bicycle
* Based on the internal empty template. 
* Author: yudai
* Tags: 
*/


model bicycle

/* Insert your model definition here */

import "road.gaml"

global{
	float max_bicycle_speed<-15*(1000/3600)#m/#s;//目標速度 km/hをm/sに変換
	float bicycle_width<-0.5#m;
	float bicycle_length<-1#m;
	float tau<-5#s;
	float A_alfa<-0.8;
	float B_alfa<-0.7;
	float lambda<-0.1; //背後から受ける斥力の重み付け
	float road_p;	//道路の境界から受ける斥力の重みづけ
	float A_road<-0.8;
	float B_road<-0.7;
	list <float> dead_list<-[0.0];
	float arrive_sum<-0.0;
	int arrive_num<-0;
}

species bicycle{
	bool left_start; 
//	make_roadで使用するもの(目的地によって変容しうる変数)
	//走行中の道路
	road use_road;
	//走行中の道路の位置
	list use_road_point;
	//自転車の中心点
	point bicycle_point;
	//1ステップ当たりに進む距離
	point move_vector;
	//色
	rgb color;
	//目標地点
	point target_point;
	//回避の時に参照するパラメータ
	float dodge;
	//目標地点から受ける引力
	point gra_p;
	//エージェントの斥力
	point agent_p;
	//道路から受ける斥力
	point road_p;
	//回避ベクトルが生まれなかった時のための力
	point as_p;
	//スポーンした時間
	float spawn_time;
	
	
	init{
		//走行中の道路
		use_road<-one_of(road where(self overlaps each));
		//shapeに反映
		shape<-polygon([
			bicycle_point + {-bicycle_length/2, -bicycle_width/2},
		    bicycle_point + {bicycle_length/2, -bicycle_width/2},
		    bicycle_point + {bicycle_length/2, bicycle_width/2},
		    bicycle_point + {-bicycle_length/2, bicycle_width/2}
		]);
		self.spawn_time<-time;
	}
	
	//目標地点から受ける引力の計算(単位はm/s)
	point update_gravity{
		//目標地点までのベクトル
		point target_vector<-target_point-bicycle_point;
		//単位ベクトルに変換
		point per_direction_vector<-target_vector/norm(target_vector);
		//目標速度に変換
		point wish_vector<-(per_direction_vector*max_bicycle_speed);
		return (wish_vector-move_vector*(1/step))/tau;
	}
	
	//道路から受ける斥力を求める(道路の境界からの距離に比例する)
	point add_road_repulsion{
			point ans<-{0,0};
			float d_to_target<-self.bicycle_point distance_to target_point;
		loop i from:0 to:(length(use_road.shape.points)-2){
			point s<-self.use_road.shape.points[i];//道路の始点
			point e<-self.use_road.shape.points[i+1];//道路の終点
			point np<-nearest_edge_v(s,e,self.bicycle_point);//自転車と最も近い点
			float d_from_edge<-self.bicycle_point distance_to np;
			if(d_from_edge)<5.0 and d_to_target>5.0 and self.bicycle_point!=np{
				point d_r<-self.bicycle_point-np;
				point e_r<-(d_r/norm(d_r));//自転車が逃げる方向の単位ベクトル
				point g<-e_r*(A_road*(exp(-1*norm(d_r)/B_road)));
				ans<-ans+g;
			}
		}
		return ans;
	}


	//道路の最近接点からエージェントまでのベクトルを返す
	point nearest_edge_v(point s,point e,point a){
		float s_to_a<-s distance_to a;

		float a_to_e<-a distance_to e;

		point vector_s_to_e<-e-s;
		float t<-((a-s)*(e-s))/((e-s)*(e-s));
		t <- max(0.0, min(1.0, t));
		point nearest_vector<-s+(e-s)*t;
		return nearest_vector;
	}
	
	
	//影響を受ける範囲にいるエージェント群をまとめる
	list<bicycle> affect_bicycles{
		list<bicycle> all_bicycles <- bicycle where (self != each);
		list<bicycle> circle_bicycles<-all_bicycles where((each distance_to self)<25#m);
	//双曲線内にいるエージェント
		list<bicycle> affect_list<-circle_bicycles where(
			((((move_vector*(self.bicycle_point-each.bicycle_point))*(move_vector*(self.bicycle_point-each.bicycle_point)))/(sqrt(3)/2)*(sqrt(3)/2))
			-(((move_vector*(self.bicycle_point-each.bicycle_point))*(move_vector*(self.bicycle_point-each.bicycle_point)))/(1/2)*(1/2)))>(-1)
		);

		return affect_list;
	}
	
	//近接エージェントから受ける斥力を一つ一つ計算し、合計した斥力をベクトルで返す
	point add_repulsion{
		list<bicycle> calculate_list<-affect_bicycles();
		point repulsion_vector<-{0,0};
		self.as_p<-{0,0};
		loop i over: calculate_list{
			repulsion_vector<-repulsion_vector+calc_repulsion_agent(i);
			self.as_p<-self.as_p+repulsion_assist(i);
			write("あしすとぱわー"+self.as_p);
		}
		return repulsion_vector;
	}
	
	//selfから最も近い点を返す 1つ目の配列がself
	list<point> return_nearest_point(bicycle a_bicycle){
		list<point> v1<-a_bicycle.shape closest_points_with(self.shape);
		return v1;
	}
	
	//一つのエージェントから受ける斥力を計算する
	point calc_repulsion_agent(bicycle a_bicycle){
		point self_n_point;
		point opponent_n_point;
		list <point> nl<-return_nearest_point(a_bicycle);
		if(nl[0]!=nl[1]){
		self_n_point<-nl[1];
		opponent_n_point<-nl[0];
		}else{
			self_n_point<-self.bicycle_point;
			opponent_n_point<-a_bicycle.bicycle_point;
		}

		//エージェントから主体までのベクトルd
		point d<-(self_n_point-opponent_n_point);
		//φを求める
		float phi<-angle_between(self_n_point,opponent_n_point-self_n_point,self.move_vector);
		float ganma<- lambda+(1-lambda)*((1+cos(phi))/2);
		point relative_speed<-a_bicycle.move_vector-self.move_vector;//論文中のyの式にあたる
		point e<-((d/norm(d))+((d-relative_speed)/norm((d-relative_speed))))*(0.5);
		float b<-0.5*(sqrt((norm(d)+norm(d-relative_speed))*(norm(d)+norm(d-relative_speed))-(norm(relative_speed)*norm(relative_speed))));//Δtは反応速度
		b<-max(0.000000001,b);
		point g<-e*(A_alfa*(max(0.1,exp(-b/B_alfa)))*((norm(d)+norm(d-relative_speed))/(2*b)));
//		write("g:"+g);
		write("b:"+b);
//		write("exp(-b/B_alfa)"+exp(-b/B_alfa));
//		write("(norm(d)+norm(d-relative_speed))"+(norm(d)+norm(d-relative_speed))/(2*b));
		
		return g*ganma;
	}
	
	//斥力がmove_vectorと同一方向にしか働かないか判定し、回避
	point repulsion_assist(bicycle a_bicycle){

		if (norm(self.agent_p)!=0){
//			float naiseki<-(self.agent_p/norm(self.agent_p))*(self.move_vector/norm(self.move_vector));
			float naiseki<-(calc_repulsion_agent(a_bicycle)/norm(calc_repulsion_agent(a_bicycle)))*(self.move_vector/norm(self.move_vector));
//			write("エージェント"+a_bicycle.color+"から受ける斥力"+calc_repulsion_agent(a_bicycle));
			//内積が-1から誤差10**-2以内であれば衝突検知
			float naiseki_error<-naiseki+1;
//			write("エージェント"+a_bicycle.color+"からの内積は"+naiseki);
//			write("内積"+naiseki_error);
			if((-0.01)<naiseki_error and naiseki_error<0.01){
				
				write("------衝突検知---------");
				float x1<-move_vector.x;
				float y1<-move_vector.y;
				
				//位置が高いほうが上へよける
				if(self.bicycle_point.y<a_bicycle.bicycle_point.y){	//自分が上の時
					write("私が上");
					if(self.move_vector.x>0){ //yは負
						//左へ
						write("左に回避1"+{y1,-x1}*0.1);
						return {y1,-x1}*1;
					}else{
						//右へ
						write("右に回避1"+{-y1,x1}*0.1);
						return {-y1,x1}*1;
					}
				}else{	//自分が下の時yは正
				write("私がした");
					if(self.move_vector.x>0){
						//右へ
						write("右に回避2"+{-y1,x1}*0.1);
						return {-y1,x1}*1;
					}else{
						//左へ
						write("左に回避2"+{y1,-x1}*0.1);
						return {y1,-x1}*1;
					}
				}
	
				}

		}else{
			return {0,0};
		}
	}
	
	
	//消去
	action check_finish{
		use_road<-one_of(road where(self overlaps each));
		bool is_arrive<-overlaps(self.shape,self.target_point);
		write("目的地に到着した？"+is_arrive);
//		use_road_point<-use_road.shape.points;

		if(is_arrive){
			write("###############到着までにかかった時間"+(time-self.spawn_time));
			
			dead_list<-dead_list+(time-self.spawn_time);
			arrive_sum<-arrive_sum+(time-self.spawn_time);
			arrive_num<-arrive_num+1;
			
			}
//		}else if(use_road=nil and (50.0<self.bicycle_point.x and self.bicycle_point.x<70.0)){
//			dead_list<-dead_list+(time-self.spawn_time);
//			arrive_sum<-arrive_sum+(time-self.spawn_time);
//			arrive_num<-arrive_num+1;
//		}
		if (use_road=nil or is_arrive){
			write("最終地点:"+self.bicycle_point);
			do die;
		}
	}
	
	//移動
	action move{
	
		//力をm/sに変換
		write("目標への引力:"+self.gra_p+"m/s");
		write("自転車から受ける斥力"+self.agent_p+"m/s");
		write("道路から受ける斥力"+self.road_p+"m/s");	
		write("アシストの力"+self.as_p+"m/s");
		write("現在の移動速度:"+self.move_vector*(1/step)+"m/s");
		write("時速:"+norm(self.move_vector*(1/step))*(3600/1000)+"km/h");

		//引力
		self.gra_p<-update_gravity();
		//斥力
		self.agent_p<-add_repulsion();
		//道路から受ける斥力
		self.road_p<-add_road_repulsion();
	
		
		self.move_vector<-self.move_vector+(self.gra_p+self.agent_p+self.road_p+self.as_p)*step;
//		write("回避以前のmove:"+move_vector);
//		write("衝突回避:"+repulsion_assist());
//		move_vector<-move_vector+repulsion_assist()*step;
//		write("以後のmove:"+move_vector);
		//1m/sを0.1m/sに変換
//		move_vector<-move_vector*0.1;
//		write("move_vector:"+move_vector);
//		write("エージェントの速度:"+norm(move_vector)*(1/step)+"m/s");
		bicycle_point<-bicycle_point+move_vector;
		shape<-polygon([
			bicycle_point + {-bicycle_length/2, -bicycle_width/2},
		    bicycle_point + {bicycle_length/2, -bicycle_width/2},
		    bicycle_point + {bicycle_length/2, bicycle_width/2},
		    bicycle_point + {-bicycle_length/2, bicycle_width/2}
		]);
	}
	
	
	
	reflex move_action{
		write("-----ここから-----"+self.color);
		do check_finish;
		do move;
		write("self:場所"+self.bicycle_point);
		write("生まれた時間:"+self.spawn_time);
		write("*****現在の時刻******"+time);
		write("---------ここまで---------"+self.color);
		write("到着リスト"+dead_list);
		if(arrive_num>0 ){
		write("合計時間"+arrive_sum);
		write("平均時間:"+arrive_sum/arrive_num);
		}
	}
	

	aspect base{
		draw shape color:self.color at:bicycle_point;
	}
}


# Copyright TAK2

require 'sketchup.rb'

class GrowStructures

def initialize
	@ip = Sketchup::InputPoint.new
    reset
end

def reset
	@ip.clear
	@pt1 = Geom::Point3d.new
	@pt2 = Geom::Point3d.new
    @state = 0
    model = Sketchup.active_model
    @selection = model.selection
    @selection.clear
	Sketchup::set_status_text TST_common.langconv( "Select 1st Structure" )
end

def activate
	self.reset
end
def get_topface( cform )
	cform.entities.each{|ce|
		if ce.kind_of? Sketchup::Face
			return ce if ce.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_TOP"
		end
	}
	return nil
end
def get_bottomface( cform )
	cform.entities.each{|ce|
		if ce.kind_of? Sketchup::Face
			return ce if ce.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_BOTTOM"
		end
	}
	return nil
end
def get_startface( cform )
	cform.entities.each{|ce|
		if ce.kind_of? Sketchup::Face
			return ce if ce.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_START"
		end
	}
	return nil
end
def get_endface( cform )
	cform.entities.each{|ce|
		if ce.kind_of? Sketchup::Face
			return ce if ce.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_END"
		end
	}
	return nil
end
def extend2_start(view)
	extend_form2( @ce , @ps1 , @ce2 , @ps2)
	view.invalidate
end

def intersect_onface( line , polypts )
	plane = Geom.fit_plane_to_points polypts[0],polypts[1],polypts[2]
	pt = Geom.intersect_line_plane(line, plane)
	return nil if pt == nil
	#poly = face.outer_loop.vertices.map{|e| e.position }
	return pt if Geom.point_in_polygon_2D( pt, polypts , true ) == true
	return nil
end

def extend_form2( cform1 , ps1 , cform2 , ps2 )
#@ce is current form 
#@tf1 = @ip.transformation
#@ps1 = @ip.position
#@fc2 is extendto face
#@tf2 = @ip.transformation
#線形材の軸方向が平行な場合無駄なので終了する
#線形材の幅を取り出す（Y方向が幅なのでheightで取り出すことになる
@tf1 = cform1.transformation
@tf2 = cform2.transformation
clickpt_t = ps1.transform( @tf1.inverse )#cform1座標内でのクリックした点の座標
cform1 = cform1.definition if cform1.kind_of? Sketchup::ComponentInstance
cform2 = cform2.definition if cform2.kind_of? Sketchup::ComponentInstance
#まず　構造フォームの開始面と終了面を取り出す
fc_start1 = get_bottomface( cform1 )
fc_end1 = get_topface( cform1 )
fc_start2 = get_startface( cform2 )
fc_end2 = get_endface( cform2 )
#xvec1はペアレントの座標のベクトル
xvec1 = Geom::Vector3d.new(1,0,0).transform(@tf1)
zvec1 = Geom::Vector3d.new(0,0,1).transform(@tf1)
#xvec2 = Geom::Vector3d.new(1,0,0).transform(@tf2)
#return if xvec1.parallel?(xvec2)

@xmin2 = fc_start2.bounds.min.x
@xmax2 = fc_end2.bounds.max.x
@ymin2 = fc_start2.bounds.min.y
@ymax2 = fc_end2.bounds.max.y
@zmin2 = fc_start2.bounds.min.z
@zmax2 = fc_end2.bounds.max.z

#cform2との交点を求める
#cform2のバウンディングボックスの６面を取り出す
cfbb2 = []
cfbb2[0] = [ [ @xmin2 , @ymin2 , @zmin2 ] , [ @xmin2 , @ymax2 , @zmin2 ] , [ @xmin2 , @ymax2 , @zmax2 ] , [ @xmin2 , @ymin2 , @zmax2 ] ]
cfbb2[1] = [ [ @xmax2 , @ymin2 , @zmin2 ] , [ @xmax2 , @ymax2 , @zmin2 ] , [ @xmax2 , @ymax2 , @zmax2 ] , [ @xmax2 , @ymin2 , @zmax2 ] ]
cfbb2[2] = [ [ @xmin2 , @ymin2 , @zmin2 ] , [ @xmax2 , @ymin2 , @zmin2 ] , [ @xmax2 , @ymin2 , @zmax2 ] , [ @xmin2 , @ymin2 , @zmax2 ] ]
cfbb2[3] = [ [ @xmin2 , @ymax2 , @zmin2 ] , [ @xmax2 , @ymax2 , @zmin2 ] , [ @xmax2 , @ymax2 , @zmax2 ] , [ @xmin2 , @ymax2 , @zmax2 ] ]
cfbb2[4] = [ [ @xmin2 , @ymin2 , @zmin2 ] , [ @xmax2 , @ymin2 , @zmin2 ] , [ @xmax2 , @ymax2 , @zmin2 ] , [ @xmin2 , @ymax2 , @zmin2 ] ]
cfbb2[5] = [ [ @xmin2 , @ymin2 , @zmax2 ] , [ @xmax2 , @ymin2 , @zmax2 ] , [ @xmax2 , @ymax2 , @zmax2 ] , [ @xmin2 , @ymax2 , @zmax2 ] ]

ipts1 = []
ipl_index = []
cnt = 0
cnt2 = 0
tvts = []
tbb = fc_start1.bounds
fc_start1.vertices.each{|vt1| tvts.push vt1.position }
#fc_start1の判定の精度を上げる。
cnt3 = 0
tvts2 = []
(0..2000).each{|tempcount|
	ttpt = (0..2).map{|tempcount2| (tbb.max[tempcount2] - tbb.min[tempcount2] ) * rand + tbb.min[tempcount2] }
	ttpt2 = ttpt.project_to_plane( fc_start1.plane )
	if Geom.point_in_polygon_2D( ttpt2 , tvts, true )
		tvts2.push ttpt2
		cnt3 += 1
	end
	break if cnt3 > 50
}
tvts2.each{|tvt2| tvts.push tvt2 }
#tvts.push tbb.center
#tvts.push [ tbb.center.x , tbb.min.y , tbb.center.z ]
#tvts.push [ tbb.center.x , tbb.max.y , tbb.center.z ]
#tvts.push [ tbb.center.x , tbb.center.y , tbb.min.z ]
#tvts.push [ tbb.center.x , tbb.center.y , tbb.max.z ]

tvts.each{|pt1|
	#pt1 = vt1.position
	pt1.x = clickpt_t.x#クリックした点の座標からの測定
	pt1t = pt1.transform(@tf1)#ペアレント座標での座標
	line1 = [ pt1t , zvec1 ]#ペアレント座標での線
	dist = 0.0
	cnt2 = 0
	chk = false
	#各バウディング面ごとに判定
	#面のインデックスごとに一番近い交点を判定
	cfbb2.each{|polypts2|
		ipt = intersect_onface( line1 , polypts2.map{|pt2| pt2.transform(@tf2) } )
		if ipt != nil
			if dist > pt1t.distance(ipt) or chk == false
				#それぞれの面上に載る交点で近いものを選別する
				chk =true
				dist = pt1t.distance(ipt)
				ipts1[cnt] = ipt
				ipl_index[cnt] = cnt2
#				UI.messagebox "#{cnt2}"
			end
		end
		cnt2 += 1
	}
	cnt += 1
}
#UI.messagebox "1"
#もっとも交点の多かった平面を交差判定用の平面として定義する
cfsize = cfbb2.size - 1
itemcount = 0
polypts = []
(0..cfsize).each{|cnt|
	if itemcount < ipl_index.select{|i| i == cnt }.size
		itemcount = ipl_index.select{|i| i == cnt }.size
		polypts = cfbb2[cnt]
		@plane2 = Geom.fit_plane_to_points polypts[0].transform(@tf2),polypts[1].transform(@tf2),polypts[2].transform(@tf2)
#		UI.messagebox "select plane is #{cnt}"
	end
}
return if @plane2 == nil
#UI.messagebox "2"
#開始面、終了面、クリック点からの延長線を定義
	spt = fc_start1.vertices[0].position.transform(@tf1)
	ept = fc_end1.vertices[0].position.transform(@tf1)
	ppt = ps1
	sline = [ spt , zvec1 ]
	eline = [ ept , zvec1 ]
	pline = [ ppt , zvec1 ]

#それぞれの交点を求める
	ipt_s = Geom.intersect_line_plane(sline, @plane2)
	ipt_e = Geom.intersect_line_plane(eline, @plane2)
	ipt_p = Geom.intersect_line_plane(pline, @plane2)

	return if ipt_s == nil or ipt_e == nil or ipt_p == nil
#それぞれの延長距離
	dist_s = ipt_s.distance( spt )
	dist_e = ipt_e.distance( ept )
	dist_p = ipt_p.distance( ppt )
	vec_s = spt.vector_to( ipt_s )
	vec_e = ept.vector_to( ipt_e )
	vec_p = ppt.vector_to( ipt_p )
#fc1に移動すべき面を代入する
	modpos = "start"
#既に延長先に接している場合
	if vec_s.length == 0
		fc1 = fc_start1
	elsif vec_e.length == 0
		fc1 = fc_end1
		modpos = "end"
	elsif vec_s.samedirection?( vec_p ) and vec_e.samedirection?( vec_p )
		if dist_s < dist_e
			fc1 = fc_start1
		else
			fc1 = fc_end1
			modpos = "end"
		end
	elsif vec_s.samedirection?( vec_p )
		fc1 = fc_end1
		modpos = "end"
	else
		fc1 = fc_start1
	end
	vec_arr = []
	vt_arr = []
	
	grp = fc1.parent
#UI.messagebox "3"
	#pt22 = @fc2.vertices[0].position.transform( @tf1.inverse * @tf2 )
	#vec22 = @fc2.normal.transform( @tf1.inverse * @tf2 )
	#plane22 = Geom.fit_plane_to_points( bsptA.transform( @tf1.inverse ) , bsptB.transform( @tf1.inverse ) , bsptC.transform( @tf1.inverse ) )#[ pt22 , vec22 ]
#fc1の属するグループの座標系の中で交点計算をしないで、交点を逆算する
	Sketchup.active_model.start_operation TST_common.langconv( "Extend Trim Structure" )
	fc1.edges.each{|ed|
		ed.explode_curve if ed.curve
	}
	fc1.vertices.each{|vt|
		if vt.curve_interior?
		else
			vtp = vt.position.transform( @tf1 )
			vline = [ vtp ,  zvec1 ]
			ipt_v = Geom.intersect_line_plane( vline, @plane2 )
			vec_v = vtp.vector_to( ipt_v )
			#if vt.curve_interior?
			#	grp.entities.add_edges [ vtp ,ipt_v ]
			#end
			if vec_v.length != 0
				vt_arr.push vt
				vec_arr.push vec_v.transform( @tf1.inverse )
			end
		end
	}

	return if vt_arr == nil
	return if vt_arr.size == 0
	grp.entities.transform_by_vectors vt_arr , vec_arr

	Sketchup.active_model.commit_operation

end
def increment_state(view)
    @state += 1
    case @state
    when 1
        	Sketchup::set_status_text TST_common.langconv( "Select ２nd structure" )
    when 2
        self.extend2_start(view)
        self.reset
    end
end

def onMouseMove(flags, x, y, view)

end

def onLButtonDown(flags, x, y, view)
	@ip.pick(view,x,y)
	face = @ip.face
	edge = @ip.edge

	ph = view.pick_helper
	ph.do_pick x,y
	pe = ph.best_picked

	model = Sketchup.active_model
	#現在作業中のモデル
	cmodel = model.active_entities.parent
	case @state
	when 0
		if pe.kind_of? Sketchup::ComponentInstance or pe.kind_of? Sketchup::Group
			if pe.get_attribute( "BEAM_SPECS","CURVE" ) == false
				@ce = pe.make_unique
				if @ce.parent.entityID == cmodel.entityID
					@tf1 = @ip.transformation
					@ps1 = @ip.position
					@selection.add @ce
					self.increment_state(view)
				else
					@ce = nil
				end
			end
		end
	when 1
		if pe.kind_of? Sketchup::ComponentInstance or pe.kind_of? Sketchup::Group
			if pe.get_attribute( "BEAM_SPECS","CURVE" ) == false
				@ce2 = pe.make_unique
				if @ce2.parent.entityID == cmodel.entityID
					@tf2 = @ip.transformation
					@ps2 = @ip.position
					@selection.add @ce2
					self.increment_state(view)
				else
					@ce2 = nil
				end
			end
		end
	end
end
end # of class


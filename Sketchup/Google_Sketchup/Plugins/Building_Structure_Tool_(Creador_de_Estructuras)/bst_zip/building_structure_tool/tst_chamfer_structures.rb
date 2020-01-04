#Chamfer_structures.
# Copyright TAK2

require 'sketchup.rb'

class ChamferStructures

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
def get_entitiesbounds( ents )
	ents2 = ents.find_all{|e| e.kind_of? Sketchup::Drawingelement }
	ptmax = [0,0,0]
	ptmin = [0,0,0]
	chk = false
	ents2.each{|e|
		if chk == false
			ptmax = e.bounds.max
			ptmin = e.bounds.min
			chk = true
		else
			ptmax.x = e.bounds.max.x if ptmax.x < e.bounds.max.x
			ptmax.y = e.bounds.max.y if ptmax.y < e.bounds.max.y
			ptmax.z = e.bounds.max.z if ptmax.z < e.bounds.max.z
			
			ptmin.x = e.bounds.min.x if ptmin.x > e.bounds.min.x
			ptmin.y = e.bounds.min.y if ptmin.y > e.bounds.min.y
			ptmin.z = e.bounds.min.z if ptmin.z > e.bounds.min.z
		end
	}
	return ptmax , ptmin
end
def get_topface( cform )
	fcs = []
	cform.entities.each{|ce|
		if ce.kind_of? Sketchup::Face
			if ce.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_TOP" and ce.edges.find_all{|ed| ed.get_attribute( "BEAMS_FACES", "LOCATION" ) == "ED_OUTLINE" } != []
				fcs.push ce
			end
		end
	}
	if fcs == []
		return nil
	else
		return fcs
	end
end
def get_bottomface( cform )
	fcs = []
	cform.entities.each{|ce|
		if ce.kind_of? Sketchup::Face
			if ce.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_BOTTOM" and ce.edges.find_all{|ed| ed.get_attribute( "BEAMS_FACES", "LOCATION" ) == "ED_OUTLINE" } != []
				fcs.push ce
			end
		end
	}
	if fcs == []
		return nil
	else
		return fcs
	end
end
def get_startface( cform )
	fcs = []
	cform.entities.each{|ce|
		if ce.kind_of? Sketchup::Face
			if ce.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_START" and ce.edges.find_all{|ed| ed.get_attribute( "BEAMS_FACES", "LOCATION" ) == "ED_OUTLINE" } != []
				fcs.push ce
			end
		end
	}
	if fcs == []
		return nil
	else
		return fcs
	end
end
def get_endface( cform )
	fcs = []
	cform.entities.each{|ce|
		if ce.kind_of? Sketchup::Face
			if ce.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_END" and ce.edges.find_all{|ed| ed.get_attribute( "BEAMS_FACES", "LOCATION" ) == "ED_OUTLINE" } != []
				fcs.push ce
			end
		end
	}
	if fcs == []
		return nil
	else
		return fcs
	end
end
def chamfer_start(view)
	chamfer_form_MS( @ce , @ps1 , @ce2 , @ps2)
	#chamfer_form_MS( @ce2 , @ps2 , @ce , @ps1)
	view.invalidate
end
def chamfer_form_MS( cform1 , ps1 , cform2 , ps2 )
	if cform1.get_attribute( "BEAM_SPECS","CLASS" ) == "MWALL" and cform2.get_attribute( "BEAM_SPECS","CLASS" ) == "MWALL"
		
		attlist1 = cform1.entities.collect{|e| e.get_attribute("BEAM_SPECS","HUGO") }.delete_if{|d| d == nil }.sort
		attlist2 = cform2.entities.collect{|e| e.get_attribute("BEAM_SPECS","HUGO")}.delete_if{|d| d == nil }.sort
		if attlist1.size == attlist1.uniq.size and attlist2.size == attlist2.uniq.size and attlist1 == attlist2
			attlist1.each{|att|
				ce = cform1.entities.find{|e| e.get_attribute("BEAM_SPECS","HUGO") == att }
				ce.make_unique
				ce2 = cform2.entities.find{|e| e.get_attribute("BEAM_SPECS","HUGO") == att }
				ce2.make_unique
				p att
				chamfer_form( ce , ps1 , ce2 , ps2 , cform1.transformation , cform2.transformation )
				chamfer_form( ce2 , ps2 , ce , ps1 , cform2.transformation , cform1.transformation )
			}
		end
	else
		chamfer_form( cform1, ps1 , cform2 , ps2)
		chamfer_form( cform2 , ps2 , cform1 , ps1)
	end
end
def chamfer_form( cform1 , ps1 , cform2 , ps2 , ptf1 = Geom::Transformation.new( [0,0,0] ) , ptf2 = Geom::Transformation.new( [0,0,0] ) )
#@ce is current form 
#@tf1 = @ip.transformation
#@ps1 = @ip.position
#@fc2 is extendto face
#@tf2 = @ip.transformation
#線形材の軸方向が平行な場合無駄なので終了する
#線形材の幅を取り出す（Y方向が幅なのでheightで取り出すことになる
@tf1 = ptf1 * cform1.transformation
@tf2 = ptf2 * cform2.transformation
xvec1 = Geom::Vector3d.new(1,0,0).transform(@tf1)
xvec2 = Geom::Vector3d.new(1,0,0).transform(@tf2)
zvec1 = Geom::Vector3d.new(0,0,1).transform(@tf1)
return if xvec1.parallel?(xvec2)

cform1 = cform1.definition if cform1.kind_of? Sketchup::ComponentInstance
cform2 = cform2.definition if cform2.kind_of? Sketchup::ComponentInstance
gr1bbmax , gr1bbmin = get_entitiesbounds( cform1.entities )
gr2bbmax , gr2bbmin = get_entitiesbounds( cform2.entities )
@amax1 = gr1bbmax.y
@amin1 = gr1bbmin.y
@amax2 = gr2bbmax.y
@amin2 = gr2bbmin.y

minvec = Geom::Vector3d.new(0,-1,0)
maxvec = Geom::Vector3d.new(0,1,0)
amin_plane1 = [ [0,@amin1,0].transform( @tf1 ) , minvec.transform( @tf1 ) ]
amax_plane1 = [ [0,@amax1,0].transform( @tf1 ) , maxvec.transform( @tf1 ) ]
amin_plane2 = [ [0,@amin2,0].transform( @tf2 ) , minvec.transform( @tf2 ) ]
amax_plane2 = [ [0,@amax2,0].transform( @tf2 ) , maxvec.transform( @tf2 ) ]
#クリックした点から近いほう遠いほうの判定で内外を決める
dist_amin2 = ps1.distance_to_plane( amin_plane2 )
dist_amax2 = ps1.distance_to_plane( amax_plane2 )
if dist_amin2 > dist_amax2
	plane_in2 = amax_plane2
	plane_out2 = amin_plane2
else
	plane_in2 = amin_plane2
	plane_out2 = amax_plane2
end
dist_amin1 = ps2.distance_to_plane( amin_plane1 )
dist_amax1 = ps2.distance_to_plane( amax_plane1 )
if dist_amin1 > dist_amax1
	plane_in1 = amax_plane1
	plane_out1 = amin_plane1
else
	plane_in1 = amin_plane1
	plane_out1 = amax_plane1
end
#まず　構造フォームの開始面と終了面を取り出す
fc_start = get_startface( cform1 )
fc_end = get_endface( cform1 )
inline = Geom.intersect_plane_plane( plane_in1 , plane_in2 )
outline = Geom.intersect_plane_plane( plane_out1 , plane_out2 )
#cform1の最上面と交点をさがす
#tpt = cform1.local_bounds.max.transform( @tf1 )
tpt = fc_end[0].bounds.max.transform( @tf1 )
bsptA = Geom.intersect_line_plane( inline , [ tpt , zvec1] )
bsptB = Geom.intersect_line_plane( outline , [ tpt , zvec1] )
#tpt = cform1.local_bounds.min.transform( @tf1 )
tpt = fc_start[0].bounds.min.transform( @tf1 )
bsptC = Geom.intersect_line_plane( inline , [ tpt , zvec1] )
plane2 = Geom.fit_plane_to_points( bsptA , bsptB , bsptC )


	xvec = Geom::Vector3d.new(1,0,0)
#開始面、終了面、クリック点からの延長線を定義
	spt = fc_start[0].vertices[0].position.transform(@tf1)
	ept = fc_end[0].vertices[0].position.transform(@tf1)
	ppt = ps1
	sline = [ spt , xvec.transform(@tf1) ]
	eline = [ ept , xvec.transform(@tf1) ]
	pline = [ ppt , xvec.transform(@tf1) ]

#それぞれの交点を求める
	ipt_s = Geom.intersect_line_plane(sline, plane2)
	ipt_e = Geom.intersect_line_plane(eline, plane2)
	ipt_p = Geom.intersect_line_plane(pline, plane2)
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
		fc1 = fc_start
	elsif vec_e.length == 0
		fc1 = fc_end
		modpos = "end"
	elsif vec_p.length == 0
		fc1 = fc_end
		modpos = "end"
	elsif vec_s.samedirection?( vec_p ) and vec_e.samedirection?( vec_p )
		if dist_s < dist_e
			fc1 = fc_start
		else
			fc1 = fc_end
			modpos = "end"
		end
	elsif vec_s.samedirection?( vec_p )
		fc1 = fc_end
		modpos = "end"
	else
		fc1 = fc_start
	end
	vec_arr = []
	vt_arr = []
	
	grp = fc1[0].parent
	
	#pt22 = @fc2.vertices[0].position.transform( @tf1.inverse * @tf2 )
	#vec22 = @fc2.normal.transform( @tf1.inverse * @tf2 )
	plane22 = Geom.fit_plane_to_points( bsptA.transform( @tf1.inverse ) , bsptB.transform( @tf1.inverse ) , bsptC.transform( @tf1.inverse ) )#[ pt22 , vec22 ]
#fc1の属するグループの座標系の中で交点計算をする
	Sketchup.active_model.start_operation TST_common.langconv( "Combine with Structure" )
	fc1.each{|fca|
		fca.edges.each{|ed|
			ed.explode_curve if ed.curve
		}
	}
	fc1.each{|fca|
		fca.vertices.each{|vt|
			if vt.curve_interior?
			else
				vtp = vt.position
				#ed1 = vt.edges.find_all{|ed| ed.faces.find_all{|fc| fc == fc1 } == [] }
				ed1 = vt.edges.find_all{|ed| ed.line[1].length != 0 }.find_all{|ed| ( fca.normal.perpendicular?(ed.line[1]) == false ) and ( ed.faces.find_all{|fc| fc == fca } == [] ) }
				vline = [ vtp ,  xvec ]
				if ed1 != []
					vline = [ ed1[0].line[0] , ed1[0].line[1] ]
				end

				#vtp = vt.position
				#vline = [ vtp ,  xvec ]
				
				ipt_v = Geom.intersect_line_plane( vline, plane22 )
				vec_v = vtp.vector_to( ipt_v )
				#if vt.curve_interior?
				#	grp.entities.add_edges [ vtp ,ipt_v ]
				#end
				if vt_arr.find_all{|vta| vta == vt } == []
				if vec_v.length != 0
					vt_arr.push vt
					vec_arr.push vec_v
				end
				end

			end
		}
	}

	return if vt_arr == nil
	return if vt_arr.size == 0
	grp.entities.transform_by_vectors vt_arr , vec_arr
#構築線も修正する
	grp.entities.each{|e|
		if e.typename == "ConstructionLine"
			if e.direction.parallel?( xvec )
				cpt = e.start
				cline = [ cpt , xvec ]
				ipt_c = Geom.intersect_line_plane( cline, plane22 )
				if modpos == "start"
					e.start = ipt_c
				else
					e.end = ipt_c
				end
			end
		end
	}
	Sketchup.active_model.commit_operation

end
def increment_state(view)
    @state += 1
    case @state
    when 1
        	Sketchup::set_status_text TST_common.langconv( "Select ２nd structure" )
    when 2
        self.chamfer_start(view)
        self.reset
    end
end

def onMouseMove(flags, x, y, view)

end

def onLButtonDown(flags, x, y, view)
	@ip.pick(view,x,y)
	ph = view.pick_helper
	ph.do_pick x,y
	pe = ph.best_picked

	model = Sketchup.active_model
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


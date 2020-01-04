#Extend_Trim_structures.　（ExtendStructures(Face)）
# Copyright TAK2

#同じ面を選択した場合、距離の変更
require 'sketchup.rb'

class GrowStructureFace

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
	@ces = []
	if @selection.empty? == false
		@ces = @selection.find_all{|se| se.kind_of? Sketchup::ComponentInstance or se.kind_of? Sketchup::Group }
		increment_state
	end

	Sketchup::set_status_text TST_common.langconv( "Select 1st Face" )

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
def grow_form2(view)
#@ce is current form 
#@tf1 = @ip.transformation
#@ps1 = @ip.position
#@fc2 is extendto face
#@tf2 = @ip.transformation
#まず　構造フォームの開始面と終了面を取り出す
	cform1 = @ce
	cform1 = @ce.definition if @ce.kind_of? Sketchup::ComponentInstance
	bclass = @ce.get_attribute("BEAM_SPECS","CLASS")
	if bclass[/COLUMN/]
		fc_start = get_startface( cform1 )
		fc_end = get_endface( cform1 )
		zvec = Geom::Vector3d.new(1,0,0)
		#UI.messagebox "COLUMN"
	else
		fc_start = get_bottomface( cform1 )
		fc_end = get_topface( cform1 )
		zvec = Geom::Vector3d.new(0,0,1)
	end
	return nil if fc_start == nil or fc_end == nil
	
	xvec = Geom::Vector3d.new(1,0,0)
	#zvec = Geom::Vector3d.new(0,0,1)
#開始面、終了面、クリック点からの延長線を定義
	spt = fc_start[0].vertices[0].position.transform(@tf1)
	ept = fc_end[0].vertices[0].position.transform(@tf1)

	ppt = @ps1
	sline = [ spt , zvec.transform(@tf1) ]
	eline = [ ept , zvec.transform(@tf1) ]
	pline = [ ppt , zvec.transform(@tf1) ]
#延長先の面のプレーンを定義
	plane2 = @fc2.plane
	plane2 = [@fc2.vertices[0].position.transform(@tf2),@fc2.normal.transform(@tf2)] if @tf2 != nil
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
	
	#grp = fc1.parent
	
	pt22 = @fc2.vertices[0].position.transform( @tf1.inverse * @tf2 )
	vec22 = @fc2.normal.transform( @tf1.inverse * @tf2 )
	plane22 = [ pt22 , vec22 ]
#fc1の属するグループの座標系の中で交点計算をする
	Sketchup.active_model.start_operation TST_common.langconv( "Extend Trim Structure" )
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
				ed1 = vt.edges.find_all{|ed| ed.line[1].length != 0 }.find_all{|ed| ( fca.normal.perpendicular?(ed.line[1]) == false ) and ( ed.faces.find_all{|fc| fc == fca } == [] ) }

				vline = [ vtp ,  zvec ]
				vline = ed1[0].line if ed1 != []
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
	cform1.entities.transform_by_vectors vt_arr , vec_arr

	Sketchup.active_model.commit_operation
	view.invalidate
end
def increment_state( view = Sketchup.active_model.active_view )
    @state += 1
    case @state
    when 1
        	Sketchup::set_status_text TST_common.langconv( "select face extended to" )
    when 2
		if @ces != []
			@ces.each{|ce|
				@ce = ce
				@ps1 = @ce.bounds.center
				@tf1 = @ce.transformation
				#UI.messagebox @ce
				self.grow_form2(view)
			}
			@ces = nil
			@selection.clear
		else
			if @fc1 == @fc2
				#self.height_byDistance(view, @fc1 , @ed1)
			else
				self.grow_form2(view)
				@selection.clear
			end
		end
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
		if face != nil
			@fc2 = nil
			@tf2 = nil
			if @ip.face
				@fc2 = @ip.face
				@tf2 = @ip.transformation
				if @fc2.parent.kind_of? Sketchup::ComponentDefinition
					if @fc2.parent.instances[0].kind_of? Sketchup::Group
						if @ces == nil
							if @fc2.parent.instances[0].entityID == @ce.entityID
								@fc2 = nil
								return
							end
						end
					end
				end
			end
			self.increment_state(view) if @fc2
		end
	end
end
end # of class


# Copyright 2011, TAK2HATA (Moso Yakionigiri)


# Name :			Click2SLAB.rb
# Description :		Create Filled area with click blank space
# Authors :			TAK2HATA

require 'sketchup.rb'

class Click2SLAB
	def initialize
		@pflist = []
		pflist_path = readProfiles( "" )
		if pflist_path == false
			@pflist.push "S15,S-150,,,"
			pflist_path = "Sample List"
		end
		defaults = Sketchup.read_default("Structure Tool", "SLAB:params")
		@slab_spec   = "S1,S-150"
		@slab_toplevel = 0.mm
		@slab_hitlevel = 0.mm
		@slab_hitrange = 20000.mm

        if defaults
            @results = eval( defaults )
			@slab_spec   = @results[0] if @results.size > 0
			@slab_toplevel = @results[1].to_l if @results.size > 1
			@slab_hitlevel = @results[2].to_l if @results.size > 2
			@slab_hitrange = @results[3].to_l if @results.size > 3
        end
		#p "@slab_spec#{@slab_spec}"

		pflist2 = []
		(@pflist.size).times{|i|
			pf = @pflist[i]
			parr = split_csvline( @pflist[i] )
			if parr.size >= 4
				pflist2.push "#{i}:#{parr[0]}:#{parr[1]}"
			end
		}
		if @slab_spec == ""
			@slab_spec  = pflist2[0]
			#p "no default"
		elsif not @pflist.index( @slab_spec )
			@slab_spec   = pflist2[0]
			#p "not in array"
		else
			i = @pflist.index( @slab_spec )
			@slab_spec = pflist2[i]
			#p "in array"
		end
		
		prompts = ["SLAB SPEC:","TopLevel:","Click Level:","Click Range:" ]
		dropdowns = [ pflist2.join("|") ]
		defaults = [ @slab_spec, @slab_toplevel ,@slab_hitlevel ,@slab_hitrange ]
		@results = UI.inputbox prompts, defaults, dropdowns , "Create Area From Clicking"
		return if not @results
		@slab_spec   = @results[0] if @results.size > 0
		if @results.size > 0
			@slab_spec   = @pflist[ split_csvline( @results[0] )[0].to_i ]
			#p "@slab_spec#{@slab_spec}"
			@results[0] = @slab_spec
		end
		@slab_toplevel = @results[1].to_l if @results.size > 1
		@slab_hitlevel = @results[2].to_l if @results.size > 2
		@slab_hitrange = @results[3].to_l if @results.size > 3
		Sketchup.write_default("Structure Tool", "SLAB:params", @results.inspect.gsub( 34.chr , "'"))
		slabspecs = split_csvline( @slab_spec )
		@hugo = slabspecs[0]
		@profile = slabspecs[1]
		@thickness = @profile.split("-")[1].to_l
		@mat = slabspecs[3]
		@fmat = slabspecs[5]
		@bmat = slabspecs[6]
		@ip = Sketchup::InputPoint.new
		reset
	end
		def add_new_material( mname = "" )
			mats = Sketchup.active_model.materials
			if mats[ mname ] == nil
				mat = mats.add mname
				mat.color = "white"
			else
				mat = mats[ mname ]
			end
			return mat
		end	
	def readProfiles( utext = "" )
		@pflist = []
		pflistall = []
		pflist_path = Sketchup.read_default("Structure Tool", "pflist_path")
		pflist_path_sjis = pflist_path
		if $kconvloaded == true and pflist_path
			pflist_path_sjis = Kconv.tosjis( pflist_path )
		end
		if pflist_path_sjis and FileTest.exist?( pflist_path_sjis )
			pflist_path = pflist_path_sjis
		end
		if pflist_path == nil or pflist_path == ""
			pflist_path = Sketchup.find_support_file "default_pflist.csv", "Plugins/building_structure_tool/"
		elsif not FileTest.exist?( pflist_path )
			UI.messagebox "#{File.basename(pflist_path )} is not Exists.So Read from Default"
			pflist_path = Sketchup.find_support_file "default_pflist.csv", "Plugins/building_structure_tool/"
		end
		if not FileTest.exist?( pflist_path )
			UI.messagebox "Error:#{File.basename(pflist_path )} is not Exists"
			return false
		end
		model = Sketchup.active_model

		Sketchup.write_default("Structure Tool", "pflist_path" , pflist_path )
		@bclass = "SLAB"
		pf_file=File.open( pflist_path ,"r")
		section = false
		clss = "ALL"
		pf_file.each{|line_p|
			line = line_p#%(#{line_p})
			line.chomp!
			if line[/^\#.*/]
				#clss = line.gsub(/[\#]/,"").split(",")[0]
				splt = split_csvline( line.gsub(/[\#]/,"") )
				clss = splt[0]
				#p split_csvline( line.gsub(/[\#]/,"") ).join( "||" )
				if splt[0].downcase == "settings" and splt.size >= 3
					if splt[2] == "inch"
						@units = "inch"
					else
						@units = "mm"
					end
				end
				if clss == @bclass
					section = true
				elsif @bclass == "ALL"
					section = true
				else
					section = false
				end
			elsif section == true
				if line[/.*\,.*/]
					cnt = line.count(",")
					line = line + ( "," * ( 9 - cnt )) if cnt < 9
					pflistall.push line + "," + clss
					#line1 = line.split(",")[0]
					#line2 = line.split(",")[1]
					line1 = split_csvline( line )[0]
					line2 = split_csvline( line )[1]
					
					if line1.index( utext.downcase ) or line2.index( utext.downcase )
						@pflist.push line + "," + clss
					elsif line1.index( utext.upcase ) or line2.index( utext.upcase )
						@pflist.push line + "," + clss
					end
				end
			end
		}
		#############
		if @pflist.size == 0 && utext != ""
			@pflist = pflistall
			UI.messagebox TST_common.langconv( "Nothing Match.All list will appear" )
		end
		###############
		pf_file.close
		###############
		return pflist_path
	end
	def split_csvline( csvline )
		proxCamma = "separator"
		splt = []
		splt = csvline.split(34.chr)
		
		(splt.size).times{|i|
			splt[i].gsub!( "," , proxCamma ) if ( i % 2 ) == 1
		}
		jointxt = splt.join
		#p jointxt
		return [jointxt] if jointxt.index( "," ) == nil
		items = jointxt.split(",")
		
		
		items.collect!{|item| item.gsub( proxCamma , "," ) }
		#items.each{|item| p item }
		return items
	end
	def reset
		@ip.clear
		Sketchup::set_status_text "click to Create Filled Area"
		
	end

	def deactivate(view)
	    view.invalidate if @drawn
	end

	def activate
		self.reset
	end

	def onMouseMove(flags, x, y, view)
	end

	def set_current_point(x, y, view)
	end
	def createSlabFromFace( ofc , t = Geom::Transformation.new )
			model = Sketchup.active_model
			ents = model.active_entities

			elist = []
			#elist.push fc
			ofc.edges.each{|ed| elist.push ed } 
			fcgrp = ents.add_group( elist )
			#t = Geom::Transformation.translation( Geom::Vector3d.new( 0,0, ( @slab_toplevel - @slab_hitlevel ) ) )
			fcgrp.transform! t
			fcgrp.entities.find_all{|e| e.kind_of? Sketchup::Edge }.each{|e2| e2.find_faces }

			fcgrp.entities.find_all{|e| e.kind_of? Sketchup::Face}.each{|e2|
				e2.material = add_new_material( @fmat ) if @fmat != ""
				e2.back_material = add_new_material( @bmat ) if @bmat != ""
			}
			fcgrp.entities.find_all{|e| e.kind_of? Sketchup::Face}.each{|e2|
				e2.pushpull @thickness
			}
			fcgrp.name = "#{@hugo}|#{@profile}"
			fcgrp.set_attribute "BEAM_SPECS","CLASS","SLAB"
			fcgrp.set_attribute "BEAM_SPECS","HUGO",@hugo
			fcgrp.set_attribute "BEAM_SPECS","PROFILE",@profile
			fcgrp.set_attribute "BEAM_SPECS","MATERIAL",@mat
			fcgrp.set_attribute "BEAM_SPECS","FL",@slab_toplevel

	end
	def onLButtonDown(flags, x, y, view)
		@ip.pick(view, x, y)
		#return if @ip.face or @ip.edge
		pt = @ip.position.clone
		camera = view.camera
		line1 = [ pt , camera.eye ]
		plane1 = [ Geom::Point3d.new( 0,0,@slab_hitlevel ) ,  Geom::Vector3d.new( 0,0,1 ) ]
		intpt = Geom.intersect_line_plane(line1, plane1)
		return if intpt == nil
		model = Sketchup.active_model
		ents = model.active_entities

		if  @ip.edge or @ip.vertex
			return
		end
		if @ip.face
			ifc = @ip.face

			if ents.find_all{|e| e.entityID == ifc.entityID }.size >= 1
				if Sketchup.version.to_f >= 7
					Sketchup.active_model.start_operation "click to slab" , true
				else
					Sketchup.active_model.start_operation "click to slab"
				end
				#p "create from face"
				eds = ifc.edges
				createSlabFromFace( ifc )
				killist = []
				eds.each{|ed| killist.push ed if ed.faces.size <= 1 }
				killist.push ifc
				ents.erase_entities killist
				Sketchup.active_model.commit_operation
				reset
				return
			elsif camera.eye.distance( intpt ) >= camera.eye.distance( pt )
			
				reset
				return
			end
		end
		slab_hitlv = @slab_hitlevel
		dzs = [ 0 , -1.mm , 1.mm ]
		dzs.each{|dz|
			@slab_hitlevel = slab_hitlv + dz
			#p "dz:#{dz}"
			plane1 = [ Geom::Point3d.new( 0,0, @slab_hitlevel ) ,  Geom::Vector3d.new( 0,0,1 ) ]
			intpt = Geom.intersect_line_plane(line1, plane1)		
			chk = create_slab_withPT  intpt , plane1
			break if chk != false
		}
		@slab_hitlevel = slab_hitlv
		reset
	end

	def onCancel(flag, view)
		Sketchup.active_model.select_tool nil
	end

	def draw(view)

	end
	def create_slab_withPT(  intpt , plane1 )
		if Sketchup.version.to_f >= 7
			Sketchup.active_model.start_operation "click to slab" , true
		else
			Sketchup.active_model.start_operation "click to slab"
		end
		model = Sketchup.active_model
		ents = model.active_entities

		grp = ents.add_group
		rad = model.bounds.diagonal * 2.0
		cen = model.bounds.center.project_to_plane( plane1 )
		cen = intpt

		cir = grp.entities.add_ngon( cen , [ 0.0 , 0.0 , 1.0 ] , @slab_hitrange , 4 )
		grp.entities.add_face cir
		intgrp = ents.add_group
		inttr = intgrp.transformation

		model.active_entities.intersect_with( true , Geom::Transformation.new , intgrp  , inttr , false , grp  )
		#intgrp.entities.add_face( intgrp.entities.find_all{|e| e.kind_of? Sketchup::Edge } )
		intgrp.entities.find_all{|e| e.kind_of? Sketchup::Edge }.each{|e2| e2.find_faces }
		grp.entities.erase_entities grp.entities.find_all{|e| e.kind_of? Sketchup::Face }

		killist = []
		killist.push grp
		killist.push intgrp
		fcs = intgrp.entities.find_all{|e| e.kind_of? Sketchup::Face }
		if fcs.size > 0
			p "faces"
			fc2 = fcs.find_all{|fc| fc.classify_point( intpt ) == 1 }
			
			if fc2.size > 0
				#p "find classify point"
				#elist = []
				#elist.push fc
				#fc2[0].edges.each{|ed| elist.push ed } 
				#fcgrp = ents.add_group( elist )
				t = Geom::Transformation.translation( Geom::Vector3d.new( 0,0, ( @slab_toplevel - @slab_hitlevel ) ) )
				#fcgrp.transform! t
				#fcgrp.entities.find_all{|e| e.kind_of? Sketchup::Edge }.each{|e2| e2.find_faces }
				#ents.erase_entities killist
				#fcgrp.entities.find_all{|e| e.kind_of? Sketchup::Face}.each{|e2|
				#	e2.material = add_new_material( @fmat ) if @fmat != ""
				#	e2.back_material = add_new_material( @bmat ) if @bmat != ""
				#}
				#fcgrp.entities.find_all{|e| e.kind_of? Sketchup::Face}.each{|e2|
				#	e2.pushpull @thickness
				#}

				#fcgrp.name = "#{@hugo}|#{@profile}"
				#fcgrp.set_attribute "BEAM_SPECS","CLASS","SLAB"
				#fcgrp.set_attribute "BEAM_SPECS","HUGO",@hugo
				#fcgrp.set_attribute "BEAM_SPECS","PROFILE",@profile
				#fcgrp.set_attribute "BEAM_SPECS","MATERIAL",@mat
				#fcgrp.set_attribute "BEAM_SPECS","FL",@slab_toplevel
				createSlabFromFace fc2[0] , t
				ents.erase_entities killist
				Sketchup.active_model.commit_operation
				return true
			else
				#p "nothing"
				Sketchup.active_model.commit_operation
				Sketchup.undo
				return false
			end
		else
			Sketchup.active_model.commit_operation
			Sketchup.undo
			return false
		end
	end
end


unless( file_loaded?( File.basename(__FILE__) ) )
	UI.menu.add_item("Click to SLAB") { Sketchup.active_model.select_tool Click2SLAB.new }
end

file_loaded(File.basename(__FILE__))
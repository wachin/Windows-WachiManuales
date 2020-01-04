# Name:   beams
# Description:draw beams shapes from list in text file.
#v0.2:modified in 2011.01.26.
#v0.3:modified in 2011.09.19
#vo.4:modified in 2001.09.30.
#  add "Add New PROFILE" in menu.
#  toolbar is shown when sketchup starting in the next time.(optimization on MAC)
#v0.5:modified in 20011.11.13.
#  small changes.
#  improve wall tool. ESC key to STOP continus of wall.
#  improve slab tool.
#  small improve in coding.
#  toolbar and menu reduced.Replace toolbar with Webdialog tool box.
#( In this code ,the menu was only comment out.so delete # of that lines, it will rebirth.)
#  Add New Function."MultiWall" Create Multi Walls easy.This object is not able to use extend_to_structure.Others are able.
#  notes:Walls in MultiWall do not have same hugo each other.(if same hugo is used,Walls do not joint automaticaly.)

require 'sketchup.rb'
require 'building_structure_tool/tst_main.rb' ###TIG'd
require 'building_structure_tool/tst_extend_to_face.rb' ###TIG'd
require 'building_structure_tool/tst_extend_to_structure.rb' ###TIG'd
require 'building_structure_tool/tst_chamfer_structures.rb' ###TIG'd
require 'building_structure_tool/tst_grow_to_structure.rb' ###TIG'd
require 'building_structure_tool/tst_grow_to_face.rb' ###TIG'd
require 'building_structure_tool/tst_click_to_slab.rb'

if FileTest.exist?( File.join( File.dirname( File.expand_path(__FILE__) ), "Kconv.rb" ) ) and FileTest.exist?( File.join( File.dirname( File.expand_path(__FILE__) ), "nkf.so" ) )
	require 'Kconv.rb'
	$kconvloaded = true
else
	$kconvloaded = false
end
module TST_common
def select_langfile
	lang_dir = File.dirname( Sketchup.find_support_file "lang.txt", "Plugins/building_structure_tool/languages/" )
	lang_path=UI.openpanel(TST_common.langconv("Select Language File"),lang_dir,"*.txt")
	lang_path.gsub!(/\\/,"/")
	return false if lang_path == "" or lang_path == false
	Sketchup.write_default( "Structure Tool", "lang_path", lang_path )
	tst_get_langtxt
	UI.messagebox TST_common.langconv("The language convert will be effecvie after Sketchup restarted")
end
def tst_get_langtxt()
	lang_path = Sketchup.find_support_file "lang.txt", "Plugins/building_structure_tool/languages/"
	lang_path = Sketchup.read_default("Structure Tool", "lang_path" , lang_path )
	lang_path.gsub!(/\\/,"/")
	@tst_langhash = Hash.new
	return nil if not FileTest.exist?( lang_path )
	
	lang_file=File.new(lang_path,"r")##read mode
	lang_file.each{|line|
		if line != "" and line["\|"]
			splt = ( line.chomp ).split("\|")
			if splt[0] != "" and splt[1] != ""
				@tst_langhash[splt[0]] = splt[1]
			end
		end
	}
	lang_file.close
end
def langconv( tstr )
	ret = ""
	#UI.messagebox tstr
	if @tst_langhash.size > 0
		ret = @tst_langhash[tstr] if @tst_langhash[tstr] != nil
		#UI.messagebox tstr
		ret = tstr if ret == ""
	else
		ret = tstr
	end
	return ret
end
def change_defaultPFPath()
	pflist_path=UI.openpanel(TST_common.langconv("Select CSV File"),"","*.csv")
	return false if pflist_path == "" or pflist_path == false
	#UI.messagebox pflist_path
	pflist_path_sjis = pflist_path
	if $kconvloaded == true
		pflist_path_sjis = Kconv.tosjis(pflist_path)
	end
	#UI.messagebox pflist_path
	#@textlist,@linelist,@plinelist,@circlelist = 
	if FileTest.exist?( pflist_path ) or FileTest.exist?( pflist_path_sjis )
		Sketchup.write_default("Structure Tool", "pflist_path" , pflist_path.gsub(/\\/,'\/') )
	else
		UI.messagebox TST_common.langconv( "This script can not read from filepath include japanese." )
		return
	end
end
def tst_exchange_dialog()
	dialogname = "Structure Tool:Exchange"
	default = ""
	default = Sketchup.read_default("Structure Tool", "Exchange")
	list_ktypes=["ALL","STEEL_COLUMN","STEEL_GIRDER","STEEL_BEAM","RC_COLUMN","RC_GIRDER","RC_BEAM","RC_FOOTING","RC_WALL","OTHER_WALL"].join("|")
	if default == "" or default == nil
		default = list_ktypes.split("|")[0]
	elsif not list_ktypes.split("|").index(default)
		default = list_ktypes.split("|")[0]
	end
	prompts=["Structure Type: "]
	dropdowns=[list_ktypes]
	values=[default]			
	results = []
	results=inputbox(prompts,values,dropdowns, dialogname )
	default = results[0]
	return nil if not results
    Sketchup.write_default("Structure Tool", "Exchange", default )
	tst_changeto_structure( default )
end
def tst_changeto_structure( ktype = "" )
	model = Sketchup.active_model
	ents = model.entities
	sel = model.selection
	
	sel.each{|grp|
		if grp.kind_of? Sketchup::Group or grp.kind_of? Sketchup::ComponentInstance
			if grp.volume > 0.0
				if grp.attribute_dictionary( "BEAM_SPECS" ) == nil
					grp.make_unique
					#if ktype == "OTHER_WALL" or ktype == "RC_WALL"
					#	tst_changeto_do_wall( grp , ktype )
					#elsif ktype == "RC_COLUMN" or ktype == "STEEL_COLUMN" or ktype == "RC_FOOTING"
					#	tst_changeto_do_column( grp , ktype )
					#elsif ktype == "RC_GIRDER" or ktype == "RC_BEAM"
					#	tst_changeto_do_girder( grp , ktype )
					#elsif ktype == "STEEL_GIRDER" or ktype == "STEEL_BEAM"
					#	tst_changeto_do_girder( grp , ktype )
					#else
						tst_changeto_do_easy( grp , ktype )
					#end
				end#if grp.attribute_dictionary( "BEAM_SPECS" ) == nil
			end#if grp.volume != nil
		end#if grp.kind_of? Sketchup::Group
	}
end
def tst_changeto_do_easy( grp , ktype )
	#grp.make_unique
	if grp.kind_of? Sketchup::Group
		gents = grp.entities
	else
		gents = grp.definition.entities
	end
	
	dist = 0.0
	xori = [0,0,0]
	zvec_base = Geom::Vector3d.new(0,0,1)
	xvec = Geom::Vector3d.new
	t = grp.transformation
	@tst_ed = nil
	@tst_fc1 = nil
	@tst_fc2 = nil
	gents.each{|e|
		if e.kind_of? Sketchup::Edge
			if e.length > dist
				#一番長いエッジを軸にする
				#梁、壁系の場合はエッジの中でもZ軸との角度が30度以上傾いているものに限定する
				if ktype == "OTHER_WALL" or ktype == "RC_WALL" or ktype == "RC_GIRDER" or ktype == "RC_BEAM" or ktype == "STEEL_GIRDER" or ktype == "STEEL_BEAM"
					vec_e = e.line[1].transform( t.inverse )
					#UI.messagebox vec_e.angle_between(zvec_base)
					if Math.sin(vec_e.angle_between(zvec_base)) > Math.sin( 30.degrees )
						dist = e.length
						xori = e.start.position
						xvec = xori.vector_to( e.end.position )
						@tst_ed = e
					end
				elsif ktype == "RC_COLUMN" or ktype == "STEEL_COLUMN" or ktype == "RC_FOOTING"
					vec_e = e.line[1].transform( t.inverse )
					#UI.messagebox vec_e.angle_between(zvec_base)
					if Math.sin(vec_e.angle_between(zvec_base)) < Math.sin( 30.degrees )
						dist = e.length
						xori = e.start.position
						xvec = xori.vector_to( e.end.position )
						@tst_ed = e
					end
				else
					dist = e.length
					xori = e.start.position
					xvec = xori.vector_to( e.end.position )
					@tst_ed = e
				end
			end
		end
	}
	#UI.messagebox "#{xvec}"

	@tst_ed.start.faces.each{|e|
		ang = ( xvec.angle_between(e.normal) * 180.0 / Math::PI + 360.0 ) % 360
		#UI.messagebox "end_#{e}_#{ang}"
			#if ang > 89.degrees and ang < 91.degrees
			if ang > 92 or ang < 88
				@tst_fc1 = e
			end
	}
	@tst_ed.end.faces.each{|e|
		ang = ( xvec.angle_between(e.normal) * 180.0 / Math::PI + 360.0 ) % 360
		#UI.messagebox "start_#{e}_#{ang}"
			if ang > 92 or ang < 88
				@tst_fc2 = e
			end
	}
	if @tst_fc1 == nil or @tst_fc2 == nil
	#UI.messagebox "#{@tst_fc1}_#{@tst_fc2}"
	else
		@tst_fc1.set_attribute "BEAMS_FACES", "LOCATION" , "FC_START"
		@tst_fc2.set_attribute "BEAMS_FACES", "LOCATION" , "FC_END"
		
		gents.each{|e|
			if e.kind_of? Sketchup::Face
				gatt = e.get_attribute( "BEAMS_FACES", "LOCATION" ) 
				if gatt == nil
					e.set_attribute "BEAMS_FACES", "LOCATION" , "FC_SIDE"
				end
				
			end
		}
		gents.find_all{|e| e.kind_of? Sketchup::Edge and e.smooth? == false }.each{|ed|
			ed.set_attribute "BEAMS_FACES", "LOCATION" , "ED_OUTLINE"
		}
		if xvec.parallel?( Geom::Vector3d.new(0,0,1) )
			zvec = xvec.cross( Geom::Vector3d.new(0,1,0) )
			yvec = xvec.cross( zvec )
		else
			yvec = xvec.cross( Geom::Vector3d.new(0,0,1) )
			zvec = xvec.cross( yvec )
		end
		t = Geom::Transformation.axes xori, xvec, yvec, zvec
		gents.transform_entities t.inverse , gents.collect{|e| e }
		t2 = grp.transformation
		grp.transformation = t 
		grp.transform! t2
		#if grp.kind_of? Sketchup::Group
		grp.name = "DefinedStructure|#{ktype}"
		#else
		#	grp.name = "#{grp.name}|#{ktype}"
		#end
		grp.set_attribute "BEAM_SPECS","CLASS",ktype
		grp.set_attribute "BEAM_SPECS","HUGO",""
		grp.set_attribute "BEAM_SPECS","PROFILE",""
		grp.set_attribute "BEAM_SPECS","MATERIAL",""
		#grp.set_attribute "BEAM_SPECS","FL",0
		grp.set_attribute "BEAM_SPECS","ROTATE",0
		grp.set_attribute "BEAM_SPECS","MIRRORZ","No"
		grp.set_attribute "BEAM_SPECS","CURVE",false
	end
end
def tst_clear_default()
	result = UI.messagebox "Clear Structure dialog default?" ,MB_YESNO
	return if result == 7
	results = []
	results[0] = TST_common.langconv("Center")
	results[1] = TST_common.langconv("Middle")
	results[2] = TST_common.langconv("Yes")
	results[3] = ""
	results[4] = TST_common.langconv("No")
	results[5] = ""
	results[6] = 0.0
	results[7] = 4000.mm
	results[8] = 0.0
	Sketchup.write_default("Structure Tool", "STEEL_COLUMN:params", results.inspect.gsub(/"/, "'"))
	Sketchup.write_default("Structure Tool", "RC_COLUMN:params", results.inspect.gsub(/"/, "'"))
	results[0] = TST_common.langconv("Center")
	results[1] = TST_common.langconv("Bottom")
	results[2] = TST_common.langconv("Yes")
	results[3] = ""
	results[4] = TST_common.langconv("No")
	results[5] = ""
	results[6] = 0.0
	results[7] = 4000.mm
	results[8] = 0.0
	Sketchup.write_default("Structure Tool", "RC_WALL:params", results.inspect.gsub(/"/, "'"))
	Sketchup.write_default("Structure Tool", "MWALL:params", results.inspect.gsub(/"/, "'"))
	results[0] = TST_common.langconv("Center")
	results[1] = TST_common.langconv("Top")
	results[2] = TST_common.langconv("Yes")
	results[3] = ""
	results[4] = TST_common.langconv("No")
	results[5] = ""
	results[6] = 0.0
	results[7] = 0.0.mm
	results[8] = 0.0
	Sketchup.write_default("Structure Tool", "STEEL_BEAM:params", results.inspect.gsub(/"/, "'"))
	Sketchup.write_default("Structure Tool", "RC_BEAM:params", results.inspect.gsub(/"/, "'"))
	Sketchup.write_default("Structure Tool", "STEEL_GIRDER:params", results.inspect.gsub(/"/, "'"))
	Sketchup.write_default("Structure Tool", "RC_GIRDER:params", results.inspect.gsub(/"/, "'"))
	Sketchup.write_default("Structure Tool", "ALL:params", results.inspect.gsub(/"/, "'"))
	Sketchup.write_default("Structure Tool", "RC_FOOTING:params", results.inspect.gsub(/"/, "'"))
	results = []
	results[0] = ""
	results[1] = 0.mm
	results[2] = 0.mm
	results[3] = 20000.mm
	Sketchup.write_default("Structure Tool", "SLAB:params", results.inspect.gsub( 34.chr ,  "'" ))

end
def tst_add_new_profile
##(0)Hugo,(1)Profile,(2)FL,(3)Material of Real,(4)Rotate,(5)FrontColor,(6)BackColor,(7)SectionColor
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

		prompts = [ "Class" , "Tag:","Profile Name:","Floor Level:","Material:","Rotate:" ,"Front Color" ,"Back Color" , "Section Color" ]
		classlist = ["ALL","STEEL_BEAM","STEEL_GIRDER","STEEL_COLUMN","RC_BEAM","RC_GIRDER","RC_COLUMN","RC_FOOTING","RC_WALL","SLAB"].join("|")
		defaults = [ "ALL" , "" , "H-100x100x8x12" , 0.mm , "" , 0.0 , "matSTEEL" ,"BLACK","BLACK" ]
		dropdowns = [ classlist ]
		results = UI.inputbox prompts, defaults, dropdowns , "Add New PROFILE to list csv file.(#{pflist_path})"
		return if not results
		classname  = results[0] if results.size > 0
		tag  = results[1] if results.size > 1
		pfname  = results[2] if results.size > 2
		fl  = results[3].to_l if results.size > 3
		mat  = results[4] if results.size > 4
		rot  = results[5].to_f if results.size > 5
		fcolor  = results[6] if results.size > 6
		bcolor  = results[7] if results.size > 7
		scolor  = results[8] if results.size > 8
		if pfname == ""
			UI.messagebox "Need profile name!"
			return
		end
		pf_file=File.open( pflist_path ,"r")
		tbuff = pf_file.readlines
		pf_file.close
		units = "mm"
		indx = 0
		( tbuff.size ).times{|i|
			line = tbuff[ i ]
			line.chomp!
			tbuff[i] = line
			if line[/^\#.*/]
					if line["settings"]
						if line["inch"]
							units = "inch"
						else
							units = "mm"
						end
					elsif line["##{classname}"]
						indx = i
					end
			end
		}
		return if indx == 0
		fl_str = "#{fl.inch.to_f}" if units == "inch"
		fl_str = "#{fl.mm.to_f}" if units == "mm"
		tbuff[ indx + 1 , 0 ] = "#{tag},#{pfname},#{fl_str},#{mat},#{rot.to_f},#{fcolor},#{bcolor},#{scolor}"
		p "write into #{indx}line"
		pf_file=File.open( pflist_path ,"w+")
		tbuff.each{|tb| pf_file.puts tb }
		pf_file.close
end
module_function :select_langfile
module_function :tst_get_langtxt
module_function :langconv
module_function :change_defaultPFPath
module_function :tst_exchange_dialog
module_function :tst_clear_default
module_function :tst_changeto_do_easy
module_function :tst_changeto_structure
module_function :tst_add_new_profile
end #module
#Attributes "BEAMS_SPECS" for GROUP
#"CLASS"--Classification like "STEEL_GIRDER" "STEEL_BEAM" ,"RC_COLUMN" ,"FONDATION GIRDER" , "STEEL_BRACE" , "FOOTING" , "WALL" , "EFFECTIVE_WALL"
#"PROFILE"--section shape like "H-100x100x6x8"
#"FL" like 0 , -150 , 100
#"MATERIAL" like SS400
#"ROTATE" like 0 , 90

#Attributes "BEAMS_FACES" for faces in the group.
#"LOCATION":like "FC_END",like "FC_START" "FC_TOP" "FC_BOTTOM"
#

#Menu
class TST_Building_dialog
	def TST_Building_dialog.show_webdialog()
		@wdlg = UI::WebDialog.new( "Building Structure tool", true, "tst_building_webdialog", 240, 700, 150, 150, true)
		#shtm.gsub!(/\'/,"\"")
		@wdlg.set_url( File.join( File.dirname( File.expand_path(__FILE__) ), "building_structure_tool/webdialog1.htm" )) #.set_html(shtm)
	    @wdlg.add_action_callback("dialog_all"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("ALL")
	    }
	    @wdlg.add_action_callback("dialog_sgirder"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("STEEL_GIRDER")
	    }
		@wdlg.add_action_callback("dialog_sbeam"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("STEEL_BEAM")
	    }
 		@wdlg.add_action_callback("dialog_scolumn"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("STEEL_COLUMN")
	    }
 		@wdlg.add_action_callback("dialog_rcgirder"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_GIRDER")
	    }
 		@wdlg.add_action_callback("dialog_rcbeam"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_BEAM")
	    }
 		@wdlg.add_action_callback("dialog_rccolumn"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_COLUMN")
	    }
 		@wdlg.add_action_callback("dialog_rcfooting"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_FOOTING")
	    }
 		@wdlg.add_action_callback("dialog_rcwall"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_WALL")
	    }
 		@wdlg.add_action_callback("dialog_rcslab"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_SLAB")
	    }
 		@wdlg.add_action_callback("tool_ex2face"){|d,p|
			Sketchup.active_model.select_tool ExtendStructures.new
	    }
 		@wdlg.add_action_callback("tool_extend"){|d,p|
			Sketchup.active_model.select_tool ExtendStructures2.new
	    }
 		@wdlg.add_action_callback("tool_grow"){|d,p|
			Sketchup.active_model.select_tool GrowStructureFace.new
	    }
 		@wdlg.add_action_callback("tool_combine"){|d,p|
			Sketchup.active_model.select_tool ChamferStructures.new
	    }
 		@wdlg.add_action_callback("tool_exchange"){|d,p|
			TST_common.tst_exchange_dialog
	    } 
		@wdlg.add_action_callback("dialog_slab"){|d,p|
			Sketchup.active_model.select_tool Click2SLAB.new
	    }
		@wdlg.add_action_callback("dialog_mwall"){|d,p|
			Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("MWALL")
	    }
       if RUBY_PLATFORM[/darwin/]
            @wdlg.show_modal { }
        else
            @wdlg.show { }
        end
	end
end#class

if( not file_loaded?( File.basename(__FILE__) ) )
	TST_common.tst_get_langtxt
	tst_main_menu = UI.menu("Plugins").add_submenu("#{TST_common.langconv( 'Building Structure Tool' )}")
	tst_main_menu.add_item("#{TST_common.langconv('WEBDIALOG')}" ) { TST_Building_dialog.show_webdialog }
	## if you want these command to be shown in Toolmenue ,valid these command.
	#tst_main_menu.add_item("#{TST_common.langconv('MULTI WALL')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("MWALL") }
	#tst_main_menu.add_item("#{TST_common.langconv('ALL(SEARCH)')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("ALL") }
	#tst_main_menu.add_item("#{TST_common.langconv('STEEL_GIRDER')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("STEEL_GIRDER") }
	#tst_main_menu.add_item("#{TST_common.langconv('STEEL_BEAM')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("STEEL_BEAM") }
	#tst_main_menu.add_item("#{TST_common.langconv('STEEL_COLUMN')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("STEEL_COLUMN") }
	#tst_main_menu.add_item("#{TST_common.langconv('RC_GIRDER')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_GIRDER") }
	#tst_main_menu.add_item("#{TST_common.langconv('RC_BEAM')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_BEAM") }
	#tst_main_menu.add_item("#{TST_common.langconv('RC_COLUMN')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_COLUMN") }
	#tst_main_menu.add_item("#{TST_common.langconv('RC_FOOTING')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_FOOTING") }
	#tst_main_menu.add_item("#{TST_common.langconv('RC_WALL')}") { Sketchup.active_model.select_tool TAKTASK::BeamsTool.new("RC_WALL") }
	#tst_main_menu.add_item("#{TST_common.langconv('SLAB(Click Area)')}") { Sketchup.active_model.select_tool Click2SLAB.new }
	tst_main_menu.add_item("#{TST_common.langconv('CLEAR Default')}") { TST_common.tst_clear_default }

	#tst_main_menu.add_separator
    #tst_main_menu.add_item( "#{TST_common.langconv('EXTEND to Face')}") { Sketchup.active_model.select_tool ExtendStructures.new }
	#tst_main_menu.add_item( "#{TST_common.langconv('EXTEND')}") { Sketchup.active_model.select_tool ExtendStructures2.new }
	#tst_main_menu.add_item( "#{TST_common.langconv('GROW')}") { Sketchup.active_model.select_tool GrowStructureFace.new }
    #tst_main_menu.add_item( "#{TST_common.langconv('COMBINE WITH')}") { Sketchup.active_model.select_tool ChamferStructures.new }
	#tst_main_menu.add_item( "#{TST_common.langconv('EXCHANGE')}") { TST_common.tst_exchange_dialog }
	#tst_main_menu.add_separator
	tst_main_menu.add_item("#{TST_common.langconv('Add New PROFILE')}" ) { TST_common.tst_add_new_profile }
	tst_main_menu.add_item("#{TST_common.langconv('Change PROFILE-LIST File')}") { TST_common.change_defaultPFPath }
	tst_main_menu.add_item("#{TST_common.langconv('Change Language File')}") { TST_common.select_langfile }
    #UI.menu("Draw").add_item("StructureTool_TAK2") { Sketchup.active_model.select_tool(TAKTASK::BeamsTool.new) }
	pdir = File.dirname( File.expand_path(__FILE__) ) + '/building_structure_tool'

	tst_tb = UI::Toolbar.new("Building Structure Tool")
	tsttitle = TST_common.langconv( "SHOW_TOOLS" )
	cmd_tst = UI::Command.new( tsttitle) { TST_Building_dialog.show_webdialog }
	cmd_tst.large_icon = cmd_tst.small_icon = pdir+"/icon_search_lg.png"
	cmd_tst.status_bar_text = cmd_tst.tooltip = tsttitle
	tst_tb.add_item( cmd_tst )
	tst_tb.show if tst_tb.get_last_state != 0
end
file_loaded(File.basename(__FILE__))
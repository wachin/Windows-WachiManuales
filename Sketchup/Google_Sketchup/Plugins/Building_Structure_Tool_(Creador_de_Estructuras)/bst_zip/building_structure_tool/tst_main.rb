# Name:   beams
# Description:draw beams shapes from list in text file.
# Making based on Dline2(D.bur)
#v0.2:modified in 2011.01.26.
#描画メイン部分
#2011/09/07 add prop wall width.
require 'sketchup.rb'
require 'building_structure_tool/tst_chamfer_structures.rb'

module TAKTASK
    class BeamsTool
		def initialize( bclass = "STEEL_BEAM" )
			@bclass = bclass
			@pwall = nil
			@units = "mm"
			Sketchup.active_model.layers.add "Structure-#{@bclass}"
		end
        def reset(view)
            @pts              = []
            @shape_pts         = []
            @state            = 0
            @drawn            = false
            @ip.clear
            @ip1.clear
            @ip2.clear
            Sketchup::set_status_text TST_common.langconv( "First point or Search Keyword" )
            view.lock_inference if view
        end
        def reset2(view)
			pt = @pts[1]
			@ip1 = Sketchup::InputPoint.new( @pts[1] )
            @pts = []
			@pts.push pt
            @shape_pts         = []
            @state            = 1
            @drawn            = false
            @ip.clear
			
            #@ip1.clear
            @ip2.clear
            Sketchup::set_status_text TST_common.langconv( "First point or Search Keyword" )
            view.lock_inference if view
        end
        def resume(view)
            if @state == 0
                Sketchup::set_status_text TST_common.langconv( "First point" )
            end
        end

        def activate
            @ip  = Sketchup::InputPoint.new
            @ip1 = Sketchup::InputPoint.new
            @ip2 = Sketchup::InputPoint.new
            Sketchup.active_model.active_view.lock_inference
            self.reset(nil)
            @drawn = false
			@wall_width = 100.mm
			if @bclass == "STEEL_COLUMN" or @bclass == "RC_COLUMN"
				@beams_just   = "Center"
				@beams_vjust   = "Middle"
				@beams_axis   = "Yes"
				@beams_fixz = ""
				@beams_spec   = ""
				#@beams_left  = 0.0 #  if @results[5] != 0.to_l
				@beams_top = 0.0
				@beams_height = 4000.mm
				@beams_rot = 0.0
				@beams_mirz = "No"
			
			elsif @bclass == "RC_WALL"
				@beams_just   = "Center"
				@beams_vjust   = "Bottom"
				@beams_axis   = "Yes"
				@beams_fixz = ""
				@beams_spec   = ""
				#@beams_left  = 0.0 #  if @results[5] != 0.to_l
				@beams_top = 0.0
				@beams_height = 4000.mm
				@beams_rot = 0.0
				@beams_mirz = "No"
				@wall_width = 100.mm
			elsif @bclass == "MWALL"
				@beams_just   = "Center"
				@beams_vjust   = "Bottom"
				@beams_axis   = "Yes"
				@beams_fixz = ""
				@beams_spec   = ""
				#@beams_left  = 0.0 #  if @results[5] != 0.to_l
				@beams_top = 0.0
				@beams_height = 4000.mm
				@beams_rot = 0.0
				@beams_mirz = "No"
				@wall_width = 100.mm
			else#if @bclass == "STEEL_BEAM" or @bclass == "RC_BEAM" or @bclass == "STEEL_GIRDER" or @bclass == "RC_GIRDER"
				@beams_just   = "Center"
				@beams_vjust   = "Top"
				@beams_axis   = "Yes"
				@beams_fixz = ""
				@beams_spec   = ""
				#@beams_left  = 0.0 #  if @results[5] != 0.to_l
				@beams_top = 0.0
				@beams_height = 0.0
				@beams_rot = 0.0
				@beams_mirz = "No"
			end
			#defaults = Sketchup.read_default("Structure Tool:#{@bclass}", "params")
			defaults = Sketchup.read_default("Structure Tool", "#{@bclass}:params")

				if defaults
					@results = eval( defaults )
					if @results.size > 7
						@beams_just   = @results[0] if @results.size > 0
						@beams_vjust   = @results[1] if @results.size > 1
						@beams_axis   = @results[2] if @results.size > 2
						@beams_spec   = @results[3] if @results.size > 3
						@beams_mirz = @results[4] if @results.size > 4
						@beams_fixz = @results[5] if @results.size > 5
						#@beams_left  = @results[5].to_l if @results.size > 5
						@beams_top = @results[6].to_l if @results.size > 6
						@beams_height = @results[7].to_l if @results.size > 7
						@beams_rot = @results[8].to_f if @results.size > 8
						@wall_width = @results[9].to_l if @results.size > 9
					end
				end

			results = []
			if @bclass == "ALL"
				# when "ALL" selected,at the first time "Search Dialog" is shown.
				default = Sketchup.read_default("Structure Tool", "searchword")
				prompts = [TST_common.langconv( "Search Word?(BLANK to ALL)" )]
				defaults = [default]
				results = UI.inputbox prompts, defaults, TST_common.langconv( "Start from searching with Words?" )
				if results != nil
					default = results[0]
					Sketchup.write_default( "Structure Tool", "searchword", default )
					dialog( default )
				else
					dialog()
				end
			else
				dialog( )
			end

            Sketchup::set_status_text "", SB_VCB_VALUE
        end

		#Reading from csv

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
					#UI.messagebox pflist_path
			elsif not FileTest.exist?( pflist_path )
				UI.messagebox "#{File.basename(pflist_path )} is not Exists.So Read from Default"
				pflist_path = Sketchup.find_support_file "default_pflist.csv", "Plugins/building_structure_tool/"
			end
			if not FileTest.exist?( pflist_path )
				UI.messagebox "Error:#{File.basename(pflist_path )} is not Exists"
				return false
			end
					#UI.messagebox pflist_path
			model = Sketchup.active_model
					#skppath = File.expand_path(model.path)
					#skpdirname = File.dirname(skppath)
					#skpbasename = File.basename(skppath, ".skp")

					#pflist_path= skpdirname + "\/pflist.csv"

			Sketchup.write_default("Structure Tool", "pflist_path" , pflist_path )
					#if FileTest.exist?( pflist_path )
					#elsif default_pflist_path != false
					#	pflist_path = default_pflist_path
					#else
					#	return false
					#end
			
			pf_file=File.open( pflist_path ,"r")
			section = false
			section = true if @bclass == "ALL"
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
			splt = csvline.split("\"")
			
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
        # Dialog
        def dialog( utext = "" )
			@pflist = []
			#TAG,PROFILE,FL,MATERIAL,Rotate,r1,r2
			#0:TAG:
				#As you like
				#...my recommend style is:"2G21" means G21 Girder on 2FL.
			#1:PROFILE:
				#like "H100x100x6x8"
				#like "SHS300x300x16"
				#like "CHS165.2x6"
				#like "L90x90x6"
				#like "C100x50x20x2.3
				#like "2[150x75x6.5x10"
				#like "RC400x800"
				#like "SRC500x800-H390x300x10x16"
				#like "FT1000x1000x300"
			#2:FL(Optional):Level of Top from Floor level.
				#like "+100" "-150" "0"
			#3:MATERIAL(Optional)
				#like "STEEL"
				#like "RC"
				#RC/Fc21
				#RC/Fc30
				#STEEL/SS400
				#STEEL/SN400C
				#STEEL/SN490C
				#STEEL/SM490A
				#STEEL/SN400B
				#STEEL/BCR295
			#4:Rotate:degrees
				#like 90
			pflist_path = readProfiles( utext )
			if @bclass == "MWALL"###########################################MWALL
				pdir = File.dirname( File.expand_path(__FILE__) ) + '/mwalls/*.skp'
				p pdir
				Dir::glob( pdir ).each {|f|
					@pflist.push "#{File.basename(f)}"
					p File.basename(f)
				}
				pflist_path = pdir
			elsif pflist_path == false
				@pflist.push "G1,H150x75x5x7,,SS400,0,,,"
				@pflist.push "G2,H175x90x5x8,,SS400,0,,,"
				@pflist.push "G3,H200x100x5.5x8,,SS400,0,,,"
				@pflist.push "G4,H250x125x6x9,,SS400,0,,,"
				@pflist.push "G5,H300x150x6.5x9,,SS400,0,,,"
				@pflist.push "RG1,RC500x1200,,RC,0,,,"
				pflist_path = "Sample List"
			end
			
            @beams_just   = TST_common.langconv( "Center" ) if not @beams_just
            @beams_vjust   = TST_common.langconv( "Top" ) if not @beams_vjust
            @beams_axis   = TST_common.langconv( "Yes" ) if not @beams_axis
			if @bclass == "MWALL"###########################################MWALL
				if @beams_spec == ""
					@beams_spec = @pflist[0]
				elsif not @pflist.index(@beams_spec)
					@beams_spec = @pflist[0]
				end
			else			
				if @beams_spec == ""
					@beams_spec   = "0," + @pflist[0]
				elsif not @pflist.index(@beams_spec)
					@beams_spec   = "0," + @pflist[0]
				else
					i = @pflist.index( @beams_spec )
					@beams_spec = "#{i}," + @beams_spec
				end
			end
            @beams_left  = 0.0.m if not @beams_left
            @beams_top = 0.0.m if not @beams_top
			@beams_height = 0.0.m if not @beams_height
			@beams_rot = 0.0 if not @beams_rot
			@beams_fixz = "" if not @beams_fixz
			@beams_mirz = TST_common.langconv( "No" ) if not @beams_mirz
			@wall_width = 100.0.m if not @wall_width
			list_just=[TST_common.langconv( "Left"),TST_common.langconv( "Center" ),TST_common.langconv( "Right") ].join("|")
			list_vjust=[TST_common.langconv( "Top"),TST_common.langconv( "Middle"), TST_common.langconv( "Bottom") ].join("|")
			list_axis=[TST_common.langconv( "Yes" ),TST_common.langconv( "No" ) ].join("|")
			@pflist2 = []
			if @bclass == "MWALL"###########################################MWALL
				@pflist2 = @pflist
			else
				(@pflist.size).times{|i|
					pf = @pflist[i]
					#if pf[/^([^,]*),([^,]*),([^,]*),([^,]*),.*/]
					#	@pflist2.push "#{i},#{$1},#{$2},#{$3},#{$4}"
					#end
					parr = split_csvline( @pflist[i] )
					if parr.size >= 4
						@pflist2.push "#{i},#{parr[0]},#{parr[1]},#{parr[2]},#{parr[3]}"
					end
				}
				bmarr = split_csvline( @beams_spec )
				if bmarr.size >= 5
					@beams_spec = "#{bmarr[0]},#{bmarr[1]},#{bmarr[2]},#{bmarr[3]},#{bmarr[4]}"
				end
			end


			list_bspec = @pflist2.join("|")
			
			prompts=["Justification:","Vertical Just:","Draw axis:","Beam Spec:","Mirror aboutZ:","Fix Z Input to(BLANK to Free)", "Top:", "Height:" , "Rotate:" ]
			prompts=prompts.map{|prp| TST_common.langconv( prp ) }
			dropdowns=[list_just,list_vjust,list_axis,list_bspec,list_axis]
			@values=[@beams_just,@beams_vjust,@beams_axis, @beams_spec , @beams_mirz ,@beams_fixz ,@beams_top,@beams_height,@beams_rot]	
			
			if @bclass == "ALL"
				dtitle = "#{TST_common.langconv( 'Structure Tool' )}(#{TST_common.langconv( 'ALL' )}):#{pflist_path}"
			elsif @bclass == "STEEL_BEAM" or @bclass == "RC_BEAM"
				dtitle = "#{TST_common.langconv( 'Structure Tool' )}(#{TST_common.langconv( 'BEAM' )}):#{pflist_path}"
			elsif @bclass == "STEEL_GIRDER" or @bclass == "RC_GIRDER"
				dtitle = "#{TST_common.langconv( 'Structure Tool' )}(#{TST_common.langconv( 'GIRDER' )}):#{pflist_path}"
			elsif @bclass == "RC_WALL"
				dtitle = "#{TST_common.langconv( 'Structure Tool' )}(#{TST_common.langconv( 'WALL' )}):#{pflist_path}"
				prompts.push "Wall Width override:"
				@values.push @wall_width
			elsif @bclass == "MWALL"###########################################MWALL
				dtitle = "#{TST_common.langconv( 'Structure Tool' )}(#{TST_common.langconv( 'MWALL' )}):#{pflist_path}"
			elsif @bclass == "RC_COLUMN" or @bclass == "STEEL_COLUMN"
				dtitle = "#{TST_common.langconv( 'Structure Tool' )}(#{TST_common.langconv( 'COLUMN' )}):#{pflist_path}"
			elsif @bclass == "RC_FOOTING"
				dtitle = "#{TST_common.langconv( 'Structure Tool' )}(#{TST_common.langconv( 'FOOTING' )}):#{pflist_path}"
			end
			@results = []
			@results=inputbox(prompts,@values,dropdowns, dtitle )
			Sketchup.active_model.select_tool(nil) if (not @results)
			return if not @results
			@beams_just   = @results[0] if @results.size > 0
			@beams_vjust   = @results[1] if @results.size > 1
			@beams_axis   = @results[2] if @results.size > 2
			if @results.size > 3
				if @bclass == "MWALL"###########################################MWALL
					@beams_spec = @results[3]
				else
					#@beams_spec   = @pflist[ @results[3].split(",")[0].to_i ]
					@beams_spec   = @pflist[ split_csvline( @results[3] )[0].to_i ]
					@results[3] = @beams_spec
					#@beams_spec   = @results[3]
				end
			end
			@beams_mirz = @results[4] if @results.size > 4
			@beams_fixz   = @results[5] if @results.size > 5
			
			@beams_top = @results[6].to_l if @results.size > 6
			@beams_height = @results[7].to_l if @results.size > 7
			@beams_rot  = @results[8].to_f if @results.size > 8
			@wall_width  = @results[9].to_l if @results.size > 9
			Sketchup.write_default("Structure Tool", "#{@bclass}:params", @results.inspect.gsub( 34.chr , "'"))
			
            #@beams_just   = @results[0]
            #@beams_vjust   = @results[1]
            #@beams_axis   = @results[2]
            #@beams_spec   = @results[3]
            #@beams_left  = @results[4].to_l #  if @results[5] != 0.to_l
            #@beams_top = @results[5].to_l
			sel = Sketchup.active_model.selection
			sellines = sel.find_all{|e| e.kind_of?( Sketchup::Edge ) or e.kind_of?( Sketchup::ConstructionLine )}
			if not sellines == [] #sel.empty?
				if sellines.size != 0
					msg = TST_common.langconv( "Auto Create from selected edges(and clines)?" ) + ":(#{sellines.size})"
					sel_res = nil
					sel_res = UI.messagebox msg , MB_YESNO
#UI.messagebox "#{sel_res}"
					if sel_res == 6#res YES
#UI.messagebox "return yes"
						auto_create_from_lines sellines
						Sketchup.active_model.select_tool nil
					end
				end
			end
			Sketchup::set_status_text "#{TST_common.langconv( 'First Point or Search word:Current')} #{@beams_spec}|#{@beams_just}|#{@beams_vjust}|#{TST_common.langconv('TOP')}= #{@beams_top}|#{TST_common.langconv( 'AXIS')}? #{@beams_axis}|#{TST_common.langconv('HEIGHT')}=#{@beams_height}|#{TST_common.langconv( 'rotate')}=#{@beams_rot}"
        end

        def deactivate(view)
            view.invalidate if @drawn
            #Sketchup.active_model.options[0]["LengthSnapLength"]=@old_snap
            #values=[@beams_just,@beams_axis,@beams_width.to_f,@beams_height.to_f]
            #Sketchup.write_default("Structure Tool:#{@bclass}", "params", values.inspect.gsub(34.chr, "'"))
        end

        def onCancel(flag, view)
            # Clean view and exit the tool
            view.invalidate if @drawn
			if ( @bclass == "RC_WALL" or @bclass == "MWALL" ) and @state == 1
				@pgeom = nil
				self.reset(view)
			else
				Sketchup.active_model.select_tool nil
			end
        end

        def onReturn(view)
            # Clean view and exit the tool
            view.invalidate if @drawn
            self.reset(view)
            Sketchup.active_model.select_tool nil
		end
		
        def drawBeam(view)
			#if Sketchup.version.to_f < 7.0
			#	Sketchup.active_model.start_operation( TST_common.langconv( "DRAW BEAM" ) )
			#else
			#	Sketchup.active_model.start_operation( TST_common.langconv( "DRAW BEAM" ) , true)
			#end
			self.create_geometry
			#Sketchup.active_model.commit_operation
			if @bclass == "RC_WALL" or @bclass == "MWALL"
				self.reset2(view)
			else
				self.reset(view)
			end
		end

        def onRButtonDown(flags, x, y, view)
            dialog()
            view.invalidate
			#onReturn(view)
        end

        def onUserText(text, view)
            if @state == 0
                # enter hariHugo
                dialog text
            end
			
            return if not @state == 1
            return if not @ip2.valid?

            #if text != "c" and text != "C"
                begin
                    value = text.to_l
                rescue
                    # Error parsing the text
                    UI.messagebox( "#{text} " + TST_common.langconv( "cannot convert to a Length" ) )
                    value = nil
                    Sketchup::set_status_text "", SB_VCB_VALUE
                end
            return if !value
			#end
            # Compute the direction and the second point
            if ( @state == 1 )            
	            #pt1 = @ip1.position
				pt2 = @ip2.position
				pt2.z = @beams_fixz.to_l if @beams_fixz != ""
				vec = @pts[0].vector_to(pt2)
                if vec.length == 0.0
	            #vec = @ip2.position - pt1
	            #if( vec.length == 0.0 )
	                UI.messagebox( TST_common.langconv("Zero length invalid !") )
	                return
	            end
	            vec.length = value
	            pt2 = @pts[0] + vec
	            # Store point
	            @pts.push(pt2)

            	#@ip1 = Sketchup::InputPoint.new( @pts[1] )
				drawBeam( view )
            end
            view.invalidate

            # This point becomes initial point
            #@ip1.copy! @ip2
            #@ip1= Sketchup::InputPoint.new(pt2)
        end

        def onMouseMove(flags, x, y, view)
            if( @state == 0 )
                Sketchup::set_status_text TST_common.langconv("First point")
                # Getting the first end
                @ip.pick view, x, y
                if( @ip != @ip1 )
                    # if the point has changed from the last one we got
                    view.invalidate if( @ip.display? or @ip1.display? )
                    @ip1.copy! @ip
                    # set the tooltip that should be displayed to this point
                    view.tooltip = @ip1.tooltip
                end
            else
                # Getting the next end
                Sketchup::set_status_text TST_common.langconv("Next point:[Esc]=Quit")
                Sketchup::set_status_text TST_common.langconv("LENGTH"), SB_VCB_LABEL
                @ip2.pick view, x, y, @ip1

                # Update the length displayed in the VCB
                if( @ip2.valid? )
                    length = @ip1.position.distance(@ip2.position)
                    Sketchup::set_status_text length.to_s, SB_VCB_VALUE
                end

                view.tooltip = @ip2.tooltip if( @ip2.valid? )
                view.invalidate
            end
        end

        def onLButtonDown(flags, x, y, view)

            if ( @state == 0 )
                #check first point
                if( @ip1.valid? )
                    # Store point
                    @pts.push(@ip1.position)
					@pts[0].z = @beams_fixz.to_l if @beams_fixz != ""
					@ip1 = Sketchup::InputPoint.new( @pts[0] )
					if @bclass == "STEEL_COLUMN" or @bclass == "RC_COLUMN"
						@pts.push( [ @pts[0].x , @pts[0].y , @pts[0].z + @beams_height ] )
						#@pts.push( [ @ip1.position.x , @ip1.position.y , @ip1.position.z + @beams_height ] )
						drawBeam( view )
					elsif @bclass == "RC_FOOTING"
						@pts.push( [ @pts[0].x , @pts[0].y , @pts[0].z + 1000.mm ] )
						#@pts.push( [ @ip1.position.x , @ip1.position.y , @ip1.position.z + 1000.mm ] )
						drawBeam( view )
					else
						@state+=1
					end
                end
            end
            if ( @state == 1 )
                #check next point
                if( @ip2.valid? )
					pt2 = @ip2.position
					pt2.z = @beams_fixz.to_l if @beams_fixz != ""
                    # Store point
                   # if @pts[0].vector_to(@ip2.position).normalize.length > 0
                    if @pts[0].vector_to(pt2).normalize.length > 0
	                    @pts.push(pt2)
						#@pts[1].z = @beams_fixz.to_l if @beams_fixz != ""
						#@ip1 = Sketchup::InputPoint.new( @pts[1] )
	                    # This point becomes initial point
	                    #@ip1.copy! @ip2
						drawBeam( view )
					end
                end
            end
            view.invalidate
        end
        
        # Draw temp line between ends of partition axis
        def draw_temp_line(pt1, pt2, view)
            #view.drawing_color = "red"
            view.set_color_from_line(pt1, pt2)
            #view.line_stipple="-.-"
            if view.inference_locked?
                view.line_width=2
            end
            @bbp = [pt1, pt2]
            view.draw_line(pt1, pt2)
        end

        def getExtents
            bb = Geom::BoundingBox.new
            #bb.aptsdd(pt) if pt
            if @bbp
            @bbp.each { |pt| bb.add(pt) }
            end
            bb
        end

        def onKeyDown(key, rpt, flags, view)
            if( key == CONSTRAIN_MODIFIER_KEY )
                # if we already have an inference lock, then unlock it
                if( view.inference_locked? )
                    view.lock_inference
                elsif( @state == 1 )
                    ##view.lock_inference @ip2, @ip1##110909
                    view.lock_inference @ip2 , @ip
                else
                    view.lock_inference @ip2
                end
                view.invalidate
            end
        end

        def onKeyUp(key, rpt, flags, view)
            if( key == CONSTRAIN_MODIFIER_KEY && view.inference_locked? )
                #(Time.now - @shift_down_time) > 0.5 )
                view.lock_inference
            end
            if key == 9 # or key == 15 or key == 48 # Tab key (according to TIG) ?
                dialog()
            end
            view.invalidate
        end
		
        def create_geometry()
			if Sketchup.version.to_f >= 7
				Sketchup.active_model.start_operation TST_common.langconv("Draw Building Structure"),true
			else
				Sketchup.active_model.start_operation TST_common.langconv("Draw Building Structure")
			end
			cgeom = drawStructure( @pts , @beams_spec , @beams_just , @beams_vjust , @beams_axis , @beams_top , @beams_rot , @beams_mirz , @wall_width )
			if @pgeom != nil and ( @bclass == "RC_WALL" or @bclass == "MWALL" )
				chmf_str = ChamferStructures.new
				chmf_str.chamfer_form_MS( cgeom , cgeom.bounds.center , @pgeom , @pgeom.bounds.center )
				#chmf_str.chamfer_form( cgeom , cgeom.bounds.center , @pgeom , @pgeom.bounds.center )
				#chmf_str.chamfer_form( @pgeom , @pgeom.bounds.center , cgeom , cgeom.bounds.center )
			end
			@pgeom = nil
			@pgeom = cgeom if @bclass == "RC_WALL" or @bclass == "MWALL"
			Sketchup.active_model.commit_operation
        end

        def draw(view)
            # Show input points when valid
            if( @ip1.valid? )
                if( @ip1.display? )
                    @ip1.draw(view)
                    #@drawn = true
                end  
                if( @ip2.valid? )
                    @ip2.draw(view) if( @ip2.display? )
                    self.draw_temp_line(@ip1.position, @ip2.position, view) if (@ip1.valid? and @ip2.valid?)
                    #@drawn = true
                end
            end
            # Show the previously drawn axis
            #self.draw_previous_points(view)
            @drawn = true
        end
				def add_Hshape_face(  grp , gw , gh , gt1 , gt2 , r1 = 0.0 )
					ents = grp.entities
					shapePts = []
					holePts = []
					if r1 == 0.0
						shapePts.push [ 0 , -gw/2, gh/2 ]			#1
						shapePts.push [ 0 , gw/2 , gh/2 ]			#2
						shapePts.push [ 0 , gw/2 , (gh/2 - gt2) ]	#3
						shapePts.push [ 0 , gt1/2, (gh/2 - gt2) ]	#4
						shapePts.push [ 0 , gt1/2, (-gh/2 + gt2) ]	#5
						shapePts.push [ 0 , gw/2 , (-gh/2 + gt2) ]	#6
						shapePts.push [ 0 , gw/2 , -gh/2 ]			#7
						shapePts.push [ 0 , -gw/2, -gh/2 ]			#8
						shapePts.push [ 0 , -gw/2, (-gh/2 + gt2) ]	#9
						shapePts.push [ 0 , -gt1/2, (-gh/2 + gt2) ]	#10
						shapePts.push [ 0 , -gt1/2, (gh/2 - gt2) ]	#11
						shapePts.push [ 0 , -gw/2, (gh/2 - gt2) ]	#12
						fc = ents.add_face shapePts
					else
						#H-AxBxCxDxR
						xa = gw/2
						xb = gt1/2
						xc = gt1/2+r1
						ya = gh/2
						yb = gh/2-gt2
						yc = gh/2-gt2-r1
						xvec = Geom::Vector3d.new 0,1,0
						zvec = Geom::Vector3d.new 1,0,0
						ed1 = ents.add_edges( [ [0,-xc,yb],[0,-xa,yb],[0,-xa,ya],[0,xa,ya],[0,xa,yb],[0,xc,yb] ] )
						ed2 = ents.add_edges( [ [0,xc,-yb],[0,xa,-yb],[0,xa,-ya],[0,-xa,-ya],[0,-xa,-yb],[0,-xc,-yb] ] )
						ed3 = ents.add_edges([ [0,xb,yc],[0,xb,-yc] ] )
						ed4 = ents.add_edges([ [0,-xb,-yc],[0,-xb,yc] ] )
						ed5 = add_arcedges( ents , [0,xc,yc] , r1 , 90.degrees , 180.degrees , 2 )#entities,center,radius,ang1,ang2,divides
						ed6 = add_arcedges( ents , [0,xc,-yc] , r1 , 180.degrees, 270.degrees, 2 )
						ed7 = add_arcedges( ents , [0,-xc,-yc] , r1 , 270.degrees, 360.degrees, 2 )
						ed8 = add_arcedges( ents , [0,-xc,yc] , r1 , 0.degrees, 90.degrees, 2 )
						
						#ed5 = ents.add_arc([0,xc,yc], xvec, zvec, r1 ,90.degrees, 180.degrees, 2 )
						#ed6 = ents.add_arc([0,xc,-yc], xvec, zvec, r1 , 180.degrees, 270.degrees, 2 )
						#ed7 = ents.add_arc([0,-xc,-yc], xvec, zvec, r1 , 270.degrees, 360.degrees, 2 )
						#ed8 = ents.add_arc([0,-xc,yc], xvec, zvec, r1 , 0.degrees, 90.degrees, 2 )
						#UI.messag
						fc = ents.add_face([ed1,ed2,ed3,ed4,ed5,ed6,ed7,ed8].flatten )
					end
					return nil if fc == nil
					return fc
				end
				def add_SHshape_face(  grp , gw , gh , gt1 , r1 = 0.0 )
					ents = grp.entities
					shapePts = []
					holePts = []
					if r1 == 0.0
						shapePts.push [ 0 , -gw/2, gh/2 ]			#1
						shapePts.push [ 0 , gw/2 , gh/2 ]			#2
						shapePts.push [ 0 , gw/2 , -gh/2 ]			#3
						shapePts.push [ 0 , -gw/2, -gh/2 ]			#4
						holePts.push [ 0,-gw/2 + gt1 , gh/2 - gt1 ]
						holePts.push [ 0 , gw/2 - gt1 , gh/2 - gt1 ]			#2
						holePts.push [ 0 , gw/2 - gt1 , -gh/2 + gt1 ]			#3
						holePts.push [ 0 , -gw/2 + gt1 , -gh/2 + gt1 ]			#4
						fc = ents.add_face shapePts
						hole = ents.add_face holePts
						ents.erase_entities hole
					else
						xa = gw/2
						xb = gw/2 - gt1
						xc = gw/2 - r1
						ya = gh/2
						yb = gh/2 - gt1
						yc = gh/2 - r1
						xvec = Geom::Vector3d.new 0,1,0
						zvec = Geom::Vector3d.new 1,0,0

						ed = []
						ed[0] = ents.add_edges( [ [0,xa,yc],[0,xa,-yc] ] )
						ed[1] = ents.add_edges( [ [0,xc,-ya],[0,-xc,-ya] ] )
						ed[2] = ents.add_edges( [ [0,-xa,-yc],[0,-xa,yc] ] )
						ed[3] = ents.add_edges( [ [0,-xc,ya],[0,xc,ya] ] )
						
						ed[4] = add_arcedges( ents , [0,xc,-yc], r1 ,270.degrees, 360.degrees, 2 )
						ed[5] = add_arcedges( ents , [0,-xc,-yc], r1 ,180.degrees, 270.degrees, 2 )
						ed[6] = add_arcedges( ents , [0,-xc,yc], r1 ,90.degrees, 180.degrees, 2 )
						ed[7] = add_arcedges( ents , [0,xc,yc], r1 ,0.degrees, 90.degrees, 2 )
						#ed[4] = ents.add_arc([0,xc,-yc], xvec, zvec, r1 ,270.degrees, 360.degrees, 2 )
						#ed[5] = ents.add_arc([0,-xc,-yc], xvec, zvec, r1 ,180.degrees, 270.degrees, 2 )
						#ed[6] = ents.add_arc([0,-xc,yc], xvec, zvec, r1 ,90.degrees, 180.degrees, 2 )
						#ed[7] = ents.add_arc([0,xc,yc], xvec, zvec, r1 ,0.degrees, 90.degrees, 2 )
						fc = ents.add_face( ed.flatten )
						
						ed = []
						ed[0] = ents.add_edges( [ [0,xb,yc],[0,xb,-yc] ] )
						ed[1] = ents.add_edges( [ [0,xc,-yb],[0,-xc,-yb] ] )
						ed[2] = ents.add_edges( [ [0,-xb,-yc],[0,-xb,yc] ] )
						ed[3] = ents.add_edges( [ [0,-xc,yb],[0,xc,yb] ] )
						ed[4] = add_arcedges( ents , [0,xc,-yc], ( r1 - gt1 ) ,270.degrees, 360.degrees, 2 )
						ed[5] = add_arcedges( ents , [0,-xc,-yc], ( r1 - gt1 ) ,180.degrees, 270.degrees, 2 )
						ed[6] = add_arcedges( ents , [0,-xc,yc], ( r1 - gt1 ) ,90.degrees, 180.degrees, 2 )
						ed[7] = add_arcedges( ents , [0,xc,yc], ( r1 - gt1 ) ,0.degrees, 90.degrees, 2 )
						#ed[4] = ents.add_arc([0,xc,-yc], xvec, zvec, ( r1 - gt1 ) ,270.degrees, 360.degrees, 2 )
						#ed[5] = ents.add_arc([0,-xc,-yc], xvec, zvec, ( r1 - gt1 ) ,180.degrees, 270.degrees, 2 )
						#ed[6] = ents.add_arc([0,-xc,yc], xvec, zvec, ( r1 - gt1 ) ,90.degrees, 180.degrees, 2 )
						#ed[7] = ents.add_arc([0,xc,yc], xvec, zvec, ( r1 - gt1 ) ,0.degrees, 90.degrees, 2 )
						hole = ents.add_face( ed.flatten )
						ents.erase_entities hole
					end
					return nil if fc == nil
					return fc
				end
				def add_CHshape_face(  grp , gw , gh , gt1 , r )
					ents = grp.entities
					shapePts = []
					holePts = []
					(0..24).each{|cnt|
						ang = ( 360.to_f / 24 * cnt.to_f ).degrees
						shapePts.push [ 0 , Math.sin( ang ) * r , Math.cos( ang ) * r ]
						holePts.push [ 0 , Math.sin( ang ) * ( r - gt1 ), Math.cos( ang ) * ( r - gt1 ) ]
					}
					crv = ents.add_curve shapePts
					crv2 = ents.add_curve holePts
					fc = ents.add_face shapePts
					hole = ents.add_face holePts
					ents.erase_entities hole

					return nil if fc == nil
					return fc
				end
				def add_Lshape_face( grp , gw , gh , gt1 , gt2 ,r1 , r2)
					ents = grp.entities
					xa = gw / 2
					xb = xa - r2
					xc = xa - gt1
					xd = xa - gt1 - r1
					xe = xa - gt1 + r2
					ya = gh / 2
					yb = ya - r2
					yc = ya - gt2
					yd = ya - gt2 - r1
					ye = ya - gt2 + r2
					xvec = Geom::Vector3d.new 0,1,0
					zvec = Geom::Vector3d.new 1,0,0
					if r1 == 0.0 or r2 == 0.0
						fc = ents.add_face( [ [0,-xc,-ya],[0,-xa,-ya],[0,-xa,ya],[0,xa,ya],[0,xa,yc],[0,-xc,yc] ] )
					else
						ed = []
						ed[0] = ents.add_edges( [[0,-xe,-ya],[0,-xa,-ya],[0,-xa,ya],[0,xa,ya],[0,xa,ye]] )
						ed[1] = ents.add_edges( [[0,xb,yc],[0,-xd,yc]] )
						ed[2] = ents.add_edges( [[0,-xc,yd],[0,-xc,-yb]] )
						ed[3] = add_arcedges( ents , [0,xb,ye], r2 ,270.degrees, 360.degrees, 2 )
						ed[4] = add_arcedges( ents , [0,-xe,-yb], r2 ,270.degrees, 360.degrees, 2 )
						ed[5] = add_arcedges( ents , [0,-xd,yd], r1 ,90.degrees, 180.degrees, 2 )
						#ed[3] = ents.add_arc([0,xb,ye], xvec, zvec,  r2 ,270.degrees, 360.degrees, 2 )
						#ed[4] = ents.add_arc([0,-xe,-yb], xvec, zvec,  r2 ,270.degrees, 360.degrees, 2 )
						#ed[5] = ents.add_arc([0,-xd,yd], xvec, zvec,  r1 ,90.degrees, 180.degrees, 2 )						
						fc = ents.add_face( ed.flatten )

					end
					return nil if fc == nil
					return fc
				end
				def add_CCshape_face( grp , gw , gh , t1 , t2 , r1 , r2 )#Mizogata
					ents = grp.entities
					shapePts = []
					holePts = []
					
					if r1 == 0.0 or r2 == 0.0
						xa = gw / 2
						xb = xa - t1
						ya = gh / 2
						yb = ya - t2
						fc = ents.add_face( [[0,-xa,-ya],[0,-xa,ya],[0,xa,ya],[0,xa,yb],[0,-xb,yb],[0,-xb,-yb],[0,xa,-yb],[0,xa,-ya]] )
					else
						#[-ghxgwxt1xt2xr1xr2
						#UI.messagebox "#{gw} ,#{gh} , #{t1} , #{t2} , #{r1} , #{r2}"
						ang = Math::PI * 5.0 / 180.0
						x0 = -gw / 2
						xa = gw / 2
						xb = x0 + t1
						xc = xb + r1 * Math.cos( ang )
						xe = xa - r2 * Math.cos( ang )
						xf = t1 / 2
						ya = gh / 2
						yj = ya - t2 + Math.sin( ang ) * (xe - xf).abs
						yk = ya - t2 - Math.sin( ang ) * (xc - xf).abs
						yi = yj + r2 * Math.cos( ang )
						yl = yk - r1 * Math.cos( ang )
						#UI.messagebox "#{x0} ,#{xa} , #{xb} , #{xc} , #{xe} , #{xf}\n#{ya} , #{yi} , #{yj} , #{yk} , #{yl}"
						xvec = Geom::Vector3d.new 0,1,0
						zvec = Geom::Vector3d.new 1,0,0

						ed = []
						ed[0] = ents.add_edges( [ [0,xa,-yi],[0,xa,-ya],[0,x0,-ya],[0,x0,ya],[0,xa,ya],[0,xa,yi] ] )
						ed[1] = ents.add_edges( [ [0,xe,yj],[0,xc,yk] ] )
						ed[2] = ents.add_edges( [ [0,xb,yl],[0,xb,-yl] ] )
						ed[3] = ents.add_edges( [ [0,xc,-yk],[0,xe,-yj] ] )
						

						cpt = [ 0 , xa-r2 , yi ]
						pts = []
						pts.push [0,xa,yi]
						arcpts( pts , cpt , r2 , 360.degrees , 275.degrees , 2 )
						pts.push [0,xe,yj]
						ed[4] = ents.add_curve( pts )
						#ed[4] = add_arcedges( ents ,  cpt , r2 , 360.degrees , 275.degrees , 2 )
						#ed[4] = ents.add_curve( [ [0,xa,yi] ,[ 0 , xa-r2 + r2 * Math.cos( ang.degrees ) , yi + r2 * Math.sin( ang.degrees )] , [0,xe,yj] ] )
						#ed[4] = ents.add_arc([0,xa-r2,yi], xvec, zvec,  r2 ,275.degrees, 360.degrees, 2 )

						cpt = [ 0 , xa-r2 ,-yi ]
						pts = []
						pts.push [0,xe,-yj]
						arcpts( pts , cpt , r2 , 85.degrees , 0.degrees , 2 )
						pts.push [0,xa,-yi]
						#ed[5] = add_arcedges( ents ,  cpt , r2 , 85.degrees , 0.degrees , 2 )
						ed[5] = ents.add_curve( pts )
						#ang = ( 0 + 85 ) / 2
						#ed[5] = ents.add_curve( [ [0,xe,-yj] ,[ 0 , xa-r2 + r2 * Math.cos( ang.degrees ) , -yi + r2 * Math.sin( ang.degrees )] , [0,xa,-yi] ] )
						#ed[5] = ents.add_arc([0,xa-r2,-yi], xvec, zvec,  r2 , 0.degrees, 85.degrees, 2 )
						
						cpt = [ 0 , x0 + t1 + r1 , yl ]
						pts = []
						pts.push [0,xb,yl]
						arcpts( pts , cpt , r1 , 95.degrees , 180.degrees , 4 )
						pts.push [0,xc,yk]
						#ed[6] = add_arcedges( ents ,  cpt , r1 , 95.degrees , 180.degrees , 4 )
						ed[6] = ents.add_curve( pts )
						#ang = ( 95 + 180 ) / 2
						#ed[6] = ents.add_curve( [ [0,xb,yl] ,[ 0 , x0 + t1 + r1 + r1 * Math.cos( ang.degrees ) , yl + r1 * Math.sin( ang.degrees )] , [0,xc,yk] ] )
						#ed[6] = ents.add_arc([0,x0 + t1 + r1,yl], xvec, zvec,  r1 , 95.degrees, 180.degrees, 2 )
						cpt = [ 0 , x0 + t1 + r1 , -yl ]
						pts = []
						pts.push [0,xb,-yl]
						arcpts( pts , cpt , r1 , 275.degrees , 180.degrees , 4 )
						pts.push [0,xc,-yk]
						#ed[7] = add_arcedges( ents , cpt , r1 , 275.degrees , 180.degrees , 4 )
						ed[7] = ents.add_curve( pts )
						#ang = ( 180 + 275 ) / 2
						#ed[7] = ents.add_curve( [ [0,xb,-yl] ,[ 0 , x0 + t1 + r1 + r1 * Math.cos( ang.degrees ) , -yl + r1 * Math.sin( ang.degrees )] , [0,xc,-yk] ] )
						#ed[7] = ents.add_arc([0,x0 + t1 + r1,-yl], xvec, zvec,  r1 , 180.degrees, 275.degrees, 2 )

						fc = ents.add_face( ed.flatten )
					end
					return nil if fc == nil
					return fc
				end
		def arcpts( pts , cpt , r2 , ang1 , ang2 , div )
			for d in ( 1..(div-1) )
				ang3 = ( ang1 * d + ang2 * ( div - d ) ) / div
				pts.push [ 0 , cpt.y + r2 * Math.cos( ang3 ) , cpt.z + r2 * Math.sin( ang3 )]
			end
		end
		def add_arcedges( ents , cpt , r2 , ang1, ang2 , div )#entities,center,radius,ang1,ang2,startpt,endpt,divides
			pts = []
			for d in ( 0..(div) )
				ang3 = ( ang1 * d + ang2 * ( div - d ) ) / div
				pts.push [ 0 , cpt.y + r2 * Math.cos( ang3) , cpt.z + r2 * Math.sin( ang3 )]
			end	
			ed = ents.add_curve pts
			return ed
		end
				def add_shapecomp_face( grp , shapename , gw , gh )
					defs = Sketchup.active_model.definitions
					ents = grp.entities
					compfilename = Sketchup.find_support_file "#{shapename}.skp", "Plugins/building_structure_tool/shapes/"
					if $kconvloaded == true
						compfilename = Kconv.tosjis(compfilename)
					end
					return nil if not FileTest.exist?( compfilename )
					t = Geom::Transformation.new( [ 0,0,0 ] )
					cdef = defs.load compfilename
					cins = ents.add_instance( cdef , t )
					ents2 = cins.explode
					fcs = ents2.find_all{|e| e.kind_of? Sketchup::Face }
					fc = fcs[0]
					gw = fc.bounds.depth
					gh = fc.bounds.height
					return fc
				end
				def add_Cshape_face( grp , gw , gh , t1 , t2 )#Mizogata
					ents = grp.entities
					shapePts = []
					holePts = []

					#C-ghxgwxt1xt2
					xa= gw / 2
					xb= xa - t2
					xc= xa - t2 * 2
					ya= gh / 2
					yb= ya - t2
					yc= ya - t2 * 2
					yd= ya - t1

					xvec = Geom::Vector3d.new 0,1,0
					zvec = Geom::Vector3d.new 1,0,0

					ed = []
					ed[0] = ents.add_edges( [ [0,-xc,ya],[0,xc,ya] ] )
					ed[1] = ents.add_edges( [ [0,xa,yc],[0,xa,yd],[0,xb,yd],[0,xb,yc] ] )
					ed[2] = ents.add_edges( [ [0,xc,yb],[0,-xc,yb] ] )
					ed[3] = ents.add_edges( [ [0,-xb,yc],[0,-xb,-yc] ] )
					ed[4] = ents.add_edges( [ [0,-xc,-yb],[0,xc,-yb] ] )
					ed[5] = ents.add_edges( [ [0,xb,-yc],[0,xb,-yd],[0,xa,-yd],[0,xa,-yc] ] )
					ed[6] = ents.add_edges( [ [0,xc,-ya],[0,-xc,-ya] ] )
					ed[7] = ents.add_edges( [ [0,-xa,-yc],[0,-xa,yc] ] )
					#ed[8] = add_arcedges( ents ,[0,-xc,yc], ( t2 * 2 ) ,90.degrees, 180.degrees, 2 )
					#ed[9] = add_arcedges( ents ,[0,-xc,yc], ( t2 ) ,90.degrees, 180.degrees, 2 )
					#ed[10] = add_arcedges( ents ,[0,xc,yc], ( t2 * 2 ) ,0.degrees, 90.degrees, 2 )
					#ed[11] = add_arcedges( ents ,[0,xc,yc], ( t2 ) ,0.degrees, 90.degrees, 2 )
					#ed[12] = add_arcedges( ents ,[0,xc,-yc], ( t2 * 2 ) ,270.degrees, 360.degrees, 2 )
					#ed[13] = add_arcedges( ents ,[0,xc,-yc], ( t2 ) ,270.degrees, 360.degrees, 2 )
					#ed[14] = add_arcedges( ents ,[0,-xc,-yc], ( t2 * 2 ) ,180.degrees, 270.degrees, 2 )
					#ed[15] = add_arcedges( ents ,[0,-xc,-yc], ( t2 ) ,180.degrees, 270.degrees, 2 )
					ed[8] = ents.add_arc([0,-xc,yc], xvec, zvec,  ( t2 * 2 ) ,90.degrees, 180.degrees, 2 )
					ed[9] = ents.add_arc([0,-xc,yc], xvec, zvec,  ( t2 ) ,90.degrees, 180.degrees, 2 )
					ed[10] = ents.add_arc([0,xc,yc], xvec, zvec,  ( t2 * 2 ) ,0.degrees, 90.degrees, 2 )
					ed[11] = ents.add_arc([0,xc,yc], xvec, zvec,  ( t2 ) ,0.degrees, 90.degrees, 2 )
					ed[12] = ents.add_arc([0,xc,-yc], xvec, zvec,  ( t2 * 2 ) ,270.degrees, 360.degrees, 2 )
					ed[13] = ents.add_arc([0,xc,-yc], xvec, zvec,  ( t2 ) ,270.degrees, 360.degrees, 2 )
					ed[14] = ents.add_arc([0,-xc,-yc], xvec, zvec,  ( t2 * 2 ) ,180.degrees, 270.degrees, 2 )
					ed[15] = ents.add_arc([0,-xc,-yc], xvec, zvec,  ( t2 ) ,180.degrees, 270.degrees, 2 )
					fc = ents.add_face( ed.flatten )

					return nil if fc == nil
					return fc
				end
				def add_Tshape_face( grp , gw , gh , t1 , t2 , r1 )
					ents = grp.entities
					ya = gh / 2
					yb = ya - t2
					yc = yb - r1
					xa = gw / 2
					xc = t1 / 2
					xb = xc + r1
					xvec = Geom::Vector3d.new 0,1,0
					zvec = Geom::Vector3d.new 1,0,0
					if r1 == 0.0
						fc = ents.add_face( [ [0,xa,ya],[0,xa,yb],[0,xc,yb],[0,xc,-ya],[0,-xc,-ya],[0,-xc,yb],[0,-xa,yb],[0,-xa,ya] ] )
					else
						ed = []
						ed[0] = ents.add_edges( [ [0,-xb,yb],[0,-xa,yb],[0,-xa,ya],[0,xa,ya],[0,xa,yb],[0,xb,yb] ] )
						ed[1] = ents.add_edges( [ [0,xc,yc],[0,xc,-ya],[0,-xc,-ya],[0,-xc,yc] ] )
						#add_arcedges( ents ,
						ed[2] = add_arcedges( ents , [0,xb,yc], r1 , 90.degrees, 180.degrees, 2 )
						ed[3] = add_arcedges( ents , [0,-xb,yc], r1 , 0.degrees, 90.degrees, 2 )
						#ed[2] = ents.add_arc( [0,xb,yc], xvec, zvec,  r1 , 90.degrees, 180.degrees, 2 )
						#ed[3] = ents.add_arc( [0,-xb,yc], xvec, zvec,  r1 , 0.degrees, 90.degrees, 2 )
						fc = ents.add_face( ed.flatten )
					end
					return nil if fc == nil
					return fc
				end
				def add_FBshape_face( grp , gw , gh )
					ents = grp.entities
					ya = gh / 2
					xa = gw / 2
					xvec = Geom::Vector3d.new 0,1,0
					zvec = Geom::Vector3d.new 1,0,0

					fc = ents.add_face( [ [0,xa,ya],[0,xa,-ya],[0,-xa,-ya],[0,-xa,ya] ] )

					return nil if fc == nil
					return fc
				end
		def auto_create_from_lines( sellines = [] )
			allpts = []

			if Sketchup.version.to_f >= 7
				Sketchup.active_model.start_operation TST_common.langconv("Draw Multi Building Structures") ,true
			else
				Sketchup.active_model.start_operation TST_common.langconv("Draw Multi Building Structures")
			end
			pts = []
			curveids = []
			sellines.each{|e|
				pts = []
				if e.kind_of? Sketchup::ConstructionLine
					pts[0] = e.start
					pts[1] = e.end
				elsif e.kind_of? Sketchup::Edge
					if e.curve == nil
						pts[0] = e.start.position
						pts[1] = e.end.position 
					elsif curveids.index( e.curve.entityID ) == nil
						pts = e.curve.vertices.collect{|vt| vt.position }
						curveids.push e.curve.entityID
					end
				end
				if pts != []
					pts.each{|ptpt|
						allpts.push ptpt if allpts.find_all{|pt| pt == ptpt }.size == 0
					}
					#allpts.push pts[1] if allpts.find_all{|pt| pt == pts[1] }.size == 0
					if @bclass == "STEEL_COLUMN" or @bclass == "RC_COLUMN" or @bclass == "RC_FOOTING"
					else
						cgeom = drawStructure( pts , @beams_spec , @beams_just , @beams_vjust , @beams_axis , @beams_top , @beams_rot , @beams_mirz , @wall_width )
					end
				end
			}
			#allpts.uniq!
			if @bclass == "STEEL_COLUMN" or @bclass == "RC_COLUMN"
				allpts.each{|apt|
					pts[0] = [ apt.x , apt.y , apt.z ]
					pts[1] = [ apt.x , apt.y , apt.z + @beams_height ]
					cgeom = drawStructure( pts , @beams_spec , @beams_just , @beams_vjust , @beams_axis , @beams_top , @beams_rot , @beams_mirz , @wall_width)
				}
			elsif @bclass == "RC_FOOTING"
				allpts.each{|apt|
					pts[0] = [ apt.x , apt.y , apt.z ]
					pts[1] = [ apt.x , apt.y , apt.z + 1000.mm ]
					cgeom = drawStructure( pts , @beams_spec , @beams_just , @beams_vjust , @beams_axis , @beams_top , @beams_rot , @beams_mirz , @wall_width)
				}
			end
			Sketchup.active_model.commit_operation
		end
		def getLengthByUnits( lstr )
			if @units == "inch"
				l = lstr.to_f.inch
			else
				l = lstr.to_f.mm
			end
			return l
		end
		def drawMwall( pts , beams_spec , beams_mirz )
	        model = Sketchup.active_model
			path = File.dirname( File.expand_path(__FILE__) ) + '/mwalls/' + beams_spec
			return if FileTest.exist?(path) != true

			definitions = model.definitions
			cdef = definitions.load( path )
			cdbb = cdef.bounds
			gw = 0.0
			gh = 0.0
			gh = cdbb.height
			gw = cdbb.depth
			
			tf = Geom::Transformation.new( Geom::Point3d.new( 0,0,0 ) )
			grp = Sketchup.active_model.active_entities.add_group
	        ents = grp.entities
			cins = ents.add_instance( cdef , tf )
			cins.explode

			ozvec = Geom::Vector3d.new( 0,0,1 )
			sec = Sketchup.active_model.selection.find_all{|se| se.kind_of? Sketchup::SectionPlane }
			if sec != []
				ozvec = Geom::Vector3d.new( -sec[0].get_plane[0] , -sec[0].get_plane[1] , -sec[0].get_plane[2] )
			end
			if ozvec.parallel?( Geom::Vector3d.new( 0,0,1 ) )
				oyvec = Geom::Vector3d.new( 0,1,0 )
			else
				oyvec = ozvec.cross( Geom::Vector3d.new( 0,0,1 ) ).normalize
			end
			vec1to2 = pts[0].vector_to( pts[1] )
			dist = pts[0].distance(pts[1])
			xvec = vec1to2.normalize!
			col = false
			
			if xvec.parallel?( ozvec )
				yvec = oyvec
				zvec = yvec.cross( xvec ).normalize
				col = true
			else
				yvec = xvec.cross( ozvec ).normalize
				zvec = yvec.cross( xvec ).normalize
			end
			
			tvec = Geom::Vector3d.new 0,0,0
			trot = Geom::Transformation.rotation Geom::Point3d.new(0,0,0) , Geom::Vector3d.new( 1,0,0 ) , 0

			tgr = Geom::Transformation.axes pts[0], xvec, yvec, zvec
			#if fl != 0.0
			#	tvvec2 = Geom::Vector3d.new 0,0,fl
			#	tgr = Geom::Transformation.translation( tvvec2 ) * tgr
			#end
			
			grp.transform! tgr

			#if col == false
			#	#tvec = tvec + tvvec# + Geom::Vector3d.new( 0, 0 , beams_top )
			#	t = Geom::Transformation.translation tvec
			#	ents.transform_entities(t, ents.collect{|e| e } )
			#end
			
			##My Mistake. Mwall is create mirrored about imaging.
			if beams_mirz == TST_common.langconv("Yes")
			else
				t = Geom::Transformation.scaling [0,0,0], 1 , -1 , 1
				ents.transform_entities(t, ents.collect{|e| e } )
			end

			ptpts = pts.collect{|ptpt| ptpt.transform( tgr.inverse ) }
			if pts.size == 2
				ents.each{|ent|
					if ent.kind_of? Sketchup::ComponentInstance or ent.kind_of? Sketchup::Group
						ent.make_unique
						#fc_start = get_startface( cform1 )
						#fc_end = get_endface( cform1 )
						#fc_start[0].
						ps1 = Geom::Point3d.new(0,0,0)
						tf1 = ent.transformation
						plane2 = [ Geom::Point3d.new( dist,0,0 ) , Geom::Vector3d.new( -1,0,0) ]
						plane22 = [ Geom::Point3d.new( dist,0,0 ).transform( tf1.inverse ) , Geom::Vector3d.new( -1,0,0).transform( tf1.inverse ) ]
						extend_strc = ExtendStructures.new
						extend_strc.extend_form_do( ent , tf1 , ps1 , plane2 , plane22 )
					end
				}
			else
				#if col == false
				#	rail = ents.add_curve( ptpts )
				#	fc.reverse!
				#	fc.followme rail
				#else
				#	return
				#end
			end

			grp.name = "MWALL-#{ File.basename( beams_spec , "*.skp" )}"
			grp.set_attribute "BEAM_SPECS","CLASS",@bclass
			grp.set_attribute "BEAM_SPECS","HUGO", beams_spec
			#grp.set_attribute "BEAM_SPECS","PROFILE",bprofile
			#grp.set_attribute "BEAM_SPECS","ROTATE",rot
			grp.set_attribute "BEAM_SPECS","MIRRORZ",beams_mirz
			if ptpts.size > 2
				grp.set_attribute "BEAM_SPECS","CURVE",true
			else
				grp.set_attribute "BEAM_SPECS","CURVE",false
			end
			ipt = [ pts[0].distance( pts[1] )/2 , 0,0]
			return grp
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
		def drawStructure( pts , beams_spec , beams_just , beams_vjust , beams_axis , beams_top , beams_rot , beams_mirz , wall_width = 0.mm )
			if @bclass == "MWALL"
				grp = drawMwall( pts , beams_spec , beams_mirz )
				return grp
			end
	        grp=Sketchup.active_model.active_entities.add_group
	        ents=grp.entities
			#shape_pts = []
			#bspecs = beams_spec.split(',')
			bspecs = split_csvline( beams_spec )
			hugo = bspecs[0]
			bprofile = bspecs[1]
			
			fl = getLengthByUnits( bspecs[2] ) + beams_top
			mat = bspecs[3]
			rot = bspecs[4].to_f.degrees + beams_rot.degrees

			shapePts = []

			shapetype = ""
			fm_name = bspecs[5]
			bm_name = bspecs[6]
			sm_name = bspecs[7]
			gw = 0.0
			gh = 0.0
			
			if bprofile[/^\[SHAPE\](.*)/]
				shapename = $1.to_s
				shapetype = "SHAPE"
			elsif bprofile[/^B*H-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
			#H-STEEL
				gh  = getLengthByUnits( $1 )
				gw  = getLengthByUnits( $2 )
				gt1 = getLengthByUnits( $3 )
				gt2 = getLengthByUnits( $4 )
				r1 = 0.0
				if bprofile[/^B*H-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
					r1 = getLengthByUnits( $5 )
				end
				shapetype = "H"
			elsif bprofile[/^FB-*(\d+\.*\d*)[xX](\d+\.*\d*)/]
			#Circleshape-STEEL
				gh = getLengthByUnits( $1 )
				gw = getLengthByUnits( $2 )
				shapetype = "FB"
			elsif bprofile[/^C*T-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
			#CT-STEEL
				gh  = getLengthByUnits( $1 )
				gw  = getLengthByUnits( $2 )
				gt1 = getLengthByUnits( $3 )
				gt2 = getLengthByUnits( $4 )
				r1 = 0.0
				if bprofile[/^C*T-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
					r1 = getLengthByUnits( $5 )
				end
				shapetype = "T"
			elsif bprofile[/^SHS-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
			#Rectang shape-STEEL
				gh  = getLengthByUnits( $1 )
				gw  = getLengthByUnits( $2 )
				gt1 = getLengthByUnits( $3 )
				r1 = 0.0
				if bprofile[/^SHS-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
					r1 = getLengthByUnits( $4 )
				end
				shapetype = "SHS"

			elsif bprofile[/^CHS-*(\d+\.*\d*)[xX](\d+\.*\d*)/]
			#Circleshape-STEEL
				gh  = getLengthByUnits( $1 )
				gw = gh
				r = gh / 2.0
				gt1 = getLengthByUnits( $2 )
				shapetype = "CHS"
			elsif bprofile[/^L-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
			#H-STEEL
				gh  = getLengthByUnits( $1 )
				gw  = getLengthByUnits( $2 )
				gt1 = getLengthByUnits( $3 )
				gt2 = gt1
				r1 = 0.0
				r2 = 0.0
				if bprofile[/^L-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
					r1 = getLengthByUnits( $4 )
					r2 = getLengthByUnits( $5 )
				end
				shapetype = "L"
			#add_Lshape_face( gfrp , gw , gh , gt1 ,r1 , r2)
			elsif bprofile[/^C-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
			#C-STEEL
				gh  = getLengthByUnits( $1 )
				gw  = getLengthByUnits( $2 )
				gt1 = getLengthByUnits( $3 )
				gt2 = getLengthByUnits( $4 )

				shapetype = "C"
			elsif bprofile[/^\[-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
			#[-STEEL
				gh  = getLengthByUnits( $1 )
				gw  = getLengthByUnits( $2 )
				gt1 = getLengthByUnits( $3 )
				gt2 = getLengthByUnits( $4 )
				r1 = 0.0
				r2 = 0.0
				if bprofile[/^\[-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
					r1 = getLengthByUnits( $5 )
					r2 = getLengthByUnits( $6 )
				end
				shapetype = "CC"
			elsif bprofile[/^RC-*(\d+\.*\d*)[xX](\d+\.*\d*)/] or bprofile[/^(\d+\.*\d*)[xX](\d+\.*\d*)/]
				gh  = getLengthByUnits( $2 )
				gw  = getLengthByUnits( $1 )
				shapePts.push [ 0, -gw/2 , gh/2]
				shapePts.push [ 0, gw/2 , gh/2]
				shapePts.push [ 0, gw/2 , -gh/2]
				shapePts.push [ 0, -gw/2 , -gh/2]
				shapetype = "RECT"
			elsif bprofile[/^RCW-*(\d+\.*\d*)/] or bprofile[/^W-*(\d+\.*\d*)/]
				gh  = @beams_height
				gw = 0.0
				gw = getLengthByUnits( $1 ) if $1
				gw = wall_width if gw == 0.0
				shapePts.push [ 0, -gw/2 , gh/2]
				shapePts.push [ 0, gw/2 , gh/2]
				shapePts.push [ 0, gw/2 , -gh/2]
				shapePts.push [ 0, -gw/2 , -gh/2]
				shapetype = "RECT"
			elsif bprofile[/^RCF-*(\d+\.*\d*)[xX](\d+\.*\d*)[xX](\d+\.*\d*)/]
				#UI.messagebox "test"
				gh  = getLengthByUnits( $2 )
				gw  = getLengthByUnits( $1 )
				pts[1] = [ pts[0].x , pts[0].y , pts[0].z - getLengthByUnits( $3 ) ]
				shapePts.push [ 0, -gw/2 , gh/2]
				shapePts.push [ 0, gw/2 , gh/2]
				shapePts.push [ 0, gw/2 , -gh/2]
				shapePts.push [ 0, -gw/2 , -gh/2]
			else
				return
			end

			ozvec = Geom::Vector3d.new( 0,0,1 )
			sec = Sketchup.active_model.selection.find_all{|se| se.kind_of? Sketchup::SectionPlane }
			if sec != []
				ozvec = Geom::Vector3d.new( -sec[0].get_plane[0] , -sec[0].get_plane[1] , -sec[0].get_plane[2] )
			end
			if ozvec.parallel?( Geom::Vector3d.new( 0,0,1 ) )
				oyvec = Geom::Vector3d.new( 0,1,0 )
			else
				oyvec = ozvec.cross( Geom::Vector3d.new( 0,0,1 ) ).normalize
			end
			vec1to2 = pts[0].vector_to( pts[1] )
			dist = pts[0].distance(pts[1])
			xvec = vec1to2.normalize!
			col = false
			
			if xvec.parallel?( ozvec )
				yvec = oyvec
				zvec = yvec.cross( xvec ).normalize
				col = true
			else
				yvec = xvec.cross( ozvec ).normalize
				#zvec = ozvec
				zvec = yvec.cross( xvec ).normalize
				#yvec.cross( xvec ).normalize
			end

			trot = Geom::Transformation.rotation Geom::Point3d.new(0,0,0) , Geom::Vector3d.new( 1,0,0 ) , 0
			if rot == 90.degrees
				gw , gh = gh ,gw
			end	

			if beams_just == TST_common.langconv("Left")
				tvec = Geom::Vector3d.new 0,-gw/2,0
			elsif beams_just == TST_common.langconv("Right")
				tvec = Geom::Vector3d.new 0,gw/2,0
			elsif beams_just == TST_common.langconv("Center")
				tvec = Geom::Vector3d.new 0,0,0
			end
			if beams_vjust == TST_common.langconv("Top")
				tvvec = Geom::Vector3d.new 0,0,-gh/2
			elsif beams_vjust == TST_common.langconv("Bottom")
				tvvec = Geom::Vector3d.new 0,0,gh/2
			elsif beams_vjust == TST_common.langconv("Middle")
				tvvec = Geom::Vector3d.new 0,0,0
			end

	        if beams_axis == TST_common.langconv("Yes")
	            cline=ents.add_cline([0,0,0],[ dist , 0, 0 ] )
	            cline.stipple="-.-"
				tgr = Geom::Transformation.translation tvec
				ents.transform_entities(tgr,cline)
	        end
			
			tgr = Geom::Transformation.axes pts[0], xvec, yvec, zvec
			if fl != 0.0
				tvvec2 = Geom::Vector3d.new 0,0,fl
				tgr = Geom::Transformation.translation( tvvec2 ) * tgr
			end
			grp.transform! tgr
			
			
			##shorino junban wo saikentousuru
			if rot == 90.degrees
				gw , gh = gh ,gw
			end	
				if shapetype == "SHAPE"
					fc = add_shapecomp_face( grp , shapename , gw , gh )
				elsif shapetype == "H"
					fc = add_Hshape_face( grp , gw , gh , gt1 , gt2 , r1  )
				elsif shapetype == "T"
					fc = add_Tshape_face( grp , gw , gh , gt1 , gt2 , r1  )
				elsif shapetype == "FB"
					fc = add_FBshape_face( grp , gw , gh )
				elsif shapetype == "SHS"
					fc = add_SHshape_face( grp , gw , gh , gt1 , r1 )
				elsif shapetype == "CHS"
					fc = add_CHshape_face( grp , gw , gh , gt1 , r )
				elsif shapetype == "L"
					fc = add_Lshape_face( grp , gw , gh , gt1 , gt2 ,r1 , r2 )
				elsif shapetype == "C"
					fc = add_Cshape_face( grp , gw , gh , gt1 ,gt2 )
				elsif shapetype == "CC"
					fc = add_CCshape_face( grp , gw , gh , gt1 , gt2, r1 , r2 )
				else
					fc = ents.add_face( shapePts )
				end
			if rot == 90.degrees
				gw , gh = gh ,gw
			end	
			
			if fm_name != ""
				fmat = add_new_material( fm_name )
				fc.material = fmat
			end
			if bm_name != ""
				bmat = add_new_material( bm_name )
				fc.back_material = bmat
			end
			#fc = ents.add_face shapePts
			#backmaterial = "st_backmaterial"
			#bmat = Sketchup.active_model.materials[ backmaterial ]
			#fc.material = Sketchup.active_model.materials.current
			#fc.back_material = "black"
			#if holePts.size > 0
			#	hole = ents.add_face holePts
			#	ents.erase_entities hole
			#end
			
			if rot != 0
				trot = Geom::Transformation.rotation Geom::Point3d.new(0,0,0) , Geom::Vector3d.new( 1,0,0 ) , rot
				ents.transform_entities(trot,fc)
			end
			if col == false
				tvec = tvec + tvvec# + Geom::Vector3d.new( 0, 0 , beams_top )
				t = Geom::Transformation.translation tvec
				ents.transform_entities(t,fc)
			end
			if beams_mirz == TST_common.langconv("Yes")
				t = Geom::Transformation.scaling [0,0,0], 1 , -1 , 1
				ents.transform_entities(t,fc)
			end
			fc.reverse!
			fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_SIDE"
			ptpts = pts.collect{|ptpt| ptpt.transform( tgr.inverse ) }
			if pts.size == 2
				fc.pushpull dist,true
				fc.reverse!	
				fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_START"
			else
				if col == false
					rail = ents.add_curve( ptpts )
					fc.reverse!
					fc.followme rail
				else
					return
				end
			end
			startfcvec = ptpts[1].vector_to( ptpts[0] )
			endfcvec = startfcvec.reverse
			#endfcvec = ptpts[ ptpts.size - 2 ].vector_to( ptpts[ ptpts.size - 1 ] )
			#railclose = true if ptpts[0] == ptpts[ ptpts.size - 1 ]
			grp.entities.find_all{|e| e.kind_of? Sketchup::Face }.each{|fc|
				#if fc.normal.samedirection? Geom::Vector3d.new( 1,0,0 )
				softedges = fc.edges.find_all{|fced| fced.soft? == true }
				if fc.normal.samedirection? endfcvec and softedges == []
					#if fc.get_attribute( "BEAMS_FACES", "LOCATION" ) == "FC_START"
					fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_END"
					#end
				elsif fc.normal.samedirection? startfcvec and softedges == []
					fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_START"
				elsif shapetype == "RECT" #bprofile[/RC.*/]
					if fc.normal.samedirection? Geom::Vector3d.new( 0,0,1 )
						fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_TOP"
					elsif fc.normal.samedirection? Geom::Vector3d.new( 0,0,-1 )
						fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_BOTTOM"
					elsif fc.normal.samedirection? Geom::Vector3d.new( 0,-1,0 )
						fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_LEFT"
					elsif fc.normal.samedirection? Geom::Vector3d.new( 0,1,0 )
						fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_RIGHT"
					end
				else
					fc.set_attribute "BEAMS_FACES", "LOCATION" , "FC_SIDE"
				end
			}
			grp.entities.find_all{|e| e.kind_of? Sketchup::Edge and e.smooth? == false }.each{|ed|
				ed.set_attribute "BEAMS_FACES", "LOCATION" , "ED_OUTLINE"
			}
			
			grp.name = "#{hugo}|#{bprofile}"
			grp.set_attribute "BEAM_SPECS","CLASS",@bclass
			grp.set_attribute "BEAM_SPECS","HUGO",hugo
			grp.set_attribute "BEAM_SPECS","PROFILE",bprofile
			grp.set_attribute "BEAM_SPECS","MATERIAL",mat
			#grp.set_attribute "BEAM_SPECS","FL",fl
			grp.set_attribute "BEAM_SPECS","ROTATE",rot
			grp.set_attribute "BEAM_SPECS","MIRRORZ",beams_mirz
			if ptpts.size > 2
				grp.set_attribute "BEAM_SPECS","CURVE",true
			else
				grp.set_attribute "BEAM_SPECS","CURVE",false
			end
			ipt = [ pts[0].distance( pts[1] )/2 , 0,0]
			#ipt.transform!( Geom::Transformation.scaling( 0.5 ) )
			#draw_hugo_text grp , "#{hugo}:#{bprofile}" ,ipt
			#label_hugo_text grp , "#{hugo}:#{bprofile}" ,ipt
			#label_dimw grp , gw , ipt
			grp.entities.find_all{|de| de.kind_of? Sketchup::Drawingelement }.each{|e| e.layer = "Structure-#{@bclass}" }
			return grp
		end
		def label_hugo_text(grp , hugo , ipt )
			return nil if hugo == ""
			Sketchup.active_model.layers.add "Structure-TAG-TEXT"
			ents = grp.entities
			hgrp = ents.add_group
			#pdir = File.dirname( File.expand_path(__FILE__) ) + '/building_structure_tool'
			defs = Sketchup.active_model.definitions
			path=Sketchup.find_support_file "bst_tag1.skp","plugins/building_structure_tool"
			df = defs.load path
			t = Geom::Transformation.translation( [0,0,0].vector_to( ipt ) )
			ci = hgrp.entities.add_instance df , t
			ci.layer = "Structure-TAG-TEXT"
			ci.explode.each{|e|
				if e.kind_of? Sketchup::Text
					e.text = hugo
					e.visible = false
					#e.layer = "Structure-TAG-TEXT"
				end
			}
			hgrp.layer = "Structure-TAG-TEXT"
			hgrp.explode
		end
		def label_dimw(grp , width , ipt )
			return nil if width == 0.0
			ents = grp.entities
			#pdir = File.dirname( File.expand_path(__FILE__) ) + '/building_structure_tool'
			defs = Sketchup.active_model.definitions
			path=Sketchup.find_support_file "bst_dimw1.skp","plugins/building_structure_tool"
			df = defs.load path
			t = Geom::Transformation.scaling( [0,0,0] , width / 100.mm )
			t = Geom::Transformation.translation( [0,0,0].vector_to( ipt ) ) * t
			ci = ents.add_instance df , t
			myset = []
			cents = ci.explode
			cents.each{|e|
				if e.kind_of? Sketchup::Edge
					myset.push e
				elsif e.kind_of? Sketchup::Drawingelement
					e.layer = "Structure_DimensionW"
				end
			}
			ents.erase_entities myset
		end
		def draw_hugo_text( grp , hugo , ipt )
			return nil if hugo == ""
			Sketchup.active_model.layers.add "Structure-TAG-TEXT"
			ents = grp.entities
			hgrp = ents.add_group
			hgrp.entities.add_3d_text hugo , TextAlignLeft , "Arial" , false, false, 120.mm , 0.2, 50.mm, true, 0.0
			hgrp.material = "Black"

			#t = Geom::Transformation.scaling( [0,0,0] , 100 / 25.4 )
			bbox = hgrp.local_bounds
			# ( - hgrp.bounds.width ) / 2 
			t = Geom::Transformation.translation( [ 0,0,0 ].vector_to( [ - bbox.center.x , bbox.height * 3 , 0 ] ) )
			hgrp.entities.transform_entities t , hgrp.entities.find_all{|e| e.kind_of? Sketchup::Face }
			
			t = Geom::Transformation.rotation( [0,0,0] , [0,0,0].vector_to( [0,1,0] ), 180.degrees )
			t = t * Geom::Transformation.rotation( [0,0,0] , [0,0,0].vector_to( [0,0,1] ), 180.degrees )
			t = Geom::Transformation.translation( [0,0,0].vector_to( ipt ) ) * t
			hgrp.transform! t
			hgrp.name = "[TAG]#{hugo}"
			hgrp.entities.each{|e|
				e.layer = "Structure-TAG-TEXT"
				if e.kind_of? Sketchup::Edge
					e.visible = false
				end
			}
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
    end # class Beam
end#module

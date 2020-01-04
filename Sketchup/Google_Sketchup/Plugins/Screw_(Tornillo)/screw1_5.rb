# Name :          Screw 3.0
# Description :   screw/spins a set of edges/components around the 
#                 z-axis (if "turns" is a negative number, rotation 
#                 is clockwise)
# Author :        Frank Wiesner
# Usage :         1. select edges and/or Components
#                 2. run script
#                 3. enter desired values in dialog box
#                 4. pick two points (offset vector)
# Note:           selecting the "spin" tool is a shortcut for selecting 
#                 the "screw" tool and picking two identical points for 
#                 the offset vector.
# Date :          25.Jun.2oo5
# Type :          script
# History:        
#                 3.0 (25.Jun.2005) - offset vector is picked interactively
#                 2.2 (31.Aug.2004) - supports spin operation
#                 2.1 (31.Aug.2004) - remembers turn/step values during SU session
#                                     expressions in dialog (i.e. use turns = 483/360.0 for a 483 degrees turn)
#                 2.0 (30.Aug.2004) - support for ConstructionPoints
#                                     instant drawing (although Sketchup does not update during execution)
#                                     status info
#                                     new algorithm for offset vector
#                                     fractional value support
#                 1.4  (5.Aug.2oo4) - cleaned up ugly transformation code, script now faster
#                                     error checking for "add_face': Points are not planar" errors
#                 1.3  (4.Aug.2oo4) - support for components
#                 1.2  (4.Aug.2oo4) - edges are smoothed
#                 1.1  (3.Aug.2oo4) - if "turns" is a negative number, rotation is clockwise, minor fixes
#                 1.o  (3.Aug.2oo4) - first version


require 'sketchup.rb'

class ScrewToolBase

    def initialize
        @smoothFaces = true
    end


    def screw(pt1, pt2, steps, turns)
        mo = Sketchup.active_model()
        ss = mo.selection()
                
        # neg. steps not allowed!
        if (steps < 0) 
            steps = -1*steps
        end
        
        rotDir = 1
        if (turns < 0) 
            turns = -1*turns
            rotDir = -1
        end
        
        angularOffset = 360.degrees/(steps.floor)
        angularOffsetComponent = 360.degrees/steps
        targetAngle = 360.degrees*turns

        # copy all relevant points in an array...
        
        verticesArray = Array.new()
        edgeArray = Array.new()
        compArray = Array.new()
        constrPtsArray = Array.new()
        
        ss.each {|e| 
            if (e.kind_of? Sketchup::Edge)
                verticesArray.push(e.vertices) 
                edgeArray.push(e) 
            end
            compArray.push(e) if e.kind_of? Sketchup::ComponentInstance
            constrPtsArray(e.position) if e.kind_of? Sketchup::ConstructionPoint
        }
        if (edgeArray.empty? && compArray.empty?)
            # UI.messagebox("At least one edge or component must be selected!")
        else
            verticesArray.flatten!
            ptArray = Array.new()
            verticesArray.each do |v|
                ptArray.push(Geom::Point3d.new(v.position))
            end
            
            # determin vertical and radial Offset
            
            fullOffsetVector = Geom::Vector3d.new(pt2.x-pt1.x, pt2.y-pt1.y, pt2.z-pt1.z)

            faceOrientation = 1
            faceOrientation = -1 if (fullOffsetVector.z<0)
            xOff = fullOffsetVector.x/steps
            yOff = fullOffsetVector.y/steps
            zOff = fullOffsetVector.z/steps

            totalNumberOfOperations = steps*turns*(ptArray.length/2)+steps*turns
            doneNumberOfOperations = 0

            # now we can do the transformations...
            # we build a 2D Array for all points
            
            
            # screwing Edges and Construction Points...

            newPtsArray = Array.new()
            oldPtsArray = ptArray;
            newConPtsArray = Array.new()
            oldConPtsArray = constrPtsArray;

            if (!fullOffsetVector.valid?)
                targetAngle = 360.degrees if (targetAngle>360.degrees)
                targetAngle = -360.degrees if (targetAngle<-360.degrees)
            end

            i = 1
            while (i*angularOffset < targetAngle)
                
                # defining transformations

                rot=Geom::Transformation.rotation(ORIGIN, Z_AXIS, i*angularOffset*rotDir)
                trans=Geom::Transformation.translation([i*xOff, i*yOff, i*zOff])

                # transform Edge Points

                newPtsArray = Array.new()
                for k in 0..(ptArray.length-1) 
                    newpt=Geom::Point3d.new([ptArray[k].x ,ptArray[k].y ,ptArray[k].z])
                    newpt.transform!(trans)
                    newpt.transform!(rot) 
                    newPtsArray[k] = newpt
                    if ((k%2)==1)
                        make_edges_and_faces(newPtsArray[k-1], newPtsArray[k], oldPtsArray[k-1], oldPtsArray[k], angularOffset*rotDir, faceOrientation)
                    end
                end
                oldPtsArray = newPtsArray

                # now the Construction Points

                newConPtsArray = Array.new()
                for k in 0..(constrPtsArray.length-1) 
                    newpt=Geom::Point3d.new([constrPtsArray[k].x ,constrPtsArray[k].y ,constrPtsArray[k].z])
                    newpt.transform!(trans)
                    newpt.transform!(rot) 
                    newConPtsArray[k] = newpt
                    mo.entities.add_edges(oldConPtsArray[k], newConPtsArray[k])
                end
                oldConPtsArray = newConPtsArray
                
                doneNumberOfOperations = doneNumberOfOperations + (ptArray.length/2)
                Sketchup.set_status_text("working... ("+String((100*Float(doneNumberOfOperations)/Float(totalNumberOfOperations)).floor)+"%)") 

                i = i+1
            end

            # doing ramaining edges (fractional part)
            
            # defining transformations

            rot=Geom::Transformation.rotation(ORIGIN, Z_AXIS, i*angularOffset*rotDir)
            trans=Geom::Transformation.translation([i*xOff, i*yOff, i*zOff])
            rotAux=Geom::Transformation.rotation(ORIGIN, Z_AXIS, targetAngle)

            # transform Edge Points

            newPtsArray = Array.new()
            for k in 0..(ptArray.length-1) 
                newpt=Geom::Point3d.new([ptArray[k].x ,ptArray[k].y ,ptArray[k].z])
                newpt.transform!(trans)
                newpt.transform!(rot) 
                aux=Geom::Point3d.new([ptArray[k].x ,ptArray[k].y ,ptArray[k].z])
                aux.transform!(rotAux) 
                slicePlane = [aux, Z_AXIS.cross(ORIGIN-aux)]
                sliceLine = [newpt, oldPtsArray[k]] 
                newPtsArray[k] = Geom.intersect_line_plane(sliceLine,slicePlane)
                if ((k%2)==1)
                    make_edges_and_faces(newPtsArray[k-1], newPtsArray[k], oldPtsArray[k-1], oldPtsArray[k], angularOffset*rotDir, faceOrientation)
                end
            end
            oldPtsArray = newPtsArray

            
            # transform Construction Points

            newConPtsArray = Array.new()
            for k in 0..(constrPtsArray.length-1) 
                newpt=Geom::Point3d.new([constrPtsArray[k].x ,constrPtsArray[k].y ,constrPtsArray[k].z])
                newpt.transform!(trans)
                newpt.transform!(rot) 
                aux=Geom::Point3d.new([ptArray[k].x ,ptArray[k].y ,ptArray[k].z])
                aux.transform!(rotAux) 
                slicePlane = [aux, Z_AXIS.cross(ORIGIN-aux)]
                sliceLine = [newpt, oldPtsArray[k]] 
                newConPtsArray[k] = Geom.intersect_line_plane(sliceLine,slicePlane)
                mo.entities.add_edges(oldConPtsArray[k], newConPtsArray[k])
            end
            oldConPtsArray = newConPtsArray

            # screwing Components...

            targetAngle = 360.degrees-0.001 if !fullOffsetVector.valid? 

            i = 1
            while (i*angularOffsetComponent < targetAngle)
                
                # defining transformations

                rot=Geom::Transformation.rotation(ORIGIN, Z_AXIS, i*angularOffsetComponent*rotDir)
                trans=Geom::Transformation.translation([i*xOff, i*yOff, i*zOff])

                # insert Components and transform...

                compArray.each do |c|
                    nc = mo.entities.add_instance(c.definition, c.transformation) 
                    nc.transform!(trans)
                    nc.transform!(rot)
                end

                doneNumberOfOperations = doneNumberOfOperations + 1
                Sketchup.set_status_text("working... ("+String((100*Float(doneNumberOfOperations)/Float(totalNumberOfOperations)).floor)+"%)") 

                i = i+1
            end

            Sketchup.set_status_text("ready.") 
        end 
    end

    def get_next_edge(e,v)
        conEdges = v.edges
        return nil if (conEdges.length < 2) 
        return conEdges[1] if (e == conEdges[0]) 
        return conEdges[0]
    end

    def make_edges_and_faces(p1, p2, p3, p4, ao, fo)
        mo=Sketchup.active_model()
        newEdges = Array.new()
        newEdges.push(mo.entities.add_edges(p1, p2).first)
        newEdges.push(mo.entities.add_edges(p4, p1).first)
        newEdges.push(mo.entities.add_edges(p3, p1).first)
        newEdges.push(mo.entities.add_edges(p4, p2).first)
        # test for colinear to avoid "add_face': Points are not planar" errors
        notColinear = true;
        vec1 = p3 - p4
        vec2 = p3 - p1
        notColinear = vec1.cross(vec2).valid?
        if (notColinear)
            if (ao*fo < 0) 
                mo.entities.add_face(p3, p4, p1)
                mo.entities.add_face(p4, p1, p2)
            else
                mo.entities.add_face(p3, p1, p4)
                mo.entities.add_face(p4, p2, p1)
            end
        end
        #smoothing edges...
        if (@smoothFaces) 
            newEdges.each do |e|
                e.smooth=true
                e.soft=true
            end
        end
    end

end # class ScrewToolBase


#-----------------------------------------------------------------------------

class ScrewTool < ScrewToolBase

    def initialize()
        @ip1 = nil
        @ip2 = nil
        @xdown = 0
        @ydown = 0
        @steps = "10.0"
        @turns = "2.25"
        super()
    end

    def activate
        @ip1 = Sketchup::InputPoint.new
        @ip2 = Sketchup::InputPoint.new
        @ip = Sketchup::InputPoint.new
        @drawn = false
        Sketchup::set_status_text "Length", SB_VCB_LABEL
        self.reset(nil)
    end

    def deactivate(view)
        view.invalidate if @drawn
    end

    def onMouseMove(flags, x, y, view)
        if( @state == 0 )
            @ip.pick view, x, y
            if( @ip != @ip1 )
                view.invalidate if( @ip.display? or @ip1.display? )
                @ip1.copy! @ip
                view.tooltip = @ip1.tooltip
            end
        else
            @ip2.pick view, x, y, @ip1
            view.tooltip = @ip2.tooltip if( @ip2.valid? )
            view.invalidate
            if( @ip2.valid? )
                length = @ip1.position.distance(@ip2.position)
                Sketchup::set_status_text length.to_s, SB_VCB_VALUE
            end
            if( (x-@xdown).abs > 10 || (y-@ydown).abs > 10 )
                @dragging = true
            end
        end
    end

    def onLButtonDown(flags, x, y, view)
        if( @state == 0 )
            @ip1.pick view, x, y
            if( @ip1.valid? )
                @state = 1
                Sketchup::set_status_text "Select second end", SB_PROMPT
                @xdown = x
                @ydown = y
            end
        else
            if( @ip2.valid? )
                self.create_geometry(@ip1.position, @ip2.position,view)
                self.reset(view)
                Sketchup.active_model.select_tool nil
            end
        end
        view.lock_inference
    end

    def onLButtonUp(flags, x, y, view)
        if( @dragging && @ip2.valid? )
            self.create_geometry(@ip1.position, @ip2.position,view)
            self.reset(view)
        end
    end

    def onKeyDown(key, repeat, flags, view)
        if( key == CONSTRAIN_MODIFIER_KEY && repeat == 1 )
            @shift_down_time = Time.now
            if( view.inference_locked? )
                view.lock_inference
            elsif( @state == 0 && @ip1.valid? )
                view.lock_inference @ip1
            elsif( @state == 1 && @ip2.valid? )
                view.lock_inference @ip2, @ip1
            end
        end
    end

    def onKeyUp(key, repeat, flags, view)
        if( key == CONSTRAIN_MODIFIER_KEY &&
            view.inference_locked? &&
            (Time.now - @shift_down_time) > 0.5 )
            view.lock_inference
        end
    end

    def onUserText(text, view)
        return if not @state == 1
        return if not @ip2.valid?
        begin
            value = text.to_l
        rescue
            UI.beep
            puts "Cannot convert #{text} to a Length"
            value = nil
            Sketchup::set_status_text "", SB_VCB_VALUE
        end
        return if !value
        pt1 = @ip1.position
        vec = @ip2.position - pt1
        if( vec.length == 0.0 )
            UI.beep
            return
        end
        vec.length = value
        pt2 = pt1 + vec
        self.create_geometry(pt1, pt2, view)
        self.reset(view)
    end

    def draw(view)
        if( @ip1.valid? )
            if( @ip1.display? )
                @ip1.draw(view)
                @drawn = true
            end
            if( @ip2.valid? )
                @ip2.draw(view) if( @ip2.display? )
                view.set_color_from_line(@ip1, @ip2)
                self.draw_geometry(@ip1.position, @ip2.position, view)
                @drawn = true
            end
        end
    end

    def onCancel(flag, view)
        self.reset(view)
    end

    def reset(view)
        @state = 0
        Sketchup::set_status_text("select first end", SB_PROMPT)
        @ip1.clear
        @ip2.clear
        if( view )
            view.tooltip = nil
            view.invalidate if @drawn
        end
        @drawn = false
        @dragging = false
    end

    def draw_geometry(pt1, pt2, view)
        view.draw_line(pt1, pt2)
    end

    def create_geometry(pt1, pt2, view)
        mo=Sketchup.active_model()
        ss = mo.selection()

        if ss.empty? 
            UI.messagebox("Please select geometry first, then reselect screw tool.")
            Sketchup.active_model.select_tool nil
        else
            prompts = ["Steps", "Turns"]
            values = [@steps, @turns]
            results = inputbox prompts, values, "Screw"
            temp1, temp2 = results
            if (temp1 != false)
                @steps = temp1
                @turns = temp2

                steps = eval(@steps)
                turns = eval(@turns)

                mo.start_operation "screw"
                screw(pt1, pt2, steps, turns)
                mo.commit_operation
            end
        end
    end

end # class ScrewTool

#-----------------------------------------------------------------------------

class SpinTool < ScrewToolBase

    def initialize()
        @stepsLathe = "10.0"
        @degs = "360.0"
        super()
    end

    def activate
        self.create_geometry()
    end

    def create_geometry()
        mo=Sketchup.active_model()
        ss = mo.selection()

        if ss.empty? 
            UI.messagebox("Please select geometry first, then reselect screw tool.")
            Sketchup.active_model.select_tool nil
        else
            prompts = ["Steps", "Degrees"]
            values = [@stepsLathe, @degs]
            results = inputbox prompts, values, "Spin"
            temp1, temp2 = results
            if (temp1 != false)
                @stepsLathe = temp1
                @degs = temp2

                steps = eval(@stepsLathe)
                deg = eval(@degs)
                
                deg = 360.0 if (deg>360.0)
                deg = -360.0 if (deg<-360.0)

                turns = deg/360.0
                
                mo.start_operation "spin"
                screw(Geom::Point3d.new(0,0,0), Geom::Point3d.new(0,0,0), steps, turns)
                mo.commit_operation
            end
        end
    end

end # class SpinTool

#-----------------------------------------------------------------------------

if( not file_loaded?("screw.rb") )
	UI.menu("Plugins").add_item("spin") { Sketchup.active_model.select_tool SpinTool.new }
	UI.menu("Plugins").add_item("screw") { Sketchup.active_model.select_tool ScrewTool.new }
end
file_loaded("screw.rb")


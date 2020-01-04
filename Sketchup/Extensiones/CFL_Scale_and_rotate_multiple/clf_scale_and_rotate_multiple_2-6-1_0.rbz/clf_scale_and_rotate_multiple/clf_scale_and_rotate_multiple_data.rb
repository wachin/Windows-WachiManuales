# See the loader file for license and author info

require 'sketchup.rb'
module CLF_Extensions_NS
	module CLF_Scale_And_Rotate_Multiple
  
    def self.uniform
      ents = Sketchup.active_model.selection
      face_me = 0
      if ents.empty?
        results = UI.messagebox "Please select groups and components before starting this plugin"
        Sketchup.send_action "selectSelectionTool:"
        return
      end
      results = UI.inputbox ['Scale about', 'Scale Factor', 'Rotation'], ['Axis', '1', '0'], ['Axis|Comp. Base|Center|World|'], 'Uniformly Scale and Rotate Multiple'
      scale = results[1].to_f
      degree = results[2].to_f
      a = Sketchup.version
      b = a[0,1].to_i
      if b > 6
        Sketchup.active_model.start_operation("Scale Multiple", true)
      else
        Sketchup.active_model.start_operation("Scale Multiple")
      end
      if results[0] == "World"
        point = [0,0,0]	
      end
      ents.each do |e|
        if (e.typename == "Group") or (e.typename == "ComponentInstance")
          if e.typename == "ComponentInstance"
            behavior = e.definition.behavior
            if behavior.always_face_camera?
              face_me = true
              e.definition.behavior.always_face_camera= false
            else
              face_me = false
            end
          else
            face_me = false
          end
          if results[0] == "Center"
            point = e.bounds.center
          end
          if results[0] == "Axis"
            point = e.transformation.origin
          end
          if results[0] == "Comp. Base"
            bbox = e.bounds
            center_point = bbox.center
            point = center_point
            halfheight = (bbox.depth / 2 )
            point[2] -= halfheight
          end
          
          e.definition.behavior.always_face_camera= true if face_me
          #t = Geom::Transformation.scaling point, scale
          #This does transformations so that 7.1 will like it.  It moves the comp to the origin, 
          #then transforms using the matrix, then puts it back in place
          t_origin = Geom::Transformation.new([1,0,0,0,0,1,0,0,0,0,1,0,-point[0],-point[1],-point[2],1])
          e.transform! t_origin

          ts1 = Geom::Transformation.new([scale,0,0,0,0,scale,0,0,0,0,scale,0,0,0,0,1])
          e.transform! ts1
           
          t_origin = Geom::Transformation.new([1,0,0,0,0,1,0,0,0,0,1,0,point[0],point[1],point[2],1])
          e.transform! t_origin

          rotate e, point, degree
        end
      end
      Sketchup.active_model.commit_operation
    end
    

    def self.rotate object, point, degree
      vector = object.transformation.zaxis
      t = Geom::Transformation.rotation point, vector, degree.degrees
      object.transform! t
    end
    

    def self.random
      ents = Sketchup.active_model.selection
      face_me = 0
      if ents.empty?
        UI.messagebox "Please select groups and components before starting this plugin"
        Sketchup.send_action "selectSelectionTool:"
        return
      end
      retrymenu = 1
      while retrymenu == 1
        results = UI.inputbox ['Scale about', 'Min Scale Factor  ', 'Max Scale Factor  ', 'Min Rotation', 'Max Rotation'], ['Axis', '0.5', '1.5', '0', '0'], ['Axis|Comp. Base|Center|World'], 'Randomly Scale and Rotate Multiple'
        if results[1] > results[2]
          retrymenu = 1
          UI.messagebox "Please set the minumum scale value to be smaller than the maximum scale value."
        else
          retrymenu = 0
        end
        
        if results[3].to_f > results[4].to_f
          retrymenu = 1
          UI.messagebox "Please set the minumum rotation value to be smaller than the maximum rotation value."
        else
          retrymenu = 0
        end
      end
      minr = results[3].to_f
      maxr = results[4].to_f
      ranger = maxr - minr
      min = results[1].to_f * 1000
      max = results[2].to_f * 1000
      range = max - min
      Sketchup.active_model.start_operation("Scale Multiple", true)
      if results[0] == "World"
        point = [0,0,0]
      end
      ents.each do |e|
        if (e.typename == "Group") or (e.typename == "ComponentInstance")
          scale = (rand(range) + min ) / 1000.0
          if e.typename == "ComponentInstance"
            behavior = e.definition.behavior
            if behavior.always_face_camera?
              face_me = true
              e.definition.behavior.always_face_camera= false
            else
              face_me = false
            end
          else
            face_me = false
          end
          if results[0] == "Center"
            point = e.bounds.center
          end
          if results[0] == "Axis"
            point = e.transformation.origin
          end
          if results[0] == "Comp. Base"
            bbox = e.bounds
            center_point = bbox.center
            point = center_point
            halfheight = (bbox.depth / 2 )
            point[2] -= halfheight
          end
          e.definition.behavior.always_face_camera= true if face_me

          #This does transformations so that 7.1 will like it.  It moves the comp to the origin, 
          #then transforms using the matrix, then puts it back in place
          t_origin = Geom::Transformation.new([1,0,0,0,0,1,0,0,0,0,1,0,-point[0],-point[1],-point[2],1])
          e.transform! t_origin

          ts1 = Geom::Transformation.new([scale,0,0,0,0,scale,0,0,0,0,scale,0,0,0,0,1])
          e.transform! ts1
           
          t_origin = Geom::Transformation.new([1,0,0,0,0,1,0,0,0,0,1,0,point[0],point[1],point[2],1])
          e.transform! t_origin
          
          degree = (rand(ranger) + minr )
          rotate e, point, degree
        end
      end
      Sketchup.active_model.commit_operation
    end
  end
end #  Module





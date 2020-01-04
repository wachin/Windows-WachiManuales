
menu = $jf_menu || UI.menu("Plugins")
menu = $submenu if $submenu
menu.add_item("JF MoveIt #{JF::MoveIt::VERSION}") { JF::MoveIt::Dialog.new() }

module JF

  module MoveIt

  WEBDIALOG_KEY = 'JF\MoveIt'.freeze
  REG_KEY       = 'JF\MoveIt'.freeze

  def self.start_operation(op_text = 'MoveIt', disable_ui = true)
    if Sketchup.active_model.method(:start_operation).arity == 1
      Sketchup.active_model.start_operation(op_text)
    else
      Sketchup.active_model.start_operation(op_text, disable_ui)
    end
  end

  def self.copy_group_or_component(ent)
    if ent.is_a? Sketchup::Group
      new_grp = ent.copy
      new_grp.material = ent.material
      return new_grp
    elsif ent.is_a? Sketchup::ComponentInstance
      parent = ent.parent
      cdef = ent.definition
      ins = parent.entities.add_instance(cdef, ent.transformation)
      ins.material = ent.material
      return ins
    end
  end

  class Dialog < UI::WebDialog

    AXES     = { "y" => Y_AXIS, "z" => Z_AXIS, "x" => X_AXIS }
    UNITS    = [1.0, 12.0, 25.4, 2.54, 0.0254]
    PLATFORM = (Object::RUBY_PLATFORM =~ /mswin|mingw32/i) ? :windows : ((Object::RUBY_PLATFORM =~ /darwin/i) ? :mac : :other)

    def initialize()
      super "MoveIt #{VERSION}", false, WEBDIALOG_KEY, 200, 200, 100, 100, true
      set_file File.join(File.dirname(__FILE__), "dialog.html")
      @keys = {"17" => false, "16" => false}
      @axis = AXES["z"]
      if PLATFORM == :windows
        show {
          mv_amt = Sketchup.read_default(REG_KEY, "move_amt", "0")
          mv_amt.gsub!(/ft/, "\\\\'")
          mv_amt.gsub!(/in/, '\"')
          script = %/o=document.getElementById("move_amt").value='#{mv_amt}';/
          self.execute_script(script)
          rot_amt = Sketchup.read_default(REG_KEY, "rot_amt", 15)
          script = %/o=document.getElementById("rot_amt").value='#{rot_amt}';/
          self.execute_script(script)
          script = "set_version(\"#{VERSION}\");"
          self.execute_script(script)
        }
      else
        show_modal {
          mv_amt = Sketchup.read_default(REG_KEY, "move_amt", "0")
          mv_amt.gsub!(/ft/, "\\\\'")
          mv_amt.gsub!(/in/, '\"')
          script = %/o=document.getElementById("move_amt").value='#{mv_amt}';/
          self.execute_script(script)
          rot_amt = Sketchup.read_default(REG_KEY "rot_amt", 15)
          script = %/o=document.getElementById("rot_amt").value='#{rot_amt}';/
          self.execute_script(script)
        }


      end

      add_action_callback("keyDownHandler") do |d, a|
        @keys[a] = true
      end

      add_action_callback("keyUpHandler") do |d, a|
        @keys[a] = false
      end

      add_action_callback("move") do |d, params|
        if( @keys["16"] ) # Shift
          slide(d, params)
          return
        end
        if params == "o"
          move0
        else
          move(d, params)
        end
      end
      add_action_callback("rotate") do |d, a|
        dir, ang = a.split(",") 
        rotate(dir, ang.to_f)
      end
      add_action_callback("drop")  do |d, a|
        drop(d, a)
      end
      add_action_callback("align") do |d, a|
        #puts "align:#{a.inspect}"
      end
      add_action_callback("undo") do
        Sketchup.undo
      end
      add_action_callback("setAxis") do |d, a|
        # puts "setAxis:#{a.inspect}"
        @axis = AXES[a]
      end
      add_action_callback("top") {| d, a| Sketchup.send_action("viewTop:") }

      set_on_close {
        amt = self.get_element_value("move_amt")
        amt.gsub!(/'/, 'ft')
        amt.gsub!(/"/, 'in')
        Sketchup.write_default(REG_KEY, "move_amt", amt)
        amt = self.get_element_value("rot_amt")
        Sketchup.write_default(REG_KEY, "rot_amt", amt)
      }

    end # initialize


    def camera
      Sketchup.active_model.active_view.camera
    end

    def slide(d, a)
      #puts "slide:#{a.inspect}"
      e = Sketchup.active_model.selection[0]
      return unless e
      ec = e.bounds.center
      pt = nil
      case a
      when "e"
        v = X_AXIS.clone
        v.length = e.bounds.width / 2
      when "w"
        v = X_AXIS.reverse
        v.length = e.bounds.width / 2
      when "n"
        v = Y_AXIS.clone
        v.length = e.bounds.height / 2
      when "s"
        v = Y_AXIS.reverse
        v.length = e.bounds.height / 2
      end
      pt = ec + v
      raytest = Sketchup.active_model.raytest(pt, v)
      if raytest
        #Sketchup.active_model.entities.add_cpoint(raytest[0])
        #Sketchup.active_model.entities.add_cline(pt, v)
        v = raytest[0] - pt
        e.transform!(v)
      end

    end

    def moveto(e, pt)
      o = e.transformation.origin
      if pt.is_a?(Array)
        pt = Geom::Point3d.new(pt)
      end
      v = pt - o
      tr = Geom::Transformation.translation(v)
      e.transform!(tr)
    end

    def move0
      e = Sketchup.active_model.selection[0]
      return unless e
      #e.transformation = Geom::Transformation.new
      moveto(e, [0,0,0])
    end

    def move(d, params)
      #puts "move:#{params.inspect}"
      elms = Sketchup.active_model.selection.find_all {|el| el.typename == "Group" or el.typename == "ComponentInstance"}
      return unless elms.size > 0
      #unless( e.typename == "Group" or e.typename == "ComponentInstance")
      #UI.messagebox("Please select a group or component.")
      #break
      #end
      JF::MoveIt.start_operation("move")
      amt = d.get_element_value("move_amt").to_f
      #puts "amt is: #{amt.inspect}"
      unit_options = Sketchup.active_model.options["UnitsOptions"]
      units_index = unit_options["LengthUnit"]
      #puts "units are: #{units_index.inspect}"
      # 0 = inches
      # 1 = feet
      # 2 = millimeters
      # 3 = centimeters
      # 4 = meters
      amt = amt / UNITS[units_index]
      #puts "amt is: #{amt.inspect}"
      elms.each do |e|
        bb = e.bounds
        x = y = z = 0
        case params
        when "n"
          y = amt
          y = bb.height if amt == 0
        when "ne"
          x = y = amt
          if amt == 0
            x = bb.width
            y = bb.height
          end
        when "e"
          x = amt
          x = bb.width if amt == 0.0
        when "se"
          x = amt
          y = -amt
          if amt == 0
            x = bb.width
            y = -bb.height
          end
        when "s"
          y = -amt
          y = -bb.height if amt == 0.0
        when "sw"
          y = -amt
          x = -amt
          if amt == 0
            y = -bb.height
            x = -bb.width
          end

        when "w"
          x = -amt
          x = -bb.width if amt == 0.0
        when "nw"
          y = amt
          x = -amt
          if amt == 0
            y = bb.height
            x = -bb.width
          end
        when "u"
          z = amt
          z = bb.depth if amt == 0.0
        when "d"
          z = -amt
          z = -bb.depth if amt == 0.0
        end # case
        pt = [x, y, z]
        tr = Geom::Transformation.new pt
        #if @cb == "false" # move, no copy
        if @keys["17"] == true # move, no copy
          e1 = JF::MoveIt.copy_group_or_component(e)
          #e.transform! tr if e.respond_to?("transform!")
        end
        if false # camera follow preview
          v = Sketchup.active_model.active_view
          c = v.camera
          c.set c.eye.transform(tr), e.transformation.origin, c.up
        end
        e.transform!(tr) if e.respond_to?("transform!")
        #e.moveto(pt)
      end # elms.each
      Sketchup.active_model.commit_operation
    end # move call_back

    def _move(o, v)
      tr = Geom::Transformation.translation(v)
      o.move!(tr) if o.respond_to?("move!")
    end # _move

    def rotate(dir, a)
      #angle = d.get_element_value("angle").to_i
      sel = Sketchup.active_model.selection[0]
      return unless sel

      if dir == "r" # random rotate all selected
        JF::MoveIt.start_operation("Random Rotate")
        Sketchup.active_model.selection.each do |s|
          next unless s.respond_to?("transformation")
          #r = 360 * rand
          r = rand(a*2.0+1.0)-a
          #print "#{r} "
          #tr = Geom::Transformation.rotation(s.transformation.origin, [0, 0, 1], r.degrees)
          tr = Geom::Transformation.rotation(s.transformation.origin, @axis, r.degrees)
          s.transform!(tr)
        end
        Sketchup.active_model.commit_operation
        return
      end

      if dir == "z" # reset rotations
        JF::MoveIt.start_operation("Reset Rotation")
        Sketchup.active_model.selection.each {|sel|
          next unless sel.respond_to?("transformation=")
          #otr = sel.transformation
          #pt = sel.transformation.origin
          #x = sel.transformation.xaxis
          #angle  = X_AXIS.angle_between(x)
          #tr = Geom::Transformation.rotation(pt, [0, 0, 1], angle)
          #y = x.transform(tr)
          #if y.samedirection?(X_AXIS)
          #sel.transform!(tr)
          #else
          #tr = Geom::Transformation.rotation(pt, [0, 0, 1], -angle)
          #sel.transform!(tr)
          #end
          #t = sel.transformation
          #tr = Geom::Transformation.axes(sel.transformation.origin, X_AXIS, Y_AXIS, Z_AXIS)
          #tr = Geom::Transformation.axes(sel.transformation.origin, t.xaxis, t.yaxis, t.zaxis)
          pt = sel.transformation.origin
          tr = Geom::Transformation.new(pt)
          #sel.transform!(tr)
          sel.transformation = tr
        }
        Sketchup.active_model.commit_operation
        return
      end
      angle = a.to_i if a
      bb = Sketchup.active_model.selection[0].bounds
      angle = -angle if dir == "cw"
      pt = bb.center
      JF::MoveIt.start_operation("Rotate")
      Sketchup.active_model.selection.each{|sel|
        next unless sel.respond_to?("transformation")
        pt = sel.transformation.origin
        #tr = Geom::Transformation.rotation(pt, [0, 0, 1], angle.degrees)
        tr = Geom::Transformation.rotation(pt, @axis, angle.degrees)
        if( @keys["17"] == true)
          c = JF::MoveIt.copy_group_or_component(sel)
        end
        sel.transform! tr
      }
      Sketchup.active_model.commit_operation
    end # rotate

    def drop(d, a)
      #puts "drop:#{a.inspect}"
      pt = nil
      JF::MoveIt.start_operation("Drop")
      Sketchup.active_model.selection.each { |e|
        next unless e.respond_to?("transformation")
        tr = e.transformation
        pt = tr.origin
        pt.z = 0
        if a == "true"
          ray = [e.transformation.origin, Z_AXIS.reverse]
          res =  Sketchup.active_model.raytest(ray)
          next unless res
          if res[0]
            #pt.z = res[0].z
            pt = res[0]
          end
        end
        tr = Geom::Transformation.new(pt)
        if e.respond_to?("transform!")
          #e.transform! tr
          #e.transformation = tr
          moveto(e, pt)
        end
      }
      Sketchup.active_model.commit_operation
    end # drop

  end # class Mover

  end # module MoveIt
end # module JF
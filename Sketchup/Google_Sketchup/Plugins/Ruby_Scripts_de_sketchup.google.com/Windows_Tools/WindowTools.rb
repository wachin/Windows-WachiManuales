=begin
# ------------------------------------------------------------
# 2008,09,20 Thanks to Jim Foltz for writing this menu routine
# ------------------------------------------------------------
=end

require 'sketchup'

require 'windowtools/glass_tool.rb'
require 'windowtools/frame_tool.rb'
require 'windowtools/trim_tool.rb'
require 'windowtools/mullion_tool.rb'

menu = UI.menu("Plugins").add_submenu("Window Tools")
toolbar = UI::Toolbar.new("Window Tools")

path = File.dirname(__FILE__) + "/windowtools/"

cmd = UI::Command.new("Glass") { Sketchup.active_model.select_tool WindowTools::GlassTool.new }
cmd.small_icon = cmd.large_icon = path + "wglass.png"
cmd.status_bar_text = "Glass Tool"
cmd.tooltip = "Glass Tool"
menu.add_item(cmd)
toolbar.add_item(cmd)

cmd = UI::Command.new("Frame") { Sketchup.active_model.select_tool WindowTools::FrameTool.new }
cmd.small_icon = cmd.large_icon = path + "wframe.png"
cmd.status_bar_text = "Frame Tool"
cmd.tooltip = "Frame Tool"
menu.add_item(cmd)
toolbar.add_item(cmd)

cmd = UI::Command.new("Trim") { Sketchup.active_model.select_tool WindowTools::TrimTool.new }
cmd.small_icon = cmd.large_icon = path + "wtrim.png"
cmd.status_bar_text = "Trim Tool"
cmd.tooltip = "Trim Tool"
menu.add_item(cmd)
toolbar.add_item(cmd)

cmd = UI::Command.new("Mullions") { Sketchup.active_model.select_tool WindowTools::MullionTool.new }
cmd.small_icon = cmd.large_icon = path + "wmullion.png"
cmd.status_bar_text = "Mullion Tool"
cmd.tooltip = "Mullion Tool"
menu.add_item(cmd)
toolbar.add_item(cmd)


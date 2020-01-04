=begin
# ------------------------------------------------------------
# 2008,09,20 Thanks to Jim Foltz for writing this menu routine
# 2008,11,24 revised Window Tools 1.1
# ------------------------------------------------------------
=end

require 'sketchup'

require 'windowtools1.1/glass_tool.rb'
require 'windowtools1.1/frame_tool.rb'
require 'windowtools1.1/trim_tool.rb'
require 'windowtools1.1/mullion_tool.rb'

menu = UI.menu("Plugins").add_submenu("Window Tools")
toolbar = UI::Toolbar.new("Window Tools")

path = File.dirname(__FILE__) + "/windowtools1.1/"

cmd = UI::Command.new("Glass") { Sketchup.active_model.select_tool GlassTool.new }
cmd.small_icon = cmd.large_icon = path + "wglass.png"
cmd.status_bar_text = "Glass Tool"
cmd.tooltip = "Glass Tool"
menu.add_item(cmd)
toolbar.add_item(cmd)

cmd = UI::Command.new("Frame") { Sketchup.active_model.select_tool FrameTool.new }
cmd.small_icon = cmd.large_icon = path + "wframe.png"
cmd.status_bar_text = "Frame Tool"
cmd.tooltip = "Frame Tool"
menu.add_item(cmd)
toolbar.add_item(cmd)

cmd = UI::Command.new("Trim") { Sketchup.active_model.select_tool TrimTool.new }
cmd.small_icon = cmd.large_icon = path + "wtrim.png"
cmd.status_bar_text = "Trim Tool"
cmd.tooltip = "Trim Tool"
menu.add_item(cmd)
toolbar.add_item(cmd)

cmd = UI::Command.new("Mullions") { Sketchup.active_model.select_tool MullionTool.new }
cmd.small_icon = cmd.large_icon = path + "wmullion.png"
cmd.status_bar_text = "Mullion Tool"
cmd.tooltip = "Mullion Tool"
menu.add_item(cmd)
toolbar.add_item(cmd)


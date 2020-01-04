module GCH_1001bit_loader

module GCH_1001bit_load

require 'sketchup.rb'
#UI.messagebox "in loader path=" + $GH1001bit_var['path']
t = Sketchup.load $GH1001bit_var['path'] + "/1001bitmenu"
puts "loading 1001bitmenu >> #{t}"

end #GCH_1001bit_load
end #GCH_1001bit_loader
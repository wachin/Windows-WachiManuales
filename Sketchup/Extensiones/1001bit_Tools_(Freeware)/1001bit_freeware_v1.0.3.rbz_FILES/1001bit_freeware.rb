#copyright Goh Chun Hee; www.1001bit.com

module GCH_1001bit_free

module GCH_1001bit_load

require 'sketchup.rb'
require 'extensions.rb'


#===============================================================
# Some default path for 1001bit folder in Windows and Mac are listed below
# Delete the '#' in front of the path you prefer to define the path
# You can edit the paths using a text editor. 
# If your 1001bit folder is in some specific location, for example F:/abc/1001bit
#Just replace the 'c:/your prefered path' with your specific path location.
# If no specific path is defined, the following scripts will assume that the 
# path to 1001bit under the plugins folder, i.e. where this file is located.
# If all fails, the script then hardcode the location to C:\1001bit
#===============================================================

#$GH1001bit_path='C:/Program Files/Google/Google SketchUp 6/Plugins/1001bit'
#$GH1001bit_path='C:/Program Files/Google/Google SketchUp 7/Plugins/1001bit'
#$GH1001bit_path='/Library/Application Support/Google Sketchup 6/SketchUp/plugins/1001bit'
#$GH1001bit_path='/Library/Application Support/Google Sketchup 7/SketchUp/plugins/1001bit'

#$GH1001bit_path='c:/your prefered path/1001bit'


#================================================================
# set default location of 1001bit folder to be similar with this file, i.e. inside the Plugins folder 
if !($GH1001bit_path)
  filep=__FILE__  
  fa=filep.split('/')
  fa.pop
  $GH1001bit_path=fa.join('/')
  $GH1001bit_path = $GH1001bit_path + '/1001bit_freeware'
end
puts "path=" + $GH1001bit_path
# check to see if the menu file exists.
if File.exist?($GH1001bit_path + '/1001bitmenu.rbs')
  
  #do nothing if path is correct and 1001bitmenu.rbs file is found

else
  
  #if the 1001bitmenu.rbs file cannot be found, rebuild the path
  filep=__FILE__  
  fa=filep.split('/')
  fa.pop
  $GH1001bit_path=fa.join('/')
  $GH1001bit_path = $GH1001bit_path + '/1001bit_freeware'
  
  #try again to see whether the menu file can be found
  if File.exist?($GH1001bit_path + '/1001bitmenu.rbs')
    
    #do nothing if the file is found
    
  else
    
    #still cannot find the 1001bitmenu file; set the path to default at c:/1001bit
    $GH1001bit_path="c:/1001bit_freeware"
    
  end
end



if File.exist?($GH1001bit_path + '/1001bit_loader.rb')
$GH1001bit_var={'path'=>$GH1001bit_path, 'language_path'=>$GH1001bit_path + '/language', 'preset_path'=>$GH1001bit_path + '/preset', 'dialog_path'=>$GH1001bit_path+'/dialogs'}
#------------------------------------------------------------------------------------------------------
#setting up 1001bt tools as extensions

mytools = SketchupExtension.new "1001bit tools", $GH1001bit_path + "/1001bit_loader.rb"
mytools.description="Plugins for architectural works from www.1001bit.com"
mytools.copyright="2008-2013, Goh Chun Hee, www.1001bit.com"
mytools.creator="Goh Chun Hee, GohCH"
mytools.version="freeware 1.0.3"

Sketchup.register_extension mytools, true


#UI.messagebox "done setting path " + $GH1001bit_var['path']
else
  UI.messagebox "1001bit setup error -- cannot find #{$GH1001bit_path}/1001bit_loader.rb file"
end

end #end GCH_1001bit_load
end #end GCH_1001bit_free
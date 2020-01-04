=begin
Copyright 2013, Chris Fullmer
All Rights Reserved

Disclaimer
THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

License
This software is distributed under the Smustard End User License Agreement
http://www.smustard.com/eula

Information
Author - Chris Fullmer
Organization - www.ChrisFullmer.com and distributed on the SketchUp Extension Warehouse
Name - Scale and Rotate Multiple
SU Version - 2013, 8, 7

Description
This script takes a selection of groups/components and scales them based on their 3d centerpoint, 
the world axis, their axis location, or their "base" (which is the center of their base for 
those of us who don't set our axes).

Usage
Select the components and/or groups to be scaled.  Run the plugin at Plugins>Chris Fullmer Tools>Scale Multiple> .  
There are two plugins found here.  One will scale everything equally.  The other will scale them randomly based on 
minimum and maximum provided values.  NOTE: The scale factors are not percentages.  They are factors.  Which means if 
you want to scale something to be twice as large, you enter 2.  If you want something to be one half the size, enter .5 .  
Entering 50 will not a result that is 50% the original, but will give a result that is 50 times larger than the original.

History
1.0 - 2009-03-13
  * First release
2.0 - 2009-03-22
  * Fixed a bug where it didn't let you scale items more than once using Axis.  Should work over and over now.
  * Added "Component Base" support for those of us who don't set our component axes.  This uses the bottom center of the component.
  * Added much more reliable FaceMe component support (I hope).
  * Added Rotation capability.  Uniform and random with user specified min/max values.
2.5 - 2009-12-22
  * Fixed scaling so that Face Me components don't freak out like they have been doing since 7.1 was introduced.  Big Thanks to Edson and Thom for helping figure out what was breaking.
  * Cleaned up some code - a big chunk thanks to a tip from TIG!
2.6.0 - 2013-04-29
  * Added EW compatibility
  * Wrapped everything into my own single namespace - woohoo!
2.6.1 2013-05-06
  * Fixed menu compatibility with older clf scripts  
=end


module CLF_Extensions_NS

  module CLF_Scale_And_Rotate_Multiple

    require 'sketchup.rb'
    require 'extensions.rb'
    
    NAME = "clf_scale_and_rotate_multiple"
    UNAME = "CLF Scale and Rotate Multiple"
    MENU_NAME = "Scale and Rotate Multiple"
    version = "1.2.1"           #EDIT
    desc = "This plugin will scale and or rotate multiple selected groups/components.  It can scale and rotate uniformly, or randomly based on minimum and maximum input parameters."
    copy_year = "2013"
    author = "Chris Fullmer"
    
#------edit above--------------------------------------------------------------- 

    
    extension = SketchupExtension.new UNAME, NAME+"/"+NAME+"_menus.rb"

    #The name= method sets the name which appears for an extension inside the Extensions Manager dialog.
    extension.name = UNAME

    # The description= method sets the long description which appears beneath an extension inside the Extensions Manager dialog.
    extension.description = desc + "  Access it via Plugins > Chris Fullmer Tools > "+MENU_NAME

    # The version method sets the version which appears beneath an extension inside the Extensions Manager dialog.
    extension.version = version

    # Create an entry in the Extension list that loads a script called
    # stairTools.rb.
    extension.copyright = copy_year
     
    # The creator= method sets the creator string which appears beneath an extension inside the Extensions Manager dialog.
    extension.creator = author

    # The register_extension method is used to register an extension with SketchUp's extension manager (in SketchUp preferences).
    Sketchup.register_extension( extension, true )
    
  end
end  
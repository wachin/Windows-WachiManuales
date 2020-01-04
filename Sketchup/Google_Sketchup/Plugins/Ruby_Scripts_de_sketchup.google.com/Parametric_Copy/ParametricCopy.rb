###---------------------------------------------------------------------
# Name : ParametricCopy.rb
# Description : Plugins > ParametricCopy - Copy, Rotate & Scale selection...
# Author:  Mike Ross, TIG (c) 2011, inspired by (and with heavy code-borrowing from) TIG's Grow2 plugin
# Install: Put ParametricCopy.rb into Plugins folder.
#         Put ParametricCopyCursor.png in Plugins/Icons/ folder.
#         (make folder if it doesn't exist)
# Usage : Move/Place Objects,Select them and pick ParametricCopy.  Pick Reference Point, 
#         Enter desired data in dialogs and see results.  
#         Shape, location, scale, order all produce different results...
#
# SINE
# SAW
#
#
# Version : 1.0  2011_10_23
# * Initial Release
# Version : 1.01 2011_10_30
# * Fixed bug in Windows with pull-down menus
# * Added "Initial_Val" parameter to Step+Sine and Linear-Step-Delta
# * Added exception capturing in all entry boxes
# 
#
###---------------------------------------------------------------------
require 'sketchup.rb'
include Math

 class UnitUtils
  def self.translationPopup
    return "feet|inches|m|cm|mm"
  end
  def self.rotationPopup
    return "degrees|radians"
  end
  def self.scalePopup
    return "none"
  end
  
  def self.convert(num, units)
    case units
      when "feet"
        return num.feet
      when "inches"
        return num.inch
      when "m"
        return num.m
      when "cm"
        return num.cm
      when "mm"
        return num.mm
      when "degrees"
        return num  
      when "radians"
        return num.radians        
    end
    return num
  end

  def self.convertNumString(numStringWithUnits) 
    return numStringWithUnits.sub("'",".feet").sub("\"",".inch").sub("mm",".mm").sub("m",".m").sub("cm",".cm").sub("deg","").sub("rad",".radians")
  end
  
  def self.getUnitString(model)
    units = "???"
    units="inches" if model.options["UnitsOptions"]["LengthUnit"]==0
    units="feet" if model.options["UnitsOptions"]["LengthUnit"]==1
    units="mm" if model.options["UnitsOptions"]["LengthUnit"]==2
    units="cm" if model.options["UnitsOptions"]["LengthUnit"]==3
    units="m" if model.options["UnitsOptions"]["LengthUnit"]==4
    return units
  end
 end
 
#######################################################################################  
#######################   Functions   ############################################
#######################################################################################  

 class FuncGenerator
  class << self; attr_accessor :fname end   
  class << self; attr_accessor :paramPrompts end    
  class << self; attr_accessor :paramsWithUnits end
  class << self; attr_accessor :paramText end
      
  def get(prompt)
    index = self.class.paramPrompts.index(prompt)
      UI.messagebox("FuncGenerator::get...Illegal param prompt: #{prompt}") if index==nil
    val = @paramVals[index]
    return val
  end
  
  def set(prompt,val)
    index = self.class.paramPrompts.index(prompt)
      UI.messagebox("FuncGenerator::get...Illegal param prompt: #{prompt}") if index==nil
    @paramVals[index]=nil
  end
  
  def hasUnits(paramIndex)
    self.class.paramsWithUnits.each { |i|
      if i==paramIndex
        return true
      end
    }
    return false
  end
  
  def displayStatusInfo(text)
    Sketchup::set_status_text(text,SB_PROMPT)
    Sketchup::set_status_text(" ",SB_VCB_LABEL)
    Sketchup::set_status_text(" ",SB_VCB_VALUE)
  end
  
  def applyUnitInfo(units)
    self.class.paramsWithUnits.each {|i|
      @paramVals[i]=UnitUtils.convert(@paramVals[i],units)
    }
  end
    
  def setParamVals(titlePrefix, unitPopup, units)
    title = titlePrefix + self.class.fname
    displayStatusInfo((units ? "units=#{units}:" : "") + " " + self.class.paramText)
    applyUnitInfo(units)
    results=inputbox(self.class.paramPrompts,@paramVals,@popups,title )
    #results.each{ |r| 
    # puts "Result: " + r.to_s
    #}
    throw :CancelRequested if !results 
    @paramVals = results
  end
  
  def generateOutput(start, n)
  end
  
  #def setAndGenerate(titlePrefix,unit,n)
      #while true
        #begin
        #setParamVals(titlePrefix,unts)
            #vals = generateOutput(n)
            #return vals
      #rescue Exception => exc
          #UI.messagebox("Bad equation: " + @paramVals[0])          
      #end
      #end #while
    #end #def setAndGenerate  
 end #class FuncGenerator

 
 class NilGen<FuncGenerator
  @fname="None"
  def generateOutput(start, n)
      return Array.new(n,start)
  end
  def setParamVals(titlePrefix,unitPopup,units)
  end
 end #class NilGen
 
 class ConstantGen<FuncGenerator
    @fname="Constant-Step"
    @paramPrompts=["step"]
  @paramsWithUnits=[0]
  @paramText="f(i)=i*step"
   def initialize 
     @popups=[""]
   @paramVals=[0.0] 
   end #def initialize
   
   def generateOutput(start, n)
    val = start
    step = get("step")
    outputA = Array.new
    outputA << val
    (1..n-1).each{ |i|
      val += step
      outputA << val
    }
    return outputA
  end
 end #class ConstantGen
    
  class FunctionEvaluator
    @evalString
    def initialize(init_str, eval_str)
      eval(init_str)
      @evalString=eval_str
    end
  def generateValues(n) 
    pi = Math::PI
    @fa=Array.new
    def f(i); return @fa[i]; end
    (0..n-1).each {|i|    
      @fa << eval(@evalString)
    }
    return @fa
    end
  end #class FunctionEvaluator
  
  class EquationBasedFuncGenerator<FuncGenerator
    class << self; attr_accessor :equation end
    class << self; attr_accessor :paramNames end
    
    #for each param name, create an initialization string which sets the value of that param name to its paramval
    #For example, if there is a param named "abc" with initial value, 100, this method will append "@abc=100" to the initialization string
    #units are handled by converting unit incicating suffixes to strings which will call actual unit functions.  
    #so we might get "@abc=100.feet" if the units are feet.
    def makeInitStringWithInstanceVars
      str=""
      (0..self.class.paramNames.length-1).each {|i|
        if (i>0)
          str+="; "
        end
        pStr = "@" + self.class.paramNames[i]
        valStr = @paramVals[i].to_s
        if hasUnits(i) 
          valStr = UnitUtils.convertNumString(valStr)
        end
        str += pStr + "=" + valStr
      }
      return str
    end #def makeInitString

    
    def makeEquationWithInstanceVars
      str = self.class.equation
      self.class.paramNames.each {|pn| 
      str = str.sub(pn,"@"+pn)
      }
      return str
    end #def convertEquation

    
    def generateOutput(start, n)
      init = makeInitStringWithInstanceVars
      eq = makeEquationWithInstanceVars
      #UI.messagebox(init + " -- " + eq)
      return FunctionEvaluator.new(init,eq).generateValues(n)
   end
  end #class EquationBasedFuncGenerator
##########  
  class FibonacciGen<EquationBasedFuncGenerator
    @fname="Fibonacci"
    @paramNames=["scaler"]
    @equation="i==0 ? 0 : i==1 ? scaler : f(i-1) + f(i-2)"
    @paramPrompts=["scaler"]
    @paramsWithUnits=[0]
    @paramText="f(i)=" + @equation
    def initialize 
      @popups=[""]
      @paramVals=[0.0] 
    end #def initialize
  end #class FibonacciGen  
##########  
  class ExponentialGen<EquationBasedFuncGenerator
    @fname="Exponential"
    @paramNames=["base","multiplier"]
    @equation="i==0 ? base : multiplier*f(i-1)"
    @paramPrompts=["base","multiplier"]
    @paramsWithUnits=[0]
    @paramText="f(i)=" + @equation
    def initialize 
        @popups=["",""]
      @paramVals=[0.0,0.0] 
    end #def initialize
  end #class ExponentialGen  

##########  
  class LinearStepDeltaGen<EquationBasedFuncGenerator
    @fname="Linear-Step-Delta"
    @paramNames=["initial_val","step","delta"]
    @equation="i==0 ? initial_val : f(i-1) + step + ((i-1)*delta)"
    @paramPrompts=["initial_val","step","delta"]
    @paramsWithUnits=[0,1,2]
    @paramText="f(i)=" + @equation
    def initialize 
        @popups=["","",""]
      @paramVals=[0.0,0.0,0.0] 
    end #def initialize
  end #class LinearStepDeltaGen  
##########  
  class SinePlusStepGen<EquationBasedFuncGenerator
    @fname="Step+Sine"
    @paramNames=["initial_val","step","amp","per"]
    @equation="i==0 ? initial_val : f(i-1) + step + (amp * sin(2*pi*i/per))"
    @paramPrompts=["initial_val","step","amplitude","period (steps)"]
    @paramsWithUnits=[0,1,2]
    @paramText="f(i)=" + @equation + " -- period is # of steps"
    def initialize 
        @popups=["","","",""]
      @paramVals=[0.0,0.0,1.0,1.0] 
    end #def initialize
  end #class SinePlusStepGen  
###########
  class FreeformGen<FuncGenerator
  @fname="Free Expression"
  @paramPrompts=["units","f(i)="]
  @paramsWithUnits=Array.new
  @paramText="For i=(0,1,...,numCopies): f(i)="
  
   def initialize
    @popups=["",""]
    @paramVals=["","sin(i)"] 
   end #def initialize
   
   def setParamVals(titlePrefix, unitPopup, units)
      @paramVals[0]=units
      @popups=[unitPopup,""]
    super(titlePrefix,unitPopup,nil)
   end
  
   def generateOutput(start, n)
      units = @paramVals[0]
      eq = @paramVals[1]
      FunctionEvaluator.new("",eq).generateValues(n).collect!{|v| UnitUtils.convert(v.to_f,units)}
   end
 end #class FreeformGen
######### 
   class ValueListGen<FuncGenerator
     @fname="Repeating Value List"
   @paramPrompts=["units","values"]
   @paramsWithUnits=Array.new
   @paramText="Values set to values in list (space-delimited).  List repeats."
  
   def initialize
     @popups=["",""]
     @paramVals=["","0 1 2 3"] 
   end #def initialize
   
   def setParamVals(titlePrefix, unitPopup, units)
      @paramVals[0]=units
      @popups=[unitPopup,""]
    super(titlePrefix,unitPopup,nil)
   end
   
   def generateOutput(start, n)
      units = get("units")
    values = get("values").split(' ').collect!{|v| UnitUtils.convert(v.to_f,units)}
    outputA = Array.new
    val_index = 0
    (0..n-1).each{ |i|
      outputA << values[val_index]
      val_index += 1
      if (val_index == values.length)
        val_index = 0
      end
    }
    return outputA  
  end
  end #class ValueListGen
 
#######################################################################################  
#######################   ParametricCopy   ############################################
#######################################################################################  

class ParametricCopy
  @@ParametricCopyCursor=nil
  
  #Set up functions
  @@FuncList=[NilGen,ConstantGen,ValueListGen,FreeformGen,LinearStepDeltaGen,ExponentialGen,FibonacciGen,SinePlusStepGen]
  @@FuncHash = Hash.new
  funcNames = Array.new
  @@FuncList.each{|f| @@FuncHash[f.fname]=f; funcNames << f.fname}
  @@FuncPopupList = funcNames.join("|")
  
#######################   ParametricCopy::activate   ############################################
  def activate
    #@@FuncList.each{|f| puts "Function: " + f.fname}
    #@@FuncList.each{|f| puts "Function in Hash: " + f.fname + " -> " + @@FuncHash[f.fname].name}
    @ip=Sketchup::InputPoint.new
    @iptemp=Sketchup::InputPoint.new
    @displayed=false
    @model=Sketchup.active_model
    @ss=@model.selection
    if @ss.empty?
      Sketchup::set_status_text("ParametricCopy: NO SELECTION ! ",SB_PROMPT)
      UI.beep
      UI.messagebox("ParametricCopy:\nNo Selection !\n\nFirst Select Object(s)\nThen Pick Rotation Center Point\nThen Input Parameters in Dialogs... \n")
      Sketchup.send_action("selectSelectionTool:")
      return nil
    end
    if not @@ParametricCopyCursor
      cursorPath=Sketchup.find_support_file("parametricCopyCursor.png","/Plugins/Icons")
      if cursorPath
        @@ParametricCopyCursor=UI::create_cursor(cursorPath,0,30)
      else
        UI.beep
      end#if
    end### ParametricCopyCursor.png MUST be in ../Plugins/Icons/ folder
  end #activate

#######################   ParametricCopy::onSetCursor   ############################################
  def onSetCursor()
    cursor=UI::set_cursor(@@ParametricCopyCursor)
  end #onSetCursor

#######################   ParametricCopy::onMouseMove   ############################################
### on MouseMove display InputPoint and update VCB
  def onMouseMove(flags,x,y,view)
    ### show VCB and status info
    Sketchup::set_status_text("ParametricCopy: Pick Rotation/Scale Reference Point... ",SB_PROMPT)
    Sketchup::set_status_text("Point: ",SB_VCB_LABEL)
    Sketchup::set_status_text("#{@ip.position}",SB_VCB_VALUE)
    view.tooltip="Rotation/Scale Reference Point: "+@ip.tooltip ###show on tooltip
    ### get position in the model
    @iptemp.pick(view,x,y)
    if(@iptemp.valid?)
      changed=@iptemp!=@ip
      @ip.copy!(@iptemp)
      @pos=@ip.position
      ### view update? 
      if(changed && (@ip.display? || @displayed)) 
        view.invalidate
      end
    end
  end #onMouseMove

#######################   ParametricCopy::onLButtonDown   ############################################
### on left click add text
  def onLButtonDown(flags,x,y,view)
    pickpoint=@ip.position
    ParametricCopy::run(pickpoint)
    Sketchup.send_action("selectSelectionTool:")
  end #onLButtonDown

#######################   ParametricCopy::draw   ############################################
  def draw(view)
     if(@ip.valid? && @ip.display?)
        @ip.draw(view)
        @displayed=true
     else
        @displayed=false
     end
  end #draw

#######################   ParametricCopy::dialogMain  ############################################
  def ParametricCopy::dialogMain(numc,ord,xyz)
  ### dialog Main
    @numcopies=numc;@order=ord;@xyzrotation=xyz
  ### show VCB and status info
    Sketchup::set_status_text("ParametricCopy... Dimensions...",SB_PROMPT)
    Sketchup::set_status_text(" ",SB_VCB_LABEL)
    Sketchup::set_status_text(" ",SB_VCB_VALUE)
  ###
    prompts=["Copies: ","Order of Operations: ","Order of Rotation: "] + @dimensions
    values=[@numcopies,@order,@xyzrotation] + Array.new(@dimensions.length,@@FuncList[0].fname)
    ordtype=["Move Rotate Scale |Move Scale Rotate |Rotate Move Scale |Rotate Scale Move |Scale Move Rotate |Scale Rotate Move ......"]
    xyztype=["X Y Z |X Z Y |Y X Z |Y Z X |Z X Y |Z Y X "]
    popups=["",ordtype,xyztype] + Array.new(@dimensions.length,@@FuncPopupList)
    while true 
      results=inputbox(prompts,values,popups,"ParametricCopy: Parameters (#{@units}/degrees)")
      throw :CancelRequested if !results
      num=results[0]
      if num < 1
        @numcopies=1
        UI.beep
        UI.messagebox("ParametricCopy:\n\nThe Number of Copies MUST be at least 1.")
      else
        return results
      end#if  
    end #while     
  end#def dialogMain
  
#######################   ParametricCopy::applyFunc   ############################################

  def ParametricCopy::applyFunc(funcName, start, num, titlePrefix, unitPopup="", units=nil) 
    vals = Array.new
    begin
      #puts("applyFunc " + funcName)
      #puts("ClassName is " + @@FuncHash[funcName].name)
      func=@@FuncHash[funcName].new
      func.setParamVals(titlePrefix,unitPopup,units) 
      vals = func.generateOutput(start, num)
    rescue Exception => exc
      UI.messagebox("Error executing " + funcName + ":\n" + exc)
      retry
    end
    return vals 
  end #def
  
#######################   ParametricCopy::copy   ############################################
  def ParametricCopy::copy()
    @copies=[]
    0.upto(@numcopies) do |copying|
      copy=@group.copy
    ###copy.make_unique###
      @copies.push(copy)
    end#upto
  end#def copy  

#######################   ParametricCopy::move   ############################################
def ParametricCopy::move()
  xVals = ParametricCopy::applyFunc(@dimensionVals[0],0,@copies.length,"X-translation ",UnitUtils.translationPopup,@units)
  yVals = ParametricCopy::applyFunc(@dimensionVals[1],0,@copies.length,"Y-translation ",UnitUtils.translationPopup,@units)
  zVals = ParametricCopy::applyFunc(@dimensionVals[2],0,@copies.length,"Z-translation ",UnitUtils.translationPopup,@units)
  counter=0  
  @copies.each{|e|
    x = xVals[counter]
    y = yVals[counter]
    z = zVals[counter]
    point=Geom::Point3d.new(x,y,z)
    transform=Geom::Transformation.new(point)
    #e.move!(transform)
    e.transform!(transform)
    counter += 1
  }#end each
 end#def


#######################   ParametricCopy::rotateDim   ############################################

def ParametricCopy::rotateDim(funcName,start,vector,dimName) 
  vals = ParametricCopy::applyFunc(funcName,0,@copies.length,dimName,UnitUtils.rotationPopup,"degrees") 
  counter = 0
  @copies.each{|e|
      rot=vals[counter]
      p=Geom::Point3d.new(@ppoint.transform(e.transformation))
    r=Math::PI*rot/180
      rotate=Geom::Transformation.rotation(p,vector,r)
      e.transform!(rotate)
  counter += 1
    }#end each
end#def rotateIndex

#######################   ParametricCopy:: defs: rotateX,Y,Z   ############################################
def ParametricCopy::rotateX()
  ParametricCopy::rotateDim(@dimensionVals[3],@gx,Geom::Vector3d.new(1,0,0),"X-rotation");
end#def
def ParametricCopy::rotateY()
  ParametricCopy::rotateDim(@dimensionVals[4],@gy,Geom::Vector3d.new(0,1,0),"Y-rotation");
end#def
def ParametricCopy::rotateZ()
  ParametricCopy::rotateDim(@dimensionVals[5],@gz,Geom::Vector3d.new(0,0,1),"Z-rotation");
end#def


#######################   ParametricCopy::rotate   ############################################

def ParametricCopy::rotate()
  if @xyzrotation=="X Y Z "
    ParametricCopy::rotateX();ParametricCopy::rotateY();ParametricCopy::rotateZ()
  end#if
  if @xyzrotation=="X Z Y "
    ParametricCopy::rotateX();ParametricCopy::rotateZ();ParametricCopy::rotateY()
  end#if
  if @xyzrotation=="Y X Z "
    ParametricCopy::rotateY();ParametricCopy::rotateX();ParametricCopy::rotateZ()
  end#if
  if @xyzrotation=="Y Z X "
    ParametricCopy::rotateY();ParametricCopy::rotateZ();ParametricCopy::rotateX()
  end#if
  if @xyzrotation=="Z X Y "
    ParametricCopy::rotateZ();ParametricCopy::rotateX();ParametricCopy::rotateY()
  end#if
  if @xyzrotation=="Z Y X "
    ParametricCopy::rotateZ();ParametricCopy::rotateY();ParametricCopy::rotateX()
  end#if
end#def

#######################   ParametricCopy::scale   ############################################
def ParametricCopy::scale()
  xVals = ParametricCopy::applyFunc(@dimensionVals[6],1.0,@copies.length,"X-scale ",UnitUtils.scalePopup)
  yVals = ParametricCopy::applyFunc(@dimensionVals[7],1.0,@copies.length,"Y-scale ",UnitUtils.scalePopup)
  zVals = ParametricCopy::applyFunc(@dimensionVals[8],1.0,@copies.length,"Z-scale ",UnitUtils.scalePopup)
  counter=0  
  @copies.each{|e|
    xscale = xVals[counter]
    yscale = yVals[counter]
    zscale = zVals[counter]
    p=Geom::Point3d.new(@ppoint.transform(e.transformation))
    scaler=Geom::Transformation.scaling(p,xscale,yscale,zscale)
    e.transform!(scaler)
    counter += 1
  }#end each
end#def

############################################################################################ 
#######################   ParametricCopy::run   ############################################
############################################################################################ 

def ParametricCopy::run(pickpoint)
  catch :CancelRequested do
      @pickpoint=pickpoint
      @model=Sketchup.active_model
      @model.start_operation("ParametricCopy")
      @entities=@model.active_entities
      @ss=@model.selection
      ### get points
      @group=@entities.add_group(@ss)
      @gtrans=@group.transformation
      @gpoint=@gtrans.origin
      @gx=@gpoint.x
      @gy=@gpoint.y
      @gz=@gpoint.z
      @ppoint=Geom::Point3d.new(@pickpoint.x-@gx,@pickpoint.y-@gy,@pickpoint.z-@gz)
      @units=UnitUtils.getUnitString(@model)
      @dimensions = ["x-translate","y-translate","z-translate","x-rotate","y-rotate","z-rotate","x-scale","y-scale","z-scale"]
      @dimensionVals = Array.new(@dimensions.length,"")
      if not @numcopies
          @numcopies=1
          @order="Move Rotate Scale "
          @xyzrotation="X Y Z "
      end #if
    
    ######################################################################
    
      ###  Dialog: choose functions
      results=ParametricCopy::dialogMain(@numcopies,@order,@xyzrotation)
      @numcopies=results[0]
      @order=results[1]
        @xyzrotation=results[2]
      (0..@dimensionVals.length-1).each { |i| @dimensionVals[i]=results[i+3] }
    
    
    #####################################################################
    
      ### Growth do stuff...
      ParametricCopy::copy()
      ### ordering
      if @order=="Move Rotate Scale "
        ParametricCopy::move();ParametricCopy::rotate();ParametricCopy::scale()
      end#if
      if @order=="Move Scale Rotate "
        ParametricCopy::move();ParametricCopy::scale();ParametricCopy::rotate()
      end#if
      if @order=="Rotate Move Scale "
        ParametricCopy::rotate();ParametricCopy::move();ParametricCopy::scale()
      end#if
      if @order=="Rotate Scale Move "
        ParametricCopy::rotate();ParametricCopy::scale();ParametricCopy::move()
      end#if
      if @order=="Scale Move Rotate "
        ParametricCopy::scale();ParametricCopy::move();ParametricCopy::rotate()
      end#if
      if @order=="Scale Rotate Move ......"
        ParametricCopy::scale();ParametricCopy::rotate();ParametricCopy::move()
      end#if
      ###
      ### tidy up...
      ### remove 'spare' original group...
      @group.erase! if @group.valid?
      ### return copies back to original state...
      @copies.each{|e|e.explode if e.valid?}
      ### commit for total undo
      @model.commit_operation
      ###
    end #catch
  end#def run
  
  
end#class

### menu  #### #########################################################
if(not file_loaded?("ParametricCopy.rb"))###
  ###UI.menu("Plugins").add_separator
  UI.menu("Plugins").add_item("ParametricCopy"){Sketchup.active_model.select_tool(ParametricCopy.new)}
  ###$submenu5.add_item("ParametricCopy [Selection]"){Sketchup.active_model.select_tool(ParametricCopy.new)}
end#if
file_loaded("ParametricCopy.rb")
### ####################################################################

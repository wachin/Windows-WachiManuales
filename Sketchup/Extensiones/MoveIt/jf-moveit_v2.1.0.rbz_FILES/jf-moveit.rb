require 'sketchup'
require 'extensions'

module JF
	module MoveIt

		VERSION = '2.1'

		ext             = SketchupExtension.new("JF MoveIt", File.join(File.dirname(__FILE__), 'jf-moveit', 'main.rb'))
		ext.creator     = "Jim Foltz <jim.foltz@gmail.com>"
		ext.description = "Dialog for moving Groups and Components."
		ext.copyright   = "2011 - 2014, Jim Foltz"
		ext.version     = VERSION

		Sketchup.register_extension(ext, true)

		old_vers = File.join(File.dirname(__FILE__), 'mover2.rb')
		if File.exists?(old_vers)
			msg = "Thank you for installing MoveIt #{VERSION}.\n\n"
			msg << "I have found an older version installed.\nShall I remove it? (Recommended)"
			if UI.messagebox(msg, MB_YESNO) == IDYES
				begin
					File.delete(old_vers)
					UI.messagebox("File removed.")
				rescue => e
					msg = "Could not remove file:\n#{old_vers}\n"
					msg << e.message << "\n"
					msg << e.backtrace.join("\n")
					UI.messagebox(msg)
					puts(msg)
				end
			end
		end

	end # module MoveIt
end # module JF
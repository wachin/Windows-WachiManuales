==================================================================
	          FOCA, Final version. December 2015

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
	KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
	WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
	PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
	OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
	OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
	OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

	Copyright (C) Eleven Paths. All Rights Reserved.
==================================================================

	Requirements:
		
		- Windows OS
		- 3.5 .NET Framework
		- (*) Crystal Reports
	
	(*) Crystal Reports is a requierment for using the reports
	    module, also known as FOQUETTA. This module provides an
	    interface for generating PDF reports of the metadata, 
	    domains, users, and all the information that have been
	    collected by the FOCA engine.
	    If needed, it can be downloaded from the following link:
	    http://downloads.businessobjects.com/akdlm/cr4vs2010/CRforVS_13_0_7.exe

==================================================================

This is a portable version of FOCA (Fingerprinting Organizations 
with Collected Archives). 
It searchs for servers, domains, URLS and public documents and 
print out discoverd information in a network tree. It also serach 
for data leaks such as metadata, directory listing, unsecure HTTP 
methods, .listing or .DS_Store files, actived cache in DNS Serves, 
etc...

The executable of FOCA is located in 'bin/FOCA.exe'. Furthermore you
can find plugins for diferents purposes in the 'plugins' folder.

For adding a plugin to FOCA you can do it from the FOCA menu located
in 'Plugins > Load/Unload plugins > Load new plugin', and select one
of the plugins that are available.

List of official available plugins:

	- plugins/Fuzzer.dll
		This plugin is a HTTP Fuzzer based in a dictionary file

	- plugins/IISShortName.dll
		This plugin exploits the tilde (~) short file name
		vulnerability in IIS

	- plugins/HandlerSQLi.dll
		This plugin analyzes URLs in order to detect a MySQL
		injection. Also it extracts the database information

	- plugins/NTFSBasedServerEnumerator.dll
		Improved version of the IISShortNameExtractor and
		Fuzzer plugins.

	- plugins/svndownloader.dll
		It downloads and mounts all the file structure from a
		.svn/entries file.

	- plugins/HeartBeatPlugin.dll
		Exploits the heartbleed vulnerability.

For more information please visit http://www.elevenpaths.com
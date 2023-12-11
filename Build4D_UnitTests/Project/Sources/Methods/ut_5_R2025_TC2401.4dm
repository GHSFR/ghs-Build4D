//%attributes = {}
// Test _build() function in the default folder
var $build : cs.Build4D.CompiledProject
var $settings : Object
var $success : Boolean
var $destinationFolder : 4D.Folder
var $buildServer : 4D.File
var $link : Text
$link:=" (https://github.com/4d/4d/issues/"+Substring(Current method name; Position("_TC"; Current method name)+3)+")"

logGitHubActions(Current method name)

// MARK:- Current project

$settings:=New object()
$settings.formulaForLogs:=Formula(logGitHubActions($1))
$settings.destinationFolder:="./Test/"
$settings.signApplication:={adHocSignature: True}

$settings.sourceAppFolder:=(Is macOS) ? Folder(Storage.settings.macServer) : Folder(Storage.settings.winServer)


$settings.compilerOptions:={targets: ["x86_64_generic"]}


//the goal : Build a server application and add a file located at an absolute path to a destination located at an absolute path
$settings.includePaths:=New collection(New object(\
"source"; "/Custom Folder/"; \
"destination"; "/Ressources EN/")\
)


$build:=cs.Build4D.Server.new($settings)


$success:=$build.build()

ASSERT($success; "(Current project) Compiled project build should success"+$link)


var $folder : 4D.Folder

// Cleanup build folder
If ($success)
	
	$folder:=$build.settings.destinationFolder.folder("Contents/Server Database"+$settings.includePaths[0].destination)
	
	$folder:=$folder.folder(Substring($settings.includePaths[0].source; 2))
	
	
	ASSERT($folder.exists; "(Current project) The folder was not copied to the specified location. "+$link)
	
	If (Is macOS)
		
		$build.settings.destinationFolder.parent.delete(fk recursive)
		
	Else 
		// to validate on windows
		$build._projectPackage.parent.folder($build._projectFile.name+"_Build").delete(fk recursive)
		
	End if 
End if 


// MARK:- External project

$settings.projectFile:=Storage.settings.externalProjectFile

$build:=cs.Build4D.Server.new($settings)


$success:=$build.build()

ASSERT($success; "(External project) Compiled project build should success"+$link)


// Cleanup build folder
If ($success)
	
	
	$folder:=$build.settings.destinationFolder.folder("Contents/Server Database"+$settings.includePaths[0].destination)
	
	$folder:=$folder.folder(Substring($settings.includePaths[0].source; 2))
	
	ASSERT($file.exists; "(External project) The folder was not copied to the specified location. "+$link)
	
	If (Is macOS)
		
		$build.settings.destinationFolder.parent.delete(fk recursive)
		
	Else 
		// to validate on windows
		$build._projectPackage.parent.folder($build._projectFile.name+"_Build").delete(fk recursive)
		
	End if 
End if 
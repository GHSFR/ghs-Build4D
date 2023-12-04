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

var $source : 4D.File
var $path : Object

$settings:=New object()
$settings.formulaForLogs:=Formula(logGitHubActions($1))
$settings.destinationFolder:="./Test/"

$settings.sourceAppFolder:=(Is macOS) ? Folder(Storage.settings.macServer) : Folder(Storage.settings.winServer)

If (Is macOS)
	$settings.compilerOptions:=New object("targets"; New collection("x86_64_generic"; "arm64_macOS_lib"))  // Silicon compilation mandatory, else no code to sign, so can't check requested result
Else 
	$settings.compilerOptions:=New object("targets"; New collection("x86_64_generic"))
End if 

//the goal : signApp app
//$settings.signApplication:={adHocSignature: True}

$source:=File("/PACKAGE/README.md")
$path:={\
source: $source.path; \
destination: "/Ressources"\
}

$settings.includePaths:=[$path]


$build:=cs.Build4D.Server.new($settings)


$success:=$build.build()

ASSERT($success; "(Current project) Compiled project build should success"+$link)

If ($success)
	
	$file:=Folder($settings.includePaths[0].destination).file($source.fullName)
	
	ASSERT($file.exists; "(Current project) file added not found "+$source.path+" "+$link)
	
	
End if 


// Cleanup build folder

If (Is macOS)
	
	$build.settings.destinationFolder.parent.delete(fk recursive)
	
Else 
	// to validate on windows
	$build._projectPackage.parent.folder($build._projectFile.name+"_Build").delete(fk recursive)
	
End if 



// MARK:- External project

$settings.projectFile:=Storage.settings.externalProjectFile


//$path.destination:="/Ressources"
$build:=cs.Build4D.Server.new($settings)


$success:=$build.build()

ASSERT($success; "(External project) Compiled project build should success"+$link)

If ($success)
	
	$file:=Folder($settings.includePaths[0].destination).file($source.fullName)
	
	ASSERT($file.exists; "(External project) file added not found "+$source.path+" "+$link)
	
End if 


// Cleanup build folder

If (Is macOS)
	
	$build.settings.destinationFolder.parent.delete(fk recursive)
	
Else 
	// to validate on windows
	$build._projectPackage.parent.folder($build._projectFile.name+"_Build").delete(fk recursive)
	
End if 

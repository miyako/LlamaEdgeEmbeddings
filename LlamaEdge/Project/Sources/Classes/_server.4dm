Class extends _LlamaEdge

Class constructor($controller : 4D:C1709.Class)
	
	Super:C1705($controller)
	
Function export_chat_ui($home : 4D:C1709.Folder)
	
	var $htmlRootFolder : 4D:C1709.Folder
	$htmlRootFolder:=This:C1470.executableFile.parent.parent.parent.folder("chatbot-ui")
	
	If ($htmlRootFolder.exists)
		$home.create()
		If (Not:C34($home.folder($htmlRootFolder.fullName).exists))
			$htmlRootFolder.copyTo($home)
		End if 
	End if 
	
Function start($option : Object) : 4D:C1709.SystemWorker
	
	var $command : Text
	$command:=This:C1470.escape(This:C1470.executablePath)
	
	var $home : 4D:C1709.Folder
	If (Value type:C1509($option.home)=Is object:K8:27)\
		 && (OB Instance of:C1731($option.home; 4D:C1709.Folder))\
		 && ($option.home.exists)
		$home:=$option.home
	Else 
		$home:=Folder:C1567(fk home folder:K87:24).folder(".LlamaEdge")
	End if 
	
	This:C1470.controller.currentDirectory:=$home.parent
	
	$option.web_ui:="./.LlamaEdge/chatbot-ui/"
	This:C1470.export_chat_ui($home)
	
	$command+=" --dir .:"+This:C1470.escape(This:C1470.controller.currentDirectory.path)
	$command+=" "
	
	$model_name:=[]
	$model_alias:=[]
	$prompt_template:=[]
	$ctx_size:=[]
	
	var $models : Collection
	$models:=[]
	If ($option.models#Null:C1517)
		var $model : cs:C1710.LlamaEdgeModel
		For each ($model; $option.models)
			$command+=" --nn-preload "+$model.model_alias+":GGML:AUTO:"
			$command+=This:C1470.escape($model.path)
			$command+=" "
			$model_name.push($model.model_name)
			$model_alias.push($model.model_alias)
			$prompt_template.push($model.prompt_template)
			$ctx_size.push(String:C10($model.ctx_size))
		End for each 
	End if 
	
	$option.model_name:=$model_name.join(",")
	$option.model_alias:=$model_alias.join(",")
	$option.prompt_template:=$prompt_template.join(",")
	$option.ctx_size:=$ctx_size.join(",")
	
	$command+=" "
	$command+=This:C1470.escape(This:C1470.executableFile.parent.parent.parent.folder("wasm").file("llama-api-server.wasm").path)
	$command+=" "
	
	var $arg : Object
	var $valueType : Integer
	var $key : Text
	
	For each ($arg; OB Entries:C1720($option))
		Case of 
			: (["home"; "help"].includes($arg.key))
				continue
		End case 
		$valueType:=Value type:C1509($arg.value)
		$key:=Replace string:C233($arg.key; "_"; "-"; *)
		Case of 
			: ($valueType=Is real:K8:4)
				$command+=(" --"+$key+" "+String:C10($arg.value)+" ")
			: ($valueType=Is text:K8:3)
				$command+=(" --"+$key+" "+This:C1470.escape($arg.value)+" ")
			: ($valueType=Is boolean:K8:9) && ($arg.value)
				$command+=(" --"+$key+" ")
			: ($valueType=Is object:K8:27) && ((OB Instance of:C1731($arg.value; 4D:C1709.File)) || (OB Instance of:C1731($arg.value; 4D:C1709.Folder)))
				$command+=(" --"+$key+" "+This:C1470.escape(This:C1470.expand($arg.value).path))
			Else 
				//
		End case 
	End for each 
	
	//SET TEXT TO PASTEBOARD($command)
	
	return This:C1470.controller.execute($command; Null:C1517; $option.data).worker
	
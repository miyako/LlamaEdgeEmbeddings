Class constructor($port : Integer; $models : Collection; $options : Object; $event : cs:C1710.event.event)
	
	var $LlamaEdge : cs:C1710.workers.worker
	$LlamaEdge:=cs:C1710.workers.worker.new(cs:C1710._server)
	
	If (Not:C34($LlamaEdge.isRunning($port)))
		
		If ($models=Null:C1517)
			$models:=[]
		End if 
		
		If ($options=Null:C1517)
			$options:={}
		End if 
		
		If ($models.length=0)
			
			var $homeFolder : 4D:C1709.Folder
			$homeFolder:=Folder:C1567(fk home folder:K87:24).folder(".LlamaEdge")
			var $model : cs:C1710.LlamaEdgeModel
			var $file : 4D:C1709.File
			var $URL : Text
			var $prompt_template : Text
			var $ctx_size : Integer
			
			//#1 is chat model
			
			$file:=$homeFolder.file("llama/Llama-3.2-3B-Instruct-Q4_K_M.gguf")
			$URL:="https://huggingface.co/second-state/Llama-3.2-3B-Instruct-GGUF/resolve/main/Llama-3.2-3B-Instruct-Q4_K_M.gguf"
			$path:="./.LlamaEdge/llama/"+$file.fullName
			$prompt_template:="llama-3-chat"
			$ctx_size:=4096
			$model_name:="llama"
			$model_alias:="default"
			
			$model:=cs:C1710.LlamaEdgeModel.new($file; $URL; $path; $prompt_template; $ctx_size; $model_name; $model_alias)
			$models.push($model)
			
			//#2 is embedding model
			
			$file:=$homeFolder.file("nomic-ai/nomic-embed-text-v2-moe.Q5_K_M.gguf")
			$URL:="https://huggingface.co/nomic-ai/nomic-embed-text-v2-moe-GGUF/resolve/main/nomic-embed-text-v2-moe.Q5_K_M.gguf"
			$path:="./.LlamaEdge/nomic-ai/"+$file.fullName
			$prompt_template:="embedding"
			$ctx_size:=512
			$model_name:="nomic"
			$model_alias:="embedding"
			
			$model:=cs:C1710.LlamaEdgeModel.new($file; $URL; $path; $prompt_template; $ctx_size; $model_name; $model_alias)
			$models.push($model)
			
			$options.home:=$homeFolder
		End if 
		
		If ($port=0) || ($port<0) || ($port>65535)
			$port:=8080
		End if 
		
		This:C1470.main($port; $models; $options; $event)
		
	End if 
	
Function onTCP($status : Object; $options : Object)
	
	If ($status.success)
		
		var $className : Text
		$className:=Split string:C1554(Current method name:C684; "."; sk trim spaces:K86:2).first()
		
		CALL WORKER:C1389($className; Formula:C1597(start); $options; Formula:C1597(onModel))
		
	Else 
		
		var $statuses : Text
		$statuses:="TCP port "+String:C10($status.port)+" is aready used by process "+$status.PID.join(",")
		var $error : cs:C1710._error
		$error:=cs:C1710._error.new(1; $statuses)
		
		If ($options.event#Null:C1517) && (OB Instance of:C1731($options.event; cs:C1710.event.event))
			$options.event.onError.call(This:C1470; $options; $error)
		End if 
		
		This:C1470.terminate()
		
	End if 
	
Function main($port : Integer; $models : Collection; $options : Object; $event : cs:C1710.event.event)
	
	main({port: $port; models: $models; options: $options; event: $event}; This:C1470.onTCP)
	
Function terminate()
	
	var $LlamaEdge : cs:C1710.workers.worker
	$LlamaEdge:=cs:C1710.workers.worker.new(cs:C1710._server)
	$LlamaEdge.terminate()
﻿Function Get-ePoQuery
{
	<#	
		.SYNOPSIS
			Gets queries available using the ePo API.
		
		.DESCRIPTION
			Sends the command specified to the McAfee EPO server. Connect-ePoServer has to be run first,
			as this function uses the epoServer global variable created by that functions connection to the server. Uses the Invoke-ePoCommand
		
			
		.EXAMPLE
			$ePoQueries = Get-ePoQuery
			$ePoQueries
		
			Retruns the output of the core.listQueries API command and stores the PowerShell custom object in a variable.
			
			
	#>
	[CmdletBinding()]
	param
	()
	Begin
    {
		If(!($epoServer))
		{
			Write-Warning "Connection to ePoServer not found. Please run Connect-ePoServer first."
			break
		}  
    }
	Process 
	{
        $results = Invoke-ePOCommand -Command "core.listQueries"
        $Queries = ForEach($result in $results.result.list.query)
        {
            $props = @{
            QueryId=$result.id
            Name=$result.name
            Description=$result.description
            ConditionExpression=$result.conditionSexp
            GroupName=$result.groupName
            UserName=$result.userName
            CreatedOn=(Get-Date $result.createdOn)
            ModifiedOn=(Get-Date $result.modifiedOn)
            CreatedBy=$result.createdBy
            ModifiedBy=$result.modifiedBy
            }
            New-Object -TypeName psobject -Property $props
        }
        $Queries
    }
    End{}
}
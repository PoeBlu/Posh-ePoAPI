Function Connect-ePoServer 
{
	<#	
		.SYNOPSIS
			The Connect-ePoServer function establishes a connection the McAfee EPO Server.
		
		.DESCRIPTION
			The Connect-ePoServer function establishes a connection the McAfee EPO Server. All results are returned in XML
			format. The System.Net below is to bypass unstrusted https, which the server in my environment returns. Lists all
			of the commands available after a successful connection has been made.
		
		.PARAMETER ePOServer
			The url used to access the McAfee EPO.

		.EXAMPLE
			Connect-ePoServer
			
			Connects to the default McAfee EPO Server.
			
		.EXAMPLE
			Connect-ePoServer -ePOServer "https://yourserver"
			
			Connects to the McAfee EPO Server at https://yourserver

        .EXAMPLE
            Connect-ePoServer -ePoServer -ePOServer "https://yourserver"
            $ePoCommands | Where {$_.Command -like "*system*"} | Get-ePoCommandHelp

            This makes an active connection to the server. It then gets the command help for all of the commands that have the word system in it.
			
		.NOTES
			This function creates two global variables, ePOServer and ePOCommands. ePOServer is the url of the McAfee EPO Server and ePOCommands is a custom PowerShell
            object that contains the command and the full command text from the core.help command. This variable $ePoCommands can be piped to Get-ePoCommandHelp.
			
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory=$False,
		ValueFromPipeline=$True, ValueFromPipelinebyPropertyName=$true)]
		[alias("CN","MachineName")]
		[string]$ePOServer	= "https://mcafeeURL"
	)
	Begin
	{
		add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

		$global:epoServer = $ePOServer
		$Credentials = Get-Credential
		$epoUser= $Credentials.GetNetworkCredential().username
		$epoPassword=$Credentials.GetNetworkCredential().password
		$global:wc=new-object System.net.WebClient
		$wc.Credentials = New-Object System.Net.NetworkCredential -ArgumentList ($epouser,$epopassword)
	}
	Process 
	{
		$url = "$($epoServer)/remote/core.help?:output=xml"
		$ePoCommands = [xml](($wc.DownloadString($url)) -replace "OK:`r`n")
		$global:ePoCommands = ForEach($Command in $ePoCommands.result.list.element)
        {
            $CommandName = ($Command -split ' ')[0]
            $CommandUse = $Command -replace ".*-"
            $props = @{Command=$CommandName
              CommandText=$CommandUse
              }
            New-Object -TypeName PSObject -Property $props
        }
        $ePoCommands
	}
	End{}
}
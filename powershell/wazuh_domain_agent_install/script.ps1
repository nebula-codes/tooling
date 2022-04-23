<#
    .SYNOPSIS
    Installs wazuh agents to all domain computers using a specific http or ftp url given.

    .DESCRIPTION
    Installs wazuh agents to all domain computers using a specific http or ftp url given.
    Will uninstall the current agent if they already exist and reinstall with the newly given parameters.
    Made for deploying to hosts that do not have internet access and can only fetch from an internal server.

    .PARAMETER SERVERURI
    The URI for the http/ftp server to retrieve the agent from.

    .PARAMETER WAZUH_MANAGER
    Specifies the wazuh manager IP or FQDN.

    .PARAMETER AGENT_VERSION
    Wazuh agent version.

    .PARAMETER WAZUH_REGISTRATION_SERVER
    Specifies the Wazuh registration server. By default, will use the manager ip given.

    .PARAMETER WAZUH_AGENT_GROUP
    Sepecifies which group to set the agents in. By default, will put in the "default" group.

    .PARAMETER EXCLUDESELF
    Do you want to exclude the server running the command. False by default.

    .PARAMETER HOSTSFILE
    Path to hosts file to deploy to.

    .EXAMPLE
    PS>script.ps1 -SERVERURI 'ftp://127.0.0.1/' -WAZUH_MANAGER '10.10.0.1' -AGENT_VERSION '4.2.6-1'

    .EXAMPLE
    PS>script.ps1 -SERVERURI 'ftp://127.0.0.1/' -WAZUH_MANAGER '10.10.0.1' -WAZUH_REGISTRATION_SERVER '10.10.0.2' -WAZUH-AGENT_GROUP 'Workstations' -EXCLUDESELF true

    .LINK
    https://github.com/nebula-codes/tooling
#>


[CmdletBinding()]
param (
    [parameter(mandatory)]
    [String]$SERVERURI,
    [parameter(mandatory)]
    [string]$WAZUH_MANAGER,
    [parameter(mandatory)]
    [string]$AGENT_VERSION,
    [string]$WAZUH_REGISTRATION_SERVER = $WAZUH_MANAGER,
    [string]$WAZUH_AGENT_GROUP = "default",
    [string]$HOSTSFILE = $null,
    [bool]$EXCLUDESELF = $false
)

$SELF = $env:COMPUTERNAME
$HOSTS = @()

if([string]::IsNullOrEmpty($HOSTSFILE)) {
    if($EXCLUDESELF){
        $HOSTS = (Get-ADComputer -Filter {Name -notlike $SELF -And Enabled -ne $False}).Name
        [Array]::Sort($HOSTS)
    } else {
        $HOSTS = (Get-ADComputer -Filter {Enabled -ne $False}).Name
        [Array]::Sort($HOSTS)
    }
} else {
    if(Test-Path -Path $HOSTSFILE -PathType Leaf){
        $HOSTS = Get-Content -Path $HOSTSFILE
    } else {
        Write-Error("Hosts file provided does not exists.")
    }
}

if($null -eq $HOSTS){
    Write-Error("Hosts list empty. Nothing to deploy to.")
    Exit
} else {
    Write-Output("Host count: " + $HOSTS.count)
}


foreach($Computer in $HOSTS){
    Invoke-Command -ComputerName $Computer -ScriptBlock {
        $AGENT = 'wazuh-agent-' + $Using:AGENT_VERSION + '.msi'
        $URI = $Using:SERVERURI + '/' + $AGENT
        
        if (-not(Test-Path -Path 'C:\wazuh_agent\')){
            New-Item -Path 'C:\wazuh_agent\' -Name "wazuh_data" -ItemType "directory";
        }

        $INSTALLER_PATH = 'C:\wazuh_agent\wazuh_data\' + $AGENT
    
        if([System.IO.File]::Exists($INSTALLER_PATH)){ 
            Write-Output("Installer agent found. Removing Previous agent.")
    
            $argList = @(
                '/x'
                $INSTALLER_PATH
                '/qn'
            )
            $Result = (Start-Process -FilePath 'msiexec.exe' -ArgumentList $argList -Wait -PassThru).ExitCode
            Write-Output($Result)
    
    
        } else {
            Invoke-WebRequest -Uri $URI -OutFile $INSTALLER_PATH; 
            Write-Output("Agent downloaded from: " + $URI);
        }
    
        if(Test-Path -Path $INSTALLER_PATH -PathType Leaf){
            $argList = @(
                '/i'
                $INSTALLER_PATH
                '/q'
                'WAZUH_MANAGER="{0}"' -f $Using:WAZUH_MANAGER
                'WAZUH_REGISTRATION_SERVER="{0}"' -f $Using:WAZUH_REGISTRATION_SERVER
                'WAZUH_AGENT_GROUP="{0}"' -f $Using:WAZUH_AGENT_GROUP
            )
    
            $Result = (Start-Process -FilePath 'msiexec.exe' -ArgumentList $argList -Wait -PassThru).ExitCode
            
            Write-Output("Results: " + $Result)
            Write-Output("Starting WazuhSvc service on " + $Computer + "..")
            Start-Service WazuhSvc   
        } else {
            Write-Output("Agent INSTALLER_PATH not found!")
        }
    }
}

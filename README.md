# tooling
General scripts and tools for home use
`
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

    .PARAMETER DATAPATH
    Path to install the agent and scripts if required. Default: "C:\srcipts\"

    .PARAMETER HOSTSFILE
    Path to hosts file to deploy to.

    .EXAMPLE
    PS> Deploy-Agents -SERVERURI 'ftp://127.0.0.1/' -WAZUH_MANAGER '10.10.0.1' -AGENT_VERSION '4.2.6-1'

    .EXAMPLE
    PS>script.ps1 -SERVERURI 'ftp://127.0.0.1/' -WAZUH_MANAGER '10.10.0.1' -WAZUH_REGISTRATION_SERVER '10.10.0.2' -WAZUH-AGENT_GROUP 'Workstations' -EXCLUDESELF true

    .LINK
    https://github.com/nebula-codes/tooling
#>
`

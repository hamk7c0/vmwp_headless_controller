Param([Parameter(Position = 0)]
    [string[]]
    $mode
)
DynamicParam {
    if ( $mode -ne "list") {
        $parameterAttribute = [System.Management.Automation.ParameterAttribute]@{
            Position = 1
            HelpMessage = "Please target vm name"
        }
        $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
        $attributeCollection.Add($parameterAttribute)
        $dynParam = [System.Management.Automation.RuntimeDefinedParameter]::new(
            'vmname', [string], $attributeCollection
        )
        $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        $paramDictionary.Add('vmname', $dynParam)
        return $paramDictionary
    }
}

Begin {
    $vmname = $PSBoundParameters['vmname']
    $INIFILE="$env:USERPROFILE\Application Data\VMware\preferences.ini"
    $EXEFILE="c:\Program Files (x86)\VMware\VMware Player\vmrun.exe"

    if (-! (Test-Path "$INIFILE")){
        Write-Error -Message "preferences.ini not found at $INIFILE" -ErrorAction Stop
    }
    if (-! (Test-Path "$EXEFILE")){
        Write-Error -Message "vmrun.exe not found at $EXEFILE" -ErrorAction Stop
    }    
}

Process {
    Function showUsage(){
        $script_file = Split-Path -Leaf .\vmp_controller.ps1$PSCommandPath
        Write-Host "Examples:"

        Write-Host ""
        Write-Host "List a virtual machine with Workstation on a Windows host"
        Write-Host "  .\$script_file list"

        Write-Host ""
        Write-Host "Starting a virtual machine with Workstation on a Windows host"
        Write-Host "  .\$script_file start [<VirtualMachineName>]"

        Write-Host ""
        Write-Host "Stopping a virtual machine with Workstation on a Windows host"
        Write-Host "  .\$script_file stop [<VirtualMachineName>]"

        Write-Host ""
        Write-Host "Suspending a virtual machine with Workstation on a Windows host"
        Write-Host "  .\$script_file suspend [<VirtualMachineName>]"


    }

    Function check_mode(){
        $result = switch($mode){
            "reset"   { ($null -ne $vmname) }
            "start"   { ($null -ne $vmname) }
            "stop"    { ($null -ne $vmname) }
            "suspend" { ($null -ne $vmname) }
            "list"    { $true }
            default   { $false }
        }
        return $result
    }

    Function get_vmlist(){
        $parameter = @{}
        (Get-Content $INIFILE) -replace "\\","\\" | %{$parameter += ConvertFrom-StringData -StringData $_} 
        $keys = @()
        $keys = [regex]::Matches($parameter.keys, "pref.mruVM[0-9]*.displayName") | % {$_.Value}

        $hash = @{}
        foreach($key in $keys){
            $name = $parameter.$key.Trim('"')
            $file = $parameter.($key.Replace(".displayName",".filename")).Trim('"')
            $hash.add($name, $file)
        }
        return $hash
    }

    Function display_vmlist(){
        $poweron_vms = @()
        $poweron_vms = ((& $EXEFILE list) -match "vmx")
        $results = @()

        foreach($key in $vmlist.Keys){
            $result = New-Object PSObject | Select-Object VirtualMachineName, IsRunning
            $result.VirtualMachineName = $key
            if ($poweron_vms -contains $vmlist.$key){
                $result.IsRunning = $true
            }else {
                $result.IsRunning = $false
            }
            $results+=$result
        }
        $results
    }

    Function operate_vm(){
        if ($vmlist.Keys -contains $vmname){
            try{
                if ($mode -eq "start"){
                    & $EXEFILE $mode $vmlist.$vmname nogui
                }else{
                    & $EXEFILE $mode $vmlist.$vmname
                }
            }catch{
                $ErrorMsg = $_.Exception_Message
                $ErrorMsg
                Write-Error -Message "Error: operation failed"
            }
        }else{
            Write-Error -Message "Target VM(name: $vmname ) not found"
        }
    }


    if ( check_mode ) {
        $vmlist = get_vmlist
        switch($mode){
            "list"  { display_vmlist }
            default { operate_vm } 
        }
    }else {
        showUsage
    }
}

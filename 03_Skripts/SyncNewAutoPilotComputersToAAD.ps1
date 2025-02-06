# SyncNewAutoPilotComputersandUsersToAAD.ps1
#
# Version 1.3
#
# Stolen from Alex Durrant. Updated by Steve Prentice, 2020
#
# Triggers an ADDConnect Delta Sync if new objects are found to be have been created
# in the OU's in question, this is helpful with Hybrid AD joined devices via Autopilot
# and helps to avoid the 3rd authentication prompt.
#
# Only devices with a userCertificate attribute are synced, so this script only attempts
# to sync devices that have been created within the last 5 hours and have the attribute set,
# which is checked every 5 minutes via any changes in the object's Modified time.
#
# Install this as a scheduled task that runs every 5 minutes on your AADConnect server.
# Change the OU's to match your environment.

Import-Module ActiveDirectory

$time = [DateTime]::Now.AddMinutes(-5)
$computersZentrale = Get-ADComputer -Filter 'Modified -ge $time' -SearchBase "OU=Deploy_Autopilot,OU=NewClients,OU=Hoedlmayr,DC=hji,DC=local" -Properties Created, Modified, userCertificate
#$computersUK = Get-ADComputer -Filter 'Modified -ge $time' -SearchBase "OU=Computer,OU=UK,OU=Standorte,DC=hji,DC=local" -Properties Created, Modified, userCertificate
#$computersNZ = Get-ADComputer -Filter 'Modified -ge $time' -SearchBase "OU=Computer,OU=NZ,OU=Standorte,DC=hji,DC=local" -Properties Created, Modified, userCertificate

#$users = Get-ADUser -Filter 'Created -ge $time' -SearchBase "OU=W10Users,OU=Users,DC=somedomain,DC=com" -Properties Created

If ($computersZentrale -ne $null) {
    ForEach ($computerZentrale in $computersZentrale) {
        $diff = $computerZentrale.Modified.Subtract($computerZentrale.Created)
        If (($diff.TotalHours -le 5) -And ($computerZentrale.userCertificate)) {
            # The below adds to AD groups automatically if you want
            #Add-ADGroupMember -Identity "Some Intune Co-management Pilot Device Group" -Members $computer
            $syncComputersZentrale = "True"
        }
    }
    # Wait for 30 seconds to allow for some replication
    Start-Sleep -Seconds 30
}

If ($syncComputersZentrale -ne $null) {
    Try { Start-ADSyncSyncCycle -PolicyType Delta }
    Catch {}
}

##########################

#If ($computersUK -ne $null) {
#    ForEach ($computerUK in $computersUK) {
#        $diff = $computerUK.Modified.Subtract($computerUK.Created)
#        If (($diff.TotalHours -le 5) -And ($computerUK.userCertificate)) {
#            # The below adds to AD groups automatically if you want
#            #Add-ADGroupMember -Identity "Some Intune Co-management Pilot Device Group" -Members $computer
#            $syncComputersUK = "True"
#        }
#    }
#    # Wait for 30 seconds to allow for some replication
#    Start-Sleep -Seconds 30
#}

#If ($syncComputersUK -ne $null) {
#    Try { Start-ADSyncSyncCycle -PolicyType Delta }
#    Catch {}
#}

###########################


#If ($computersNZ -ne $null) {
#    ForEach ($computerNZ in $computersNZ) {
#        $diff = $computerNZ.Modified.Subtract($computerNZ.Created)
#        If (($diff.TotalHours -le 5) -And ($computerNZ.userCertificate)) {
#            # The below adds to AD groups automatically if you want
#            #Add-ADGroupMember -Identity "Some Intune Co-management Pilot Device Group" -Members $computer
#            $syncComputersNZ = "True"
#        }
#    }
    # Wait for 30 seconds to allow for some replication
#    Start-Sleep -Seconds 30
#}

#If ($syncComputersNZ -ne $null) {
#    Try { Start-ADSyncSyncCycle -PolicyType Delta }
#    Catch {}
#}



#Created By Mateusz Jędrusik
$DC = 0
$DCCounter = 0 
$DomainControllers = 0
$SKP = Read-Host "Insert User Login"
  $locked = Get-ADUser $SKP -Properties * | Select-Object LockedOut
        if ($Locked.LockedOut -eq 1){ #IF closed 
            $DomainControllers = Get-ADDomainController -Filter * #DC Check
            $LockedOutStats = @()    
                Foreach($DC in $DomainControllers){ #foreach
                $DCCounter++ 
                $dc.HostName
                Write-Progress -Activity "Connecting to DC" -Status "Querring $($DC.Hostname)" -PercentComplete (($DCCounter/$DomainControllers.Count) * 100)
                $Userinfo = Get-ADUser -Identity $SKP -Server $DC.HostName -Properties AccountLockoutTime,LastBadPasswordAttempt,BadPwdCount,LockedOut 
  
                If($UserInfo.BadPwdCount -gt 0){#if user
                    
                    $LockedOutStats += New-Object -TypeName PSObject -Property @{#Table
                            DomainController       = $DC.Name
                            Name                   = $UserInfo.Name 
                            SID                    = $UserInfo.SID.Value 
                            LockedOut              = $UserInfo.LockedOut 
                            BadPwdCount            = $UserInfo.BadPwdCount 
                            BadPasswordTime        = $UserInfo.BadPasswordTime             
                            AccountLockoutTime     = $UserInfo.AccountLockoutTime 
                            LastBadPasswordAttempt = ($UserInfo.LastBadPasswordAttempt).ToLocalTime() 
                    }#table          
                    }#if user
                    
                }#Zamknięcie Foreach

                $LockedOutStats | Format-Table -Property DomainController,Name,LockedOut,BadPwdCount,AccountLockoutTime,LastBadPasswordAttempt -AutoSize              
                Foreach($DC in $LockedOutStats){ #foreach start scan
                cd 'PATH' #Inser PATH to eventCombMT.exe
                .\eventcombMT.exe /s:$($DC.DomainController) /evt:"529 644 675 676 681 4625 4648 4771 4768 4740" /text:$SKP /start /log:sec /et:safa
                }#close foreach skan
                $unlock = Read-Host "Would you like to unlock account? Y/N"
                if ($unlock -eq "Y"){ #if unlock Y
                Unlock-ADAccount -Identity $SKP
                    if ($blokada.LockedOut -eq 0){ #if zablokowane
                    Write-Host "Account unlocked"
                    }#if zablokowane
                    else{ #if zablokowane true
                    Write-Host "Account still locked"
                    } #if zablokowane true
                }#if unlock Y
                elseif($unlock -eq "N"){#if unlock N
                Write-Host "Account unlocked"
                }#if unlock N
                else{#if error
                Write-Host "Bad info"
                }#if error
        }#if Closed
        else {
        Write-Host "Account not locked"
        }  

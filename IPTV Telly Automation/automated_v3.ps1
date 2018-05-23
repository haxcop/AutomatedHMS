######### Created by Carlos L. AKA: HAXCOP #############
######################### V3 ###########################
#and thanks to the creators of these tools used bellow#
# tombowditch = https://github.com/tombowditch/telly
# jjssoftware = https://github.com/jjssoftware/m3u-epg-editor
# Removed actions to add path enviroments and refresh sesions for a simpler wide use
# ENJOY #
Function TEST-LocalAdmin { 
    Return ([security.principal.windowsprincipal] [security.principal.windowsidentity]::GetCurrent()).isinrole([Security.Principal.WindowsBuiltInRole] "Administrator") 
} 
function directories {
    $global:L = "$Home\Documents\telly"
    if (!(test-path $L)) { mkdir $L}
    
    Set-Location "$L"

    $global:Original = "$L\Original"
    if (!(test-path $Original)) { mkdir $Original }

    $global:DG = "$L\Sorted"
    if (!(test-path $DG)) { mkdir $DG }

    $global:HD = "$L\HD"
    if (!(test-path $HD)) { mkdir $HD }

    $global:SD = "$L\SD"
    if (!(test-path $SD)) { mkdir $SD }

    $global:m3u = "$L\m3u-epg-editor-master\"
    
} 
Function download_telly {
    if (!(Test-Path $L\telly.exe)) {
        
        Write-Output "Downloading telly v0.5 into  $L\telly.exe"
        #telly variables
        $tellyURL = "https://github.com/tombowditch/telly/releases/download/v0.5/telly-windows-amd64.exe" # This could change 
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $tellyURL -OutFile "$L\telly.exe" ;
    }
    
}
function download_m3u_epg_editor {
    
    if (!(Test-Path "$m3u")) {
        
        Write-Output "Downloading m3u-epg-editor into $L\m3u-epg-editor-master"
        #m3u editor variable
        $m3u_editor_url = "https://github.com/jjssoftware/m3u-epg-editor/archive/master.zip" # this could change in time
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest $m3u_editor_url -OutFile "$L\m3u-epg-editor-master.zip" ;
        Expand-Archive "$L\m3u-epg-editor-master.zip" -DestinationPath $L ;
        Remove-Item -Path "$L\m3u-epg-editor-master.zip" -Force;
                           
    }
} 
function download_python27 {
    if (!(Test-Path "C:\Python27")) {
    
   
        $message = 'In order to run this script we will need python27 and the dependencies'
        $question = 'Would you like to install python27 and the dependencies required to run this script or want to do it manually later?'
        
        $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
        
        $decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)
        if ($decision -eq 0) {
            
            Write-Host 'confirmed'
            #Python URL link
            $pythonMSI = "$L\python-2.7.14.amd64.msi"
            $pythonURI = "https://www.python.org/ftp/python/2.7.14/python-2.7.14.amd64.msi" 
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri "$pythonURI" -outfile "$pythonMSI" | Out-Null
        }
        else {
            Write-Host "Python2.7.14 Is Required to work properly with this Script"
            Write-Host "Please donwload it and try again after installation
                        Including the following dependencies
                        requests
                        python-dateutil"


            Exit-PSSession
        }
    }
} 
function Install_Python27 {
    

    # declared where python is being downloaded
    $pythonMSI = "$home\documents\telly\python-2.7.14.amd64.msi" 
    $targetDir = "C:\Python27"

    if (!(Test-Path $targetDir)) {
        Write-Verbose "Installing $pythonMSI....."
        Write-host ""
        Write-host 
        "Please wait until the installation process finish...
        ----------------------------------------------------
        "
        Write-host ""
        msiexec.exe /i $pythonMSI /qnf /norestart /l $L\python.logs.txt  ADDLOCAL=ALL | out-null
        Remove-Item -Path $pythonMSI -Force

        
    }
} 
function install_python_pkg {
    C:\Python27\python.exe -m pip install --upgrade pip;
    if (!(Test-Path "C:\Python27\Lib\site-packages\requests")) {
        
        C:\Python27\python.exe -m pip install requests
    }
    
    if (!(Test-Path "C:\Python27\Lib\site-packages\python_dateutil-2.7.2.dist-info")) {
        
        C:\Python27\python.exe -m pip install python-dateutil
    }
    Write-Output ""    
    Write-Host "Moving on with the script."
    
} 
#Adding recursive deletion of groups in the file
function m3u_semi_automated {
    <# Add your channels or channel groups manually as showed below for direct automation and uncomment it
    $ChannelGroups = "'sports','ireland'"
    Comment with # the line bellow #$GC = Read-Host "" & #$ChannelGroups = "$CG" if you do not want user prompt
    and uncomment the above  $ChannelGroups = "'Your','Channels'"
    #>
    $Vaders2 = "http://api.vaders.tv/vget?username=______&password=_______&format=ts"
    $VadersEPG_VOD = "http://vaders.tv/p2.xml.gz"
    $CG = "sports"
    $G = "$DG\Sorted"
    Write-Output "Starting to downloand and sort alphetically the channels and groups"
    Write-Output "" 
    Write-Output ""   
    Write-Output ""
   
    cd $m3u
    C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$Vaders2" -e="$VadersEPG_VOD" -g "'$CG'" -c="$no_epg_channels" --outdirectory="$DG" --outfilename="$G";
   

    $Sorted_m3u = "$G.m3u8"
    $Original_Local = "file:///$Original_m3u" # alt you can use the original file downloaded for manual teak of the lines below
    $Sorted_m3u_Local = "file:///$Sorted_m3u" # By preference I choose the already sorted file
    <# Filter the undesired channels (you can take this ones running the epg-ditor once with or without the Groups {$CG} above to see the NON-EPG channel list as shown {$uc})
    $no_epg_channels = "'26 tv hd','a&e lt hd','amc lt hd','axn lt hd','animal planet hd lt','azteca 13','azteca 7','bandamax lt','cbn hd','cbs news hd','cbs sports hq','cnn lt','canal 11','canal de las estrellas','cinecanal','comedy central lt','de pelicula','discovery channel lt hd','discovery civilization','discovery home & health','discovery science lt','discovery theater','discovery turbo lt','disney jr lt','disney lt hd','disney xd lt','e! lt','espn 2 lt','espn 3 lt','espn lt','fight tyme','fox action lt','fox cinema lt','fox movies lt','fox sports 2 lt hd','fox sports 3 lt hd','fox sports carolina hd','fox sports indiana hd','fox sports lt hd','fox sports south georgia hd','fox sports south georgia hd','fox sports tennessee hd','fox sports tennessee hd','galavision hd','hbo family lt hd','hbo lt hd','hbo plus lt hd','hbo signature lt hd','history lt hd','mimusica hd','nbc philadelphia','nbc universo 2 hd','nbc universo 2 hd','nbc universo hd','nbc universo hd','nat geo lt','nat geo wild lt','osn cricket hd','rds 2','sony lt','spectrum sportsnet hd','spectrum sportsnet la hd','tva sports hd','telemundo los angeles hd','unimas hd','univision miami hd'"
	#>
    $no_epg_channels = Get-Content "$DG\no_epg_channels.txt"
    $SC = "$DG\sorted.channels.txt" # Channels from A-Z
    $SCNG = "$DG\sorted.channels.nogroup.txt" # Channels from A-Z without Group	
    $filename_hd = "$HD\hd.channels.only.txt" # No SD Channels List
    $filename_sd = "$SD\sd.channels.only.txt" # No HD Channels List
    $IPTVSD = "$SD\SDTv.unique.txt" # SD Channels List without Duplicates
    $IPTVHD = "$HD\HDTv.unique.txt" # HD Channels List without Duplicates
    (get-content $SC) -replace "'$CG'", "" | out-file "$SCNG"
    (get-content $SCNG) -notmatch "hd" | out-file $filename_sd
    get-content $filename_sd | Sort-Object | get-unique > $IPTVSD
    $replaceCharacter = ''
    $contentSD = Get-Content $IPTVSD
    $contentSD[-1] = $contentSD[-1] -replace '^(.*).$', "`$1$replaceCharacter"
    $contentSD | Set-Content $IPTVSD
    (get-content $scng) -match "hd" | out-file $filename_hd
    get-content $filename_hd | Sort-Object | get-unique > $IPTVHD
    $contentHD = Get-Content $IPTVHD
    $contentHD[-1] = $contentHD[-1] -replace '^(.*).$', "`$1$replaceCharacter"
    $contentHD | Set-Content $IPTVHD
    $gcSD = Get-Content $IPTVSD
    $gcHD = Get-Content $IPTVHD
    $I = "$HD\HDTv" 
    $K = "$SD\SDTv"
    $message = 'Step 1 complete, Cool! *_0'
    $question = 'Would you like to create a separate folder with HD Channels only?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        cd $m3u
        C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$Sorted_m3u_Local" -e="$VadersEPG_VOD" -g "'$CG'" --channels="$no_epg_channels,$gcSD" --outdirectory="$HD" --outfilename="$I"
        
        
        $HDTv = "$HD\HDTv.m3u8"
        Remove-Item "$HD\original.*"

    }
    else {
        Write-Host 'Ok no HD Then...'
    }
  
    $message = 'Step 2 to create an even better sorting'
    $question = 'Would you like to create a separate folder with SD Channels only?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 0)
    if ($decision -eq 0) {
        Write-Host 'Cool!'
        
        cd $m3u
        C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$Sorted_m3u_Local" -e="$VadersEPG_VOD" -g "'$CG'" --channels="$no_epg_channels,$gcHD" --outdirectory="$SD" --outfilename="$K"      
       
        $SDTv = "$SD\SDTv.m3u8"
        Remove-Item "$SD\original.*"
    }
    else {
        Write-Host 'Ok no SD Then...'
    }    
   
    Move-Item "$DG\original.*" -Destination $Original -Force
    $message = '...Telly Scripts Time as Come...'
    $question = 'Would you like to Run Telly with the sorted channels?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        
        Write-Output "Set-Location ""$DG""
                    $L\telly.exe -listen 127.0.0.1:9077 -playlist=""$($Sorted_m3u)"" -temp ""$DG"" -streams 5 -friendlyname ""Sorted_Channels"" -deviceid ""10000009"" -logrequests" | set-content $DG\telly_Sorted.ps1

        Write-Output "@ECHO OFF
                      PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $DG\telly_Sorted.bat

        Start-Process -FilePath "$DG\telly_Sorted.bat"

    }
    else {
        Write-Host 'OK...'
    }
    $message = '0_o'
    $question = 'Would you like to Run Telly with the HD channels?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No')) 
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        Write-Output "Set-Location ""$HD""
                        $L\telly.exe -listen 127.0.0.1:8077 -playlist=""$($HDTv)"" -temp ""$HD"" -streams 5 -friendlyname ""HDTv"" -deviceid ""10000008"" -logrequests" | set-content $HD\telly_HD.ps1

        Write-Output "@ECHO OFF
                      PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $HD\telly_HD.bat
        Start-Process -FilePath "$HD\telly_HD.bat"

    }
    else {
        Write-Host 'OK...'
    }
    $message = '...0_0'
    $question = 'Would you like to Run Telly with the SD channels?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        Write-Output "Set-Location ""$SD""
                        $L\telly.exe -listen 127.0.0.1:7077 -playlist=""$($SDTv)"" -temp ""$SD"" -streams 5 -friendlyname ""SDTv"" -deviceid ""10000007"" -logrequests" | set-content $SD\telly_SD.ps1
        Write-Output "@ECHO OFF
                      PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $SD\telly_SD.bat
        Start-Process -FilePath "$SD\telly_SD.bat"

    }
    else {
        Write-Host '-_-'
    }    
}
function m3u_manual {
    
    #<#
    $Vaders2 = Read-Host "
    Plese include your Vader's VOD ot Live TV M3U-URL or even local File 
    You can change this for FABI IPTV or any other Local File
    Keep in Mind the groups showed below will only apply for Vader's.
    If you are using another provider please check the m3u file

    VOD:   http://vaders.tv/get.php?username=XXX&password=XXX&type=m3u_plus&output=ts 
    Live:  http://api.vaders.tv/vget?username=XXX&password=XXX&format=ts
    Local: file:///C:\your\file\path.m3u
    
    Set your M3U"
    
    # B Set your epg
    $VadersEPG_VOD = Read-Host "
    
    Please include your Vaders EPG
    VOD:   http://vaders.tv/xmltv.php?username=usr&password=pass
    Live:  http://vaders.tv/p2.xml.gz
    Local: file:///C:\your\file\path.xml 
   
    Set your EPG"
    # uncomment below to not show the message 
    #<#
    
    Write-Output  "
    Original groups found in Vader's Live & VOD M3U these could change
    in time to time, please check your M3U in case of any error
    ===========================================
     IPTV Groups                     
    'afghani'                   ,'arabic'
    'bangla'	                ,'canada'
    'filipino'	                ,'france'
    'germany'	                ,'gujrati'
    'india'	                    ,'ireland'
    'italy'	                    ,'korea'
    'latino'	                ,'live events'
    'malayalam'	                ,'marathi'
    'pakistan'	                ,'portugal'
    'premium movies'            ,'punjabi'
    'scandinavian'              ,'spain'
    'sports'	                ,'tamil'
    'telugu'	                ,'thai'
    'Movies'                    ,'4K Movies'
    'united kingdom'            ,'united states'
    'united states - regionals','Live Events'
    ============================================
    " 
    #>
	
    $CG = Read-Host "Please enter your TV Groups, TV Channels in this way: 'groups','channels' the input MUST BE LOWERCASE
    You can see the Vader's groups above for reference
    
    Set your Channels or Groups"
    $GC1 = "'$GC'"

    $G = "$DG\Sorted"
    
    Write-Output "Starting to downloand and sort alphetically the channels and groups"
    Write-Output "" 
    Write-Output ""   
    Write-Output ""

    cd $m3u
    C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$Vaders2" -e="$VadersEPG_VOD" -g "$CG" -c="$no_epg_channels" --outdirectory="$DG" --outfilename="$G";

    $Sorted_m3u = "$G.m3u8"
    $Original_Local = "file:///$Original_m3u" # alt you can use the original file downloaded for manual teak of the lines below
    $Sorted_m3u_Local = "file:///$Sorted_m3u" # By preference I choose the already sorted file
    $no_epg_channels = Get-Content "$DG\no_epg_channels.txt"
    $SC = "$DG\sorted.channels.txt" # Channels from A-Z
    $SCNG = "$DG\sorted.channels.nogroup.txt" # Channels from A-Z without Group	
    $filename_hd = "$HD\hd.channels.only.txt" # No SD Channels List
    $filename_sd = "$SD\sd.channels.only.txt" # No HD Channels List
    $IPTVSD = "$SD\SDTv.unique.txt" # SD Channels List without Duplicates
    $IPTVHD = "$HD\HDTv.unique.txt" # HD Channels List without Duplicates
    $file = $SC 

    (get-content $SC) -replace $CG, "" | out-file "$SCNG";
    (get-content $SCNG) -notmatch "hd" | out-file $filename_sd;
    get-content $filename_sd | Sort-Object | get-unique > $IPTVSD;
    $replaceCharacter = ''
    $contentSD = Get-Content $IPTVSD;
    $contentSD[-1] = $contentSD[-1] -replace '^(.*).$', "`$1$replaceCharacter";
    $contentSD | Set-Content $IPTVSD;
    (get-content $scng) -match "hd" | out-file $filename_hd;
    get-content $filename_hd | Sort-Object | get-unique > $IPTVHD;
    $contentHD = Get-Content $IPTVHD;
    $contentHD[-1] = $contentHD[-1] -replace '^(.*).$', "`$1$replaceCharacter";
    $contentHD | Set-Content $IPTVHD;
    $gcSD = Get-Content $IPTVSD;
    $gcHD = Get-Content $IPTVHD;
    $I = "$HD\HDTv" 
    $K = "$SD\SDTv"
    $message = 'Step 1 complete, Cool! *_0'
    $question = 'Would you like to create a separate folder with HD Channels only?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'

        cd $m3u
        C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$Sorted_m3u_Local" -e="$VadersEPG_VOD" -g "$CG" --channels="$no_epg_channels,$gcSD" --outdirectory="$HD" --outfilename="$I"
        
        $HDTv = "$HD\HDTv.m3u8"
        Remove-Item "$HD\original.*"

    }
    else {
        Write-Host 'Ok no HD Then...'
    }
  
    $message = 'Step 2 to create an even better sorting'
    $question = 'Would you like to create a separate folder with SD Channels only?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'Cool!'

        cd $m3u
        C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$Sorted_m3u_Local" -e="$VadersEPG_VOD" -g "$CG" --channels="$no_epg_channels,$gcHD" --outdirectory="$SD" --outfilename="$K"
       
        $SDTv = "$SD\SDTv.m3u8"
        Remove-Item "$SD\original.*"
    }
    else {
        Write-Host 'Ok no SD Then...'
    }    
   
    Move-Item "$DG\original.*" -Destination $Original -Force
    $message = '...Telly Scripts Time as Come...'
    $question = 'Would you like to Run Telly with the sorted channels?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        
        Write-Output "Set-Location ""$DG""
                        $L\telly.exe -listen 127.0.0.1:9077 -playlist=""$($Sorted_m3u)"" -temp ""$DG"" -streams 5 -friendlyname ""Sorted_Channels"" -deviceid ""10000009"" -logrequests" | set-content $DG\telly_Sorted.ps1

        Write-Output "@ECHO OFF
                      PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $DG\telly_Sorted.bat

        Start-Process -FilePath "$DG\telly_Sorted.bat"

    }
    else {
        Write-Host 'OK...'
    }
    $message = '0_o'
    $question = 'Would you like to Run Telly with the HD channels?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No')) 
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        Write-Output "Set-Location ""$HD""
                        $L\telly.exe -listen 127.0.0.1:8077 -playlist=""$($HDTv)"" -temp ""$HD"" -streams 5 -friendlyname ""HDTv"" -deviceid ""10000008"" -logrequests" | set-content $HD\telly_HD.ps1

        Write-Output "@ECHO OFF
                      PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $HD\telly_HD.bat
        Start-Process -FilePath "$HD\telly_HD.bat"

    }
    else {
        Write-Host 'OK...'
    }
    $message = '...0_0'
    $question = 'Would you like to Run Telly with the SD channels?'
    $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
    $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
    $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
    if ($decision -eq 0) {
        Write-Host 'confirmed'
        Write-Output "Set-Location ""$SD""
                    $L\telly.exe -listen 127.0.0.1:7077 -playlist=""$($SDTv)"" -temp ""$SD"" -streams 5 -friendlyname ""SDTv"" -deviceid ""10000007"" -logrequests" | set-content $SD\telly_SD.ps1
        Write-Output "@ECHO OFF
                      PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $SD\telly_SD.bat
        Start-Process -FilePath "$SD\telly_SD.bat"

    }
    else {
        Write-Host '-_-'
    }    
}

## VARS
#TEST-LocalAdmin;
#if (!(TEST-LocalAdmin)) {Write-Host " You Need to RUN AS ADMINISTRATOR first"; Return}
#Write-Output "Creating Directories"
#directories;
#download_telly;
#download_m3u_epg_editor;
#download_python27;
#Install_Python27;
#Write-Output " Checking Python dependencies...";
#install_python_pkg;
# At this point you can choose between m3u_manual or m3u_automated IF you have modified the required paths and arguments into the function.
#m3u_semi_automated;
m3u_manual;
## End
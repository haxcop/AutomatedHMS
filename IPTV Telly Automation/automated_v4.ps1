######### Created by Carlos L. AKA: HAXCOP #############
# changes in v4 by chazlarson
# only remove last character of channel list if it's a comma
# split up batch-file generation and invocation to reduce duplicated code
# don't ask to start Telly for HD or SD if those weren't generated
# remove tests on python modules to account for possible upgrades
# merge semi-automated and manual; reduce duplicated code
# [semi-auto is now triggered by emptying the defines at the top of the file]
# renamed some variables for readability
# wrapped user-editable paths in quotes to allow paths with spaces
# 
######################### V3 ###########################
#and thanks to the creators of these tools used bellow#
# tombowditch = https://github.com/tombowditch/telly
# jjssoftware = https://github.com/jjssoftware/m3u-epg-editor
# Removed actions to add path enviroments and refresh sesions for a simpler wide use
# ENJOY #

########################################################################################################
################################ USER-EDITABLE PARAMETERS ##############################################
########################################################################################################

# if these are filled in, the script will run without asking for them
# ala the original "semi-automated" mode.
$global:m3u_url = ""
#		VOD:   http://vaders.tv/get.php?username=XXX&password=XXX&type=m3u_plus&output=ts 
#		Live:  http://api.vaders.tv/vget?username=XXX&password=XXX&format=ts
#		Local: file:///C:\your\file\path.m3u

$global:epg_url = ""
#		VOD:   http://vaders.tv/xmltv.php?username=usr&password=pass
#		Live:  http://vaders.tv/p2.xml.gz
#		Local: file:///C:\your\file\path.xml 

$global:channel_group_list = ""
# $global:channel_group_list = "'sports','united states','united kingdom','united states - regionals'"
#		Original groups found in Vader's Live & VOD M3U these could change
#		in time to time, please check your M3U in case of any error
#		===========================================
#		 IPTV Groups                     
#		'afghani'                   ,'arabic'
#		'bangla'                    ,'canada'
#		'filipino'                  ,'france'
#		'germany'                   ,'gujrati'
#		'india'                     ,'ireland'
#		'italy'                     ,'korea'
#		'latino'                    ,'live events'
#		'malayalam'                 ,'marathi'
#		'pakistan'                  ,'portugal'
#		'premium movies'            ,'punjabi'
#		'scandinavian'              ,'spain'
#		'sports'                    ,'tamil'
#		'telugu'                    ,'thai'
#		'Movies'                    ,'4K Movies'
#		'united kingdom'            ,'united states'
#		'united states - regionals','Live Events'
$global:base_dir = "$Home\Documents\telly"
$global:original = "$base_dir\original"
$global:DG = "$base_dir\sorted"
$global:HD = "$base_dir\HD"
$global:SD = "$base_dir\SD"
$global:m3u = "m3u-epg-editor-master"

$global:tellyURL = "https://github.com/tombowditch/telly/releases/download/v0.5/telly-windows-amd64.exe" # This could change 
$global:m3u_editor_url = "https://github.com/jjssoftware/m3u-epg-editor/archive/master.zip"              # this could change in time

# Note that the Python iunstall directory is hard-coded below to "C:\Python27"
# leave that alone.

########################################################################################################
################################ END USER-EDITABLE PARAMETERS ##########################################
########################################################################################################

########################################################################################################
################################ CONTINUE SCROLLING AT YOUR OWN RISK ###################################
########################################################################################################

Function TEST-LocalAdmin { 
    Return ([security.principal.windowsprincipal] [security.principal.windowsidentity]::GetCurrent()).isinrole([Security.Principal.WindowsBuiltInRole] "Administrator") 
} 
function directories {
	Write-Output "Creating Directories"

    if (!(test-path "$base_dir")) { mkdir "$base_dir"}
    
    Set-Location "$base_dir"

    if (!(test-path "$original")) { mkdir "$original" }

    if (!(test-path "$DG")) { mkdir "$DG" }

    if (!(test-path "$HD")) { mkdir "$HD" }

    if (!(test-path "$SD")) { mkdir "$SD" }

} 
Function download_telly {
    if (!(Test-Path "$base_dir\telly.exe")) {
        Write-Output "Downloading telly v0.5 into  $base_dir\telly.exe"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $tellyURL -OutFile "$base_dir\telly.exe" ;
    }
    
}
function download_m3u_epg_editor {
    
    if (!(Test-Path "$base_dir\$m3u")) {
        
        Write-Output "Downloading m3u-epg-editor into $base_dir\$m3u"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest $m3u_editor_url -OutFile "$base_dir\$m3u.zip" ;
        Expand-Archive "$base_dir\$m3u.zip" -DestinationPath "$base_dir" ;
        Remove-Item -Path "$base_dir\$m3u.zip" -Force;
                           
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
            $pythonMSI = "$base_dir\python-2.7.14.amd64.msi"
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
    $pythonMSI = "$base_dir\python-2.7.14.amd64.msi" 
    $targetDir = "C:\Python27"

    if (!(Test-Path "$targetDir")) {
        Write-Verbose "Installing $pythonMSI....."
        Write-host ""
        Write-host 
        "Please wait until the installation process finish...
        ----------------------------------------------------
        "
        Write-host ""
        msiexec.exe /i "$pythonMSI" /qnf /norestart /l "$base_dir\python_install_log.txt"  ADDLOCAL=ALL | out-null
        Remove-Item -Path "$pythonMSI" -Force
    }
} 
function install_python_pkg {
	C:\Python27\python.exe -m pip install --upgrade pip
	C:\Python27\python.exe -m pip install requests
	C:\Python27\python.exe -m pip install python-dateutil
    Write-Output ""    
    Write-Host "Moving on with the script."
} 

function m3u_processing {
    
    if ($m3u_url) { 
        Write-Host 'M3U Link predefined as: ' $m3u_url
    } 
    else 
    { 
		$m3u_url = Read-Host "
		Plese include your Vader's VOD ot Live TV M3U-URL or even local File 
		You can change this for FABI IPTV or any other Local File
		Keep in Mind the groups showed below will only apply for Vader's.
		If you are using another provider please check the m3u file

		VOD:   http://vaders.tv/get.php?username=XXX&password=XXX&type=m3u_plus&output=ts 
		Live:  http://api.vaders.tv/vget?username=XXX&password=XXX&format=ts
		Local: file:///C:\your\file\path.m3u
	
		Set your M3U"
    }

    if ($epg_url) { 
        Write-Host 'EPG Link predefined as: ' $epg_url
    } 
    else 
    { 
		# B Set your epg
		$epg_url = Read-Host "
	
		Please include your Vaders EPG
		VOD:   http://vaders.tv/xmltv.php?username=usr&password=pass
		Live:  http://vaders.tv/p2.xml.gz
		Local: file:///C:\your\file\path.xml 
   
		Set your EPG"
    }

    if ($channel_group_list) { 
        Write-Host 'Channel Groups predefined as: ' $channel_group_list
    } 
    else 
    { 
		Write-Output  "
		Original groups found in Vader's Live & VOD M3U these could change
		in time to time, please check your M3U in case of any error
		===========================================
		 IPTV Groups                     
		'afghani'                   ,'arabic'
		'bangla'                    ,'canada'
		'filipino'                  ,'france'
		'germany'                   ,'gujrati'
		'india'                     ,'ireland'
		'italy'                     ,'korea'
		'latino'                    ,'live events'
		'malayalam'                 ,'marathi'
		'pakistan'                  ,'portugal'
		'premium movies'            ,'punjabi'
		'scandinavian'              ,'spain'
		'sports'                    ,'tamil'
		'telugu'                    ,'thai'
		'Movies'                    ,'4K Movies'
		'united kingdom'            ,'united states'
		'united states - regionals','Live Events'
		============================================
		" 
		$channel_group_list = Read-Host "Please enter your TV Groups, TV Channels in this way: 'groups','channels' the input MUST BE LOWERCASE
		You can see the Vader's groups above for reference
	
		Set your Channels or Groups"
    }
	
    $G = "$DG\Sorted"
    
    Write-Output "Downloading and sorting the channels and groups"
    Write-Output "" 
    Write-Output ""   
    Write-Output ""

    cd "$base_dir\$m3u"
    C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$m3u_url" -e="$epg_url" -g "$channel_group_list" -c="$no_epg_channels" --outdirectory="$DG" --outfilename="$G";

    $Sorted_m3u = "$G.m3u8"
    $original_Local = "file:///$original_m3u" # alt you can use the original file downloaded for manual teak of the lines below
    $Sorted_m3u_Local = "file:///$Sorted_m3u" # By preference I choose the already sorted file
    $no_epg_channels = Get-Content "$DG\no_epg_channels.txt"
    $SC = "$DG\sorted.channels.txt" # Channels from A-Z
    $SCNG = "$DG\sorted.channels.nogroup.txt" # Channels from A-Z without Group	
    $filename_hd = "$HD\hd.channels.only.txt" # No SD Channels List
    $filename_sd = "$SD\sd.channels.only.txt" # No HD Channels List
    $IPTVSD = "$SD\SDTv.unique.txt" # SD Channels List without Duplicates
    $IPTVHD = "$HD\HDTv.unique.txt" # HD Channels List without Duplicates
    $file = $SC 

    (get-content $SC) -replace $channel_group_list, "" | out-file "$SCNG";
    (get-content $SCNG) -notmatch "hd" | out-file $filename_sd;

    # These lists of unique channels are different in the single vs multiple channel case
	# the multi-channel file has an extra comma at the end of it, which needs to be stripped
	$replaceCharacter = ''

    get-content $filename_sd | Sort-Object | get-unique > $IPTVSD;
    $contentSD = Get-Content $IPTVSD;
    $contentSD[-1] = $contentSD[-1] -replace '^(.*),$', "`$1$replaceCharacter";
    $contentSD | Set-Content $IPTVSD;
    (get-content $scng) -match "hd" | out-file $filename_hd;

    get-content $filename_hd | Sort-Object | get-unique > $IPTVHD;
    $contentHD = Get-Content $IPTVHD;
    $contentHD[-1] = $contentHD[-1] -replace '^(.*),$', "`$1$replaceCharacter";
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

        cd "$base_dir\$m3u"
        C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$Sorted_m3u_Local" -e="$epg_url" -g "$channel_group_list" -c="$no_epg_channels,$gcSD" --outdirectory="$DG" --outfilename="$I";

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

        cd "$base_dir\$m3u"
        C:\Python27\python.exe .\m3u-epg-editor.py --sortchannels --m3uurl="$Sorted_m3u_Local" -e="$epg_url" -g "$channel_group_list" -c="$no_epg_channels,$gcHD" --outdirectory="$DG" --outfilename="$K";
       
        $SDTv = "$SD\SDTv.m3u8"
        Remove-Item "$SD\original.*"
    }
    else {
        Write-Host 'Ok no SD Then...'
    }    
   
    Move-Item "$DG\original.*" -Destination $original -Force
}

function build_batch_files {

    Write-Output "Generating batch files..."

    $G = "$DG\Sorted"
    $Sorted_m3u = "$G.m3u8"
    $HDTv = "$HD\HDTv.m3u8"
    $SDTv = "$SD\SDTv.m3u8"
   
    if ((test-path $Sorted_m3u)) {
        Write-Output "Set-Location ""$DG""
        ""$base_dir\telly.exe"" -listen 127.0.0.1:9077 -playlist=""$($Sorted_m3u)"" -temp ""$DG"" -streams 5 -friendlyname ""Sorted_Channels"" -deviceid ""10000009"" -logrequests" | set-content $DG\telly_Sorted.ps1

        Write-Output "@ECHO OFF
        PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $DG\telly_Sorted.bat
     }

    if ((test-path $HDTv)) {
        Write-Output "Set-Location ""$HD""
        ""$base_dir\telly.exe"" -listen 127.0.0.1:8077 -playlist=""$($HDTv)"" -temp ""$HD"" -streams 5 -friendlyname ""HDTv"" -deviceid ""10000008"" -logrequests" | set-content $HD\telly_HD.ps1

        Write-Output "@ECHO OFF
        PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $HD\telly_HD.bat
     }

    if ((test-path $SDTv)) {
        Write-Output "Set-Location ""$SD""
        ""$base_dir\telly.exe"" -listen 127.0.0.1:7077 -playlist=""$($SDTv)"" -temp ""$SD"" -streams 5 -friendlyname ""SDTv"" -deviceid ""10000007"" -logrequests" | set-content $SD\telly_SD.ps1
        
		Write-Output "@ECHO OFF
        PowerShell.exe -NoProfile -Command ""& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dpn0.ps1""' -Verb RunAs}""" | set-content $SD\telly_SD.bat
     }
}
function run_telly {
    
    $message = '...Telly Scripts Time as Come...'

    if ((test-path "$DG\telly_Sorted.bat")) {
		$question = 'Would you like to Run Telly with the sorted channels?'
		$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
		$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
		$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
		$decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
		if ($decision -eq 0) {
			Write-Host 'confirmed'
			
			Start-Process -FilePath "$DG\telly_Sorted.bat"

		}
		else {
			Write-Host 'OK...'
		}
	}

    if ((test-path "$HD\telly_HD.bat")) {
		$message = '0_o'
		$question = 'Would you like to Run Telly with the HD channels?'
		$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
		$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
		$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No')) 
		$decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
		if ($decision -eq 0) {
			Write-Host 'confirmed'

			Start-Process -FilePath "$HD\telly_HD.bat"

		}
		else {
			Write-Host 'OK...'
		}
	}

    if ((test-path "$SD\telly_SD.bat")) {
		$message = '...0_0'
		$question = 'Would you like to Run Telly with the SD channels?'
		$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
		$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
		$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
		$decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
		if ($decision -eq 0) {
			Write-Host 'confirmed'

			Start-Process -FilePath "$SD\telly_SD.bat"

		}
		else {
			Write-Host '-_-'
		}    
	}
}

## VARS
TEST-LocalAdmin;
if (!(TEST-LocalAdmin)) {Write-Host " You Need to RUN AS ADMINISTRATOR first"; Return}
Write-Output "Automated Telly script v4"

directories;
download_telly;

download_m3u_epg_editor;

download_python27;
Install_Python27;
Write-Output " Checking Python dependencies...";
install_python_pkg;

Clear-Host
m3u_processing;
build_batch_files;
run_telly;
## End

#Input path for log file
$TranscriptPath = "C:\temp\FolderRedirectionToOneDriveKnownFolders.log"

Start-Transcript -Path "$TranscriptPath"

#Define Variables
#The LookFor variable is what you look for as the key value to determine if folder redirection is enabled, ex. internal.domain.com
$LookFor = "internal.domain.com"
#The ShareName is the exact path you are looking to replace, and is used in the "Shell Folders" registry section only.  For example if your users have a folder redirection path on the Documents folder
#of "\\internal.domain.com\users\username\documents" then this should be set to "\\internal.domain.com\Users".  
$ShareName = "\\internal.domain.com\users"

#Set "Shell Folders" back to normal, if folder missing it will recreate it as well.  Creates folder with same permissions but administrators group is owner instead of user, this didn't impact the user in testing.
#It will check for the presence of the key and check if it contains the $LookFor variable if so it puts it back to the default values.  It will also remove OneDrive registry if users if found to have redirection.
$userReg = Get-ChildItem -Path "Registry::HKEY_USERS"
foreach ($user in $userReg)
{
	If (Test-Path -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders")
	{
		If ($(Get-ItemProperty -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" | select-object -ExpandProperty "Personal" -ErrorAction SilentlyContinue) -ne $null)
		{
			$Personal = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "Personal" -ErrorAction SilentlyContinue
			If ($Personal -match "$LookFor")
			{
				$new = $Personal.replace("$ShareName", "C:\Users")
				Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" | Set-ItemProperty -Name "Personal" -Value $new
				Write-Host "Shell Folders - Personal value changed from $Personal to $new in the $($user.name) registry"
				#START - ONEDRIVE KEY REMOVAL
				#This is present here to remove OneDrive from the registry for the user, if it made it here then it is fine if this key gets deleted.
				#It is necessary to get the OneDrive Known Folders to work.
				Remove-Item -Path "Registry::$($user.name)\Software\Microsoft\OneDrive" -Force -Verbose -Recurse
				Write-Host "Users OneDrive Folder Removed in the $($user.name) registry."
				#END - ONEDRIVE KEY REMOVAL
			}
			$new = $null
			#Create a folder if missing in the user profile
			$TestPath = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "Personal" -ErrorAction SilentlyContinue
			If ($(Test-Path -Path $TestPath) -eq $false)
			{
				New-Item -ItemType directory -Path $TestPath
				Write-Host "Shell Folders - Personal folder created at $TestPath"
				#Create the folder but only difference is Administrator is Owner of Folder, all other permissions the same.
			}
			$TestPath = $null
		}
		
		If ($(Get-ItemProperty -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" | select-object -ExpandProperty "Favorites" -ErrorAction SilentlyContinue) -ne $null)
		{
			$Favorites = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "Favorites" -ErrorAction SilentlyContinue
			If ($Favorites -match "$LookFor")
			{
				$new = $Favorites.replace("$ShareName", "C:\Users")
				Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" | Set-ItemProperty -Name "Favorites" -Value $new
				Write-Host "Shell Folders - Favorites value changed from $Favorites to $new in the $($user.name) registry"
				#Create a folder if missing in the user profile
				$TestPath = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "Favorites" -ErrorAction SilentlyContinue
				If ($(Test-Path -Path $TestPath) -eq $false)
				{
					New-Item -ItemType directory -Path $TestPath
					Write-Host "Shell Folders - Favorites folder created at $TestPath"
					#Create the folder but only difference is Administrator is Owner of Folder, all other permissions the same.
				}
				$TestPath = $null
			}
			$new = $null
		}
		
		
		If ($(Get-ItemProperty -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" | select-object -ExpandProperty "My Pictures" -ErrorAction SilentlyContinue) -ne $null)
		{
			$MyPictures = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "My Pictures" -ErrorAction SilentlyContinue
			If ($MyPictures -match "$LookFor")
			{
				$new = $MyPictures.replace("$ShareName", "C:\Users")
				Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" | Set-ItemProperty -Name "My Pictures" -Value $new
				Write-Host "Shell Folders - My Pictures value changed from $MyPictures to $new in the $($user.name) registry"
				#Create a folder if missing in the user profile
				$TestPath = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "My Pictures" -ErrorAction SilentlyContinue
				If ($(Test-Path -Path $TestPath) -eq $false)
				{
					New-Item -ItemType directory -Path $TestPath
					Write-Host "Shell Folders - My Pictures folder created at $TestPath"
					#Create the folder but only difference is Administrator is Owner of Folder, all other permissions the same.
				}
				$TestPath = $null
			}
			$new = $null
		}
	}
}


#Set the "User Shell Folders" back to defaults
#It will check for the presence of the key and check if it contains $LookFor variable if so it puts it back to the default values.

$userReg = Get-ChildItem -Path "Registry::HKEY_USERS"
foreach ($user in $userReg)
{
	If (Test-Path -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders")
	{
		If ($(Get-ItemProperty -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | select-object -ExpandProperty "Personal" -ErrorAction SilentlyContinue) -ne $null)
		{
			$Personal = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "Personal" -ErrorAction SilentlyContinue
			If ($Personal -match "$LookFor")
			{
				$new = '%USERPROFILE%\Documents'
				Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | Set-ItemProperty -Name "Personal" -Value $new
				Write-Host "User Shell Folders - Personal value changed from $Personal to $new in the $($user.name) registry"
			}
			$new = $null
		}
		
		If ($(Get-ItemProperty -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | select-object -ExpandProperty "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -ErrorAction SilentlyContinue) -ne $null)
		{
			$PersonalGUID1 = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -ErrorAction SilentlyContinue
			If ($PersonalGUID1 -match "$LookFor")
			{
				$new = '%USERPROFILE%\Documents'
				Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | Set-ItemProperty -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Value $new
				Write-Host "User Shell Folders - Personal GUID1 {F42EE2D3-909F-4907-8871-4C22FC0BF756} value changed from $PersonalGUID1 to $new in the $($user.name) registry"
			}
			$new = $null
		}
		
				
		If ($(Get-ItemProperty -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | select-object -ExpandProperty "Favorites" -ErrorAction SilentlyContinue) -ne $null)
		{
			$Favorites = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "Favorites" -ErrorAction SilentlyContinue
			If ($Favorites -match "$LookFor")
			{
				$new = '%USERPROFILE%\Favorites'
				Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | Set-ItemProperty -Name "Favorites" -Value $new
				Write-Host "User Shell Folders - Favorites value changed from $Favorites to $new in the $($user.name) registry"
			}
			$new = $null
		}
		
		
		If ($(Get-ItemProperty -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | select-object -ExpandProperty "My Pictures" -ErrorAction SilentlyContinue) -ne $null)
		{
			$MyPictures = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "My Pictures" -ErrorAction SilentlyContinue
			If ($MyPictures -match "$LookFor")
			{
				$new = '%USERPROFILE%\Pictures'
				Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | Set-ItemProperty -Name "My Pictures" -Value $new
				Write-Host "User Shell Folders - My Pictures value changed from $MyPictures to $new in the $($user.name) registry"
			}
			$new = $null
		}
		
		If ($(Get-ItemProperty -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | select-object -ExpandProperty "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -ErrorAction SilentlyContinue) -ne $null)
		{
			$PicturesGUID1 = Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -ErrorAction SilentlyContinue | Get-ItemPropertyValue -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -ErrorAction SilentlyContinue
			If ($PicturesGUID1 -match "$LookFor")
			{
				$new = '%USERPROFILE%\Pictures'
				Get-Item -Path "Registry::$($user.name)\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" | Set-ItemProperty -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -Value $new
				Write-Host "User Shell Folders - My Pictures GUID1 {0DDD015D-B06C-45D5-8C4C-F59713854639} value changed from $PicturesGUID1 to $new in the $($user.name) registry"
			}
			$new = $null
		}
	}
}
Stop-Transcript

# **USE AT YOUR OWN RISK, TEST IN YOUR ENVIRONMENT PRIOR TO PUTTING IN PRODUCTION.**

# Folder-Redirection-to-OneDrive-Known-Folders

## Description
This will remove the Folder Redirection settings that are pushed to users by Group Policy, and replace with the default values 
	across all users accounts whether they are logged in or not.  You only need to run this script once on a computer as it affects
	all user accounts on it.  This particular script adjusts only the Documents, Favorites, and Pictures folders.  Other folders 
	could be added but you would need to modify the script.
## Steps taken to move from Folder Redirection to OneDrive Known Folders.
Script tested on Windows 10 22H2.

**Please Note:**  Below are the Folder redirection group policy settings I tested with prior unassigning from users.  
- Target Setting: Basic - Redirection everyone's folder to the same location.
- Target Folder Location:  Create a folder for each user under the root path
- Settings: Checked - Move the contents of Documents to the new location.
- Policy Removal:  Set to "Leave the folder in the new location when policy is removed"
  
**Please Note:**  Below are the OneDrive settings push by Intune I tested with that were in place well before hand.	 Key to this is the "Silently sign in...." setting so it automatically logs in again at logon.
- "Allow syncing OneDrive accounts for only specific organizations" set to "Enabled"
- "Prevent users from syncing personal OneDrive accounts (User)" set to "Enabled"
- "Set the sync app update ring" set to "Enabled"
- "Update ring: (Device)" set to "Deferred"
- "Silently sign in users to the OneDrive sync app with their Windows credentials" set to "Enabled"
- "Use OneDrive Files On-Demand" set to "Enabled"

### Steps

1. Apply the "Silently move Windows known folders to OneDrive", the one were you pick Desktop/Pictures/Documents in Intune to the device.  Wait for the setting to apply to the machine.

2. Unassign the Folder Redirection group policy from the users.  Keep in mind that even though Folder Redirection policy is no longer applying it has tattooed itself to the user accounts that have logged in.  In testing I found that while folder redirection settings were still present on the user account, the Intune OneDrive known folders policy doesn't have any effect.

3. Run the script as admin or system against the computer.  It will put all users on the machine back to defaults, and clear the Onedrive registry for each user.

4. If a user is logged in they will not notice a difference, the original redirections will continue to work until they logoff or restart the computer.

5. Once logged in within a minute you will notice the OneDrive Known Folders syncing is working.  Other user accounts on the computer are also converted, and when they logon everything works with OneDrive just the same.

## Script Instructions
Make sure to populate the variables at the beginning of the script.

**$LookFor** -  The LookFor variable is what you look for as the key value to determine if folder redirection is enabled, ex. internal.domain.com

**$ShareName** - The ShareName is the exact path you are looking to replace, and is used in the "Shell Folders" registry section only.  For example if your users have a folder redirection path on the Documents folder of "\\internal.domain.com\users\username\documents" 
					then this should be set to "\\internal.domain.com\Users".

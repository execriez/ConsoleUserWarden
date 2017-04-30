# ConsoleUserWarden
![Logo](images/ConsoleUserWarden.jpg "Logo")

Run custom code when the console user changes on MacOS.

##Description:

ConsoleUserWarden catches MacOS console user changes, to allow you to run custom code when a user logs in, or switches users.

This custom code can be used instead of Login scripts, and possibly instead of Logout scripts; depending on your situation.

ConsoleUserWarden consists of the following components:

	ConsoleUserWarden                - The main binary that catches the console user change events
	ConsoleUserWarden-NewConsoleUser - Called when the active console user changes
	ConsoleUserWarden-NoConsoleUser  - Called when there is no active console user  

The example ConsoleUserWarden-NewConsoleUser and ConsoleUserWarden-NoConsoleUser are bash scripts.

The example scripts simply use the "say" command to let you know when the console user changes. You should customise these scripts to your own needs.


##How to install:

Download the ConsoleUserHookWarden zip archive from <https://github.com/execriez/ConsoleUserHookWarden>, then unzip the archive on a Mac workstation.

Ideally, to install - you should double-click the following installer package which can be found in the "SupportFiles" directory.

	  ConsoleUserHookWarden.pkg
	
If the installer package isn't available, you can run the command-line installer which can be found in the "util" directory:

	  sudo Install

The installer will install the following files and directories:

	  /Library/LaunchDaemons/com.github.execriez.ConsoleUserHookWarden.plist
	  /usr/ConsoleUserHookWarden/

There's no need to reboot.

After installation, your computer will speak whenever the ConsoleUser changes.
 
You can alter the example shell scripts to alter this behavior, these can be found in the following location:

	  /usr/ConsoleUserHookWarden/bin/ConsoleUserWarden-NewConsoleUser
	  /usr/ConsoleUserHookWarden/bin/ConsoleUserWarden-NoConsoleUser

If the installer fails you should check the logs.

##Logs:

Logs are written to the following file:

  /Library/Logs/com.github.execriez.ConsoleUserHookWarden.log
  
The following is an example of a typical log file:

	30 Apr 2017 09:24:18 PreInstall[36506]: Information: Performing pre-install checks
	30 Apr 2017 09:24:18 PreInstall[36506]: Information: OK to install.
	30 Apr 2017 09:24:18 PostInstall[36551]: Information: Performing post-install checks
	30 Apr 2017 09:24:18 PostInstall[36551]: Notice: Loading LaunchDaemon file com.github.execriez.consoleuserwarden.plist
	30 Apr 2017 09:24:18 PostInstall[36551]: Information: ConsoleUserWarden installed OK.
	30 Apr 2017 09:24:53 ConsoleUserWarden-NoConsoleUser[2023]: Notice: No Console User - 'none' (previously 'init')
	30 Apr 2017 09:25:08 ConsoleUserWarden-NewConsoleUser[5968]: Notice: New Console User - 'local' (previously 'none')
	30 Apr 2017 09:25:08 ConsoleUserWarden-NewConsoleUser[5968]: Information: User local logged in
	30 Apr 2017 09:25:58 ConsoleUserWarden-NewConsoleUser[11241]: Notice: New Console User - 'loginwindow' (previously 'local')
	30 Apr 2017 09:26:04 ConsoleUserWarden-NewConsoleUser[11773]: Notice: New Console User - 'offline' (previously 'loginwindow')
	30 Apr 2017 09:26:04 ConsoleUserWarden-NewConsoleUser[11773]: Information: User offline logged in
	30 Apr 2017 09:26:30 ConsoleUserWarden-NewConsoleUser[16781]: Notice: New Console User - 'local' (previously 'offline')
	30 Apr 2017 09:26:30 ConsoleUserWarden-NewConsoleUser[16781]: Information: Fast User Switch local
	30 Apr 2017 09:26:42 ConsoleUserWarden-NewConsoleUser[16901]: Notice: New Console User - 'offline' (previously 'local')
	30 Apr 2017 09:26:42 ConsoleUserWarden-NewConsoleUser[16901]: Information: Fast User Switch offline
	30 Apr 2017 09:26:54 ConsoleUserWarden-NewConsoleUser[18111]: Notice: New Console User - 'loginwindow' (previously 'offline')
	30 Apr 2017 09:26:54 ConsoleUserWarden-NewConsoleUser[18111]: Information: User offline logged out
	30 Apr 2017 09:27:05 ConsoleUserWarden-NewConsoleUser[18673]: Notice: New Console User - 'local' (previously 'loginwindow')
	30 Apr 2017 09:27:05 ConsoleUserWarden-NewConsoleUser[18673]: Information: User local logged in
	30 Apr 2017 09:27:16 ConsoleUserWarden-NoConsoleUser[20672]: Notice: No Console User - 'none' (previously 'local')
	30 Apr 2017 09:27:16 ConsoleUserWarden-NoConsoleUser[20672]: Information: User local logged out
	30 Apr 2017 09:27:28 ConsoleUserWarden-NewConsoleUser[21406]: Notice: New Console User - 'local' (previously 'none')
	30 Apr 2017 09:27:28 ConsoleUserWarden-NewConsoleUser[21406]: Information: User local logged in
	30 Apr 2017 09:28:11 Uninstall[28251]: Notice: Uninstalling ConsoleUserWarden.
	30 Apr 2017 09:28:11 Uninstall[28251]: Notice: Removing LaunchDaemon service com.github.execriez.consoleuserwarden
	30 Apr 2017 09:28:11 Uninstall[28251]: Notice: Deleting LaunchDaemon file com.github.execriez.consoleuserwarden.plist
	30 Apr 2017 09:28:11 Uninstall[28251]: Notice: Deleting project dir /usr/local/ConsoleUserWarden
 

##How to uninstall:

To uninstall you should double-click the following uninstaller package which can be found in the "SupportFiles" directory.

	  ConsoleUserHookWarden-Uninstaller.pkg
	
If the uninstaller package isn't available, you can uninstall from a shell by typing the following:

	  sudo /usr/local/ConsoleUserHookWarden/util/Uninstall

The uninstaller will uninstall the following files and directories:

	  /Library/LaunchDaemons/com.github.execriez.ConsoleUserHookWarden.CheckHooks.plist
	  /usr/ConsoleUserHookWarden/

There's no need to reboot.

After the uninstall everything goes back to normal, and console user changes will not be tracked.

##History:

1.0.2 - 29 APR 2017

* First public release.

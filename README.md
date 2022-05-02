# ConsoleUserWarden
![Logo](images/ConsoleUserWarden.jpg "Logo")

Run custom code when the console user changes on MacOS.

## Description:

ConsoleUserWarden catches MacOS console user changes, to allow you to run custom code when a user logs in, logs out, or switches users.

Depending on your situation, this custom code can be used instead of com.apple.loginwindow LoginHook and LogoutHook scripts.

ConsoleUserWarden consists of the following components:

	ConsoleUserWarden                - The main binary that catches the console user change events
	ConsoleUserWarden-UserLoggedIn   - Called after a user logs in and becomes the active console
	ConsoleUserWarden-UserLoggedOut  - Called after the active console user logs out
	ConsoleUserWarden-UserSwitch     - Called after the active console user switches to another logged in user
 
ConsoleUserWarden-UserLoggedIn, ConsoleUserWarden-UserLoggedOut and ConsoleUserWarden-UserSwitch are bash scripts.

The example scripts simply write to a log file in /tmp. You should customise the scripts to your own needs.


## How to install:

Open the Terminal app, and download the latest [ConsoleUserWarden.pkg](https://raw.githubusercontent.com/execriez/ConsoleUserWarden/master/SupportFiles/ConsoleUserWarden.pkg) installer to your desktop by typing the following command. 

	curl -k --silent --retry 3 --retry-max-time 6 --fail https://raw.githubusercontent.com/execriez/ConsoleUserWarden/master/SupportFiles/ConsoleUserWarden.pkg --output ~/Desktop/ConsoleUserWarden.pkg

To install, double-click the downloaded package.

The installer will install the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.consoleuserwarden.plist
	/usr/ConsoleUserWarden/
	/usr/ConsoleUserWarden/bin/
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedIn
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedOut
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserSwitch

There's no need to reboot.

After installation, your computer will write to the log file /tmp/ConsoleUserWarden.log whenever the ConsoleUser changes. 

If the installer fails you should check the installation logs.


## Modifying the example scripts:

After installation, three simple example scripts can be found in the following location:

	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedIn
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedOut
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserSwitch

These scripts simply write to the log file /tmp/ConsoleUserWarden.log whenever the ConsoleUser changes. Modify the scripts to your own needs.

**ConsoleUserWarden-UserLoggedIn**

	#!/bin/bash
	#
	# Called by ConsoleUserWarden as root as follows:    
	#   ConsoleUserWarden-UserLoggedIn "ActiveConsoleUserName"
	
	# Get active console user
	sv_ActiveConsoleUserName="${1}"
	
	# Do Something
	echo "$(date '+%d %b %Y %H:%M:%S %Z') UserLoggedIn - User '${sv_ActiveConsoleUserName}' logged in" >> /tmp/ConsoleUserWarden.log

**ConsoleUserWarden-UserLoggedOut**

	#!/bin/bash
	#
	# Called by ConsoleUserWarden as root as follows:    
	#   ConsoleUserWarden-UserLoggedOut "PreviousConsoleUserName"
	
	# Get active console user
	sv_PreviousConsoleUserName="${1}"
	
	# Do Something
	echo "$(date '+%d %b %Y %H:%M:%S %Z') UserLoggedOut - User '${sv_PreviousConsoleUserName}' logged out" >> /tmp/ConsoleUserWarden.log

**ConsoleUserWarden-UserSwitch**

	#!/bin/bash
	#
	# Called by ConsoleUserWarden as root as follows:    
	#   ConsoleUserWarden-UserLoggedIn "ActiveConsoleUserName" "PreviousConsoleUserName"
	
	# Get active console user
	sv_ActiveConsoleUserName="${1}"
	
	# Get previous console user
	sv_PreviousConsoleUserName="${2}"
	
	# Do Something
	echo "$(date '+%d %b %Y %H:%M:%S %Z') UserSwitch - Switched to User '${sv_ActiveConsoleUserName}' from '${sv_PreviousConsoleUserName}'" >> /tmp/ConsoleUserWarden.log


## How to uninstall:

Open the Terminal app, and download the latest [ConsoleUserWarden-Uninstaller.pkg](https://raw.githubusercontent.com/execriez/ConsoleUserWarden/master/SupportFiles/ConsoleUserWarden-Uninstaller.pkg) uninstaller to your desktop by typing the following command. 

	curl -k --silent --retry 3 --retry-max-time 6 --fail https://raw.githubusercontent.com/execriez/ConsoleUserWarden/master/SupportFiles/ConsoleUserWarden-Uninstaller.pkg --output ~/Desktop/ConsoleUserWarden-Uninstaller.pkg

To uninstall, double-click the downloaded package.

The uninstaller will remove the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.consoleuserwarden.plist
	/usr/ConsoleUserWarden/

After the uninstall everything goes back to normal, and console user changes will not be tracked.

There's no need to reboot.

## Logs:

The example scripts write to the following log file:

	/tmp/ConsoleUserWarden.log

The installer writes to the following log file:

	/Library/Logs/com.github.execriez.consoleuserwarden.log
  
You should check this log if there are issues when installing.

## History:

1.0.7 - 02 MAY 2022

* Compiled as a fat binary to support both Apple Silicon and Intel Chipsets. This version requires MacOS 10.9 or later.

* The example scripts now just write to a log file. Previously they made use of the "say" command.

* The package creation and installation code has been aligned with other "Warden" projects.

* Log out events could be missed previously due to some logic errors. Those errors have been fixed in this version.

1.0.6 - 03 OCT 2018

* Console user change events no longer wait for earlier events to finish before running. Events can now be running simultaneously.

* The example scripts have been simplified, and the readme has been improved.

1.0.5 - 01 JUN 2017

* Recompiled to be backward compatible with MacOS 10.7 and later

1.0.4 - 06 MAY 2017

* Fixed a memory leak.

1.0.3 - 30 APR 2017

* The ConsoleUserWarden binary now distinguishes login, logout and user switch events; in order to call an appropriate bash script.

1.0.2 - 29 APR 2017

* First public release.

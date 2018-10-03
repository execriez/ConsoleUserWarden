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
	ConsoleUserWarden-UserSwitch     - Called after the active console user switches to a logged in user
 
ConsoleUserWarden-UserLoggedIn, ConsoleUserWarden-UserLoggedOut and ConsoleUserWarden-UserSwitch are bash scripts.

The example scripts simply use the "say" command to let you know when the console user logs in, logs out or swiches. You should customise the scripts to your own needs.


## How to install:

Download the ConsoleUserWarden installation package here [ConsoleUserWarden.pkg](https://raw.githubusercontent.com/execriez/ConsoleUserWarden/master/SupportFiles/ConsoleUserWarden.pkg)

The installer will install the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.consoleuserwarden.plist
	/usr/ConsoleUserWarden/
	/usr/ConsoleUserWarden/bin/
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedIn
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedOut
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserSwitch

There's no need to reboot.

After installation, your computer will speak whenever the ConsoleUser changes. 

If the installer fails you should check the installation logs.

## Modifying the example scripts:

After installation, three simple example scripts can be found in the following location:

	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedIn
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedOut
	/usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserSwitch

These simple scripts use the "say" command to speak whenever the ConsoleUser changes. Modify the scripts to alter this default behaviour.

**ConsoleUserWarden-UserLoggedIn**

	#!/bin/bash
	#
	# Called by ConsoleUserWarden as root as follows:    
	#   ConsoleUserWarden-UserLoggedIn "ActiveConsoleUser"
	# i.e.
	#   ConsoleUserWarden-UserLoggedIn "localuser"

	# Get active console user
	sv_ActiveConsoleUser="${1}"

	# Do something
	say "User ${sv_ActiveConsoleUser} logged in"

**ConsoleUserWarden-UserLoggedOut**

	#!/bin/bash
	#
	# Called by ConsoleUserWarden as root as follows:    
	#   ConsoleUserWarden-UserLoggedIn "PreviousConsoleUser"
	# i.e.
	#   ConsoleUserWarden-UserLoggedIn "localuser"

	# Get active console user
	sv_PreviousConsoleUser="${1}"

	# Do something
	say "User ${sv_PreviousConsoleUser} logged out"

**ConsoleUserWarden-UserSwitch**

	#!/bin/bash
	#
	# Called by ConsoleUserWarden as root as follows:    
	#   ConsoleUserWarden-UserLoggedIn "ActiveConsoleUser" "PreviousConsoleUser"
	# i.e.
	#   ConsoleUserWarden-UserLoggedIn "newuser" "olduser"

	# Get active console user
	sv_ActiveConsoleUser="${1}"

	# Get previous console user
	sv_PreviousConsoleUser="${2}"

	# Do something
	say "User Switch to ${sv_ActiveConsoleUser}"


## How to uninstall:

Download the ConsoleUserWarden uninstaller package here [ConsoleUserWarden-Uninstaller.pkg](https://raw.githubusercontent.com/execriez/ConsoleUserWarden/master/SupportFiles/ConsoleUserWarden-Uninstaller.pkg)

The uninstaller will remove the following files and directories:

	/Library/LaunchDaemons/com.github.execriez.consoleuserwarden.plist
	/usr/ConsoleUserWarden/

After the uninstall everything goes back to normal, and console user changes will not be tracked.

There's no need to reboot.

## Logs:

The ConsoleUserWarden binary writes to the following log file:

	/var/log/systemlog
  
The following is an example of a typical system log file entry:

	Oct  3 20:44:03 mymac-01 ConsoleUserWarden[5853]: User logged in: 'offline'
	Oct  3 20:44:47 mymac-01 ConsoleUserWarden[5853]: User switch: to 'local' from 'offline'
	Oct  3 20:45:01 mymac-01 ConsoleUserWarden[5853]: User switch: to 'offline' from 'local'

The installer writes to the following log file:

	/Library/Logs/com.github.execriez.consoleuserwarden.log
  
You should check this log if there are issues when installing.

## History:

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

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
 
The example ConsoleUserWarden-UserLoggedIn, ConsoleUserWarden-UserLoggedOut and ConsoleUserWarden-UserSwitch are bash scripts.

The example scripts simply use the "say" command to let you know when the console user logs in, logs out or swiches. You should customise these scripts to your own needs.


## How to install:

Download the ConsoleUserWarden zip archive from <https://github.com/execriez/ConsoleUserWarden>, then unzip the archive on a Mac workstation.

Ideally, to install - you should double-click the following installer package which can be found in the "SupportFiles" directory.

	  ConsoleUserWarden.pkg
	
If the installer package isn't available, you can run the command-line installer which can be found in the "util" directory:

	  sudo Install

The installer will install the following files and directories:

	  /Library/LaunchDaemons/com.github.execriez.ConsoleUserWarden.plist
	  /usr/ConsoleUserWarden/

There's no need to reboot.

After installation, your computer will speak whenever the ConsoleUser changes.
 
You can alter the example shell scripts to alter this behavior, these can be found in the following location:

	  /usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedIn
	  /usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserLoggedOut
	  /usr/ConsoleUserWarden/bin/ConsoleUserWarden-UserSwitch

If the installer fails you should check the logs.

## Logs:

The ConsoleUser bash scripts write to the following log file:

	/Library/Logs/com.github.execriez.ConsoleUserWarden.log
  
The following is an example of a typical ConsoleUserWarden log file:

	03 May 2017 12:40:58 PreInstall[37153]: Information: Performing pre-install checks
	03 May 2017 12:40:58 PreInstall[37153]: Information: OK to install.
	03 May 2017 12:40:59 PostInstall[37196]: Information: Performing post-install checks
	03 May 2017 12:40:59 PostInstall[37196]: Notice: Loading LaunchDaemon file com.github.execriez.consoleuserwarden.plist
	03 May 2017 12:40:59 PostInstall[37196]: Information: ConsoleUserWarden installed OK.
	03 May 2017 12:42:07 ConsoleUserWarden-UserLoggedIn[5497]: Notice: User logged in - 'local'
	03 May 2017 12:44:05 ConsoleUserWarden-UserLoggedIn[12115]: Notice: User logged in - 'offline'
	03 May 2017 12:45:04 ConsoleUserWarden-UserSwitch[17191]: Notice: User Swich to 'local' (previously 'offline')
	03 May 2017 12:45:13 ConsoleUserWarden-UserSwitch[17239]: Notice: User Swich to 'offline' (previously 'local')
	03 May 2017 12:45:24 ConsoleUserWarden-UserLoggedOut[18987]: Notice: User logged out - 'offline'
	03 May 2017 12:45:37 ConsoleUserWarden-UserSwitch[20638]: Notice: User Swich to 'local' (previously 'loginwindow')
	03 May 2017 12:45:50 ConsoleUserWarden-UserLoggedOut[22245]: Notice: User logged out - 'local'
	03 May 2017 12:46:05 ConsoleUserWarden-UserLoggedIn[22836]: Notice: User logged in - 'local'
	03 May 2017 12:47:32 Uninstall[29678]: Notice: Uninstalling ConsoleUserWarden.
	03 May 2017 12:47:32 Uninstall[29678]: Notice: Removing LaunchDaemon service com.github.execriez.consoleuserwarden
	03 May 2017 12:47:32 Uninstall[29678]: Notice: Deleting LaunchDaemon file com.github.execriez.consoleuserwarden.plist
	03 May 2017 12:47:32 Uninstall[29678]: Notice: Deleting project dir /usr/local/ConsoleUserWarden
  
The ConsoleUser binary writes to the following log file:

	/var/log/systemlog
  
The following is an example of a typical system log file:

	May  3 12:41:36 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'none', old user 'init' new list '/root/', old list '/'
	May  3 12:42:07 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'local', old user 'none' new list '/local/', old list '/root/'
	May  3 12:42:11 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: User logged in: 'local'
	May  3 12:43:59 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'loginwindow', old user 'local' new list '/root/local/', old list '/local/'
	May  3 12:44:05 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'offline', old user 'loginwindow' new list '/offline/local/', old list '/root/local/'
	May  3 12:44:07 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: User logged in: 'offline'
	May  3 12:45:03 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'local', old user 'offline' new list '/offline/local/', old list '/offline/local/'
	May  3 12:45:06 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: User switch: to 'local' from 'offline'
	May  3 12:45:13 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'offline', old user 'local' new list '/offline/local/', old list '/offline/local/'
	May  3 12:45:15 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: User switch: to 'offline' from 'local'
	May  3 12:45:23 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'loginwindow', old user 'offline' new list '/root/local/', old list '/offline/local/'
	May  3 12:45:26 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: User logged out: 'offline'
	May  3 12:45:36 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'local', old user 'loginwindow' new list '/local/', old list '/root/local/'
	May  3 12:45:38 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: User switch: to 'local' from 'loginwindow'
	May  3 12:45:50 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'none', old user 'local' new list '/', old list '/local/'
	May  3 12:45:52 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: User logged out: 'local'
	May  3 12:46:05 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: New Console User: new user 'local', old user 'none' new list '/local/', old list '/root/'
	May  3 12:46:06 afielk-m0sy1i4g.lits.blackpool.ac.uk ConsoleUserWarden[55]: User logged in: 'local'

## How to uninstall:

To uninstall you should double-click the following uninstaller package which can be found in the "SupportFiles" directory.

	  ConsoleUserWarden-Uninstaller.pkg
	
If the uninstaller package isn't available, you can uninstall from a shell by typing the following:

	  sudo /usr/local/ConsoleUserWarden/util/Uninstall

The uninstaller will uninstall the following files and directories:

	  /Library/LaunchDaemons/com.github.execriez.ConsoleUserWarden.plist
	  /usr/ConsoleUserWarden/

There's no need to reboot.

After the uninstall everything goes back to normal, and console user changes will not be tracked.

## History:

1.0.5 - 01 JUN 2017

* Recompiled to be backward compatible with MacOS 10.7 and later

1.0.4 - 06 MAY 2017

* Fixed a memory leak.

1.0.3 - 30 APR 2017

* The ConsoleUserWarden binary now distinguishes login, logout and user switch events; in order to call an appropriate bash script.

1.0.2 - 29 APR 2017

* First public release.


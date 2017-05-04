#!/bin/bash
#
# Short:    Common routines (shell)
# Author:   Mark J Swift
# Version:  1.0.3
# Modified: 30-Apr-2017
#
# Should be included into scripts as follows:
#   . /usr/local/LabWarden/inc/Common.sh
#
  
# Only run the code if it hasn't already been run
if test -z "${GLB_sv_ProjectSignature}"
then
  
  # Sets the following globals:
  #
  #  GLB_sv_ProjectSignature                - Project signature (com.github.execriez.LabWarden)
  #  GLB_sv_ProjectMajorVersion             - Project major version (i.e. 2)
  #
  #  GLB_sv_BinDirPath                      - Path to binaries such as rsync or CocoaDialog
  #  GLB_sv_ProjectConfigDirPath            - Path to main LabWarden settings files
  #
  #  GLB_iv_LogLevelTrap                    - The default logging level
  #  GLB_bv_LogIsActiveStatus               - Whether the log is currently active (true/false)
  #
  #  GLB_iv_ThisScriptStartEpoch            - When the script started running
  #  GLB_sv_ThisScriptFilePath              - Full source path of running script
  #  GLB_sv_ThisScriptDirPath               - Directory location of running script
  #  GLB_sv_ThisScriptFileName              - filename of running script
  #  GLB_sv_ThisScriptName                  - Filename without extension
  #  GLB_iv_ThisScriptPID                   - Process ID of running script
  #
  #  GLB_sv_ThisUserLogDirPath              - Directory where the user log is stored
  #
  #  GLB_sv_ThisUserName                    - The name of the user that is running this script
  #  GLB_iv_ThisUserID                      - The user ID of the user that is running this script
  #  GLB_bv_ThisUserIsAdmin                 - Whether the user running the script is an admin (true/false)
  #
  #
  # Defines the following LabWarden functions:
  #
  #  GLB_nf_logmessage <loglevel> <messagetxt>                        - Output message text to the log file
  #  GLB_if_GetPlistArraySize <plistfile> <property>                  - Get an array property size from a plist file
  #
  #  Key:
  #    GLB_ - LabWarden global variable
  #
  #    bv_ - string variable with the values "true" or "false"
  #    iv_ - integer variable
  #    sv_ - string variable
  #
  #    nf_ - null function    (doesn't return a value)
  #    bf_ - boolean function (returns string values "true" or "false"
  #    if_ - integer function (returns an integer value)
  #    sf_ - string function  (returns a string value)
  
  # ---
  
  # All code is run from a subdirectory within the main project directory
  GLB_sv_ProjectDirPath="$(dirname $(dirname ${0}))"

  # Load the contants, only if they are not already loaded
  if test -z "${GLB_sv_ProjectName}"
  then
    . "${GLB_sv_ProjectDirPath}"/inc/Constants.sh
  fi
  
  # -- Begin Function Definition --
  
  # Convert log level integer into log level text
  GLB_sf_LogLevel()   # loglevel
  {  
    local iv_LogLevel
    local sv_LogLevel
    
    iv_LogLevel=${1}
    
    case ${iv_LogLevel} in
    0)
      sv_LogLevel="Emergency"
      ;;
      
    1)
      sv_LogLevel="Alert"
      ;;
      
    2)
      sv_LogLevel="Critical"
      ;;
      
    3)
      sv_LogLevel="Error"
      ;;
      
    4)
      sv_LogLevel="Warning"
      ;;
      
    5)
      sv_LogLevel="Notice"
      ;;
      
    6)
      sv_LogLevel="Information"
      ;;
      
    7)
      sv_LogLevel="Debug"
      ;;
      
    *)
      sv_LogLevel="Unknown"
      ;;
      
    esac
    
    echo ${sv_LogLevel}
  }
  
  # Save a message to the log file
  GLB_nf_logmessage()   # loglevel messagetxt
  {  
    local iv_HalfLen
    local iv_LogLevel
    local sv_Message
    local sv_LogLevel
    
    iv_LogLevel=${1}
    sv_Message="${2}"
        
    if [ ${iv_LogLevel} -le ${GLB_iv_LogLevelTrap} ]
    then
      sv_LogLevel="$(GLB_sf_LogLevel ${iv_LogLevel})"
  
      if [ "${GLB_bv_LogIsActiveStatus}" = "true" ]
      then
        # Check if we need to start a new log
        if test -e "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.log"
        then
          if [ $(stat -f "%z" "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.log") -gt ${GLB_iv_MaxLogSizeBytes} ]
          then
            mv -f "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.log" "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.previous.log"
          fi
        fi
  
        echo "$(date '+%d %b %Y %H:%M:%S') ${GLB_sv_ThisScriptFileName}[${GLB_iv_ThisScriptPID}]: ${sv_LogLevel}: ${sv_Message}"  >> "${GLB_sv_ThisUserLogDirPath}/${GLB_sv_ProjectSignature}.log"
        echo >&2 "$(date '+%d %b %Y %H:%M:%S') ${GLB_sv_ThisScriptFileName}[${GLB_iv_ThisScriptPID}]: ${sv_LogLevel}: ${sv_Message}"
      fi
    fi
  }
  
  GLB_if_GetPlistArraySize()   # plistfile property - given an array property name, returns the size of the array 
  {
    local sv_PlistFilePath
    local sv_PropertyName

    sv_PlistFilePath="${1}"
    sv_PropertyName="${2}"

    /usr/libexec/PlistBuddy 2>/dev/null -c "Print ':${sv_PropertyName}'" "${sv_PlistFilePath}" | grep -E "^ " | grep -E "$(/usr/libexec/PlistBuddy 2>/dev/null -c "Print ':${sv_PropertyName}'" "${sv_PlistFilePath}" | grep -E "^ " | head -n1 | sed "s|\(^[ ]*\)\([^ ]*.*\)|\^\1\\[\^ }\]|")" | wc -l | sed "s|^[ ]*||"
  }
 
  # -- End Function Definition --
  
  # Take a note when this script started running
  GLB_iv_ThisScriptStartEpoch=$(date -u "+%s")
  
  # -- Set Defaults
  
  # Set whether the log is on by default
  GLB_bv_LogIsActiveStatus=${GLB_bv_LogIsActiveStatusDefault}
  
  # Set the maximum log size
  GLB_iv_MaxLogSizeBytes=${GLB_iv_MaxLogSizeBytesDefault}
  
  # Set the logging level
  GLB_iv_LogLevelTrap=${GLB_iv_LogLevelTrapDefault}
  
  # Set the user notify dialog level
  GLB_iv_NotifyLevelTrap=${GLB_iv_NotifyLevelTrapDefault}
  
  # -- Get some info about this project
  
  GLB_sv_ProjectSignature="$(echo ${GLB_sv_ProjectDeveloper}.${GLB_sv_ProjectName} | tr [A-Z] [a-z])"
  GLB_sv_ProjectMajorVersion="$(echo "${GLB_sv_ProjectVersion}" | cut -d"." -f1)"
  
  # Decide where the config/pref files go (if there are any)
  GLB_sv_ProjectConfigDirPath="/Library/Preferences/SystemConfiguration/${GLB_sv_ProjectSignature}/V${GLB_sv_ProjectMajorVersion}"
  
  # Path to useful binaries
  GLB_sv_BinDirPath="/usr/local/${GLB_sv_ProjectName}/bin"
  
  # -- Get some info about this script
  
  # Full source of this script
  GLB_sv_ThisScriptFilePath="${0}"
  
  # Get dir of this script
  GLB_sv_ThisScriptDirPath="$(dirname "${GLB_sv_ThisScriptFilePath}")"
  
  # Get filename of this script
  GLB_sv_ThisScriptFileName="$(basename "${GLB_sv_ThisScriptFilePath}")"
  
  # Filename without extension
  GLB_sv_ThisScriptName="$(echo ${GLB_sv_ThisScriptFileName} | sed 's|\.[^.]*$||')"
  
  # Get Process ID of this script
  GLB_iv_ThisScriptPID=$$
  
  # -- Get some info about the running user
  
  # Get user name
  GLB_sv_ThisUserName="$(whoami)"
  
  # Get user ID
  GLB_iv_ThisUserID="$(id -u ${GLB_sv_ThisUserName})"
  
  # Check if the user running this script is an admin (returns "true" or "false")
  if [ "$(dseditgroup -o checkmember -m "${GLB_sv_ThisUserName}" -n . admin | cut -d" " -f1)" = "yes" ]
  then
    GLB_bv_ThisUserIsAdmin="true"
  else
    GLB_bv_ThisUserIsAdmin="false"
  fi
    
  # Decide where the log files go
  if [ "${GLB_sv_ThisUserName}" = "root" ]
  then
    GLB_sv_ThisUserLogDirPath="/Library/Logs"
  else
    GLB_sv_ThisUserLogDirPath=~/Library/Logs
  fi

fi

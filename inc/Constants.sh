#!/bin/bash
#
# Short:    Constants (shell)
# Author:   Mark J Swift
# Version:  1.0.4
# Modified: 06-May-2017
#
# Should be included into scripts as follows:
#   . /usr/local/ConsoleUserWarden/inc/Constants.sh
#

# Only run the code if it hasn't already been run
if test -z "${GLB_sv_ProjectName}"
then

  # Sets the following ConsoleUserWarden globals:
  #
  #  GLB_sv_ProjectName                     - Project name (ConsoleUserWarden)
  #  GLB_sv_ProjectInitials                 - Project initials (CUW)
  #  GLB_sv_ProjectDeveloper                - Project developer (com.github.execriez)
  #  GLB_sv_ProjectVersion                  - Project version (i.e. 1.0.3)
  #
  #  GLB_iv_MaxLogSizeBytes                 - Maximum length of ConsoleUserWarden log(s)
  #  GLB_bv_LogIsActiveStatusDefault              - Whether we should log by default (true/false) 
  #
  #  GLB_iv_MsgLevelEmerg                   - (0) Emergency, system is unusable
  #  GLB_iv_MsgLevelAlert                   - (1) Alert, should be corrected immediately
  #  GLB_iv_MsgLevelCrit                    - (2) Critical, critical conditions (some kind of failure in the systems primary function)
  #  GLB_iv_MsgLevelErr                     - (3) Error, error conditions
  #  GLB_iv_MsgLevelWarn                    - (4) Warning, may indicate that an error will occur if no action is taken
  #  GLB_iv_MsgLevel                        - (5) Notice, events that are unusual, but not error conditions
  #  GLB_iv_MsgLevelInfo                    - (6) Informational, normal operational messages that require no action
  #  GLB_iv_MsgLevelDebug                   - (7) Debug, information useful for developing and debugging
  #
  #  Key:
  #    GLB_ - ConsoleUserWarden global variable
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
  
  GLB_sv_ProjectName="ConsoleUserWarden"
  GLB_sv_ProjectInitials="CUW"
  GLB_sv_ProjectDeveloper="com.github.execriez"
  GLB_sv_ProjectVersion="1.0.4"

  # --- 
  
  # The following constants never change
  
  GLB_iv_MsgLevelEmerg=0
  GLB_iv_MsgLevelAlert=1
  GLB_iv_MsgLevelCrit=2
  GLB_iv_MsgLevelErr=3
  GLB_iv_MsgLevelWarn=4
  GLB_iv_MsgLevelNotice=5
  GLB_iv_MsgLevelInfo=6
  GLB_iv_MsgLevelDebug=7

  # -- Initial default values

  # Set whether the log is on by default
  GLB_bv_LogIsActiveStatusDefault="true"

  # Set the maximum log size
  GLB_iv_MaxLogSizeBytesDefault=81920
  
  # Set the logging level
  GLB_iv_LogLevelTrapDefault=${GLB_iv_MsgLevelDebug}
  
  # Set the user notify dialog level
  GLB_iv_NotifyLevelTrapDefault=${GLB_iv_MsgLevelInfo}
  
fi
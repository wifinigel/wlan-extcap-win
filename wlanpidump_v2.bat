@echo off
SETLOCAL
REM #################################################################
REM # 
REM # This script runs on a Windows 10 machine and will allow
REM # Wireshark on a Windows machine to decode captured frames,
REM # using a WLANPi as a wireless capture device. The Windows machine
REM # machine must have IP connectivity to your WLANPi. This is generally
REM # achieved by connecting the Windows machine USB port to the WLANPi 
REM # micro-USB socket and establishing an OTG connection. Alternatively,
REM # the WLANPi can be connected to a network (local or remote) and 
REM # and an IP connection established between the Windows machine & the
REM # WLANPi.
REM # 
REM # This script is installed on to a Windows machine and can be
REM # used to run an over the air wireless capture on a WLANPi.
REM # The capture output is displayed within Wireshark on the 
REM # Windows machine. 
REM #
REM # The Wireshark GUI can be used to configure all session details such
REM # as the WLANPi IP address, channel selection and remote login details.
REM #
REM # Pre-requisites:
REM # 
REM #    - Wireshark 3.0.6 or later (ensure the SSHDump option is
REM #      added during the install...not added by default)
REM #    - WLANPi with image v1.9 or later*
REM #    - A wireless NIC capable of monitor modeplugged in to the WLANPi 
REM #      (e.g. CF-912)
REM #    - Network connectivity between the Wireshark laptop & WLANPi
REM #
REM # (* To make this work on v1.8.3, SSH to your WLANPi and edit the file:
REM #
REM #    /etc/sudoers.d/wlanpidump
REM #
REM #  Change the line:
REM # 
REM #    wlanpi ALL = (root) NOPASSWD: /sbin/ip, /usr/sbin/iw
REM #
REM #  to:
REM #
REM #    wlanpi ALL = (root) NOPASSWD: /sbin/ip, /usr/sbin/iw, /bin/date
REM #
REM #  ...and then save)
REM # 
REM # Installation:
REM '
REM # To install this utlity, simply copy this batch file to the 
REM # extcap directory of your Wireshark installation. By default,
REM # this can be found at 'C:\Program Files\Wireshark\extcap' if
REM # you are using the 64-bit version of Wireshark.
REM #
REM # To make things easier, if you are using the same WLANPi regularly,
REM # the default details for your WLANPi can also be entered in to 
REM # this script  to save re-entering them repeatedly.
REM #
REM # Set the variables below to configure the defaults for your
REM # environment, such as WLANPi credentials & IP address.
REM # Please use a plain text editor to make the updates to this
REM # file (e.g. Notepad)
REM # 
REM # Once this script file is in position, fire up Wireshark and look at 
REM # the list of interfaces on the home screen of Wireshark. You will
REM # see a new interface avaiable at the bottom: 
REM # 
REM #   'WLAN Pi remote capture (Win)'
REM # 
REM # Click on the configuration cog next to the interface name and 
REM # use the menu options that pop-up to configure the capture session.
REM # 
REM # To re-configure the session parameters (e.g. change channels) once
REM # a capture session is complete, hit File -> Close and close the 
REM # current capture (and optionally save). This will return you to the 
REM # Wireshark home screen and allow access to the interface configuration
REM # cog again.
REM # 
REM # (Suggestions & feedback: wifinigel@gmail.com)
REM # 
REM # 
REM # To do (maybe):
REM # 	1. Debug to file?
REM # 	2. usage output improve
REM # 	3. Sanity check values entered (e.g. username, no pwd)
REM # 	4. Signal errors to Wireshark
REM # 	5. Env var for password?
REM #################################################################

REM !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
REM !
REM ! Set your variables here, but make sure no trailing spaces 
REM ! accidentally at end of lines - you WILL have issues!
REM ! 
REM ! Remember, 192.168.42.1 is the default WLANPi address when
REM ! using Ethernet over USB.
REM !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
set username=wlanpi
set password=wlanpi
set host=169.254.42.1
set remote_interface=wlan0
set time_set=1

REM ############### NOTHING TO SET BELOW HERE #######################

rem ########################
rem # Configure global vars 
rem ########################
:init
    set "__NAME=%~n0"
    set "__VERSION=2.0.2"
    set "__YEAR=2020"

    set "__BAT_FILE=%~0"
    set "__BAT_PATH=%~dp0"
    set "__BAT_NAME=%~nx0"
	
	set "sshdump_path=%__BAT_PATH%sshdump.exe"
	rem # Set some Extcap defaults
	set "capture=0"
	set "extcap_interfaces=0"
	set "extcap_interface="
	set "extcap_dlts=0"
	set "extcap_config=0"
	set "fifo="
	set "extcap_version=0"
	set "frame_slice=0"
	
	rem # Set some interface defaults
	set "port=22"
	set "sshkey="
	set "remote_channel=36"
	set "remote_channel_width=HT20"
	set "remote_filter="
	
	set "IW=/sbin/iw"
	set "IWCONFIG=/sbin/iwconfig"
	set "IFCONFIG=/sbin/ifconfig"
	set "TCPDUMP=/usr/sbin/tcpdump"

rem ######################
rem # Command args parser 
rem ######################

rem Parse args passed (these have to be done first or values in args vars lost)
:parse

	if "%~1"=="" goto :main
	
	rem - Extcap Arguments
	if /i "%~1"=="--capture"            set "capture=1" & shift & goto :parse
	if /i "%~1"=="--extcap-interfaces"  set "extcap_interfaces=1" & shift & goto :parse
	if /i "%~1"=="--extcap-interface"   set "extcap_interface=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--extcap-dlts"        set "extcap_dlts=1" & shift & goto :parse
	if /i "%~1"=="--extcap-config"      set "extcap_config=1" & shift & goto :parse
	if /i "%~1"=="--fifo"               set "fifo=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--time-set"           set "time_set=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--extcap-version"     set "extcap_version=1" & shift & goto :parse
	if /i "%~1"=="--version"            set "extcap_version=1" & shift & goto :parse
	
	rem - Interface Arguments
	if /i "%~1"=="--host"                  set "host=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--port"                  set "port=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--username"              set "username=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--password"              set "password=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--sshkey"                set "sshkey=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--remote-interface"      set "remote_interface=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--remote-channel"        set "remote_channel=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--remote-channel-width"  set "remote_channel_width=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--remote-filter"         set "remote_filter=%~2" & shift & shift & goto :parse
	if /i "%~1"=="--frame-slice"           set "frame_slice=%~2" & shift & shift & goto :parse

	rem - Misc arguments
	if /i "%~1"=="--help"  goto :usage
	if /i "%~1"=="-h"      goto :usage
	
	rem This ensures we don't get stuck in loop if we get unknown arg
	shift
    goto :parse

rem ####################
rem # Main
rem #################### 	
:main

	rem - Process request for interface list from Wireshark
	if "%extcap_interfaces%"=="1" call :extcap_interface_func & goto :end
	
		rem - Process request for dlts list from Wireshark
	if "%extcap_dlts%"=="1" call :extcap_dlts_func & goto :end

	rem - process request to provide config options to Wireshark for GUI
	if "%extcap_config%"=="1" call :extcap_config_func & goto :end
	
	rem - Process capture request
	if "%capture%"=="1" call :capture_func & goto :end
	
	rem - Display script version & exit
	if "%extcap_version%"=="1" call :extcap_version_func & goto :end
	
	rem - end of main (if we get here, nothing was processed)
    echo Nothing passed to process...
	EXIT /B 1

rem ####################
rem # Functions
rem #################### 
:extcap_interface_func
    echo extcap {version=1.0}
    echo interface {value=wifidump2}{display=WLAN Pi 2.x rem cap (Win) (v%__VERSION%)}
	EXIT /B 0

:extcap_dlts_func
    echo dlt {number=147}{name=wifidump}{display=Remote capture dependent DLT}
	EXIT /B 0

:extcap_version_func
    echo extcap {version=%__VERSION%}
	EXIT /B 0

:extcap_config_func
    rem Capture Tab
    echo arg {number=0}{call=--remote-channel}{display=Channel}{type=selector}{tooltip=The channel to capture (1-14, 36-165)}{group=Capture}
    echo arg {number=1}{call=--remote-channel-width}{display=Channel Width}{type=selector}{tooltip=The width of the channel to capture}{group=Capture}

    rem # Server Tab
    echo arg {number=2}{call=--host}{display=WLAN Pi Address}{type=string}{tooltip=The remote SSH host. It can be both an IP address or a hostname}{required=true}{default=%host%}{group=Server}
    echo arg {number=3}{call=--port}{display=WLAN Pi Port}{type=unsigned}{tooltip=The remote SSH host port (1-65535)}{range=1,65535}{default=22}{group=Server}

    rem # Authentication Tab
    echo arg {number=4}{call=--username}{display=WLAN Pi Username}{type=string}{tooltip=The remote SSH username. If not provided, the current user will be used}{default=%username%}{group=Authentication}
    echo arg {number=5}{call=--password}{display=WLAN Pi Password}{type=string}{tooltip=The SSH password, used when other methods (SSH agent or key files) are unavailable.}{default=%password%}{group=Authentication}
    echo arg {number=6}{call=--sshkey}{display=Path to SSH Private Key}{type=fileselect}{tooltip=The path on the local filesystem of the private ssh key}{group=Authentication}

    rem # Advanced Tab
    echo arg {number=7}{call=--remote-interface}{display=Remote Interface}{type=string}{tooltip=The name of the interface used for capturing (usually wlan0 in the WLANPi)}{default=wlan0}{group=Advanced}
    echo arg {number=8}{call=--remote-filter}{display=Remote Capture Filter}{type=string}{tooltip=The remote capture filter in BPF format (not the same as Wireshark display filters)- e.g. wlan type mgt}{group=Advanced}
	echo arg {number=9}{call=--frame-slice}{display=Frame Slice (bytes)}{type=string}{tooltip=Frame slicer (bytes) - 500 is a good number for wireless (Zero is no slice, i.e.full frames)}{default=0}{group=Advanced}
	echo arg {number=10}{call=--time-set}{display=Sync WLANPi Time}{type=radio}{tooltip=Enable/disable time sync from laptop to remote host}{group=Advanced}

	rem set time sync selector based on default config setting
	set ts_arg0_default={default=true}
	set ts_arg1_default={default=false}

	if %time_set%==1 (
		set ts_arg0_default={default=false}
		set ts_arg1_default={default=true}
	)

	rem # Time sync radio values
	echo value {arg=10}{value=0}{display=Disabled}%ts_arg0_default%
	echo value {arg=10}{value=1}{display=Enabled}%ts_arg1_default%


    rem # Channel values
    echo value {arg=0}{value=1}{display=Channel 1 / 2412 MHz}
	echo value {arg=0}{value=2}{display=Channel 2 / 2417 MHz}
	echo value {arg=0}{value=3}{display=Channel 3 / 2422 MHz}
	echo value {arg=0}{value=4}{display=Channel 4 / 2427 MHz}
	echo value {arg=0}{value=5}{display=Channel 5 / 2432 MHz}
	echo value {arg=0}{value=6}{display=Channel 6 / 2437 MHz}
	echo value {arg=0}{value=7}{display=Channel 7 / 2442 MHz}
	echo value {arg=0}{value=8}{display=Channel 8 / 2447 MHz}
	echo value {arg=0}{value=9}{display=Channel 9 / 2452 MHz}
	echo value {arg=0}{value=10}{display=Channel 10 / 2457 MHz}
	echo value {arg=0}{value=11}{display=Channel 11 / 2462 MHz}
	echo value {arg=0}{value=12}{display=Channel 12 / 2467 MHz}
	echo value {arg=0}{value=13}{display=Channel 13 / 2472 MHz}
	echo value {arg=0}{value=13}{display=Channel 14 / 2484 MHz}
	echo value {arg=0}{value=36}{display=Channel 36 / 5180 MHz}
	echo value {arg=0}{value=40}{display=Channel 40 / 5200 MHz}
	echo value {arg=0}{value=44}{display=Channel 44 / 5220 MHz}
	echo value {arg=0}{value=48}{display=Channel 48 / 5240 MHz}
	echo value {arg=0}{value=52}{display=Channel 52 / 5260 MHz}
	echo value {arg=0}{value=56}{display=Channel 56 / 5280 MHz}
	echo value {arg=0}{value=60}{display=Channel 60 / 5300 MHz}
	echo value {arg=0}{value=64}{display=Channel 64 / 5320 MHz}
	echo value {arg=0}{value=100}{display=Channel 100 / 5500 MHz}
	echo value {arg=0}{value=104}{display=Channel 104 / 5520 MHz}
	echo value {arg=0}{value=108}{display=Channel 108 / 5540 MHz}
	echo value {arg=0}{value=112}{display=Channel 112 / 5560 MHz}
	echo value {arg=0}{value=116}{display=Channel 116 / 5580 MHz}
	echo value {arg=0}{value=120}{display=Channel 120 / 5600 MHz}
	echo value {arg=0}{value=124}{display=Channel 124 / 5620 MHz}
	echo value {arg=0}{value=128}{display=Channel 128 / 5640 MHz}
	echo value {arg=0}{value=132}{display=Channel 132 / 5660 MHz}
	echo value {arg=0}{value=136}{display=Channel 136 / 5680 MHz}
	echo value {arg=0}{value=140}{display=Channel 140 / 5700 MHz}
	echo value {arg=0}{value=144}{display=Channel 144 / 5720 MHz}
	echo value {arg=0}{value=149}{display=Channel 149 / 5745 MHz}
	echo value {arg=0}{value=153}{display=Channel 153 / 5765 MHz}
	echo value {arg=0}{value=157}{display=Channel 157 / 5785 MHz}
	echo value {arg=0}{value=161}{display=Channel 161 / 5805 MHz}
	echo value {arg=0}{value=165}{display=Channel 165 / 5825 MHz}


    rem # Channel width values
    echo value {arg=1}{value=HT20}{display=20 MHz}
    echo value {arg=1}{value=HT40-}{display=40- MHz}
    echo value {arg=1}{value=HT40+}{display=40+ MHz}
    echo value {arg=1}{value=80MHz}{display=80 MHz}
	
	EXIT /B 0

:capture_func

	rem ################################################
	rem update filter statement if value for filter set
	rem ################################################
	set filter_statement=

	if not "%remote_filter%"=="" (
		set filter_statement= -f %remote_filter%
	)

	rem ##########################
	rem set time sync if enabled
	rem ##########################
	set time_cmd=

	rem Setting WLANPi time to current time (uses UTC for global compatibility)
	rem As this uses Powershell to get UTC time, check Powershell is available
	where /q powershell.exe
	IF ERRORLEVEL 1 goto :nodate
	if %time_set%==0 goto :nodate

	powershell.exe (get-date)::Now.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') > "%TEMP%\locatime.txt"
	set /P datetime=<"%TEMP%\locatime.txt"
	set time_cmd=sudo date -s '%datetime%' ^> /dev/null;
	set kill_old_instances_cmd=if [ `pidof tcpdump` ]; then sudo kill -9 `pidof tcpdump`; fi;
	set if_down=sudo %IFCONFIG% %remote_interface% down;
	set if_up=sudo %IFCONFIG% %remote_interface% up;
	set set_monitor=sudo %IWCONFIG% %remote_interface% mode monitor;

	:nodate
	set capture_cmd="%kill_old_instances_cmd% %time_cmd% %if_down% %set_monitor% %if_up% sudo %IW% %remote_interface% set channel %remote_channel% %remote_channel_width% > /dev/null && sudo %TCPDUMP% -i %remote_interface%  %filter_statement% -s %frame_slice% -U -w - "
	
	call "%sshdump_path%" --extcap-interface sshdump --remote-host %host% --remote-port %port% --remote-capture-command %capture_cmd% --remote-username %username% --remote-password %password% --fifo %fifo% --capture
	
	EXIT /B %ERRORLEVEL%

:usage
	echo.
    echo  Usage:
    echo.
    echo.
    echo.  %__BAT_NAME% --help           shows basic help
    echo.  %__BAT_NAME% --version        shows the version
    echo.  %__BAT_NAME% --extcap-config  shows menu widget code
    echo.  %__BAT_NAME% --extcap-capture runs capture mode
    echo.
    goto :end    

rem ####################
rem # Exit point
rem ####################
:end
	EXIT /B %ERRORLEVEL%
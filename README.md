# wlan-extcap-win
Wireshark extcap interface for remote wireless captures in Windows 10 - based on Adrian Granados' original python scripts on the [wlan-extcap project][wlan-extcap]

This is an easy to install plug-in to allow configuration and capture from a WLANPi directly from Wireshark. It has most of the features of the previous [WLANPiShark project][wlanpishark-github], but runs within the Wireshark GUI rather than from a Windows command prompt. It is written as a native Windows batch file to make it as easy as possible to use for Windows users to be able to install (i.e. no other dependancies to install on your Windows 10 machine). 

![Screenshot][Capture_Image]

## Installation

### Quickstart

If you want to get going quickly and are happy to try out the defaults*, go with the following steps:

1. Make sure you have Wireshark 3.0.x installed, with the SSHDump option (in the Tools section) checked during install
    1. Here is the check-box you need for SSHDump (Under the Tools snap-open) - *** Don't miss this step *** ![SSH Dump option Image][sshdump_image]
    2. if you are wondering if your Wireshark installation already has SSHDump, it probably hasn't - it's not a default component that's installed with Wireshark. You can do a quick check by looking to see if the sshdump.exe file is installed in your Wireshark extcap directory. If you don't have it, re-install Wireshark
2. Make sure you have WLANPi image version 1.8.3 (see required fix for v1.8.3 below). Once we have a prime-time v1.9.x release (due Dec 2019), the fix described below will not be required, but please do not use any of the 1.9 alpha versions.
    1. You'll also need a Wi-Fi NIC card plugged to the WLANPi USB that supports monitor mode (e.g. CF-912)
3. Download this file: [wlanpidump.bat][wlanpidump.bat] (right-click, Save link as...)
4. Copy the file to the extcap directory of your Wireshark installation ('C:\Program Files\Wireshark\extcap' by default for the 64-bit version)
5. Make sure you have network connectivity to your WLANPi
6. Start Wireshark
   1. Look at the interface list on the Wireshark GUI home page
   2. Locate the interface called 'WLAN Pi remote capture (Win)'
   3. Click the small cog icon next to the interface to configure your capture session ![Interfaces][Interface_Image]
7. Once your capture is complete, if you'd like to change the capture configuration, hit File -> Close and select the configuration cog again to set session parameters

(* Assumed defaults: credentials are wlanpi/wlanpi, connection via local USB OTG (so WLANPii IP address is 192.168.42.1), wireless intrface is wlan0, WLANPi time is set from laptop - these can be changed from the GUI. To make permanent default changes, you will need to edit the wlanpidump.bat file yourself - docs to follow on this)

### Image Version 1.8.3 Workaround

To make this fully functional on v1.8.3, SSH to your WLANPi and edit the file '/etc/sudoers.d/wlanpidump' (you only need to do this once):

```
    sudo nano /etc/sudoers.d/wlanpidump
```

  Change the line:

``` 
    wlanpi ALL = (root) NOPASSWD: /sbin/iwconfig, /usr/sbin/iw
```

  to:

```
    wlanpi ALL = (root) NOPASSWD: /sbin/iwconfig, /usr/sbin/iw, /bin/date
```

  ...and then save by hitting Ctrl-X and hitting 'Y' to save changes

## Screen-shots

### Operation 

![Capture Tab][Capture_Image]

![Server Tab][Server_Image]

![Authentication Tab][Auth_Image]

![Advanced Tab][Adv_Tab_Image]

### Install

![Install Tools][tools_image]

![SSHDump][sshdump_image]


<!-- Links -->

[wlan-extcap]: https://github.com/adriangranados/wlan-extcap
[Capture_Image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wireshark_capture_tab.JPG
[Server_Image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wireshark_server_tab.JPG
[Auth_Image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wireshark_auth_tab.JPG
[Adv_Tab_Image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wireshark_adv_tab.JPG
[Interface_Image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wireshark_interface_list.JPG
[wlanpishark-github]: https://github.com/WLAN-Pi/WLANPiShark2
[wlanpidump.bat]: https://github.com/wifinigel/wlan-extcap-win/raw/master/wlanpidump.bat
[sshdump_image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wireshark_install_sshdump.JPG
[tools_image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wireshark_install_tools.JPG
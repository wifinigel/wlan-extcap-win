# wlan-extcap-win
Wireshark extcap interface for remote wireless captures in Windows - based on Adrian Granados' original python scripts on the [wlan-extcap project][wlan-extcap]

This is an easy to install plug-in to allow configuration and remote capture from a WLANPi directly from Wireshark (...I know!). It has many of the features of the previous [WLANPiShark project][wlanpishark-github], but runs within the Wireshark GUI rather than from a Windows command prompt. It is written as a native Windows batch file to make it as easy as possible to use for Windows users to be able to install (i.e. no other dependancies to install on your Windows machine). 

![Screenshot][Capture_Image]

## Installation

### Quickstart

If you want to get going quickly and are happy to try out the defaults, go with the following steps:

1. Make sure you have Wireshark 3.0.x installed, with the SSHDump option checked during install
2. Make sure you have WLANPIimage version 1.9.0 or later installed (due Nov/Dec 2019 - see fix for v1.8.3 below)
3. Download this file: [wlanpidump.bat][wlanpidump.bat]
4. Copy the file to the extcap directory of your Wireshark installation ('C:\Program Files\Wireshark\extcap' by default for the 64-bit version)
5. Make sure you have network connectivity to your WLANPi
6. Start Wireshark
   1. Look at the interface list on the Wireshark GUI home page
   2. Locate the interface called 'WLAN Pi remote capture (Win)'
    3. Click the small cog icon next to the interface to configure your capture session
7. Once your capture is complete, if you'd like to change the capture configuration, hit File -> Close and select the configuration cog again to set session parameters

### Image Version 1.8.3 Workaround

To make this fully functional on v1.8.3, SSH to your WLANPi and edit the file '/etc/sudoers.d/wlanpidump' (you only need to do this once):

```
    sudo nano /etc/sudoers.d/wlanpidump
```

  Change the line:

``` 
    wlanpi ALL = (root) NOPASSWD: /sbin/ip, /usr/sbin/iw
```

  to:

```
    wlanpi ALL = (root) NOPASSWD: /sbin/ip, /usr/sbin/iw, /bin/date
```

  ...and then save by hitting Ctrl-X and hitting 'Y' to save changes


<!-- Links -->

[wlan-extcap]: https://github.com/adriangranados/wlan-extcap
[Capture_Image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wireshark_capture_tab.JPG
[wlanpishark-github]: https://github.com/WLAN-Pi/WLANPiShark2
[wlanpidump.bat]: https://github.com/wifinigel/wlan-extcap-win/raw/master/wlanpidump.bat
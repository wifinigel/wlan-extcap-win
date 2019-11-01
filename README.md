# Windows 10 Wireshark Plug-in for WLANPi Wireless Captures (wlan-extcap-win)
![wlanpi Image][wlanpi_image]

This is an easy to install plug-in to allow configuration and wireless capture from a WLANPi directly within the Wireshark GUI. It has most of the features of the previous [WLANPiShark project][wlanpishark-github], but runs within the Wireshark GUI rather than from a Windows command prompt (...so is MUCH easier to use). It is written as a native Windows batch file to make it as easy as possible to use for Windows users to be able to install (i.e. there are no other dependancies to install on your Windows 10 machine). 

(_Note: this is based on Adrian Granados' original python scripts on the [wlan-extcap project][wlan-extcap] - if you're a Mac user, check it out!_)

![Screenshot][Capture_Image]

## 1. Installation

### 1.1 Quickstart

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

(* _Assumed defaults: credentials are wlanpi/wlanpi, connection via local USB OTG (so WLANPii IP address is 192.168.42.1), wireless intrface is wlan0, WLANPi time is set from laptop - these can be changed from the GUI. To make permanent default changes, you will need to edit the wlanpidump.bat file yourself - docs to follow on this_)

### 1.2 Image Version 1.8.3 Workaround

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

### 1.3 Installation - Full Version

Installing the wlan-extcap-win plugin is relatively easy. Once you have Wireshark installed on your Winodws 10 machine and your WLANPi up and running, it's pretty much just a case of copying one file in to your Wireshark directory. 

Before we can get to the good stuff though, we need to get a few things in place. I like pictures, so here is a picture of what we're going to achieve:

![WLANPI Operation Overview][wlanpi_overview]

To summarise, we want to use our WLANPi to capture 802.11 frames over the air. Windows is very tricky when comes to getting a native wireless adapter that can be used in monitor mode to capture 802.11 frames, so the WLANPi (which CAN capture 802.11 frames) is a nice solution to capture frames for us and stream them in to our copy of Wireshark on our Windows laptop.

#### 1.4.1 Connectivity

The WLANPi needs to be configured to operate on a specific channel we'd like to capture on, as well as setting things like the channel width. The configuration is done over an SSH session fro our Windows machine, so needs some credentials to login in to our WLANPi to make the changes.

The Windows machine and WLANPi can be connected via any type of IP network connection. In the example above, the Windows laptop is connected via a USB connection to the micro-USB connector on the WLANPI. This both powers the WLANPi, and also forms an Ethernet over USB network connection. This is something that Windows does automatically for us. If you look on your Windows network interface list after you plug in your WLANPi, you'll see a new  interface which is shown as an Ethernet adapter with a 192.168.42.x address. A good check before trying to use our plugin it to try an SSH session to the WLANPi from the Windows laptop to make sure network connectivity has been establised.

#### 1.4.2 Wireshark

We need Wireshark installed on our Windows machine so that we can configure our WLANPi and display captured wireless frames. 

If you don't already have Wireshark installed, do a quick Google and download the latest version. You must use verison 3.0.6 or later. However, before you double click the Wireshark install file and hit next, next, next...you need to know the following information. There is an optional component you need to install called 'SSHDump'. It isn't one of the default selected components, so you need to look out for it and make sure it's selected before completing the Wireskark install. You will find it under the Tools option during the installation wizard:

![Install Tools][tools_image]

![SSHDump][sshdump_image]

If you already have Wireshark installed, you probably need to run the installer again and select the SSHDump component. You can check by looking in the 'extcap' folder of your Wireshark install (the default folder for the 64-bit verison is 'C:\Program Files\Wireshark\extcap') and checking if you have the sshdump.exe file. If not, you need to run the installer again.

### 2. Operation

Once you have your laptop hooked up to the WLANPi, you have Wireshark set-up, then you're ready to capture.

Fire up Wireshark and look out for the interface list at the bottom of the app home page. You should see something like this:

![Interfaces][Interface_Image]

If you click the small cog icon next to the 'WLANPi remote capture' inteface, you will get access to the configuration panels to set up the connection to the WLANPi. Each of the panels is shown below (with an explanation of the options):

![Capture Tab][Capture_Image]

* Channel: Select the channel that you would like the WLANPi to capture on
* Channel width: Select the width of the channel you wish capture (note, it the channel is 40MHz wide and you only select 20MHz, you likely won't see ant data frames in your capture)

![Server Tab][Server_Image]

* WLAN Pi Address: This is the IP address of your WLANPi, which is 192.168.42.1 bey default if you use the direct USB connection method. However, the WLANPI could be connected anywhere on your network, so simply enter the IP address where you can reach your WLANPi.
* WLANPi Port: The ususal network port for SSH is 22, which is the default provided in this utility. If you change the port used by SSH on you WLANPi for some reason, you will need to update this field to match

![Authentication Tab][Auth_Image]

* WLAN Pi Username: As an SSH session is established between your Windows machine and the WLANPi, login credentials are required. The default username used on a default WLANPi image is 'wlanpi'. If you have a different account on the WLANPi you would like to use, update this field
* WLAN Pi Username: As an SSH session is established between your Windows machine and the WLANPi, login credentials are required. The default password used on a default WLANPi image is 'wlanpi'. If you change the default password or have a different account on the WLANPi you would like to use, update this field
* Path to SSH Private Key: If you choose to use a priavet key to authenticate instead of using a username/password, enter the pasth to the key file here

![Advanced Tab][Adv_Tab_Image]

* Remote Interface: This is the name of the wireless interface on the WLANPi being used to do the capture. This is generally wlan0, but if you have two NICS plugged in to the WLANPi, the 2nd NIC would be wlan1. To verify the interface name, SSH to the WLANPi and execute the command 'sudo /usr/sbin/iw dev' to see the wireless interface names
* Remote Capture Filter: There may be some instabce whe you only want to capture specific frames or frame types and not pull all frames across the link between your WLAN and your laptop. This is particularly relevant if you WLANPi is at a remote site and you don't want to pull lots of data across your network. A capture filter will do this job for you. However, the syntax of the capture filters is not the same as the diaply filter syntax yiu many be used to in Wireshark. For a guide on capture filters you can use, check out this blog article I wrote a while back: [Wireshark Capture Filters for 802.11][filter_article].
* Frame Slice (bytes): This is another useful mechanism for keep the level of traffic down that is generated by a capture - it also keeps you capture file sizes down. If you apply a frame slice value, then capured frames will be sliced of after the number of bytes specified. This is particulalry good for keeping large data frames to a resonable size if you are capturing on a busy network. You have to be careful not to be too aggressive with this, as you may lose useful informtion in larger frames such as beacons, so I'd recommend you prbably don't go much below 400 bytes with this value generally.
* Sync WLANPi Time: One of the issues with using the WLANPi over the direct USB connection method is that the WLANPi does not get any time sync information. It also does not remember the time between now and the last time you powered it on. If you enable this feature, the local time from you laptop will be used to update the time on your WLANPi befor each capture begins. However, if you WLANPI is connected to your network somewhere and it getting its time from NTP, you will likley want to disable this feature, as NTP is probably going to be a slighlty more accurate time.

## 3. Setting Script Defaults


## 4. FAQ


## 5. Support 


## 6. Credits

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
[wlanpi_image]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wlanpi_and_nic.jpg
[wlanpi_overview]: https://github.com/wifinigel/wlan-extcap-win/blob/master/images/wlan_extcap_win_Overview.jpg
[filter_article]: http://wifinigel.blogspot.com/2018/04/wireshark-capture-filters-for-80211.html
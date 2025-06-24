<p align="center">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/AppLogo.png" width="400"/>
</p>

<p align="center" style="text-align: center">
  <a href="https://github.com/mirham/MenuBarIP//tags" rel="nofollow">
    <img alt="GitHub tag (latest SemVer pre-release)" src="https://img.shields.io/github/v/tag/mirham/MenuBarIP?include_prereleases&label=version"/>
  </a>
  <a href="https://github.com/mirham/MenuBarIP/blob/main/LICENSE">
    <img alt="License" src="https://img.shields.io/github/license/mirham/MenuBarIP"/>
  </a>
  <img alt="macOS" src="https://img.shields.io/badge/macOS-blue?logo=apple"/>
  <img alt="Swift" src="https://img.shields.io/badge/Swift-grey?logo=swift"/>
  <img alt="Pet project" src="https://img.shields.io/badge/Pet project-purple?logo=github"/>
</p>

## Introduction
MirHam MenuBarIP is a macOS menu bar application designed to display your public and local IP addresses with various customization options.

## Why
I was surprised to find that all similar applications in the App Store are paid and offer limited customization. Creating my own was not a big challenge, so now I’m sharing it with everyone.

## Features
- Highly customizable menu bar items and used APIs
- Periodic internet connection checks
- Continuous operation, even after computer restarts
- Displays public IP on a map
- Logs public IP changes
- Option to run application or script (Shell, Javascript, Perl, Python, Ruby, PHP, AppleScript, CSharp) when the public IP changes
- Ability to use shebangs for unsupported script types
- Option to use custom API to retrieve public IP address and geolocation information

## Compatibility
This application is compatible with macOS 15.0 and above. All versions below 2.0 are compatible with macOS 14.0. Version [2.2](https://github.com/mirham/MenuBarIP/releases/download/2.2/MenuBarIP_macOS14.dmg) is the last compatible version for macOS 14.0 and will only be upgraded by request.

## Installation
Download the DMG installer from the [releases](https://github.com/mirham/MenuBarIP/releases), mount it, and drag and drop the application to the Applications folder. That's it! However, you will need to allow launching applications from unidentified developers to start the application, as I don't have an Apple developer license.

## Screenshots

### Menu bar
<p align="left">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/MenuBarView.png">
</p>

### Available items
<p align="left">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/AvailableItems.png">
</p>

### Color theme support
<p align="left">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/DarkTheme.png">
</p>
<p align="left">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/LightTheme.png">
</p>

### Map
<p align="left">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/MapView.png" width="800">
</p>

### Log
<p align="left">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/Log.png" width="400">
</p>

### Settings
<p align="left">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/Settings1.png" width="400">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/Settings2.png" width="400">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/Settings3.png" width="400">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/Settings4.png" width="400">
  <img src="https://github.com/mirham/MenuBarIP/blob/main/Images/Settings5.png" width="400">
</p>

## Scripting
As an advanced user, you can run your own application or script whenever your public IP address changes. This allows you to gain even more benefits from the app. The new public IP address will be passed into your script as a parameter. 

Supported types of scripts:
- Shell
- Javascript
- Perl
- Python
- Ruby
- PHP
- AppleScript
- CSharp
- Any from shebang, if the interpreter exists

Here's a sample Shell script that displays a notification in the macOS Notification Center and saves the public IP address in a log file.

```shell
#!/bin/bash

# Check if IP argument is provided
if [ -z "$1" ]; then
    echo "Error: No IP address provided" >> ~/Scripts/ip_change.log
    exit 1
fi

# Store the IP address
IP="$1"

# Display macOS notification, notifications from "Script Editor" must be enabled in Notifications
osascript -e "display notification \"New public IP address: $IP\" with title \"IP Address Update\""

# Log execution
echo "$(date): New IP: $IP" >> ~/Scripts/ip_change.log

exit 0
```
> [!IMPORTANT]
> Make sure your script is executable, otherwise, it won't work. 

You can make the script executable with the command:
```
chmod +x /path/to/your/script.sh
```

## Troubleshooting
### Where I can find public IP API?
You can find free IP APIs that return plain text and require no API key by searching online for "Free IP API plain text no API key." While many are available, not all may work in your country. Alternatively, you can create and deploy your own public IP API, it's not very complicated. The main condition is that it must return only the IP address as plain text, without any additional data.
### Where I can find public IP info API?
This is more complex, but you can also search online for "Free IP geolocation API no API key." While many free services exist, most require registration and an API key in the request. However, you are welcome to use them if you wish.

I can recommend two free services:

 - ```http://ip-api.com/json/%IP%``` – This one is used by default.
 - ```https://free.freeipapi.com/api/json/%IP%``` – This one is less accurate.

The mapping for the last service is as follows:

  - City name -> ```cityName```
  - Country code -> ```countryCode```
  - Country name -> ```countryName```
  - IP address -> ```ipAddress```
  - Latitude -> ```latitude```
  -  Longitude -> ```longitude```
  -  Region name -> ```regionName```
  -  Zip code -> leave blank
### The app dispalys "Obtaining IP..." for a long time
This could happen if some public IP APIs are unreachable from your current connection location. The app skips these, but this process takes time. Furthermore, after updating the public IP, the app attempts to use them again. I recommend checking public IP APIs in your browser. If an API no more rapidly return an IP address as plain text, you should remove that API from the app. This will solve the problem. Additionally, you can find new free APIs online, if they work well, feel free to add them to the app.
### The app dispalys "No active IP API"
This means no IP API can be called at this moment, and the application cannot obtain your public IP address. For the app to function normally, at least one IP API must be available and working properly. But it is better to have a lot of them, **at least 10**, to prevent this message from appearing. You can check the status of each IP API under `Settings` -> `IP APIs`. The "No active IP API" message indicates a network problem, such as a connection or DNS issue. Try restarting the application to reactivate the IP APIs. If this doesn't resolve the problem, please find and add working IP APIs, as explained in the previous instructions. 
### The app displays "No Internet" although there is an Internet connection
The app determines your internet connection status by calling the address configured in `Settings` -> `General` -> `Check if internet access using address` (which is google.com by default). If this site doesn't respond, the app considers there to be no internet connection. Please use a reliable address with an uptime close to 100% and one that is available in your country.
### Shell script doesn't run
Make sure you have ```/bin/zsh``` on your computer, and your script is executable.
You can make the script executable with the command:
```
chmod +x /path/to/your/script.sh
``` 
Also, make sure your script works using Terminal. If it functions properly in Terminal, it should also work with the application.
Here is the Terminal command to check the example script from above (use the correct path to your shell script file):
```
'/ScriptExample/update_ip.sh' 15.15.15.15
``` 

## Improvement
> [!TIP]
> If you have any ideas, thoughts, or concerns, don't hesitate to contact me. I'm happy to help and improve the application.

## Disclaimer
> [!WARNING]
> I'm not a professional Swift developer (though I am a professional .NET developer). All my macOS apps are made for personal use by myself and my family simply because I have the skills to create them (and for fun, of course 😊). If my application has caused any harm, I apologize for that, but please be aware that you use it at your own risk.

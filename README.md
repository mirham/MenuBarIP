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
- Highly customizable menu bar items
- Periodic internet connection checks
- Continuous operation, even after computer restarts
- Displays public IP on a map
- Logs public IP changes
- Runs shell scripts when the public IP changes
- Option to use custom API to retrieve public IP address and geolocation information

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

### Scripting

As an advanced user, you can run your own shell script whenever your public IP address changes. This allows you to gain even more benefits from the app. The new public IP address will be passed into your script as a parameter.

Here's an example script that displays a notification in macOS' Notification Center.

```shell
#!/bin/bash

# Check if IP argument is provided
if [ -z "$1" ]; then
    echo "Error: No IP address provided" >> ~/Scripts/ip_change.log
    exit 1
fi

# Store the IP address
IP="$1"

# Display macOS notification
osascript -e "display notification \"New public IP address: $IP\" with title \"IP Address Update\""

# Log execution
echo "$(date): New IP: $IP" >> ~/Scripts/ip_change.log

exit 0
```

## Improvement
> [!TIP]
> If you have any ideas, thoughts, or concerns, don't hesitate to contact me. I'm happy to help and improve the application.

## Disclaimer
> [!WARNING]
> I'm not a professional Swift developer (though I am a professional .NET developer). All my macOS apps are made for personal use by myself and my family simply because I have the skills to create them (and for fun, of course 😊). If my application has caused any harm, I apologize for that, but please be aware that you use it at your own risk.

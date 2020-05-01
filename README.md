# Mosco
Delphi add-in and companion macOS app

Please find binaries in the Releases folder.

## Brief instructions

### Installation

Delphi Expert:

For releases prior to 1.0.0 Beta 6, there is no installer, so the expert will need to be added manually. To do this, run regedit, navigate to:

  HKEY_CURRENT_USER\Software\Embarcadero\BDS\20.0\Experts

..and add a string value named Mosco, which has a value pointing to where you have placed Mosco260.dll


macOS App:

For releases prior to 1.0.0 Beta 6, there is no installer, so unzip Mosco.app from Mosco.zip somewhere onto your Mac (e.g. in /Applications)

The app is yet to be notarized, so if you're running Catalina, it may be prevented from running.

## Using Mosco

### macOS App

The macOS app runs as an "accessory", which means an icon (of the Kremlin) will appear in the status area of the menu bar. 

Where available:

Click the icon to drop down the menu

Click the Options menu item to set the desired port

Click the Start/Stop menu item to start and stop Mosco (see known issues)

Click View Log to see diagnostic messages

Click Create Installer.. to create an installer for your macOS apps

Click Notarize to notarize your macOS apps.

Click Upload.. to show the Upload to App Store dialog. Enter your Apple ID and App Specific Password (1st step in [macOS App Notarization](http://docwiki.embarcadero.com/RADStudio/Rio/en/MacOS_Notarization)) and click Upload.

Click PAServers.. to configure PAServer instances that can be started/stopped from the dialog. At present, only the port is configurable.

## Known issues with the Mosco macOS app

Any action that causes the menu to update (e.g. stopping/starting the server) may result in a crash. The current workaround is to just restart Mosco


### Delphi Expert

The expert adds items to the Project Manager context menu i.e. the one that appears when you right-click a project in the Project Manager

Click Mosco Options to configure the address/port for the macOS app, and for error logging

The following functions will work only when the Mosco macOS app is running, e.g:

Add SDK Frameworks - brings up a dialog that allows you to add available frameworks to the selected SDK. 
Show Deployed App - brings up the deployed app (if it has been deployed) in Finder on the Mac.

The following functions will work whether or not the Mosco macOS app is running:

Select Profile - instant switching of connection profiles
Select SDK - instant switching of SDKs










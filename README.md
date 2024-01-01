# Mosco

This repository is for source for use in clients, documentation, and for reporting issues

The latest release version can be downloaded [here](https://www.delphiworlds.com/mosco/latest), and older installers are [here](https://www.delphiworlds.com/mosco/older).

## Description

Mosco is an application for macOS that provides functionality to help ease the iOS/macOS development process

## Installation

Installation is straightforward - run the installer and follow the prompts

## Documentation

Can be found [here](Docs/Readme.md).

## Version History

v1.6.0 (Jan 1st, 2024)

* Added Deploy Extensions feature to back end - [Codex](https://github.com/DelphiWorlds/Codex) v2.1.0 or later can use this feature
* Fixed lock ups that could occur when creating installer
* Minor tweaks 

v1.5.0 (Nov 8th, 2023)

* Refactored back end code - [Codex](https://github.com/DelphiWorlds/Codex) v2.0.0 or later will work with Mosco v1.5.0
* Fixed issue with adding/removing PAServer entries
* Minor tweaks 

v1.4.1 (Apr 15th, 2023)

* Corrected which part of team info to use as TeamID 
* Fixed random AVs that occur when executing processes

v1.4.0 (Feb 26th, 2023)

* Refactored server part as a REST server (was using ZeroMQ)
* Updated notarization process to use `notarytool` command where supported (Xcode 14+)
* Added certificate and profile functions that [Codex](https://github.com/DelphiWorlds/Codex) uses
* Fixed launching instances of PAServer on macOS 13.0
* Fixed a bug with SDK searching

v1.3.0 (Jun 16th, 2022)

* Added submenu for easier launching of PAServers
* Added Refresh button to Certs and Profiles view
* Fixed issue with notarization
* Other minor fixes

v1.2.2 (Jan 4th, 2022)

* Added support for Monkey Builder
* Added option for obscuring passwords in messages window
* Added providers list to notarization 
* Various minor fixes

v1.2.1 (Oct 11th, 2021)

* Added workaround for [Apple App Store deployment issue](https://quality.embarcadero.com/browse/RSP-35701)
* Added option for notarization sleep time
* Changed notarization so that apps deployed using Development config can be notarized
* Fixed issue with notarization of installers

v1.2.0 (Sept 10th, 2021) - First public version












# REDD's PCAP UPLOADER (RPU)

A cross-platform utility for uploading PCAP files to Online Hash Crack (OHC).

## About the Project

RPU was created to give the Flipper Zero WiFi Dev Board and Marauder Community an easy way to upload all those wonderful 
PCAP files to OHC - ([OnlineHashCrack.com](https://OnlineHashCrack.com)) and get results in Email on-the-go. RPU was written in BATCH (Windows 
Systems) and BASH (Most Unix Based Systems) to provide as wide of compatibility as possible.

## Version 2.1 - New Features & Improvements

This version includes three platform-specific scripts that maintain consistent behavior and output across different operating systems:

- `upload-unix.sh` - For Linux and other Unix-based systems
- `upload-macos.sh` - Specifically optimized for macOS
- `upload-win.cmd` - For Windows 10 and newer

### New Features

- Email validation across all platforms
- Automatic creation of a "sent" directory for processed files
- Persistent email storage (saves your email in email.txt)
- Compatible path handling for each operating system
- Consistent output messages across all platforms
- Upload history logging (in upload_history.log)
- Recursive directory scanning
- Optional PCAP file verification
- Progress indicators for uploads
- Command-line options for scripting

## Little About PCAP Files

### What is a PCAP?
Packet capture (PCAP) is a networking practice involving the interception of data packets travelling over a network. 
Once the packets are captured, they can be stored by IT teams for further analysis.

### What is packet capture used for?
Packet capturing helps to analyze networks, identify network performance issues and manage network traffic. It allows 
IT teams to detect intrusion attempts, security issues, network misuse, packet loss, and network congestion. It enables
network managers to capture data packets directly from the computer network. The process is known as packet sniffing.

IT teams prefer using packet monitoring software to perform crucial tasks, such as:
* Monitoring WAN Traffic
* Tracking Network Usage
* Isolating Compromised Systems
* Testing Security of WAN's
* Detecting Suspicious Traffic
* Identify Rogue Attacks

## Command-Line Options

All scripts now support the following command-line options:

```
  -h, --help         Show this help message
  -r, --recursive    Search for PCAP files in subdirectories
  -v, --verify       Verify files are valid PCAP files before upload
  -n, --no-verify    Skip PCAP file verification (default behavior)
  -s, --silent       Hide progress indicators
  -e EMAIL           Specify email address for results
```

Example: `./upload-unix.sh -r -e your@email.com`

## How to Use

### Windows

1. Place your .pcap files in the same directory as the script
2. Double-click `upload-win.cmd` to run or use command-line options
3. Enter your email when prompted (or pre-configure in the script)
4. All PCAP files will be uploaded to OHC and moved to the "sent" folder

### macOS

1. Place your .pcap files in the same directory as the script
2. Open Terminal and navigate to the script directory
3. Make the script executable with: `chmod +x upload-macos.sh`
4. Run with: `./upload-macos.sh` or use command-line options
5. Enter your email when prompted (or pre-configure in the script)
6. All PCAP files will be uploaded to OHC and moved to the "sent" folder

### Linux/Unix

1. Place your .pcap files in the same directory as the script
2. Open Terminal and navigate to the script directory
3. Make the script executable with: `chmod +x upload-unix.sh`
4. Run with: `./upload-unix.sh` or use command-line options
5. Enter your email when prompted (or pre-configure in the script)
6. All PCAP files will be uploaded to OHC and moved to the "sent" folder

## Pre-configuring Your Email

To avoid entering your email each time, you can either:

1. Edit the script directly and set the EMAIL variable at the top
2. Create a file named `email.txt` in the same directory with your email address
3. Use the `-e` command-line option when running the script

### Reset Email Address
To reset the EMAIL used to receive results, just delete "email.txt" in the directory where you have the script running. The script will prompt you for your EMAIL next time you run it.

## Configuration Options

You can customize the behavior by setting these options in the script:

- RECURSIVE_MODE - Set to true to scan subdirectories (default: false)
- VERIFY_PCAP - Set to true to verify PCAP files before upload (default: false)
- SHOW_PROGRESS - Set to true to show curl progress meter (default: true)

## Requirements

- Windows: curl.exe (included in Windows 10 1803 and later)
- macOS/Linux: curl (usually pre-installed)

## Known Issues

- Some AV's (Anti-Viruses/Firewalls) may block scripts from using CURL correctly on Windows
- In Version 2.1, the issue with spaces in usernames and paths has been fixed

## Credits

Created by REDD (InfoSecREDD) - Creator/Developer 

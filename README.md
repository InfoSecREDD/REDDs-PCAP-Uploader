# REDD's PCAP UPLOADER (RPU)

## - About the Project -
RPU was created to give the Flipper Zero WiFi Dev Board and Marauder Community a easy way to upload all those wonderful 
PCAP files to OHC [OnlineHashCrack.com](OnlineHashCrack.com) and get results in Email on-the-go. RPU was written in BATCH (Windows 
Systems) and BASH (Most Unix Based Systems) to provide as wide of compatibility as possible.


# Little about PCAP Files

## What is a PCAP?
Packet capture (PCAP) is a networking practice involving the interception of data packets travelling over a network. 
Once the packets are captured, they can be stored by IT teams for further analysis.

## What is packet capture used for?
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

# Usage:
## Running RPU
- Download the latest [release](https://github.com/InfoSecREDD/REDDs-PCAP-Uploader/releases) of RPU.
- Unzip the zip file contents into your PCAP folder or onto your SDcard.
- Run either "upload-unix.sh" for UNIX systems OR Run "upload-win.cmd" for Windows systems. (MacOS Coming Soon)
- Input your Email Address you want the results of your PCAP files to be sent to and hit ENTER. (only 1st time using.)
- RELAX! - That is it! The script will do the rest.
- Hit ENTER to close the script.

## Reset Email Address
- To reset the EMAIL used to receive results, just delete "email.txt" in the directory you have the script running. The script will prompt you for your EMAIL next time you run the script.



## Credits:
REDD (InfoSecREDD) - Creator/Developer

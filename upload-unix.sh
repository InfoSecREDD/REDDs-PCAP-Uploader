#!/bin/bash
# Credits: REDD
# TARGET OS: Unix - BASH/Shell Script
# Version: 2.1 - Unified UNIX/Linux Version

# SET YOUR EMAIL BELOW OR SET IT IN THE SCRIPT!


EMAIL=""

# CONFIGURATION OPTIONS
RECURSIVE_MODE=false   # Set to true to scan subdirectories
VERIFY_PCAP=false      # Set to false to skip PCAP file verification (original behavior)
SHOW_PROGRESS=true     # Set to true to show curl progress meter


CURR_DIR="$PWD"
SENT_DIR="$CURR_DIR/sent"
LOG_FILE="$CURR_DIR/upload_history.log"

# Check for dependencies
check_dependencies() {
    local missing_deps=()
    
    # Check for curl - required
    if ! command -v curl &> /dev/null; then
        missing_deps+=("curl")
    fi
    
    # Check for file - useful for PCAP verification but not required
    if ! command -v file &> /dev/null; then
        if [ "$VERIFY_PCAP" = true ]; then
            echo "Note: 'file' command not found. Basic PCAP verification will be used."
        fi
    fi
    
    # Check for readlink or realpath - at least one is needed for path resolution
    if ! command -v readlink &> /dev/null && ! command -v realpath &> /dev/null; then
        echo "Warning: Neither 'readlink' nor 'realpath' found. Basic path resolution will be used."
    fi
    
    # If curl is missing, we need to report it
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Error: Required dependencies missing: ${missing_deps[*]}"
        echo "Please install the missing dependencies and try again."
        echo "On Debian/Ubuntu: sudo apt-get install ${missing_deps[*]}"
        echo "On Fedora/RHEL: sudo dnf install ${missing_deps[*]}"
        echo "On Arch Linux: sudo pacman -S ${missing_deps[*]}"
        exit 1
    fi
}

# Run dependency check
check_dependencies

if [ -f "email.txt" ]; then
        if [ "$EMAIL" == "" ]; then
                EMAIL_FROM_FILE=$(cat email.txt)
                EMAIL="$EMAIL_FROM_FILE"
        fi
fi
clear;

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if file is a valid PCAP
is_valid_pcap() {
    local file="$1"
    if command_exists file; then
        # Check with file command if available
        file -b "$file" | grep -qi "pcap\|libpcap\|tcpdump\|capture" && return 0
    else
        # Simple header check if file command not available
        # Check for pcap magic numbers: d4c3b2a1 or a1b2c3d4
        # PCAPNG: 0a0d0d0a
        local magic=$(hexdump -n 4 -e '1/4 "%08x"' "$file" 2>/dev/null)
        if [[ "$magic" == "d4c3b2a1" || "$magic" == "a1b2c3d4" || "$magic" == "0a0d0d0a" ]]; then
            return 0
        fi
    fi
    return 1
}

function PAUSE(){
        echo ""
        echo "DONE!!"
        read -p "Press any key to continue . . ."
        echo ""
}

function SET_EMAIL(){
        read -p "Enter the Email you want to use for Results: " EMAIL
        echo "$EMAIL" > email.txt
        CHECK_EMAIL;
}

# Find all PCAP files
function FIND_PCAPS() {
    local pcap_files=()
    
    if [ "$RECURSIVE_MODE" = true ]; then
        # Find PCAP files recursively
        echo "Searching for PCAP files in $CURR_DIR and subdirectories..."
        if command_exists find; then
            while IFS= read -r file; do
                pcap_files+=("$file")
            done < <(find "$CURR_DIR" -type f -name "*.pcap" 2>/dev/null)
        else
            # Fallback if find is not available
            pcap_files=($(ls -R 2>/dev/null | grep -i "\.pcap$"))
        fi
    else
        # Find PCAP files in current directory only
        for file in *.pcap; do
            # Skip if no matches found
            [[ -e "$file" ]] || continue
            pcap_files+=("$file")
        done
    fi
    
    echo "${pcap_files[@]}"
}

function SEND(){
        local curl_opts=""
        # Check if any .pcap files exist before iterating
        local pcap_files=($(FIND_PCAPS))
        
        if [ ${#pcap_files[@]} -gt 0 ]; then
            # Set curl options for progress display
            if [ "$SHOW_PROGRESS" = true ]; then
                curl_opts="-#"
            else
                curl_opts="-s"
            fi
            
            echo "Found ${#pcap_files[@]} PCAP files to process."
            
            for i in "${pcap_files[@]}"; do
                echo "Processing: $i"
                
                # Verify PCAP file if option enabled
                if [ "$VERIFY_PCAP" = true ]; then
                    if ! is_valid_pcap "$i"; then
                        echo "Warning: $i does not appear to be a valid PCAP file. Skipping."
                        continue
                    fi
                fi
                
                # Use readlink -m for Linux, fall back to other methods if needed
                UPLOAD_FILE_PATH=$(readlink -m "$i" 2>/dev/null || readlink -f "$i" 2>/dev/null || realpath "$i" 2>/dev/null || echo "$PWD/$i")
                echo "Uploading: $i"
                
                # Execute the curl command with progress options
                curl $curl_opts -X POST -F "email=$EMAIL" -F "file=@$UPLOAD_FILE_PATH" https://api.onlinehashcrack.com
                
                # Create sent directory if it doesn't exist
                if [ ! -d "$SENT_DIR" ]; then
                    mkdir -p "$SENT_DIR"
                fi
                
                # Create subdirectories in sent directory if recursive mode
                if [ "$RECURSIVE_MODE" = true ] && [[ "$i" == */* ]]; then
                    rel_dir=$(dirname "$i")
                    mkdir -p "$SENT_DIR/$rel_dir"
                    mv "$i" "$SENT_DIR/$i"
                else
                    mv "$i" "$SENT_DIR/$(basename "$i")"
                fi
                
                # Log the upload
                echo "$(date '+%Y-%m-%d %H:%M:%S') - Uploaded: $i - Email: $EMAIL" >> "$LOG_FILE"
                
                echo "Done processing: $i"
                echo "---------------------------------"
            done
            echo "All PCAP files have been processed."
        else
                echo "NO PCAP FILES FOUND!"
                echo ""
        fi
}

function CHECK_PCAPS(){
        SEND;
}

function CHECK_EMAIL(){
        # More compatible email validation 
        if [[ "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                CHECK_PCAPS;
        else
                echo "$EMAIL is NOT a Valid Email! Please try another Email."
                SET_EMAIL;
        fi
}

function SHOW_HELP() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --help         Show this help message"
    echo "  -r, --recursive    Search for PCAP files in subdirectories"
    echo "  -v, --verify       Verify files are valid PCAP files before upload"
    echo "  -n, --no-verify    Skip PCAP file verification (default behavior)"
    echo "  -s, --silent       Hide progress indicators"
    echo "  -e EMAIL           Specify email address for results"
    echo
    echo "Example: $0 -r -e your@email.com"
}

# Parse command line arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -r|--recursive)
        RECURSIVE_MODE=true
        shift
        ;;
        -v|--verify)
        VERIFY_PCAP=true
        shift
        ;;
        -n|--no-verify)
        VERIFY_PCAP=false
        shift
        ;;
        -s|--silent)
        SHOW_PROGRESS=false
        shift
        ;;
        -e)
        EMAIL="$2"
        shift
        shift
        ;;
        -h|--help)
        SHOW_HELP
        exit 0
        ;;
        *)    # unknown option
        POSITIONAL+=("$1")
        shift
        ;;
    esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

function HEADER(){
        echo ""
        echo ""
        echo "  :::::::::  :::::::::: :::::::::  :::::::::  ::: ::::::::    "
        echo "  :+:    :+: :+:        :+:    :+: :+:    :+: :+ :+:    :+:     "
        echo "  +:+    +:+ +:+        +:+    +:+ +:+    +:+    +:+            "
        echo "  +#++:++#:  +#++:++#   +#+    +:+ +#+    +:+    +#++:++#++     "
        echo "  +#+    +#+ +#+        +#+    +#+ +#+    +#+           +#+     "
        echo "  #+#    #+# #+#        #+#    #+# #+#    #+#    #+#    #+#     "
        echo "  ###    ### ########## #########  #########      ########      "
        echo "                 REDD's PCAP OHC UPLOADER"
        echo "                  ( Version 2.1 - UNIX )"
        echo ""
        if [ "$RECURSIVE_MODE" = true ]; then echo "RECURSIVE MODE: ENABLED"; fi
        if [ "$VERIFY_PCAP" = true ]; then echo "PCAP VERIFICATION: ENABLED"; fi
        echo ""
        echo ""
        echo "Email: $EMAIL";
        echo ""
        CHECK_EMAIL;
}

# If help was requested, show it. Otherwise, run the main program
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    SHOW_HELP
else
    HEADER;
    PAUSE;
fi

#!/bin/bash
# Credits: REDD
# TARGET OS: Unix - BASH/Shell Script

# SET YOUR EMAIL BELOW OR SET IT IN THE SCRIPT!


EMAIL=""





CURR_DIR="$PWD"
SENT_DIR="$CURR_DIR/sent"
if [ -f "email.txt" ]; then
        if [ "$EMAIL" == "" ]; then
                EMAIL_FROM_FILE=$(cat email.txt)
                EMAIL="$EMAIL_FROM_FILE"
        fi
fi
clear;
function PAUSE(){
        echo ""
        echo "DONE!!"
        read -p "Press any key to continue . . ."
        echo ""
}
function SET_EMAIL(){
        read -p "Enter the Email you want to use for Results: " EMAIL
        CHECK_EMAIL;
}
function SEND(){
        for i in *.pcap; do
                UPLOAD_FILE_PATH=$(readlink -m $i)
                curl -X POST -F "email=$EMAIL" -F "file=@$UPLOAD_FILE_PATH" https://api.onlinehashcrack.com
                if [ ! -d "$SENT_DIR" ]; then
                        mkdir -p $SENT_DIR
                fi
                mv $i $SENT_DIR/$i
        done
}
function CHECK_PCAPS(){
        PCAP_FILES=$(ls *.pcap 2>/dev/null | wc -l)
        if [ "$PCAP_FILES" != "0" ]; then
                SEND;
        else
                echo "NO PCAP FILES FOUND!"
                echo ""
        fi
}
function CHECK_EMAIL(){
        grep -qE '[[:alnum:]]+@[[:alnum:]]+(.[[:alnum:]]+){1,2}' <<< $EMAIL 2>/dev/null
        if [[ "$?" == "0" ]]; then
                CHECK_PCAPS;
        else
                echo "$EMAIL is NOT a Valid Email! Please try another Email."
                SET_EMAIL;
        fi
}
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
        echo "                  ( Version 1.3 - UNIX )"
        echo ""
        echo ""
        echo ""
        echo "Email: $EMAIL";
        echo ""
        CHECK_EMAIL;
}
HEADER;
PAUSE;

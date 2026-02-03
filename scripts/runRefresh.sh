clear && clear

ADBLOCK_DIR="abp"
DOMAINS_DIR="domains"
UNBOUND_DIR="unbound"

BUNNYCDN_ADBLOCK_DIR="adblock"
BUNNYCDN_DOMAIN_DIR="$DOMAINS_DIR"

USERNAME="$1"
EMAIL="$2"
API_KEY="$3"
DATE=$(date -u +'%Y%m%d.%H%M00')

currDate() {
    date -u +'%Y-%m-%d %H:%M:%S%3'
    return 0
}

logMessage() {
    local message=$1
    echo "$(currDate) | $message"
    return 0
}

copyToDomainFormat() {
    OLD_FILE=$1
    NEW_FILE=$(echo "$OLD_FILE" | sed -E 's/adblock\.txt/domain\.txt/g')

    if [ -f "$ADBLOCK_DIR/$OLD_FILE" ]; then
        logMessage "Creating $NEW_FILE"

        NEW_BODY=$(cat $ADBLOCK_DIR/$OLD_FILE | sed '/^# /d; /^\[/d; /^$/d' | sed -E 's/!/#/g' | sed -E 's/^\|\|//g' | sed -E 's/\^//g') # | sort -u)
        echo "$NEW_BODY" > $DOMAINS_DIR/$NEW_FILE
        
        logMessage "Created $NEW_FILE"
    fi
}

copyToUnboundFormat() {
    OLD_FILE=$(echo "$1" | sed -E 's/adblock\.txt/domain\.txt/g')
    NEW_FILE=$(echo "$OLD_FILE" | sed -E 's/domain\.txt/unbound\.conf/g')

    if [ -f "$DOMAINS_DIR/$OLD_FILE" ]; then
        logMessage "Creating $NEW_FILE"

        cat $DOMAINS_DIR/$OLD_FILE | grep '^#' > $UNBOUND_DIR/$NEW_FILE;
        echo "server:" >> $UNBOUND_DIR/$NEW_FILE;
        cat $DOMAINS_DIR/$OLD_FILE | grep '^[^#]' | sed -E 's/^([^#].*)/    local-zone: "\1." always_null/g' >> $UNBOUND_DIR/$NEW_FILE;

        logMessage "Created $NEW_FILE"
    fi
}

uploadFileToBunnyCDN() {
    curl --request PUT \
            --url https://storage.bunnycdn.com/adlists-rtf/adlist/$3/$1 \
            -H "AccessKey: $API_KEY" \
            -H 'Content-Type: application/octet-stream' \
            -H 'accept: application/json'  \
            --data-binary @$2/$1
}

uploadToBunnyCDN() {
    echo "Uploading to BunnyCDN"

    echo "Uploading $ADBLOCK_DIR"
    FILES=$(find $ADBLOCK_DIR -type f -name '*.txt' -o -name '*.txt.gz' | sort -u)

    for FILE in ${FILES[@]}; do
        FILE_NAME="$(echo "$FILE" | cut -d "/" -f2)"

        uploadFileToBunnyCDN $FILE_NAME $ADBLOCK_DIR $BUNNYCDN_ADBLOCK_DIR
    done

    echo "
    Uploading $DOMAINS_DIR
    "
    FILES=$(find $DOMAINS_DIR -type f -name '*.txt' -o -name '*.txt.gz' | sort -u)

    for FILE in ${FILES[@]}; do
        FILE_NAME="$(echo "$FILE" | cut -d "/" -f2)"

        uploadFileToBunnyCDN $FILE_NAME $DOMAINS_DIR $BUNNYCDN_DOMAIN_DIR
    done

    wait

    echo "Uploaded to BunnyCDN"
}

logMessage "Pulling Latest from Git"

git config user.name "$USERNAME"
git config user.email "$EMAIL"

git pull

logMessage "Pulled Latest from Git"
logMessage "Cleaning Up Previous Run"

if [ -d "$ADBLOCK_DIR" ]; then
    rm $ADBLOCK_DIR/*
fi

if [ ! -d "$ADBLOCK_DIR" ]; then
    mkdir $ADBLOCK_DIR
fi

if [ -d "$ADBLOCK_DIR" ]; then
    rm $ADBLOCK_DIR/*.gz
fi

if [ -d "$DOMAINS_DIR" ]; then
	rm "$DOMAINS_DIR/*"
fi

if [ ! -d "$DOMAINS_DIR" ]; then
    mkdir $DOMAINS_DIR
fi

if [ -d "$DOMAINS_DIR" ]; then
	rm "$DOMAINS_DIR/*.gz"
fi

if [ -d "$UNBOUND_DIR" ]; then
	rm "$UNBOUND_DIR/*"
fi

if [ ! -d "$UNBOUND_DIR" ]; then
    mkdir $UNBOUND_DIR
fi

if [ -d "$UNBOUND_DIR" ]; then
	rm "$UNBOUND_DIR/*.gz"
fi

logMessage "Cleaned Up Previous Run"
logMessage "Pulling Latest Blocklists"

bash scripts/generateHostToAdblockPro.sh urlhaus.hostfile.adblock.txt https://urlhaus.abuse.ch/downloads/hostfile
bash scripts/generateHostToAdblockPro.sh frellwits.swedish.adblock.txt https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt
bash scripts/generateHostToAdblockPro.sh adaway.adblock.txt https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt
bash scripts/generateHostToAdblockPro.sh ph00lt0.blocklist.adblock.txt https://raw.githubusercontent.com/ph00lt0/blocklist/master/hosts-blocklist.txt

bash scripts/generateAdblockProCombined.sh hagezi.native.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/hagezi.native.abp
bash scripts/generateAdblockProCombined.sh mullvad.malware.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/mullvad.malware.abp
bash scripts/generateAdblockProCombined.sh mullvad.trackers.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/mullvad.trackers.abp
bash scripts/generateAdblockProCombined.sh advertising.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/advertising.abp
bash scripts/generateAdblockProCombined.sh adlist.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/adlist.abp
bash scripts/generateAdblockProCombined.sh nrd14.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/nrd14.abp
bash scripts/generateAdblockProCombined.sh nrd28.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/nrd28.abp
# bash scripts/generateAdblockProCombined.sh nrd30.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/nrd30.abp

logMessage "Generating Mullvard Blocklists"
bash scripts/generateMullvardAdvertising.sh
logMessage "Generated Mullvard Blocklists"

logMessage "Pulled Latest Blocklists"

logMessage "Copy to $DOMAINS_DIR"

TXT_FILES=(mullvad.advertising.adblock.txt mullvad.malware.adblock.txt mullvad.trackers.adblock.txt ph00lt0.blocklist.adblock.txt urlhaus.hostfile.adblock.txt nrd14.adblock.txt nrd28.adblock.txt)

for FILE in ${TXT_FILES[@]}; do
    copyToDomainFormat $FILE

    if [[ "$FILE" != "urlhaus.hostfile.adblock.txt" ]]; then
        copyToUnboundFormat $FILE
    fi
done

logMessage "Copied to $DOMAINS_DIR"
logMessage "Compressing Files"

gzip -k -9 -f $ADBLOCK_DIR/*.txt
gzip -k -9 -f $DOMAINS_DIR/*.txt
gzip -k -9 -f $UNBOUND_DIR/*.conf

logMessage "Compressed Files"

ls -1 $ADBLOCK_DIR/ | wc -l
ls -1 $DOMAINS_DIR/ | wc -l
ls -1 $UNBOUND_DIR/ | wc -l

# uploadFileToBunnyCDN nrd14.txt $ADBLOCK_DIR $BUNNYCDN_ADBLOCK_DIR
# uploadFileToBunnyCDN nrd14.txt.gz $ADBLOCK_DIR $BUNNYCDN_ADBLOCK_DIR

# uploadFileToBunnyCDN nrd14.txt $DOMAINS_DIR $BUNNYCDN_DOMAIN_DIR
# uploadFileToBunnyCDN nrd14.txt.gz $DOMAINS_DIR $BUNNYCDN_DOMAIN_DIR

# uploadFileToBunnyCDN nrd28.txt $ADBLOCK_DIR $BUNNYCDN_ADBLOCK_DIR
# uploadFileToBunnyCDN nrd28.txt.gz $ADBLOCK_DIR $BUNNYCDN_ADBLOCK_DIR

# uploadFileToBunnyCDN nrd28.txt $DOMAINS_DIR $BUNNYCDN_DOMAIN_DIR
# uploadFileToBunnyCDN nrd28.txt.gz $DOMAINS_DIR $BUNNYCDN_DOMAIN_DIR

logMessage "Updated Files"

# uploadToBunnyCDN

logMessage "Updating Markdown"
bash scripts/generateCDNMarkdown.sh
logMessage "Updated Markdown"

logMessage "Removing Large Files"
rm $(find abp -type f -size +50M)
rm $(find domains -type f -size +50M)
rm $(find unbound -type f -size +50M)
logMessage "Removed Large Files"

logMessage "Pushing to GitHub"

git add .
git commit -m "Updated Adlists @ $DATE"
git tag "$DATE"
# git push
# git push origin "$DATE"

logMessage "Pushed to GitHub"

# uploadToBunnyCDN
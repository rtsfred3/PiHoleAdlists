API_KEY="$1"

DIR="abp"

if [ ! -d "$DIR" ]; then
    mkdir $DIR
fi

removeAdblockExtras() {
    echo "$(cat $1 | sed '/^!/d' | sed '/^\[/d' | sed '/^#/d' | sort)" > $1
}

fetchAdblockUrl() {
    curl "$2" --silent > $DIR/$1
    removeAdblockExtras  $DIR/$1
    # curl "$2" --silent | sed '/^!/d' | sed '/^\[/d' | sed '/^#/d' | sort >> $DIR/$1
}

uploadFileToBunnyCDN() {
    curl --request PUT \
            --url https://storage.bunnycdn.com/adlists-rtf/adlist/adblock/$1 \
            -H "AccessKey: $API_KEY" \
            -H 'Content-Type: application/octet-stream' \
            -H 'accept: application/json'  \
            --data-binary @$DIR/$1
}

bash scripts/generateHostToAdblockPro.sh urlhaus.hostfile.adblock.txt https://urlhaus.abuse.ch/downloads/hostfile
bash scripts/generateHostToAdblockPro.sh frellwits.swedish.adblock.txt https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt

fetchAdblockUrl tif.mini.txt https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/adblock/tif.mini.txt

mv $DIR/tif.mini.txt $DIR/mullvad.malware.adblock.txt
cat $DIR/urlhaus.hostfile.adblock.txt >> $DIR/mullvad.malware.adblock.txt
clear && clear

DIR="abp"

USERNAME="$1"
EMAIL="$2"
API_KEY="$3"
DATE=$(date -u +'%Y%m%d.%H%M00')

uploadFileToBunnyCDN() {
    curl --request PUT \
            --url https://storage.bunnycdn.com/adlists-rtf/adlist/adblock/$1 \
            -H "AccessKey: $API_KEY" \
            -H 'Content-Type: application/octet-stream' \
            -H 'accept: application/json'  \
            --data-binary @$DIR/$1
}

uploadToBunnyCDN() {
    echo "Uploading to BunnyCDN"

    FILES=$(find $DIR -type f -name '*.txt' -o -name '*.txt.gz' | sort -u)

    for FILE in ${FILES[@]}; do
        FILE_NAME="$(echo "$FILE" | cut -d "/" -f2)"

        uploadFileToBunnyCDN $FILE_NAME
    done

    wait

    echo "Uploaded to BunnyCDN"
}

git config user.name "$USERNAME"
git config user.email "$EMAIL"

git pull

if [ -d "$DIR" ]; then
    rm $DIR/*
fi

if [ ! -d "$DIR" ]; then
    mkdir $DIR
fi

bash scripts/generateHostToAdblockPro.sh urlhaus.hostfile.adblock.txt https://urlhaus.abuse.ch/downloads/hostfile
bash scripts/generateHostToAdblockPro.sh frellwits.swedish.adblock.txt https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt
bash scripts/generateHostToAdblockPro.sh adaway.adblock.txt https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt
bash scripts/generateHostToAdblockPro.sh ph00lt0.blocklist.adblock.txt https://raw.githubusercontent.com/ph00lt0/blocklist/master/hosts-blocklist.txt

bash scripts/generateAdblockProCombined.sh hagezi.native.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/hagezi.native.abp
bash scripts/generateAdblockProCombined.sh mullvad.malware.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/mullvad.malware.abp
bash scripts/generateAdblockProCombined.sh mullvad.trackers.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/mullvad.trackers.abp
bash scripts/generateAdblockProCombined.sh advertising.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/advertising.abp
bash scripts/generateAdblockProCombined.sh adlist.adblock.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/adlist.abp
# bash scripts/generateAdblockProCombined.sh nrd14.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/nrd14.abp
# bash scripts/generateAdblockProCombined.sh nrd30.txt https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/nrd30.abp

# uploadFileToBunnyCDN $DIR/nrd14.txt
# uploadFileToBunnyCDN $DIR/nrd14.txt.gz

# uploadFileToBunnyCDN $DIR/nrd30.txt
# uploadFileToBunnyCDN $DIR/nrd30.txt.gz

echo "Updated Files"

# uploadToBunnyCDN

bash scripts/generateCDNMarkdown.sh

rm $(find abp -type f -size +50M)

echo "Pushing to GitHub"

git add .
git commit -m "Updated Adlists @ $DATE"
git tag "$DATE"
git push
git push origin "$DATE"

echo "Pushed to GitHub"

uploadToBunnyCDN
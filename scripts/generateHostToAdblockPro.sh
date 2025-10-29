clear && clear

DIR="abp"

# FILE=adlist.host.abp.txt
# HOST_LISTS=("https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts" "https://raw.githubusercontent.com/AdAway/adaway.github.io/master/hosts.txt" "https://raw.githubusercontent.com/ph00lt0/blocklist/master/hosts-blocklist.txt")
# FILE=$(echo $HOST_LIST | cut -d "/" -f7)

# FILE=frellwits.swedish.abp.txt
# HOST_LIST="https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt"

FILE="$1"
HOST_LIST="$2"

echo $FILE
echo $HOST_LIST

DEDUPED_FILE="tmp_${FILE}"

if [ -f "$DIR/$FILE" ]; then
    rm $DIR/$FILE
fi

if [ ! -d "$DIR" ]; then
    mkdir $DIR
fi

echo "" > $DIR/$FILE

echo "[Adblock Plus]
! Generated at $(date -u +'%Y-%m-%d %H:%M:%S UTC')
! 
! Sources: $HOST_LIST
! " > $DIR/$DEDUPED_FILE

curl "$HOST_LIST" --silent | sed '/^#/d' | sed -E 's/^[^ #]+[ ]+(.+)$/\1/g' | sort >> $DIR/$FILE

echo "$(cat $DIR/$FILE | sed -E 's/^(0|127)\.0\.0\.(0|1)(	)?//g' | sort)" > $DIR/$FILE

echo "$(cat $DIR/$FILE | sort | sed -E '/^[ 	]+#/d' | sed -E 's/^(.+) #.*$/\1/g' | sed '/^$/d' | sed '/^(0|127)\.0\.0\.(0|1)$/d' | sort -u)" > $DIR/$FILE
echo "$(sed -E 's/^/||/g' $DIR/$FILE | sed -E 's/([|0-9a-z\.\-]+)/\1\^/g' | sort)" >> $DIR/$DEDUPED_FILE
# echo "$(cat $DIR/$FILE | sort | sed -E 's/^(.+)$/||\1^/g')" >> $DIR/$DEDUPED_FILE

mv $DIR/$DEDUPED_FILE $DIR/$FILE

# gzip -k -9 -f $DIR/$FILE
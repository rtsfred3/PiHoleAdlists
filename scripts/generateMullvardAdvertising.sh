clear; clear;

DIR="abp"

FILE_NAME="mullvad.advertising.adblock.txt"

echo "[Adblock Plus]
! Generated at $(date -u +'%Y-%m-%d %H:%M:%S UTC')
! 
! Sources:
! https://small.oisd.nl
! https://v.firebog.net/hosts/AdguardDNS.txt
! https://raw.githubusercontent.com/lassekongo83/Frellwits-filter-lists/master/Frellwits-Swedish-Hosts-File.txt
! " > $DIR/$FILE_NAME

FILE_ONE=$(curl -s https://v.firebog.net/hosts/AdguardDNS.txt | sed '/#/d' | sed '/^$/d' | sed -E 's/^([^\|].*[^\^])$/\|\|\1\^/g')
FILE_TWO=$(cat $DIR/frellwits.swedish.adblock.txt | sed '/^!/d' | sed '/^\[/d' | sed '/^#/d' | sort)
FILE_THREE=$(curl -s https://small.oisd.nl | sed '/^!/d' | sed '/^\[/d' | sed '/^#/d' | sort)

BODY=$(echo "$FILE_ONE
$FILE_TWO
$FILE_THREE" | sed '/^$/d' | sort -u)

echo "$BODY" >> $DIR/$FILE_NAME

# gzip -k -9 -f $DIR/$FILE_NAME
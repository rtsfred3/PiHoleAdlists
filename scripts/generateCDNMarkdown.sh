echo "**Adlists**" > CDNs.md

processFile() {
    SHORT_FILE=$(echo "$FILE" | cut -d "/" -f2)

	GH="[GH](https://raw.githubusercontent.com/rtsfred3/Adlists/main/$FILE)"
	GL="[GL](https://gitlab.com/rtsfred3/Adlists/-/raw/main/$FILE)"
	JSDELIVR="[Mirror 1](https://cdn.jsdelivr.net/gh/rtsfred3/Adlists@main/$FILE)"
	STATICALLY="[Mirror 2](https://cdn.statically.io/gh/rtsfred3/Adlists/main/$FILE)"
	STATICALLYGITLAB="[Mirror 3](https://cdn.statically.io/gl/rtsfred3/Adlists/main/$FILE)"

	echo "| $SHORT_FILE | $GH $GL $JSDELIVR $STATICALLY | $(date -r $FILE "+%Y-%m-%d %H:%M:%S") |" >> CDNs.md
}

echo "| File | Link | Last Modified |
| :------- | :------: | :------: |" >> CDNs.md
for FILE in $(find abp -type f -name '*.txt' | sort -u); do
    processFile $FILE
done

echo "" >> CDNs.md

echo "**Compressed Adlists**" >> CDNs.md

echo "| File | Link | Last Modified |
| :------- | :------: | :------: |" >> CDNs.md
for FILE in $(find abp -type f -name '*.txt.gz' | sort -u); do
    processFile $FILE
done
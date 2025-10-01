echo "**Adlists**" > CDNs.md

processFile() {
    SHORT_FILE=$(echo "$FILE" | cut -d "/" -f2)

	GH="[GH](https://raw.githubusercontent.com/rtsfred3/Adlists/main/$FILE)"
	GL="[GL](https://gitlab.com/rtsfred3/Adlists/-/raw/main/$FILE)"
	JSDELIVR="[JSDelivr](https://cdn.jsdelivr.net/gh/rtsfred3/Adlists@main/$FILE)"
	STATICALLY="[Statically (GitHub)](https://cdn.statically.io/gh/rtsfred3/Adlists/main/$FILE)"
	STATICALLYGITLAB="[Statically (GitLab)](https://cdn.statically.io/gl/rtsfred3/Adlists/main/$FILE)"

	echo "| $SHORT_FILE | $GH $GL $JSDELIVR $STATICALLY $STATICALLYGITLAB | $(date -r $FILE "+%Y-%m-%d %H:%M:%S") |" >> CDNs.md
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
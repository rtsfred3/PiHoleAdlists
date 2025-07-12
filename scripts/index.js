const fs = require('node:fs');
const Adlist = require('./Adlist.js');

async function fetchAdlist(url) {
    const response = await fetch(url);

    if (!response.ok) {
        throw new Error(`Response status: ${response.status}`);
    }

    return (await response.text()).split("\n").filter((e) => !e.startsWith("!")).filter((e) => !e.startsWith("#"));
}

async function fetchAdlistUrl(url) {
    const response = await fetch(url);

    if (!response.ok) {
        throw new Error(`Response status: ${response.status}`);
    }

    const text = await response.text();

    const adlistLines = new Adlist(text);

    return adlistLines.AdguardPro;
}

async function generateCombinedAdlistFromUrls(urlList) {
    const currDate = new Date(Date.now());

    var initialLines = ['[Adblock Plus]', `! Generated at ${currDate.toISOString()}`, '! Sources:'];
    var urlLines = [];

    for (let address of urlList) {
        initialLines.push(`! ${address}`);
    }

    initialLines = initialLines.concat(Array(3).fill('!', 0, 3));

    for (let address of urlList) {
        var tempArr = await fetchAdlistUrl(address);
        urlLines = urlLines.concat(tempArr);
    }

    urlLines = urlLines.sort();
    urlLines = [...new Set(urlLines)];
    urlLines = urlLines.sort();

    var lines = initialLines.concat(urlLines);
    return lines.join('\n');
}

async function generateBlocklistFromEnabledGravityAdlists(url, fileName) {
    var defaultAddresses = await fetchAdlist(url);

    const body = await generateCombinedAdlistFromUrls(defaultAddresses);

    try{
        fs.writeFileSync(`adlist/${fileName}`, body);
    } catch (err) {
        console.error(err);
    }
}

async function uploadToGist(token, filesList) {
    var updatedGist = {
        "description": "A combined Adblock list from Pi-Hole",
        "files": {}
    }

    // const fsOut = fs.readFileSync(`adlist/${filesList[0]}`, { encoding: 'utf8', flag: 'r' });
    // updatedGist['files'][filesList[0].replace('.txt', '')] = { "content": fsOut };

    for (let fileName of filesList) {
        const fsOut = fs.readFileSync(`adlist/${fileName}`, { encoding: 'utf8', flag: 'r' });

        updatedGist['files'][fileName.replace('.txt', '')] = { "content": fsOut };
    }

    var options = {
        method: "PATCH",
        headers: {
            'Accept': 'application/vnd.github+json',
            'X-GitHub-Api-Version': '2022-11-28',
            'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(updatedGist)
    };

    const response = await fetch('https://api.github.com/gists/9e99f7549cbcf0e00b745f2315657d53', options);

    console.log(response);

    if (response.status) {
        console.log(await response.json())
    }
}

generateBlocklistFromEnabledGravityAdlists("https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/adlist", "adblock.txt");
generateBlocklistFromEnabledGravityAdlists("https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/advertising", "advertising.txt");
generateBlocklistFromEnabledGravityAdlists("https://gist.githubusercontent.com/rtsfred3/8553b13be1263ccd5c296f5eb512e6e9/raw/hagezi.native.adlist", "hagezi.native.adblock.txt");

// uploadToGist('token', ['adblock.txt', 'advertising.txt', 'hagezi.native.adblock.txt']);
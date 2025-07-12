module.exports = class Adlist {
    get raw_lines() {
        return this.text.split("\n").filter((e) => e.length > 0).map((e) => e.trim());
    }

    get isAdblockPro() {
        return this.raw_lines.length > 0 && this.raw_lines[0] == '[Adblock Plus]';
    }

    get linesNoComments() {
        return this.raw_lines.filter((e) => !['!', '#'].includes(e.substring(0, 1)))
    }

    get AdguardPro() {
        var adguardLines = this.linesNoComments.map((line) => line.includes(' ') ? line.split(' ')[1] : line);
        adguardLines = adguardLines.filter((e) => e.includes('.') && e != 'localhost.localdomain' && e != '0.0.0.0');

        if (!this.isAdblockPro) {
            adguardLines = adguardLines.map((line) => {
                if (!line.startsWith('||')) {
                    line = `||${line}`;
                }
                if (!line.endsWith('^')) {
                    line = `${line}^`;
                }
                return line;
            });
        }

        return adguardLines;
    }

    get Lines() {
        return this.AdguardPro.length;
    }

    constructor(text) {
        this.text = text;
    }

    toText() {
        return '[Adblock Plus]\n' + this.AdguardPro.join('\n');
    }
}
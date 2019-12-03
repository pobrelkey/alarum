# Alarum

A streaming-audio white noise generator and alarm clock for your Android phone, written in bash.

### What?!

For my 800km hike on the [Camino Francés](https://en.m.wikipedia.org/wiki/French_Way) (great fun, you should go), I needed a headphones-only alarm clock for staying in hostels - one which plays white noise over the headphones all night to block out ~~snorers~~ ambient noise, then sounds the alarm over headphones only so as not to wake other ~~snorers~~ guests.  I couldn't find any libre Android apps which would do this, so I lashed together this minimal, Unix-y solution over a lazy evening or two.

This script runs under [Termux](https://termux.com/), and exposes a web server on localhost port 3999, serving up a very simple (HTML 3.2) UI.  You use this to launch [VLC](https://www.videolan.org/vlc/download-android.html) to play a stream of white noise until your desired wake time, at which point it fades into the internet radio station of your choice (or failing that, an alarm tone).

### Disclaimer/Warning

**This script is almost certainly not for you if you don't understand shell scripting and/or wouldn't already have Termux installed on your phone anyway.**

I wrote it as a minimal viable solution solely to meet my own needs; little effort was made to present a polished user interface or configuration experience.  As I don't have any need to add features for myself, and won't be maintaining or supporting this script for other users, you are heartily encouraged to fork and customize this script to add your own customizations.

### Installation/Usage

You'll first need to install the VLC and Termux apps, and the [`sox`](http://sox.sourceforge.net/) and [`pv`](https://www.ivarch.com/programs/pv.shtml) Termux packages (in Termux run: `pkg install sox pv`).

Download the script to somehere on your phone you can easily run it from a Termux prompt, make it executable (`chmod +x alarum.sh`), then run it and point your web browser to: `http://127.0.0.1:3999/`  The UI should be self-explanatory: input a wake-up time as four digits, optionally separating hour and minute with a colon; select a radio station to wake up to, if any; and submit the form, whence the server will return a playlist file which should launch VLC.  (VLC will then make a separate HTTP request to the server to get the actual audio stream.)

### Caveats

The path to the alarm tone is valid on my phone (on [LineageOS](https://www.lineageos.org/) 15), and may or may not be valid on yours - or you may want to wake up to a different alarm tone than the default.  In either case, you'll need to edit the script as appropriate.

The list of available radio stations represents my own personal preferences.  Feel free to edit the script to add your own favorites; note that your intended radio station(s) will need to support plain (Icecast-style) HTTP streaming.

Finally: you'll need Internet connectivity to use this script, even if you don't elect to stream a radio station at wake time, as Android switches off the networking stack entirely (even for loopback) if you have no mobile data signal and no wifi.  Blame Google for this ~~braindead nonsense~~ feature, not me.

### License

This script comes to you with NO WARRANTY under the [MIT License](LICENSE).

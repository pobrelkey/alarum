# Alarum

A streaming-audio white noise generator and alarm clock for your Android phone, written in bash.

### What?!

For my 800km hike on the [Camino Francés](https://en.wikipedia.org/wiki/French_Way) (a great experience, you should go), I needed a headphones-only alarm clock for staying in hostels - one which plays white noise over the headphones all night to block out ~~snorers~~ ambient noise, then sounds the alarm over only the headphones and not the speaker so as not to wake other ~~snorers~~ guests.  I couldn't find any [libre](https://en.wikipedia.org/wiki/Libre_software) Android apps which would do this, so I lashed together this minimal, Unix-y solution over a lazy evening or two.

This bash script runs under [Termux](https://termux.com/), and implements a web server on localhost port 3999, serving up a very simple (HTML 3.2) UI.  You use this to launch [VLC](https://www.videolan.org/vlc/download-android.html) to play a stream of white noise which lasts until your desired wake time, at which point the white noise fades into the internet radio station of your choice (or failing that, an alarm tone).

### Disclaimer/Warning

**This script is almost certainly not for you if you don't understand shell scripting and/or wouldn't already have Termux installed on your phone anyway.**

I wrote it as a minimal viable solution solely to meet my own needs; little effort was made to present a polished user interface or configuration experience.  As I don't need to add features for myself, and won't be maintaining or supporting this script for other users, you are heartily encouraged to fork this script and customize it to your tastes.

### Installation/Usage

You'll first need to install the VLC and Termux apps, and the [`sox`](http://sox.sourceforge.net/) and [`pv`](https://www.ivarch.com/programs/pv.shtml) Termux packages (in Termux run: `pkg install sox pv`).

Download [the script](alarum.sh) to somehere on your phone you can easily run it from a Termux prompt, make it executable (`chmod +x alarum.sh`), then run it and point your web browser to: `http://127.0.0.1:3999/`  The UI should be self-explanatory: enter a wake-up time; select a radio station to wake up to, if any; and submit the form, whence the server will return a playlist file which should launch VLC.  (VLC will then make a separate HTTP request to the server to get the actual audio stream.)

### FAQ

##### Any bugs?

 * You'll need Internet connectivity to use this script, even if you don't elect to stream a radio station at wake time, as Android switches off the networking stack entirely (even for loopback) if you have no mobile data signal and no wifi.  Blame Google for this ~~braindead nonsense~~ feature, not me.
 * Verify that the path to the `ALARM_TONE` specified in the script is valid for your phone.  (It works for me on [LineageOS](https://www.lineageos.org/) 15; I can't guarantee that commercial ROMs will work.)  If it isn't, or if you'd prefer to have a different default alarm tone, edit the script as appropriate.

##### Why the limited choice of radio stations?

The list of available radio stations represents my own personal preferences.  Feel free to edit the script to add your own favorites; note that your intended radio station(s) will need to support plain (Icecast-style) HTTP streaming.

##### Why did you write it in bash?

Partly because it would be easiest to produce the audio stream by piping a bunch of Unix tools together in a complicated manner, which is ths sort of thing bash is good at.  Partly because I wanted something as lightweight as possible to run on my phone under Termux.  Mostly for fun though.

##### Any other tips?

I used [Plugfones](https://www.plugfones.com/) corded in-ear headphones with this script.  Before the Camino, they were my usual commuting headphones.  Compact, inexpensive and lightweight (13g a pair), they provide 27db of ambient noise reduction, and comfortably stay in your ears while you sleep - though audiophiles will probably grumble about the sound quality.  I considered these so critical to a good night's sleep - and thus my journey - that I carried a spare pair in the bottom of my pack in case my primary pair failed or went missing.  (Sure enough, I had to deploy the spare pair before my Camino was even half finished.)

### License

This script comes to you with NO WARRANTY under the [MIT License](LICENSE).

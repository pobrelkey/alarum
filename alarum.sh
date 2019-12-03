#!/usr/bin/env bash

#
# Alarum: a streaming-audio white noise generator and alarm clock
# https://github.com/pobrelkey/alarum
#
# Copyright (c) 2019 pobrelkey
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#


LISTEN_PORT=3999

if [ "${1}" != '--inetd' ]
then
	echo "Listening on port ${LISTEN_PORT}"
	exec busybox nc -ll -p ${LISTEN_PORT} -e "${0}" --inetd
fi

ALARM_TONE="$(dirname -- "${0}")/hassium.ogg"
if [ \! -e ${ALARM_TONE} ]
then
	ALARM_TONE=/system/media/audio/alarms/Hassium.ogg
fi

# read HTTP headers, ignore all but the URI
read METHOD URI VERSION
HEADER="not blank"
while [ "x${HEADER}" != 'x' ]
do
	read -t 0.1 HEADER
done

if [ "${METHOD}" != 'GET' ]
then
	echo -ne "HTTP/1.0 501 Unsupported Method\015\012"
	echo -ne "Content-type: text/html\015\012"
	echo -ne "Pragma: no-cache\015\012"
	echo -ne "Connection: close\015\012"
	echo -ne "\015\012"
	echo "<html><head><title>Unsupported method</title></head><body><h1>Unsupported method</h1></body></html>"
	exit 0
fi


case ${URI} in
	/playlist*)
		DELAY_MINS=10
		DELAY_SECS=$(( ${DELAY_MINS} * 60 ))
		TIME="$(sed -nr -e '/[?&]time=[0-9]/{s/^.*[?&]time=(([0-9]|%3[Aa])+).*$/\1/;s/%3[Aa]/:/;p;q}' <<<"${URI}")"
		STATION=$(sed -nr -e '/[?&]station=[0-9]/{s/^.*[?&]station=([0-9]+).*$/\1/;p;q}' <<<"${URI}")
		echo -ne "HTTP/1.0 200 OK\015\012"
		echo -ne "Content-type: audio/x-scpls\015\012"
		echo -ne "Pragma: no-cache\015\012"
		echo -ne "Connection: close\015\012"
		echo -ne "\015\012"
		cat <<-__PLAYLIST__
			[playlist]
			NumberOfEntries=15
			File1=/stream?time=${TIME}&station=${STATION}
			Title1=Alarm set for ${TIME}
			File2=/stream?delay=${DELAY_SECS}&station=${STATION}
			Title2=Snooze for ${DELAY_MINS} minutes
			File3=/stream?delay=${DELAY_SECS}&station=${STATION}&snooze=2
			Title3=Second snooze for ${DELAY_MINS} minutes
			File4=/stream?delay=${DELAY_SECS}&station=${STATION}&snooze=3
			Title4=Third snooze for ${DELAY_MINS} minutes
			File5=/stream?delay=${DELAY_SECS}&station=${STATION}&snooze=4
			Title5=Fourth snooze for ${DELAY_MINS} minutes
			File6=/stream?delay=${DELAY_SECS}&station=${STATION}&snooze=5
			Title6=Fifth snooze for ${DELAY_MINS} minutes
			File7=/stream?delay=0&station=${STATION}&snooze=6
			Title7=Oh just wake up already!
			File8=/stream?delay=0&station=${STATION}&snooze=7
			Title8=Oh just wake up already!
			File9=/stream?delay=0&station=${STATION}&snooze=8
			Title9=Oh just wake up already!
			File10=/stream?delay=0&station=${STATION}&snooze=9
			Title10=Oh just wake up already!
			File11=/stream?delay=0&station=${STATION}&snooze=10
			Title11=Oh just wake up already!
			File12=/stream?delay=0&station=${STATION}&snooze=11
			Title12=Oh just wake up already!
			File13=/stream?delay=0&station=${STATION}&snooze=12
			Title13=Oh just wake up already!
			File14=/stream?delay=0&station=${STATION}&snooze=13
			Title14=Oh just wake up already!
			File15=/stream?delay=0&station=${STATION}&snooze=14
			Title15=Oh just wake up already!
		__PLAYLIST__
		;;

	/stream*)
		DELAY=$(sed -nr -e '/[?&]delay=[0-9]/{s/^.*[?&]delay=([0-9]+).*$/\1/;p;q}' <<<"${URI}")
		if [ "x${DELAY}" == 'x' ] || [ "${DELAY}" -le 0 ] || [ "${DELAY}" -gt $(( 16 * 3600 )) ]
		then
			TIME4="$(sed -nr -e '/[?&]time=[0-9]/{s/^.*[?&]time=(([0-9]|:|%3[Aa])+).*$/\1/;s/(%3[Aa]|:)//;s/([0-9][0-9])$/  \1/;p;q}' <<<"${URI}")"
			if [ "x${TIME4}" != 'x' ]
			then
				MINUTES=${TIME4: -2:2}
				HOURS=" ${TIME4:0:2}"
				HOURS=${HOURS%[ ]}
				HOURS=${HOURS%[ ]}
				TIME="${HOURS:=6}:${MINUTES:=00}"
				DAYSECS=$(( ( "10#${HOURS#[ ]}" * 60 + "10#${MINUTES}" ) * 60 ))
				NOWSECS=$(( ( "10#$(date +%H)" * 60 + "10#$(date +%M)" ) * 60 + "10#$(date +%S)" ))
				DELAY=$(( (86400 + "${DAYSECS}" - "${NOWSECS}") % 86400 ))
			fi
		fi
		if [ "x${DELAY}" == 'x' ] || [ "${DELAY}" -le 0 ] || [ "${DELAY}" -gt $(( 16 * 3600 )) ]
		then
			DELAY=0
		fi
		
		STATION=$(sed -nr -e '/[?&]station=[0-9]/{s/^.*[?&]station=([0-9]+).*$/\1/;p;q}' <<<"${URI}")
		STATION_URL=''
		# BBC URLs from: http://www.suppertime.co.uk/blogmywiki/2015/04/updated-list-of-bbc-network-radio-urls/
		case "${STATION}" in 
			4)
				STATION_URL='http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio4fm_mf_p'
				;;
			5)
				STATION_URL='http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio5live_mf_p'
				;;
			6)
				STATION_URL='http://bbcmedia.ic.llnwd.net/stream/bbcmedia_6music_mf_p'
				;;
			8)
				STATION_URL='http://netcast.kfjc.org:80/'
				;;
			0)
				STATION_URL='http://bbcwssc.ic.llnwd.net/stream/bbcwssc_mp1_ws-einws'
				#STATION_URL='http://bbcwssc.ic.llnwd.net/stream/bbcwssc_mp1_ws-eieuk'
				;;
		esac
		
		echo -ne "HTTP/1.0 200 OK\015\012"
		echo -ne "Content-type: audio/flac\015\012"
		echo -ne "Pragma: no-cache\015\012"
		echo -ne "Connection: close\015\012"
		echo -ne "\015\012"
		
		SENSIBLE_RAW="-t raw -r 44100 -e signed -b 16 -c 2"

		if [ "${DELAY}" -lt 15 ]
		then
			DELAY=15
		fi

		(
			# what will we want to play for the last 15 seconds of the delay?
			if [ "${DELAY}" -gt 15 ]
			then
				# if long delay, we'll be fading up from conditioned brown noise
				DELAY_SYNTH_ARGS="brownnoise highpass 100"

				# Now play the "long bit" of the delay (what we sleep to)...
				# Note that we rate-limit this to "real time" so that VLC doesn't
				# buffer hours of the radio stream opened in the next step.
				(
					# start with one second of sine tone as a stream-start indicator
					sox -q -n ${SENSIBLE_RAW} - synth 1 sine "$(date +%Y)" vol -15 dB
					# ...then spew brown noise
					sox -q -n ${SENSIBLE_RAW} - synth $(( ${DELAY} - 15 )) ${DELAY_SYNTH_ARGS}
				) | pv --quiet --rate-limit $(( 44100 * 4 ))
			else
				# if less than 15 seconds delay, just play the sine tone
				DELAY_SYNTH_ARGS="sine $(date +%Y) vol -15 dB"
			fi

			# play the last 15 seconds of the delay, fading into the alarm tone/radio		
			sox -q \
				${SENSIBLE_RAW} <(sox -q -n ${SENSIBLE_RAW} - synth 15 ${DELAY_SYNTH_ARGS}) \
				${SENSIBLE_RAW} <(
					# pipe the radio stream if relevant
					if [ "x${STATION_URL}" != 'x' ]
					then
						busybox wget -q -O - "${STATION_URL}" | sox -q -t mp3 - ${SENSIBLE_RAW} - rate 44100 channels 2
					fi
					# once stream ends/fails, or if no stream, play alarm tone
					sox -q "${ALARM_TONE}" ${SENSIBLE_RAW} - rate 44100 channels 2 repeat 999
				) \
				${SENSIBLE_RAW} - splice -q 15,3
		) | sox -q ${SENSIBLE_RAW} - -t flac -C 0 - rate 44100 channels 2
		;;

	*)
		echo -ne "HTTP/1.0 200 OK\015\012"
		echo -ne "Content-type: text/html\015\012"
		echo -ne "Pragma: no-cache\015\012"
		echo -ne "Connection: close\015\012"
		echo -ne "\015\012"
		cat <<-__INDEX_PAGE__
			<html><head>
			<title>Fancy alarm clock</title>
			</head></body>
			<form action="/playlist" method="GET">
				<h1>Fancy alarm clock</h1>
				<p>
					Sleep until (HH:MM): <input type="text" name="time" size="5" />
				</p>
				<p>
					Wake to radio?
					<select name="station">
						<option value=""  selected="selected" />No</option>
						<option value="0" />BBC World Service</option>
						<option value="4" />BBC Radio 4</option>
						<option value="5" />BBC Radio 5 Live</option>
						<option value="6" />BBC Radio 6 Music</option>
						<option value="8" />KFJC</option>
					</select>
				</p>
				<p>
					<input type="submit" value="Nighty night!" />
				</p>
			</form>
			</body></html>
		__INDEX_PAGE__
		;;
esac


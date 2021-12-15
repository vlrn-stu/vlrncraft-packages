#!/bin/sh
VOLUME_ICONS=("" "")
MUTED_ICON=""
MUTED_COLOR="%{F#6b6b6b}"
VOLUME=2

update_sink() {
    sink=$(pw-play --list-targets | sed -n 's/^*[[:space:]]*\([[:digit:]]\+\):.*$/\1/p')
}

volume_up() {
    update_sink
    pactl set-sink-volume "$sink" +"$VOLUME"%
}

volume_down() {
    update_sink
    pactl set-sink-volume "$sink" -"$VOLUME"%
}

volume_mute() {
    update_sink
    pactl set-sink-mute "$sink" toggle
}

volume_print() {
    VOLUME=$(pactl list sinks | sed -n "/Sink #${sink}/,/Volume/ s!^[[:space:]]\+Volume:.* \([[:digit:]]\+\)%.*!\1!p" | head -n1)
    IS_MUTED=$(pactl list sinks | sed -n "/Sink #${DEFAULT_SINK_ID}/,/Mute/ s/Mute: \(yes\)/\1/p")
	VOLUME="$((VOLUME-25))"
    if [ "${IS_MUTED}" != "" ]; then
        echo "${MUTED_COLOR}${MUTED_ICON} MUTE"
    else
        if [ "${VOLUME}" -le '40' ]; then
            printf '%s ' "${VOLUME_ICONS[0]}"
        elif [ "${VOLUME}" -gt '40' ]; then
            printf '%s ' "${VOLUME_ICONS[1]}"
        fi

        echo "${VOLUME}% ${DEFAULT_SINK}"
    fi

}


listen() {
	 volume_print

    pactl subscribe | while read -r event; do
        if echo "$event" | grep -qv "Client"; then
            volume_print
            sleep .2
        fi
    done
}


case "$1" in
    --up)
        volume_up
        ;;
    --down)
        volume_down
        ;;
    --mute)
        volume_mute
        ;;
    *)
        listen
        ;;
esac

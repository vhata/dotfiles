#!/bin/bash

#yabai -m query --windows | jq -r '.[] | "YABAI_WIN\(.app | gsub(" "; "_"))=\(.id)"'
get_windows() {
    yabai -m query --windows | jq -r 'group_by(.app) | map(to_entries[] | "YABAI_WIN\(.value.app | gsub("\u200e"; "") | gsub("[ .-]"; "_"))_\(.key)=\(.value.id)") | .[]'
}

movewin() {
    local _winpref="YABAI_WIN${1}"
    local _winvar
    compgen -v "$_winpref" | while read _winvar ; do
        local _winid="${!_winvar}"
        if [ -n "$_winid" ] ; then
            yabai -m window "$_winid" --space "$2" || echo "Error: $1"
        fi
    done
}

gridwin() {
    local _winpref="YABAI_WIN${1}"
    local _winvar
    compgen -v "$_winpref" | while read _winvar ; do
        local _winid="${!_winvar}"
        if [ -n "$_winid" ] ; then
            yabai -m window "$_winid" --grid "$2" || echo "Error: $1"
        fi
    done
}

focuswin() {
    local _winpref="YABAI_WIN${1}"
    local _winvar
    compgen -v "$_winpref" | while read _winvar ; do
        local _winid="${!_winvar}"
        if [ -n "$_winid" ] ; then
            yabai -m window --focus "$_winid"
        fi
    done
}

embiggenwin() {
    local _winpref="YABAI_WIN${1}"
    local _winvar
    compgen -v "$_winpref" | while read _winvar ; do
        local _winid="${!_winvar}"
        if [ -n "$_winid" ] ; then
            yabai -m window "$_winid" --space 6
            sleep 0.5
            yabai -m window "$_winid" --grid "8:6:1:1:4:6"
            yabai -m window --focus "$_winid"
        fi
    done
}

#!/usr/bin/env bash
set -euo pipefail

target="__HOME__/.local/share/sounds/PurpleOps/stereo"
mkdir -p "$target"

render() {
  local name="$1"
  local duration="$2"
  local fade_start="$3"
  local expression="$4"

  ffmpeg -y -hide_banner -loglevel error \
    -f lavfi -i "aevalsrc=${expression}:s=48000:d=${duration}" \
    -af "highpass=f=80,lowpass=f=5000,volume=18dB,afade=t=in:st=0:d=0.012,afade=t=out:st=${fade_start}:d=0.08,aformat=channel_layouts=stereo" \
    -c:a libvorbis -q:a 4 \
    "$target/$name.oga"
}

# Calm ascending identity: present, but short enough not to slow the session.
render desktop-login 0.68 0.58 \
  "0.045*sin(2*PI*392*t)*between(t\\,0.00\\,0.24)+0.040*sin(2*PI*523.25*t)*between(t\\,0.13\\,0.43)+0.036*sin(2*PI*659.25*t)*between(t\\,0.30\\,0.65)"
cp "$target/desktop-login.oga" "$target/system-ready.oga"

# Information and completion cues use the brighter lavender register.
render message 0.32 0.22 \
  "0.045*sin(2*PI*740*t)*between(t\\,0.00\\,0.13)+0.038*sin(2*PI*987.77*t)*between(t\\,0.10\\,0.29)"
cp "$target/message.oga" "$target/message-new-instant.oga"

render complete 0.48 0.38 \
  "0.040*sin(2*PI*523.25*t)*between(t\\,0.00\\,0.13)+0.038*sin(2*PI*659.25*t)*between(t\\,0.11\\,0.27)+0.034*sin(2*PI*783.99*t)*between(t\\,0.24\\,0.45)"

# Warning and error cues are lower and deliberately non-alarming.
render dialog-warning 0.38 0.28 \
  "0.045*sin(2*PI*392*t)*between(t\\,0.00\\,0.17)+0.038*sin(2*PI*466.16*t)*between(t\\,0.15\\,0.35)"

render dialog-error 0.42 0.32 \
  "0.050*sin(2*PI*220*t)*between(t\\,0.00\\,0.20)+0.042*sin(2*PI*174.61*t)*between(t\\,0.18\\,0.39)"

# Device cues mirror one another so direction is immediately recognizable.
render device-added 0.32 0.22 \
  "0.040*sin(2*PI*440*t)*between(t\\,0.00\\,0.14)+0.036*sin(2*PI*659.25*t)*between(t\\,0.12\\,0.29)"

render device-removed 0.32 0.22 \
  "0.038*sin(2*PI*659.25*t)*between(t\\,0.00\\,0.14)+0.040*sin(2*PI*440*t)*between(t\\,0.12\\,0.29)"

cp "$target/device-added.oga" "$target/power-plug.oga"
cp "$target/device-removed.oga" "$target/power-unplug.oga"

# The volume cue is intentionally tiny because it repeats.
render audio-volume-change 0.10 0.035 \
  "0.026*sin(2*PI*640*t)*between(t\\,0.00\\,0.08)"

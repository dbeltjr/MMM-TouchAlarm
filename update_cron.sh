#!/bin/bash

# Specify the path to jq
jqPath="/usr/bin/jq"

# Check if jq is installed
if [ ! -x "$jqPath" ]; then
  echo "Error: jq is not installed at $jqPath. Please install jq before running this script."
  exit 1
fi

# Read the time from the JSON file
newHour=$("$jqPath" -r '.hour' /home/dietpi/MagicMirror/modules/MMM-TouchAlarm/alarm.json)
newMinutes=$("$jqPath" -r '.minutes' /home/dietpi/MagicMirror/modules/MMM-TouchAlarm/alarm.json)

echo "New hour: $newHour"
echo "New minutes: $newMinutes"

# Construct the new cron entry
cron_entry="$newMinutes $newHour * * * /usr/bin/sudo sh -c 'echo \"255\" > /sys/class/backlight/rpi_backlight/brightness'"

echo "New cron entry: $cron_entry"

# Create a temporary file
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Use awk to update the crontab content
(crontab -l | awk '/# This is my special cron job/ {print $0; print "'"$cron_entry"'"; found=1; next} found && /^[[:digit:]]/ {next} 1') > "$temp_file"

# Install the new crontab
crontab "$temp_file"

echo "Cron job updated."

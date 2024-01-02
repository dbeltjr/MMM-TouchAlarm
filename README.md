# Touchable Alarm Clock Module for MagicMirror<sup>2</sup>

### Includes Instructions at the Bottcom for Integrating Screen Brightness That Matches Alarm Time

## Dependencies

* An installation of [MagicMirror<sup>2</sup>](https://github.com/MichMich/MagicMirror)

## Installation

1. Navigate to the MagicMirror/modules directory.
1. Execute `git clone https://github.com/dbeltjr/MMM-TouchAlarm.git`
1. Configure the module as per below
1. Restart MagicMirror

    ```
    {
        module: 'MMM-TouchAlarm',
        position: 'bottom_left',
        config: {
            snoozeMinutes: 10, // I want to snooze longer
            alarmTimeoutMinutes: 5, // Stop the alarm automatically after 5 minutes
            alarmSoundFile: 'blackforest.mp3', // Play some birds
            alarmSoundFadeSeconds: 60 // Increase the volume slowly
            // ...
        }
    }
    ```

## (Currently) Known limitations

* If you hit snooze, the alarm time will be updated. So the next day you have to reset the alarm and reduce it by the snoozed time.

* If you close an alarm it will not be automatically reset for the next day, you'll have to click the bell again.


## Config Options

| **Option** | **Default** | **Description** |
| ---                     | --- | --- |
| `minutesStepSize`       | `5` | Increasing/Decreasing the minutes in the configuration screen with this step size. |
| `snoozeMinutes`         | `5` | Alarm will be fired again in x minutes after snoozing. |
| `alarmTimeoutMinutes`   | `5` | Stop the alarm automatically after this amount of minutes. |
| ---                     | --- | --- |
| `alarmSound`            | `true` | Should an alarm sound be played. |
| `alarmSoundFile`        | `'alarm.mp3'` | Name and extension of your alarm sound. File needs to be placed in `~/MagicMirror/modules/MMM-TouchAlarm/sounds`. Standard files are `alarm.mp3` and `blackforest.mp3`.  Alternatively specify a web stream `http` or `https`. |
| `alarmSoundMaxVolume`   | `1.0` | The maximum volume of alarm (between 0.0 and 1.0). |
| `alarmSoundFade`        | `true` | Should the alarm sound file be faded. |
| `alarmSoundFadeSeconds` | `30` | Within how many seconds should the alarm reach the configured `alarmSoundMaxVolume`. |
|                         | | |
| **Expert Options**      | | |
| `debug`                 | `false` | If set to `true` it will show some debug information in the console. |
| `alarmStoreFileName`    | `alarm.json` | File name to store information even if the Magic Mirror restarts. |

## Alarm Sounds

There are already two alarm sounds:

* [alarm.mp3](http://www.orangefreesounds.com/mp3-alarm-clock/) | From Alexander licensed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)
* [blackforest.mp3](http://www.orangefreesounds.com/coo-coo-clock-sound/) | From Alexander licensed under [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)

### Outgoing

* `MMM-TouchAlarm-ALARM-CHANGED` -> will send `hour`: number, `minutes`: number, `active`: boolean, `nextAlarm`: moment-timestamp
* `MMM-TouchAlarm-ALARM-FIRED`   -> will send `hour`: number, `minutes`: number
* `MMM-TouchAlarm-ALARM-SNOOZE`  -> will send `hour`: number, `minutes`: number

# Integration with Adjusting Screen Brightness with Alarm Time

**Caveat - This was created for a Raspberry Pi 3B+ with the official 7" Touch Screen and may need to be adjusted for any other particular application**

## Dependencies

1. Go to home directory `cd ~`
1. Install jq `sudo apt-get install jq`

## Setup Cron with Script

1. Move `update_cron.sh` to your home directory
1. Edit script to put in proper file paths `sudo nano update_cron.sh`
1. Modify these two lines for proper file path to alarm.json:
	```
	newHour=$("$jqPath" -r '.hour' /home/dietpi/MagicMirror/modules/MMM-TouchAlarm/alarm.json)
	newMinutes=$("$jqPath" -r '.minutes' /home/dietpi/MagicMirror/modules/MMM-TouchAlarm/alarm.json)
	```
1. If a different command needs to be used in cron to adjust screen brightness, it must be edited in the script as well under:
	```
	# Construct the new cron entry
	cron_entry="$newMinutes $newHour * * * /usr/bin/sudo sh -c 'echo \"255\" > /sys/class/backlight/rpi_backlight/brightness'"
	```
1. Save and Exit
1. Execute `sudo chmod +x update_cron.sh` to ensure script has execute permission
1. Edit Cron under root user `sudo crontab -e`

1. Add the following at the end of crontab:
	```
	30 21 * * * /usr/bin/sudo sh -c 'echo 10 > /sys/class/backlight/rpi_backlight/brightness'
	*/10 * * * * /home/dietpi/update_cron.sh

	# This is my special cron job
	0 6 * * * /usr/bin/sudo sh -c 'echo 255 > /sys/class/backlight/rpi_backlight/brightness'
	```
	This reduces the screen brightness to "10" at 9:30 PM and then runs the update_cron.sh every 10 minutes. It copies the hour and minutes from alarm.json and updates the cron task after the phrase "# This is my special cron job"
	Anything edited below "# This is my special cron job" will be deleted and re-added each time the alarm is changed.
1. Save and Exit crontab
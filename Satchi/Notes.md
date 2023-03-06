#  General notes about the development

To reset the locationManager authorization for the running simulators: xcrun simctl privacy booted reset all

## TODO:

- Do not remove a track for user when the user stops sharing the track. Only the shareing should stop
- Add logging. Apple Logger spews out either too much or nothing depending on env variables. Not usable at the moment



- Maybe scrap the MapView and use this: https://github.com/pauljohanneskraft/Map?ref=iosexample.com

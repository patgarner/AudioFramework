# AudioFramework
AudioFramework

This framework creates enables users to add a full fledged audio mixing board to their project which has the ability to load virtual instruments as well as third party effects plugins.

How to install:
After downloading the project, open in Xcode.

Simultaneously open your Xcode project, the one which you would like to add the AudioFramework to.

With both projects open, go to the Products folder at the bottom far left pane of Xcode.

Drag the AudioFramework.framework into your Xcode project under "Frameworks"

Now in your project (not AudioFramework) under Targets, select your main target.

Under General->Frameworks, Libraries, and Embedded Content you should see AudioFramework.framwork. If you don't redo steps above.

Select "Embed and sign"

Now create a view controller in your project in the storyboard or nib editor.

Set the class type of this view controller to "MixerViewController4"

Now run your project and the Mixer should appear.

Load virtual instruments and plugins by clicking the empty cells on the mixer.

To send midi data, call the various functions availabe on AudioService.shared such as:

    noteOn(_ note: UInt8, withVelocity velocity: UInt8, channel: UInt8) {
    noteOff(_ note: UInt8, channel: UInt8) {
    set(volume: UInt8, channel: UInt8){
    set(pan: UInt8, channel: UInt8){
    set(tempo: UInt8){
    setController(number: UInt8, value: UInt8, channel: UInt8)

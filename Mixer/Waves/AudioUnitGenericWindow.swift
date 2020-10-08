import AVFoundation
import Cocoa

class AudioUnitGenericWindow: NSWindowController {
    @IBOutlet var scrollView: NSScrollView!
    public let toolbar = AudioUnitToolbarController(nibName: "AudioUnitToolbarController", bundle: Bundle.main)

    private var audioUnit: AVAudioUnit?

    convenience init(audioUnit: AVAudioUnit) {
        self.init(windowNibName: "AudioUnitGenericWindow")
        contentViewController?.view.wantsLayer = true
        self.audioUnit = audioUnit
        toolbar.audioUnit = audioUnit
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        window?.addTitlebarAccessoryViewController(toolbar)
    }
}

class AudioUnitToolbarController: NSTitlebarAccessoryViewController {
    @IBOutlet var bypassButton: NSButton!

    public var audioUnit: AVAudioUnit?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction func handleBypass(_ sender: NSButton) {
        guard let audioUnit = audioUnit else { return }

        let buttonState = bypassButton.state == .on

        audioUnit.auAudioUnit.shouldBypassEffect = buttonState
    }
}

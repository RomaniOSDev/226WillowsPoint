import AudioToolbox

enum SoundManager {
    static func playSuccess() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playFail() {
        AudioServicesPlaySystemSound(1521)
    }
}

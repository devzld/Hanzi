import Foundation
import AVFoundation

/// 中文语音朗读服务（系统 TTS）
final class SpeechService: NSObject, ObservableObject {

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    /// 朗读文本（逐字朗读时调用方逐个传入即可）
    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        synthesizer.stopSpeaking(at: .immediate)

        let rate = Float(UserDefaults.standard.object(forKey: "speechRate") as? Float ?? 0.45)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        utterance.rate = rate
        utterance.pitchMultiplier = 1.0
        utterance.postUtteranceDelay = 0.15
        synthesizer.speak(utterance)
    }

    /// 依次朗读多个字/词
    func speakAll(_ items: [String]) {
        guard !items.isEmpty else { return }
        synthesizer.stopSpeaking(at: .immediate)

        let rate = Float(UserDefaults.standard.object(forKey: "speechRate") as? Float ?? 0.45)
        for item in items {
            let utterance = AVSpeechUtterance(string: item)
            utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
            utterance.rate = rate
            utterance.postUtteranceDelay = 0.5
            synthesizer.speak(utterance) // 自动排队依次朗读
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // 预留：朗读完成回调（如自动跳到下一字）
    }
}

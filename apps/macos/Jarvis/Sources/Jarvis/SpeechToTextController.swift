import Foundation
import Speech
import AVFoundation

/// Placeholder STT implementation.
/// IMPORTANT: Apple Speech may require network depending on device/settings.
/// For guaranteed offline for all users, replace with whisper.cpp integration.
final class SpeechToTextController {
    private let recognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()

    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    func start(completion: @escaping (Result<String, Error>) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else {
                completion(.failure(NSError(domain: "JarvisSTT", code: 1, userInfo: [NSLocalizedDescriptionKey: "Speech permission not granted"])) )
                return
            }

            DispatchQueue.main.async {
                self.startInternal(completion: completion)
            }
        }
    }

    private func startInternal(completion: @escaping (Result<String, Error>) -> Void) {
        stop()

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record, mode: .measurement, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            completion(.failure(error))
            return
        }

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = false
        self.request = req

        let input = audioEngine.inputNode
        let format = input.outputFormat(forBus: 0)
        input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            req.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            completion(.failure(error))
            return
        }

        task = recognizer?.recognitionTask(with: req) { result, error in
            if let error {
                completion(.failure(error))
                self.stop()
                return
            }
            if let result, result.isFinal {
                completion(.success(result.bestTranscription.formattedString))
                self.stop()
            }
        }

        // Auto-stop after a short window (push-to-talk behavior). Adjust as desired.
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            if self.audioEngine.isRunning {
                self.stop()
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil

        request?.endAudio()
        request = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

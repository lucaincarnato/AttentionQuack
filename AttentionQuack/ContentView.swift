//
//  ContentView.swift
//  AttentionQuack
//
//  Created by Luca Maria Incarnato on 11/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @AppStorage("AudioFile") var audioFile: URL?
    @State private var isPickerPresented = false
    var player: AudioPlayer = AudioPlayer()
    
    var body: some View {
        VStack {
            Button() {
                if audioFile == nil {
                    isPickerPresented.toggle()
                    // View to add from File app
                } else {
                    player.playSound(from: audioFile!)
                }
            } label: {
                Image(systemName: audioFile == nil ? "plus" : "play.fill")
                    .frame(width: 150, height: 150)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5).onEnded() { _ in
                    audioFile = nil
                }
            )
            .sheet(isPresented: $isPickerPresented) {
                        AudioFilePicker { url in
                            audioFile = url
                        }
                    }
        }
        .padding()
    }
}

struct AudioFilePicker: UIViewControllerRepresentable {
    var onPicked: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.audio], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPicked: (URL) -> Void

        init(onPicked: @escaping (URL) -> Void) {
            self.onPicked = onPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPicked(url)
        }
    }
}

#Preview {
    ContentView()
}

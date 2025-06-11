//
//  ContentView.swift
//  AttentionQuack
//
//  Created by Luca Maria Incarnato on 11/06/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @AppStorage("FirstLaunch") var firstLaunch: Bool = true
    @AppStorage("AudioFile") var audioFile: URL?
    @State private var isPickerPresented = false
    @State private var longPressed = false
    @State private var successFeedback: Bool = false
    @State private var errorFeedback: Bool = false
    var player: AudioPlayer = AudioPlayer()
    
    private var width = UIScreen.main.bounds.width
    private var height = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack{
            if (firstLaunch && audioFile != nil){
                Image("OnboardingImage")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                Text("Hold it")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.accent)
                    .offset(x: 0, y: -300)
            }
            VStack {
                Button() {
                    if longPressed {
                        longPressed = false
                        return
                    }
                    if audioFile == nil {
                        isPickerPresented.toggle()
                        // View to add from File app
                    } else {
                        successFeedback.toggle()
                        player.playSound(from: audioFile!)
                    }
                } label: {
                    Image(audioFile == nil ? "addButton" : "button")
                        .frame(width: 150, height: 150)
                }
                .sensoryFeedback(.success, trigger: successFeedback)
                .sensoryFeedback(.error, trigger: errorFeedback)
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 0.5, maximumDistance: 3).onEnded() { _ in
                        audioFile = nil
                        longPressed = true
                        firstLaunch = false
                        errorFeedback.toggle()
                        player.stopSound()
                    }
                )
                .simultaneousGesture(
                    LongPressGesture(minimumDuration: 3.1).onEnded() { _ in
                        audioFile = nil
                        longPressed = true
                        firstLaunch = false
                        player.stopSound()
                        player.playSound("quack")
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

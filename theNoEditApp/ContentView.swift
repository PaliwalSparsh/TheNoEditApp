import SwiftUI
import AppKit

struct ContentView: View {
    @State private var images = [NSImage]()
    @State private var imageIDs = [NSImage: UUID]()
    @State private var selectedImages = Set<UUID>()
    @State private var gridSize: CGFloat = 100
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize))]) {
                    ForEach(images, id: \.self) { image in
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: gridSize, height: gridSize)
                            .onTapGesture {
                                if let id = imageIDs[image] {
                                    if selectedImages.contains(id) {
                                        selectedImages.remove(id)
                                    } else {
                                        selectedImages.insert(id)
                                    }
                                }
                            }
                            .border(selectedImages.contains(imageIDs[image]!) ? Color.blue : Color.clear)
                    }
                }
            }
            
            HStack(spacing: 20) {
                Button("Import Images") {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseDirectories = true
                    panel.begin { response in
                        if response == NSApplication.ModalResponse.OK {
                            for url in panel.urls {
                                if let image = NSImage(contentsOf: url) {
                                    images.append(image)
                                    imageIDs[image] = UUID()
                                }
                            }
                        }
                    }
                }
                
                Slider(value: $gridSize, in: CGFloat(100)...CGFloat(600), label: {
                    Text("Size")
                }).frame(maxWidth: 400)

            }.padding()
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

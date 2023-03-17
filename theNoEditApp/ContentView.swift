import SwiftUI
import AppKit

struct ContentView: View {
    @State private var images = [NSImage]()
    @State private var imageIDs = [NSImage: UUID]()
    @State private var selectedImages = Set<UUID>()
    @State private var gridSize: CGFloat = 100
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Slider(value: $gridSize, in: CGFloat(50)...CGFloat(600)) {
                        EmptyView()
                    } minimumValueLabel: {
                        Image(systemName: "minus")
                    } maximumValueLabel: {
                        Image(systemName: "plus")
                    }
                    .frame(maxWidth: 160)

                    Spacer()
                    
                    Button(action: {
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
                    }) {
                        Text("Import Images")
                        .frame(maxWidth: 160)
                    }

                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(.thinMaterial)
                Divider()
            }

            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize))], spacing: 0) {
                    ForEach(images, id: \.self) { image in
                        ZStack {
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
                            //MARK: Add overlay checkbox here to show if the item is selected or not.
                        }
                    }
                }
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

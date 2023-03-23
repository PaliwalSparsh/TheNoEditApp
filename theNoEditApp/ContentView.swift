import SwiftUI
import AppKit

struct ContentView: View {
    @State private var images = [NSImage]()
    @State private var imageIDs = [NSImage: UUID]()
    @State private var selectedImages = Set<UUID>()
    @State private var gridSize: CGFloat = 100
    @State private var maxGridSize: CGFloat = 1200
    @State private var showSquareImages: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack(spacing: 0) {
                    // MARK: toolbar
                    HStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Slider(value: $gridSize, in: CGFloat(50)...CGFloat(maxGridSize)) {
                                EmptyView()
                            } minimumValueLabel: {
                                Image(systemName: "minus")
                            } maximumValueLabel: {
                                Image(systemName: "plus")
                            }
                            .frame(maxWidth: 160)
                            Toggle(isOn: $showSquareImages) {
                                Image(systemName: "rectangle.expand.vertical" )
                            }.labelsHidden()
                                .toggleStyle(.button)
                        }
                        
                        
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
                // MARK: Image Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize), spacing: 0)], spacing: 32) {
                        ForEach(images, id: \.self) { image in
                            VStack {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: showSquareImages ? .fill: .fit)
                                    .frame(width: gridSize, height: gridSize)
                                    .clipped()
                                    .border(selectedImages.contains(imageIDs[image]!) ? Color.blue : Color.clear)
                                    .overlay(alignment: .topLeading) {
                                        selectedImages.contains(imageIDs[image]!) ?
                                        Image(systemName:"checkmark.circle.fill")
                                            .foregroundColor(.white)
                                            .padding([.top, .leading], 4):
                                        Image(systemName:"circle")
                                            .foregroundColor(.white)
                                            .padding([.top, .leading], 4)
                                    }
                            }
                            .background(.white)
                            .onTapGesture {
                                if let id = imageIDs[image] {
                                    if selectedImages.contains(id) {
                                        selectedImages.remove(id)
                                    } else {
                                        selectedImages.insert(id)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    
                }
                .onAppear {
                    maxGridSize = geo.size.height - 18
                }
                .onChange(of: geo.size.height) { height in
                    let ratio = gridSize/maxGridSize
                    maxGridSize = geo.size.height - 18
                    gridSize = ratio * maxGridSize
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: showSquareImages)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

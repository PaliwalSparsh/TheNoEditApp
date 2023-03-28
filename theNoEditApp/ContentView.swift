import SwiftUI
import AppKit
import UniformTypeIdentifiers
import QuickLookThumbnailing

let MINIMUM_POSSIBLE_SIZE_OF_GRID: CGFloat = 600

struct ImageModel: Identifiable, Equatable {
    var id: UUID = UUID()
    var url: URL
    var data: NSImage
}

struct ContentView: View {
    @State private var images = [ImageModel]()
    @State private var selectedImages = Set<UUID>()
    @State private var gridSize: CGFloat = MINIMUM_POSSIBLE_SIZE_OF_GRID
    @State private var maxGridSize: CGFloat = 1200
    @State private var showSquareImages: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    // MARK: toolbar
                    HStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Slider(value: $gridSize, in: CGFloat(100)...CGFloat(maxGridSize), step: CGFloat(100)) {
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
                        Button(action: handleImport) {
                            Text("Import Images")
                                .frame(maxWidth: 120)
                        }
                        
                        ShareLink(items: images.filter{selectedImages.contains($0.id)}.map{$0.url})
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(.thinMaterial)
                    Divider()
                }
                
                if(selectedImages.count > 0) {
                    VStack(spacing: 0) {
                        HStack(alignment: .center, spacing:0) {
                            Text("**\(selectedImages.count)** images select")
                        }
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(.ultraThickMaterial)
                        .padding(.horizontal, 8)
                        Divider()
                    }
                }
                
                
                // MARK: Image Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: gridSize), spacing: 0)], spacing: 32) {
                        ForEach(images) { image in
                            let isSelected = selectedImages.contains(image.id)
                            let overlayImageName = isSelected ? "checkmark.circle.fill" : "circle"
                            
                            VStack {
                                Image(nsImage: image.data)
                                    .resizable()
                                    .aspectRatio(contentMode: showSquareImages ? .fill: .fit)
                                    .frame(width: gridSize, height: gridSize)
                                    .clipped()
                                    .border(isSelected ? Color.accentColor: Color.clear, width: 4)
                                    .overlay(alignment: .topLeading) {
                                        Image(systemName: overlayImageName)
                                            .foregroundColor(.accentColor)
                                            .padding([.top, .leading], 4)
                                    }
                            }
                            .background(.white)
                            .onTapGesture {
                                if isSelected {
                                    selectedImages.remove(image.id)
                                } else {
                                    selectedImages.insert(image.id)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    maxGridSize = max(Double(geo.size.height/100).rounded(.towardZero) * 100, MINIMUM_POSSIBLE_SIZE_OF_GRID)
                    gridSize = MINIMUM_POSSIBLE_SIZE_OF_GRID
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
        .animation(.easeInOut, value: images)
    }
    
    private func handleImport() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .rawImage, .tiff, .heif, .heic]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.begin { response in
            if response == NSApplication.ModalResponse.OK {
                for url in panel.urls {
                    // Use quicklook thumbnailing framework to generate thumbnails, much faster than other way to doing things
                    let request = QLThumbnailGenerator.Request(fileAt: url, size: CGSize(width: 800, height: 800), scale: 1, representationTypes: .thumbnail)
                    
                    QLThumbnailGenerator.shared.generateRepresentations(for: request) {
                        thumbnail, representation, error in
                        if let data = thumbnail {
                            images.append(ImageModel(url: url, data: data.nsImage))
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

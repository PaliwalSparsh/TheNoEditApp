import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var images = [NSImage]()
    @State private var imageIDs = [NSImage: UUID]()
    @State private var selectedImages = Set<UUID>()
    @State private var gridSize: CGFloat = 100
    @State private var maxGridSize: CGFloat = 1200
    @State private var showSquareImages: Bool = false
    @State private var isImportingImages: Bool = true
    
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
                        
                        Button(action: handleImport) {
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
                    maxGridSize = geo.size.height - 18
                }
                .onChange(of: geo.size.height) { height in
                    let ratio = gridSize/maxGridSize
                    maxGridSize = geo.size.height - 18
                    gridSize = ratio * maxGridSize
                }
                .overlay {
                    if(isImportingImages) {
                        ProgressView()
                    }else{
                        EmptyView()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut, value: showSquareImages)
    }
    
    private func handleImport() {
        isImportingImages = true
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .rawImage, .tiff, .heif, .heic]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.begin { response in
            if response == NSApplication.ModalResponse.OK {
                for url in panel.urls {
                    
                    let image = downsample(imageAt: url, to: CGSize(width: 400, height: 400), scale: 1)
                    images.append(image)
                    imageIDs[image] = UUID()
                    
                    // MARK: This set of code was meant to be used if users selects a directory instead of individual images
                    // do {
                    //     let urlContentType = try url.resourceValues(forKeys: [.contentTypeKey]).contentType
                    //     if (panel.allowedContentTypes.contains(urlContentType!)) {
                    //         let image = downsample(imageAt: url, to: CGSize(width: 400, height: 400), scale: 1)
                    //         images.append(image)
                    //         imageIDs[image] = UUID()
                    //     }
                    // } catch {
                    //     print("Caught an error")
                    // }
                }
            }
        }
        isImportingImages = false
    }
    
    private func downsample(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> NSImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
        
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
        
        let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
                                          kCGImageSourceShouldCacheImmediately: true,
                                    kCGImageSourceCreateThumbnailWithTransform: true,
                                           kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
        let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)!
        return NSImage(cgImage: downsampledImage, size: NSSize(width: downsampledImage.width, height: downsampledImage.height))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

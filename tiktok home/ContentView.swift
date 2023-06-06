//
//  ContentView.swift
//  tiktok home
//
//  Created by Rahul on 03/04/23.
//

import SwiftUI
import PhotosUI
import AVKit

struct ContentView: View {
    @State var assets = [PHAsset]()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 10) {
                ForEach(assets, id: \.self) { asset in
                    if asset.mediaType == .image {
                        Image(uiImage: getImage(asset: asset))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            //.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                    } else if asset.mediaType == .video {
                        VideoPlayer(player: AVPlayer(url: getVideoUrl(asset: asset)))
                            //.frame(width: UIScreen.main.bounds.width / 3 - 15, height: UIScreen.main.bounds.width / 3 - 15)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            //.frame(maxWidth: .infinity, maxHeight: .infinity)
                            .cornerRadius(10)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                    }
                }
            }
            .padding()
        }
        //.content.offset(x: 0)
        .isPagingEnabled()
        .onAppear {
            fetchAssets()
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let assets = PHAsset.fetchAssets(with: options)
        assets.enumerateObjects { (object, count, stop) in
            self.assets.append(object)
        }
    }
    
    func getImage(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var image = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), contentMode: .aspectFill, options: option) { (result, info) in
            image = result ?? UIImage()
        }
        return image
    }
    
    func getVideoUrl(asset: PHAsset) -> URL {
        let manager = PHImageManager.default()
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.deliveryMode = .automatic
        var url = URL(fileURLWithPath: "")
        manager.requestAVAsset(forVideo: asset, options: option) { (asset, audioMix, info) in
            if let urlAsset = asset as? AVURLAsset {
                url = urlAsset.url
            }
        }
        return url
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct ScrollViewPagingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIScrollView.appearance().isPagingEnabled = true
            }
            .onDisappear {
                UIScrollView.appearance().isPagingEnabled = false
            }
    }
}

extension ScrollView {
    func isPagingEnabled() -> some View {
        modifier(ScrollViewPagingModifier())
    }
}

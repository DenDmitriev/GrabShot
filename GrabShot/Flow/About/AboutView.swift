//
//  AboutView.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 17.08.2023.
//

import SwiftUI


struct AboutView: View {
    
    @Environment(\.openURL) var openURL
    
    @AppStorage(DefaultsKeys.grabCount)
    var grabCount: Int = .zero

    let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    let appVersionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
    let ffmpeg = "[FFmpeg](http://ffmpeg.org)"
    let lgpURL = "[LGPLv2.1](http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html)"
    let ffmpegKit = "[FFmpegKit](https://github.com/arthenica/ffmpeg-kit)"
    
    var body: some View {
        VStack(spacing: Grid.pt8) {
            Image("AppIcon256")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Grid.pt128, height: Grid.pt128)
            
            VStack {
                if let appName = appName {
                    Text(appName)
                        .font(.system(size: Grid.pt48))
                        .fontWeight(.thin)
                }
                
                if let appVersionNumber = appVersionNumber {
                    HStack {
                        Text(NSLocalizedString("Version", comment: "Title"))
                        Text(appVersionNumber)
                    }
                }
            }
            
            VStack {
                Text(
                    grabCount.formatted(.number)
                    + " "
                    + NSLocalizedString("shots", comment: "Title")
                )
                    .font(.title)
                    .fontWeight(.medium)
                
                HStack(spacing: Grid.pt2) {
                    Text("grabbed from")
                    
                    if let date = UserDefaultsService.default.getFirstInitDate()?.formatted(date: .long, time: .omitted) {
                        Text(date)
                    }
                }
            }
            .multilineTextAlignment(.center)
            
            VStack {
                if let copyright = copyright {
                    Text(copyright)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Text(.init(ffmpeg))
                        Text(.init(lgpURL))
                        Text(.init(ffmpegKit))
                    }
                }
            }
            .font(.caption)
            .padding()
        }
        .frame(minWidth: Grid.pt400, minHeight: Grid.pt400)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

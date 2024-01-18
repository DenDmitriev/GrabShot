//
//  NetworkService.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 18.01.2024.
//

import Foundation

class NetworkService {
    typealias Failure = NetworkServiceError
    
    enum Hosting {
        case vimeo(response: VimeoResponse?)
        case youtube(response: YoutubeResponse?)
        
        var hosts: [String] {
            switch self {
            case .vimeo:
                ["vimo.com", "vimeo.com"]
            case .youtube:
                ["youtube.com", "youtu.be"]
            }
        }
        
        init?(host: String?) {
            guard let host else { return nil }
            switch host {
            case let host where Self.isHosting(host: host, for: .vimeo(response: nil)):
                self = .vimeo(response: nil)
            case let host where Self.isHosting(host: host, for: .youtube(response: nil)):
                self = .youtube(response: nil)
            default:
                return nil
            }
        }
        
        static private func isHosting(host: String, for hosting: Self) -> Bool {
            for someHost in hosting.hosts {
                if host.contains(someHost) {
                    return true
                }
            }
            return false
        }
    }
    
    static func requestHostingRouter(by url: URL) async throws -> Result<Hosting, Error> {
        guard let host = Hosting(host: url.host) else { return .failure(NetworkServiceError.invalidURL) }
        switch host {
        case .vimeo:
            let response = try await Self.requestVimeoHosting(by: url)
            return .success(.vimeo(response: response))
        case .youtube:
            let response = try await Self.requestYoutubeHosting(by: url)
            return .success(.youtube(response: response))
        }
    }
    
    static private func requestVimeoHosting(by url: URL) async throws -> VimeoResponse {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.query = nil
        guard let videoId = components?.url?.lastPathComponent else { throw NetworkServiceError.invalidURL }
        guard videoId != "" else { throw Failure.invalidVideoId }
        
        let configURL = "https://player.vimeo.com/video/{id}/config"
        let dataURL = configURL.replacingOccurrences(of: "{id}", with: videoId)
        
        guard let url = URL(string: dataURL) else { throw Failure.invalidURL }
        
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        let vimeoResponse = try JSONDecoder().decode(VimeoResponse.self, from: data)
        
        return vimeoResponse
    }
    
    static private func requestYoutubeHosting(by url: URL) async throws -> YoutubeResponse {
        print(#function, url)
        throw NetworkServiceError.invalidURL
    }
}

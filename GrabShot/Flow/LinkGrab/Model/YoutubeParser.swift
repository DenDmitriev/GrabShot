//
//  YoutubeParser.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 16.01.2024.
//

import Foundation

public extension URL {
    /**
     Parses a query string of an URL
     
     @return key value dictionary with each parameter as an array
     */
    func dictionaryForQueryString() -> [String: AnyObject]? {
        return self.query?.dictionaryFromQueryStringComponents()
    }
}

public extension NSString {
    /**
     Convenient method for decoding a html encoded string
     */
    func stringByDecodingURLFormat() -> String {
        let result = self.replacingOccurrences(of: "+", with:" ")
        return result
//        return result.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    }
    
    /**
     Parses a query string
     
     @return key value dictionary with each parameter as an array
     */
    func dictionaryFromQueryStringComponents() -> [String: AnyObject] {
        var parameters = [String: AnyObject]()
        for keyValue in components(separatedBy: "&") {
            let keyValueArray = keyValue.components(separatedBy: "=")
            if keyValueArray.count < 2 {
                continue
            }
            let key = keyValueArray[0].stringByDecodingURLFormat()
            let value = keyValueArray[1].stringByDecodingURLFormat()
            parameters[key] = value as AnyObject
        }
        return parameters
    }
}

public class YoutubeParser: NSObject {
    static let infoURL = "http://www.youtube.com/get_video_info?video_id="
    static var userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.4 (KHTML, like Gecko) Chrome/22.0.1229.79 Safari/537.4"
    /**
     Method for retrieving the youtube ID from a youtube URL
     
     @param youtubeURL the the complete youtube video url, either youtu.be or youtube.com
     @return string with desired youtube id
     */
    public static func youtubeIDFromYoutubeURL(youtubeURL: URL) -> String? {
        guard let youtubeHost = youtubeURL.host
        else { return nil }
        
        let youtubePathComponents = youtubeURL.pathComponents
        let youtubeAbsoluteString = youtubeURL.absoluteString
        
        if youtubeHost == "youtu.be" {
            return youtubePathComponents[1]
        } else if youtubeAbsoluteString.ranges(of: "www.youtube.com/embed").count > .zero {
            return youtubePathComponents[2]
        } else if youtubeHost == "youtube.googleapis.com" || youtubeURL.pathComponents.first! == "www.youtube.com" {
            return youtubePathComponents[2]
        } else if let queryString = youtubeURL.dictionaryForQueryString(), let searchParam = queryString["v"] as? String {
            return searchParam
        } else {
            return nil
        }
    }
    /**
     Method for retreiving a iOS supported video link
     
     @param youtubeURL the the complete youtube video url
     @return dictionary with the available formats for the selected video
     
     */
    public static func h264videosWithYoutubeID(youtubeID: String) async throws -> [String: AnyObject]? {
        if youtubeID.count > 0 {
            let urlString = String(format: "%@%@", infoURL, youtubeID) as String
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            request.httpMethod = "GET"
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let responseString = String(data: data, encoding: .utf8) else { throw NSError() }
            
            let parts = responseString.dictionaryFromQueryStringComponents()
            if parts.count > 0 {
                var videoTitle: String = ""
                var streamImage: String = ""
                if let title = parts["title"] as? String {
                    videoTitle = title
                }
                if let image = parts["iurl"] as? String {
                    streamImage = image
                }
                if let fmtStreamMap = parts["url_encoded_fmt_stream_map"] as? String {
                    // Live Stream
                    if let isLivePlayback: AnyObject = parts["live_playback"]{
                        if let hlsvp = parts["hlsvp"] as? String {
                            var videoDictionary: [String: AnyObject] = [:]
                            videoDictionary["url"] = "\(hlsvp)" as AnyObject
                            videoDictionary["title"] = "\(videoTitle)" as AnyObject
                            videoDictionary["image"] = "\(streamImage)" as AnyObject
                            videoDictionary["isStream"] = true as AnyObject
                            return videoDictionary
                        }
                    } else {
                        let fmtStreamMapArray = fmtStreamMap.components(separatedBy: ",")
                        for videoEncodedString in fmtStreamMapArray {
                            var videoComponents = videoEncodedString.dictionaryFromQueryStringComponents()
                            videoComponents["title"] = videoTitle as AnyObject
                            videoComponents["isStream"] = false as AnyObject
                            return videoComponents as [String: AnyObject]
                        }
                    }
                }
            }
        }
        return nil
    }
    /**
     Block based method for retreiving a iOS supported video link
     
     @param youtubeURL the the complete youtube video url
     @param completeBlock the block which is called on completion
     
     */
    public static func h264videosWithYoutubeURL(youtubeURL: URL, completion: (([String: AnyObject]?, NSError?) -> Void)?) async throws {
        guard let youtubeID = youtubeIDFromYoutubeURL(youtubeURL: youtubeURL),
              let videoInformation = try await h264videosWithYoutubeID(youtubeID: youtubeID)
        else {
            completion?(nil, NSError(domain: "com.player.yt.backgroundqueue", code: 1001, userInfo: ["error": "Invalid YouTube URL"]))
            return
        }
        
        completion?(videoInformation, nil)
    }
}

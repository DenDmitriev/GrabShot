//
//  FFmpegCommandBuilder.swift
//  GrabShot
//
//  Created by Denis Dmitriev on 27.03.2024.
//

import Foundation

//struct FFmpegCommandBuilder {
//    let loglevel: String
//    let inputURL: URL
//    let outputURL: URL
//    let overwrite: String
//    let startSecond: Double
//    let update: String
//    let frames: String
//    let format: String
//    let pixelFormat: String
//    let quality: String
//    
//    enum Keys: String {
//        case loglevel = "-loglevel"
//        case overwrite = "-y"
//        case startSecond = "-ss"
//        case input = "-i"
//        case update = "-update"
//        case frames = "-frames:v"
//        case format = "-f"
//        case pixelFormat = "-pix_fmt"
//        case quality = "-q:v"
//        case output = ""
//    }
//    
//    func grabCommand() -> String {
//        [
//            Keys.loglevel.rawValue, "error", // "warning",
//            Keys.overwrite.rawValue, //Overwrite output files without asking
//            Keys.startSecond.rawValue, "\(startSecond)",
//            Keys.input.rawValue, "'\(path)'",
//            Keys.update.rawValue, "1", // Указывает что будет одно изображение обновляться. Для отключения предупреждения
//            Keys.frames.rawValue, "1", //Set the number of video frames to output  -vframes
//            Keys.format.rawValue, "mjpeg",
//            Keys.pixelFormat.rawValue, "yuvj420p", //Set pixel format
//            Keys.quality.rawValue, "\(qualityReduced)",
//            Keys.output.rawValue, "'\(urlImage.relativePath)'"
//        ].joined(separator: " ")
//    }
//}

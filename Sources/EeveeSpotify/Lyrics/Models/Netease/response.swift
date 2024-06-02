//
//  File.swift
//  
//
//  Created by s s on 2024/5/31.
//

import Foundation


struct NeteaseSearchResponse : Codable {
    var result : NeteaseSearchResult
    var code: Int
}

struct NeteaseSearchResult : Codable {
    var songs: [NeteaseSong]
    var songCount : Int
}

struct NeteaseSong : Codable{
    var name: String
    var id: Int
    var dt: Int
    var ar: [NeteaseArtist]
    var originSongSimpleData: NeteaseSimpleSong?
}

struct NeteaseSimpleSong : Codable {
    var songId: Int
    var name: String
    var artists: [NeteaseArtist]
}

struct NeteaseLyricResponse: Codable {
    var code: Int
    var lrc: NeteaseLyric
    var tlyric: NeteaseLyric?
    var romalrc: NeteaseLyric?
    var klyric: NeteaseLyric?
}

struct NeteaseLyric : Codable{
    var version: Int
    var lyric: String
}

struct NeteaseArtist : Codable {
    var id: Int
    var name: String
    var alias: [String]?
}

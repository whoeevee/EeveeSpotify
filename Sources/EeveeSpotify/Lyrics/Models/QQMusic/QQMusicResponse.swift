//
//  QQMusicResponse.swift
//  EeveeSpotify
//
//  Created by s s on 2024/6/7.
//

import Foundation


struct QQMusicSearchRes : Codable {
    var code: Int
    var data: QQMusicSearchData
}

struct QQMusicSinger : Codable {
    var id: Int
    var mid: String
    var name: String
    var name_hilight: String?
}

struct QQMusicSong : Codable {
    var songmid: String
    var interval: Int
    var singer: [QQMusicSinger]
    var songname: String
    var lyric: String
    
}

struct QQMusicSearchSong : Codable {
    var totalnum: Int
    var list: [QQMusicSong]
}

struct QQMusicSearchData : Codable {
    var song: QQMusicSearchSong
}

struct QQMusicLyricRes : Codable{
    var code: Int
    var lyric: String?
    var trans: String?
}

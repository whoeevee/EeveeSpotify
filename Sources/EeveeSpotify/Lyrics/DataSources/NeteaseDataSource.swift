//
//  File.swift
//  
//
//  Created by s s on 2024/5/31.
//

import Foundation


struct NeteaseDataSource {
    private let searchUrl = URL(string: "https://interface.music.163.com/api/cloudsearch/pc")!
    private let lyricUrl = URL(string: "https://music.163.com/api/song/lyric")!
    
    
    private let session : URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        session = URLSession(configuration: configuration)
    }
    
    
    func search(_ query: String, _ searchLimit: Int) throws -> [NeteaseSong] {

        
        let semaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?
        
        var request1 = URLRequest(url: searchUrl)
        request1.httpMethod = "POST"
        request1.httpBody = "s=\(query.addingPercentEncoding(withAllowedCharacters: .alphanumerics)! )&type=1&limit=\(searchLimit)&offset=0".data(using: .utf8)
        
        let task = session.dataTask(with: request1) { response, _, err in
            error = err
            data = response
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()

        if let error = error {
            throw error
        }

        
        return try JSONDecoder().decode(NeteaseSearchResponse.self, from: data!).result.songs
        
    }
    
    func getLyric(_ song: NeteaseSong) throws -> NeteaseLyricResponse {
        let semaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?
        
        var request1 = URLRequest(url: lyricUrl)
        request1.httpMethod = "POST"
        request1.httpBody = "id=\(song.id)&tv=-1&lv=-1&rv=-1&kv=-1".data(using: .utf8)
        
        let task = session.dataTask(with: request1) { response, _, err in
            error = err
            data = response
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()

        if let error = error {
            throw error
        }
        
        let lyricRes = try JSONDecoder().decode(NeteaseLyricResponse.self, from: data!)

        if lyricRes.lrc.lyric.isEmpty {
            throw LyricsError.NoSuchSong
        }
        
        return lyricRes
    }

    func mutualContain(_ s1: String, _ s2: String) -> Bool {
        let name1 = s1.lowercased().replacingOccurrences(of: " ", with: "")
        let name2 = s2.lowercased().replacingOccurrences(of: " ", with: "")
        return name1.contains(name2) || name2.contains(name1)
    }
    
    func artistMatch(_ group1: [NeteaseArtist], _ artistNames: [String]) -> Bool {
        var neteaseArtistNames = [String]()
        // 别名也要考虑
        for artist in group1 {
            neteaseArtistNames.append(artist.name)
            if let alias = artist.alias {
                neteaseArtistNames.append(contentsOf: alias)
            }
        }
        
        for artist in neteaseArtistNames {
            for targetName in artistNames {

                if mutualContain(artist, targetName) {
                    return true
                }
            }

        }
        return false
    }
    
    func durationMatch(_ duration: Int, _ target: Int, threshold: Int = 1000) -> Bool {
        return (abs(duration - target) < threshold)
    }
    
    func isInstrumental(_ lowerTitle: String) -> Bool {
        return lowerTitle.contains("instrumental") || lowerTitle.contains("off vocal") || lowerTitle.contains("vocal off")
    }

    func getSong(
        title: String,
        artistsString: String,
        duration: Int
    ) throws -> NeteaseSong {
        // 先用曲名+作者精确搜索,找不到再只用曲名搜索
        // 有可能搜到二创,要验证作者名,如果有originSongSimpleData,则很有可能是原版
        let spotifyArtists = artistsString.components(separatedBy: ", ")
        let lowerTitle = title.lowercased()
        let isOffVocal = isInstrumental(lowerTitle)

        // 联合创作就每个作者都搜一遍
        for artist in spotifyArtists {
            let hits1 = try self.search("\(title) \(artist)", 5)
            for hit in hits1 {
                if durationMatch(hit.dt, duration) && artistMatch(hit.ar,  spotifyArtists) && (isOffVocal == isInstrumental(hit.name.lowercased())) {
                    return hit
                }
                
                // 有原作者,可能性很大
                if let orgSong = hit.originSongSimpleData {
                    if artistMatch(orgSong.artists,  spotifyArtists) && (isOffVocal == isInstrumental(orgSong.name.lowercased())) {
                        return NeteaseSong(name: orgSong.name, id: orgSong.songId, dt: -1, ar: orgSong.artists)
                    }
                }
            }
        }
        
        // 精确搜索没找到就扩大范围,只按曲名搜索
        let hits = try self.search(title, 30)
        for hit in hits {
            if durationMatch(hit.dt, duration) && artistMatch(hit.ar,  spotifyArtists) && (isOffVocal == isInstrumental(hit.name.lowercased())) {
                return hit
            }
            
            // 有原作者,可能性很大
            if let orgSong = hit.originSongSimpleData {
                if artistMatch(orgSong.artists,  spotifyArtists) && (isOffVocal == isInstrumental(orgSong.name.lowercased())) {
                    return NeteaseSong(name: orgSong.name, id: orgSong.songId, dt: -1, ar: orgSong.artists)
                }
            }
        }

        // 还没找到? 按照曲名是否包含&时间长度大致相同匹配(即便是二创,长度应该大致相同吧?)
        if let song = hits.first(
            where: { durationMatch($0.dt, duration, threshold: 4000) && mutualContain($0.name, title) }
        ) {
            return song
        }

        // 找仅曲名包含不如交给回落处理
        
        throw LyricsError.NoSuchSong
    }
}

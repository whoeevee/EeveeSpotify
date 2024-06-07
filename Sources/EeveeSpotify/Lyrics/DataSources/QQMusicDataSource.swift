//
//  QQMusicDataSource.swift
//  EeveeSpotify
//
//  Created by s s on 2024/6/7.
//

import Foundation

struct QQMusicLyric {
    var lyric: String = ""
    var trans: String?
    
    init(_ lrcRes: QQMusicLyricRes) throws {
        if let encodedLrc = lrcRes.lyric {
            lyric = try QQMusicLyric.decode(encodedLrc)
        }
        if let encodedLrc = lrcRes.trans {
            trans = try QQMusicLyric.decode(encodedLrc)
        }
    }
    
    private static func decode(_ base64EncodedString: String) throws -> String {
        guard
            let base64EncodedData = base64EncodedString.data(using: .utf8),
            let data = Data(base64Encoded: base64EncodedData),
            let result = String(data: data, encoding: .utf8)
        else {
            NSLog("Failed to decode qq music lrc!")
            throw LyricsError.DecodingError
        }

        return result
    }
}

class QQMusicDataSource {
    private let searchUrl = "https://c.y.qq.com/soso/fcgi-bin/client_search_cp?format=json&p=1&cr=1&g_tk=5381&t=0"
    private let lyricUrl = "https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg?g_tk=5381&loginUin=0&hostUin=0&inCharset=utf8&outCharset=utf8&notice=0&platform=yqq&needNewCode=0&format=json&songmid="
    
    private let session : URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "Referer": "https://y.qq.com"
        ]
        session = URLSession(configuration: configuration)
    }
    
    func search(_ query: String, _ searchLimit: Int) throws -> [QQMusicSong] {
        let semaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?
        
        var request1 = URLRequest(url: URL(string: "\(searchUrl)&n=\(searchLimit)&w=\(query.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)")!)
        request1.httpMethod = "GET"
        
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
        let res = try JSONDecoder().decode(QQMusicSearchRes.self, from: data!)
        
        if res.code != 0 {
            NSLog("QQ Music server returned a non-zero code: \(res.code)")
            throw LyricsError.NoSuchSong
        }

        
        return res.data.song.list
    }
    
    func getLyric(_ song: QQMusicSong) throws -> QQMusicLyric {
        let semaphore = DispatchSemaphore(value: 0)
        var data: Data?
        var error: Error?
        
        var request1 = URLRequest(url: URL(string: "\(lyricUrl)\(song.songmid)")!)
        request1.httpMethod = "GET"
        
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
        
        let lyricRes = try JSONDecoder().decode(QQMusicLyricRes.self, from: data!)
        
        if lyricRes.code != 0 {
            throw LyricsError.NoSuchSong
        }
        
        return try QQMusicLyric(lyricRes)
    }
    
    func mutualContain(_ s1: String, _ s2: String) -> Bool {
        let name1 = s1.lowercased().replacingOccurrences(of: " ", with: "")
        let name2 = s2.lowercased().replacingOccurrences(of: " ", with: "")
        return name1.contains(name2) || name2.contains(name1)
    }
    
    func artistMatch(_ group1: [QQMusicSinger], _ artistNames: [String]) -> Bool {
        var qqArtistNames = [String]()
        // 别名也要考虑
        for artist in group1 {
            qqArtistNames.append(artist.name)
            if let alias = artist.name_hilight {
                qqArtistNames.append(alias)
            }
        }
        
        for artist in qqArtistNames {
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
    ) throws -> QQMusicSong {
        // 先用曲名+作者精确搜索,找不到再只用曲名搜索
        // 有可能搜到二创,要验证作者名,如果有originSongSimpleData,则很有可能是原版
        let spotifyArtists = artistsString.components(separatedBy: ", ")
        let lowerTitle = title.lowercased()
        let isOffVocal = isInstrumental(lowerTitle)

        // 联合创作就每个作者都搜一遍
        for artist in spotifyArtists {
            let hits1 = try self.search("\(title) \(artist)", 5)
            for hit in hits1 {
                if durationMatch(hit.interval * 1000, duration, threshold: 2001) && artistMatch(hit.singer,  spotifyArtists) && (isOffVocal == isInstrumental(hit.songname.lowercased())) {
                    return hit
                }
            }
        }
        
        // 精确搜索没找到就扩大范围,只按曲名搜索
        let hits = try self.search(title, 30)
        for hit in hits {
            if durationMatch(hit.interval * 1000, duration, threshold: 2001) && artistMatch(hit.singer,  spotifyArtists) && (isOffVocal == isInstrumental(hit.songname.lowercased())) {
                return hit
            }
        }

        // 还没找到? 按照曲名是否包含&时间长度大致相同匹配(即便是二创,长度应该大致相同吧?)
        if let song = hits.first(
            where: { durationMatch($0.interval * 1000, duration, threshold: 4001) && mutualContain($0.songname, title) }
        ) {
            return song
        }

        // 找仅曲名包含不如交给回落处理
        throw LyricsError.NoSuchSong
    }
    
    
    static func parseLyrics(_ plain: PlainLyrics) -> [LyricsLine] {
        var lyricLines: [LyricsLine] = []
        // 检测纯音乐
        if plain.content == "[00:00:00]此歌曲为没有填词的纯音乐，请您欣赏" {
            lyricLines.append(LyricsLine.with {
                $0.offsetMs = 0
                $0.content = "此歌曲为没有填词的纯音乐，请您欣赏"
            })
            return lyricLines
        }

        
        var lines = plain
            .content
            .components(separatedBy: "\n")

        if let last = lines.last, last.isEmpty {
            lines.removeLast()
        }
        
        // 检查是不是真的timeSynced
        var realSynced = true
        if plain.timeSynced {
            let match0 = plain.content.firstMatch(
                "\\[(?<minute>\\d{2}):(?<seconds>\\d{2}\\.?\\d*).{0,2}\\] ?(?<content>.*)"
            )
            if match0 == nil {
                realSynced = false
            }
        }
        
        if plain.timeSynced && realSynced {
            // 解决QQ音乐翻译和原文轴对不上的问题
            var translationLines = [LyricsLine]()
            if UserDefaults.neteaseShowTranslation, let translation = plain.translation {
                var translateLines = translation
                    .components(separatedBy: "\n")
                
                if let last = translateLines.last, last.isEmpty {
                    translateLines.removeLast()
                }
                
                for line in translateLines {
                    let match0 = line.firstMatch(
                        "\\[(?<minute>\\d{2}):(?<seconds>\\d{2}\\.?\\d*).{0,2}\\] ?(?<content>.*)"
                    )
                    
                    guard let match = match0 else {
                        continue
                    }
                    
                    var captures: [String: String] = [:]
                    
                    for name in ["minute", "seconds", "content"] {
                        
                        let matchRange = match.range(withName: name)
                        
                        if let substringRange = Range(matchRange, in: line) {
                            captures[name] = String(line[substringRange])
                        }
                    }
                    
                    let minute = Int(captures["minute"]!)!
                    let seconds = Float(captures["seconds"]!)!
                    let content = captures["content"]!.htmlDecoded()
                    
                    let offset = Int32(minute * 60 * 1000 + Int(seconds * 1000))
                    
                    translationLines.append(LyricsLine.with {
                        $0.offsetMs = offset
                        $0.content = content
                    })
                    
                }

            }
            
            for line in lines {
                
                let match = line.firstMatch(
                    "\\[(?<minute>\\d{2}):(?<seconds>\\d{2}\\.?\\d*).{0,2}\\] ?(?<content>.*)"
                )
                
                guard let match = match else {
                    continue
                }
                
                var captures: [String: String] = [:]
                
                for name in ["minute", "seconds", "content"] {
                    
                    let matchRange = match.range(withName: name)
                    
                    if let substringRange = Range(matchRange, in: line) {
                        captures[name] = String(line[substringRange])
                    }
                }
                
                let minute = Int(captures["minute"]!)!
                let seconds = Float(captures["seconds"]!)!
                let content = captures["content"]!.htmlDecoded()
                
                let offset = Int32(minute * 60 * 1000 + Int(seconds * 1000))
                
                lyricLines.append(LyricsLine.with {
                    $0.offsetMs = offset
                    $0.content = content
                })
            }
            
            
            lyricLines.sort(by: { $0.offsetMs < $1.offsetMs})
            if UserDefaults.neteaseShowTranslation {
                translationLines.sort(by: { $0.offsetMs < $1.offsetMs})
                
                // 对轴,在线性时间内完成
                var j = 0
                let jmax = translationLines.count
                for i in 0...(lyricLines.count - 1) {
                    // 只匹配非空行!
                    if lyricLines[i].content.isEmpty {
                        lyricLines[i].content = lyricLines[i].content.lyricsNoteIfEmpty
                        continue
                    }
                    
                    // 找到接下来第一个非空的翻译
                    while j < jmax && translationLines[j].content.isEmpty {
                        j += 1
                    }
                    if j >= jmax {
                        break
                    }
                    
                    // 遇到双斜杠就忽略
                    if translationLines[j].content == "//" {
                        j += 1
                        continue
                    }
                    lyricLines[i].content = "\(lyricLines[i].content)\n\(translationLines[j].content)"
                    j += 1
                }
                
            }
            return lyricLines
        }

        lyricLines = lines.map { line in
            LyricsLine.with { $0.content = line }
        }
        return lyricLines
    }
}

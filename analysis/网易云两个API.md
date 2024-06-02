# 网易云两个API

1. 搜索
```http

POST https://interface.music.163.com/api/cloudsearch/pc
Content-Type: application/x-www-form-urlencoded

s=suzume&type=1&limit=30&offset=0
```
每首歌的dt字段是毫秒为单位的长度

2.  歌词
```http
POST https://music.163.com/api/song/lyric
Content-Type: application/x-www-form-urlencoded

id=1978516959&tv=-1&lv=-1&rv=-1&kv=-1
```
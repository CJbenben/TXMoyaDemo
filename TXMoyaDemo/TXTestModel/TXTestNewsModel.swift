//
//  TXTestNewsModel.swift
//  TXMoyaDemo
//
//  Created by powershare on 2024/7/1.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

struct TXTestNewsModel: Codable {
    let stat: String?
    let data: [TXTestNewModel?]?
    let page: String?
    let pageSize: String?
}

struct TXTestNewModel: Codable {
    let uniquekey: String?
    let title: String?
    let date: String?
    let category: String?
    let author_name: String?
    let url: String?
}

//"uniquekey": "16b01e0e8665916f41b5139a697bd986",
//"title": "互联网销售预包装食品需进一步规范",
//"date": "2024-07-15 08:40:00",
//"category": "头条",
//"author_name": "人民网，供稿：人民资讯",
//"url": "https:\/\/mini.eastday.com\/mobile\/240715084040812810702.html",
//"thumbnail_pic_s": "",
//"is_content": "1"

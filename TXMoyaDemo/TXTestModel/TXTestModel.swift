//
//  TXTestModel.swift
//  TXMoyaDemo
//
//  Created by powershare on 2024/7/1.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

struct TXTestModel: Codable {
    let stat: String?
    let data: [TXTestDataModel?]?
    let page: String?
    let pageSize: String?
}

struct TXTestDataModel: Codable {
    let key: String?
    let name: String?
    let time: String?
    let category: String?
    let author: String?
}

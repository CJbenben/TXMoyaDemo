//
//  TXSampleDataModel.swift
//  TXMoyaDemo
//
//  Created by powershare on 2024/7/1.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

struct TXSampleDataModel: Codable {
    let index: String?
    let data: [TXSampleDataItemModel?]?
    let currPage: String?
    let pageSize: String?
}

struct TXSampleDataItemModel: Codable {
    let id: String?
    let title: String?
    let time: String?
    let price: Float?
    let count: Int?
}

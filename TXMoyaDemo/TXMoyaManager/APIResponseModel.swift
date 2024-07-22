//
//  APIResponseModel.swift
//  TXMoyaDemo
//
//  Created by powershare on 2024/7/1.
//  Copyright © 2024 ChenJie. All rights reserved.
//

import UIKit

struct APIResponseModel<T: Codable>: Codable {
    let error_code: Int
    let reason: String
    let result: T?
}

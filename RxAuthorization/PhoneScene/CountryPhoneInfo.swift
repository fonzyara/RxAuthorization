//
//  CountryPhoneInfo.swift
//  RxAuthorization
//
//  Created by Vladimir Alecseev on 28.12.2022.
//

import Foundation
struct CountryPhoneInfo: Codable {
    let flags: Flags
    let name: Name
    let idd: Idd
    let capital, altSpellings: [String]
}

// MARK: - Flags
struct Flags: Codable {
    let png: String
    let svg: String
}

// MARK: - Idd
struct Idd: Codable {
    let root: Root
    let suffixes: [String]
}

enum Root: String, Codable {
    case empty = ""
    case the1 = "+1"
    case the2 = "+2"
    case the3 = "+3"
    case the4 = "+4"
    case the5 = "+5"
    case the6 = "+6"
    case the7 = "+7"
    case the8 = "+8"
    case the9 = "+9"
}

// MARK: - Name
struct Name: Codable {
    let common, official: String
    let nativeName: [String: NativeName]
}

// MARK: - NativeName
struct NativeName: Codable {
    let official, common: String
}
//struct CountryPhoneInfo: Codable {
//    let flags: Flags
//    let name: Name
//    let idd: Idd
//}
//
//// MARK: - Flags
//struct Flags: Codable {
//    let png: String
//}
//
//// MARK: - Idd
//struct Idd: Codable {
//    let root: Root
//}
//
//enum Root: String, Codable {
//    case empty = ""
//    case the1 = "+1"
//    case the2 = "+2"
//    case the3 = "+3"
//    case the4 = "+4"
//    case the5 = "+5"
//    case the6 = "+6"
//    case the7 = "+7"
//    case the8 = "+8"
//    case the9 = "+9"
//}
//
//// MARK: - Name
//struct Name: Codable {
//    let common: String
//}



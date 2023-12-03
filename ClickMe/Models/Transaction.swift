//
//  Transaction.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-18.
//

import Foundation
import UIKit

enum TransactionType: String, Codable {
    case guestCancelSchedule
    case scheduleStarted
    case scheduleFinished
    case tips
    case cashOutCoins
    case purchaseCoins
    case unknown
    
    func name() -> String {
        switch self {
        case .guestCancelSchedule:
            return "Cancelled booking"
        case .scheduleStarted:
            return "Booking confirmed"
        case .scheduleFinished:
            return "Booking finished"
        case .tips:
            return "Donation"
        case .cashOutCoins:
            return "Withdraw"
        case .purchaseCoins:
            return "Purchase"
        case .unknown:
            return "Unknown transaction"
        }
    }
}

extension TransactionType {
    init(from decoder: Decoder) throws {
        self = try TransactionType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}


struct Transaction: Codable {
    var identifier: Int
    var earnedTrans: Int?
    var purchasedTrans: Int?
    var otherTrans: Int?
    var actionType: TransactionType
    var owner: ListUser?
    var theOther: ListUser?
    var schedule: Schedule?
    var createdAt: Date
    
    var amount: Int {
        return earnedTrans ?? purchasedTrans ?? otherTrans ?? 0
    }
    
    var amountColor: UIColor {
        if amount > 0 {
            return ThemeManager.shared.themeData!.indigo.hexColor
        } else if amount == 0 {
            return ThemeManager.shared.themeData!.textLabel.hexColor
        } else {
            return .systemRed
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case earnedTrans
        case purchasedTrans
        case otherTrans
        case actionType
        case owner
        case theOther
        case schedule
        case createdAt
    }
}

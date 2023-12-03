//
//  Wallet.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-01.
//

import Foundation

enum WalletType: String, Codable {
    case purchased = "purchased"
    case earned = "earned"
    case other = "other"
    
    func name() -> String {
        switch self {
        case .purchased:
            return "purchased coin"
        case .earned:
            return "earned coin"
        case .other:
            return "other coin"
        }
    }
}

struct Wallet: Codable {
    var identifier: Int
    var purchasedCoins: Int
    var earnedCoins: Int
    var otherCoins: Int
    var preferredAccount: WalletType
    
    var preferredAccountAmount: Int {
        switch preferredAccount {
        case .purchased:
            return purchasedCoins
        case .earned:
            return earnedCoins
        case .other:
            return otherCoins
        }
    }
    
    var total: Int {
        return purchasedCoins + earnedCoins
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case purchasedCoins = "purchased_coins"
        case earnedCoins = "earned_coins"
        case otherCoins = "other_coins"
        case preferredAccount
    }
}

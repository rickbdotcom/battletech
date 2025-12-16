//
//  File.swift
//  battletech
//
//  Created by Richard Burgess on 12/12/25.
//

import Foundation

let doubleClanHeatSinkPerTon = 12.0

let ammoWeight = [
    "MG": 1.0 / 200.0,
    "SRM": 1.0 / 100.0,
    "LRM": 1.0 / 120.0,
    "AC2": 1.0 / 25.0,
    "AC5": 1.0 / 15.0,
    "AC10": 1.0 / 8.0,
    "AC20": 1.0 / 5.0,
    "GAUSS": 1.0 / 8.0,
    "LB2X": 1.0 / 25.0,
    "LB5X": 1.0 / 15.0,
    "LB10X": 1.0 / 8.0,
    "LB20X": 1.0 / 5.0
]
struct Weapon: Decodable & SpreadsheetConvertible {
    let category: String
    let weaponType: String
    let weaponSubType: String
    let heatGenerated: Double
    let damage: Double
    let tonnage: Double
    let bonusValueA: String
    let bonusValueB: String
    let description: Description
    let shotsWhenFired: Double
    let maxRange: Int
    let ammoCategoryID: String?

    var bonus: String {
        [bonusValueA, bonusValueB].joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case category = "Category"
        case weaponType = "Type"
        case weaponSubType = "WeaponSubType"
        case heatGenerated = "HeatGenerated"
        case damage = "Damage"
        case tonnage = "Tonnage"
        case bonusValueA = "BonusValueA"
        case bonusValueB = "BonusValueB"
        case description = "Description"
        case shotsWhenFired = "ShotsWhenFired"
        case maxRange = "MaxRange"
        case ammoCategoryID
    }

    struct Description: Decodable {
        let uiName: String

        enum CodingKeys: String, CodingKey {
            case uiName = "UIName"
        }
    }

    var totalDamage: Double {
        damage * shotsWhenFired
    }

    func effectiveTonnage(heatSinkPerTon: Double, rounds: Double) -> Double {
        tonnage + (heatGenerated / heatSinkPerTon) + ammoTonnage(rounds: rounds)
    }

    func ammoTonnage(rounds: Double) -> Double {
        guard let ammoCategoryID, let weight = ammoWeight[ammoCategoryID] else {
            return 0
        }
        return rounds * shotsWhenFired * weight
    }

    var displayDamagePerHeat: String {
        heatGenerated == 0 ? "No Heat" : String(format: "%.1f", totalDamage / heatGenerated)
    }

    var displayDamagePerTon: String {
        String(format: "%.1f", totalDamage / tonnage)
    }

    var displayDamage: String {
        String(totalDamage)
    }

    var displayTonnage: String {
        String(tonnage)
    }

    var displayHeatGenerated: String {
        String(heatGenerated)
    }

    var displayMaxRange: String {
        String(maxRange)
    }

    func effectiveDamagePerTon(
        heatSinkPerTon: Double = doubleClanHeatSinkPerTon,
        rounds: Double = 10
    ) -> Double {
        totalDamage / effectiveTonnage(heatSinkPerTon: heatSinkPerTon, rounds: rounds)
    }

    var displayEffectiveDamagePerTon: String {
        String(format: "%.1f", effectiveDamagePerTon())
    }

    var displayName: String {
        description.uiName
    }

    static func header() -> String {
        [
            "Name",
            "Category",
            "Type",
            "Sub Type",
            "Range",
            "Damage",
            "Tonnage",
            "Heat",
            "Dmg/Ton",
            "Eff Dmg/Ton",
            "Dmg/Heat",
            "Bonus"
        ].joined(separator: "\t")
    }

    func toRow() -> String {
        [
            displayName,
            category,
            weaponType,
            weaponSubType,
            displayMaxRange,
            displayDamage,
            displayTonnage,
            displayHeatGenerated,
            displayDamagePerTon,
            displayEffectiveDamagePerTon,
            displayDamagePerHeat,
            bonus,
        ]
        .joined(separator: "\t")
    }
}

extension BattleTech {
    func parseWeapons() throws {
        guard weapons.isEmpty == false else {
            return
        }

        let files = try jsonPaths(from: weapons)

        try (
            [Weapon.header()] +
            convert(files: files, type: Weapon.self, verbose: verbose)
        )
        .joined(separator: "\n")
        .data(using: .utf8)?.write(to: URL(fileURLWithPath: "weapons.tsv"))
    }
}

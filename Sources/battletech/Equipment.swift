//
//  File.swift
//  battletech
//
//  Created by Richard Burgess on 12/12/25.
//

import Foundation

struct Equipment: Decodable & SpreadsheetConvertible {
    let tonnage: Double
    let bonusValueA: String
    let bonusValueB: String
    let description: Description

    var bonus: String {
        [bonusValueA, bonusValueB].joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case tonnage = "Tonnage"
        case bonusValueA = "BonusValueA"
        case bonusValueB = "BonusValueB"
        case description = "Description"
    }

    struct Description: Decodable {
        let uiName: String

        enum CodingKeys: String, CodingKey {
            case uiName = "UIName"
        }
    }

    var displayName: String {
        description.uiName
    }

    var displayTonnage: String {
        String(tonnage)
    }

    static func header() -> String {
        [
            "Name",
            "Tonnage",
            "Bonus"
        ].joined(separator: "\t")
    }

    func toRow() -> String {
        [
            displayName,
            displayTonnage,
            bonus
        ]
        .joined(separator: "\t")
    }
}

extension BattleTech {
    func parseEquipment() throws {
        guard equipment.isEmpty == false else {
            return
        }

        let files = try jsonPaths(from: equipment)

        try (
            [Equipment.header()] +
            convert(files: files, type: Equipment.self, verbose: verbose)
        )
        .joined(separator: "\n")
        .data(using: .utf8)?.write(to: URL(fileURLWithPath: "equipment.tsv"))
    }
}

//
//  File.swift
//  battletech
//
//  Created by Richard Burgess on 12/12/25.
//

import Foundation

struct Mech: Decodable & SpreadsheetConvertible {
    let Description: DescriptionInfo

    struct DescriptionInfo: Decodable {
        let Name: String

    }

    static func header() -> String {
        [
            "Designation",
            "Model",
            "Class",
            "Tons",
            "Free",
            "Melee",
            "Walk",
            "Jump Jets",
            "Total",
            "Ballistic",
            "Energy",
            "Missile",
            "Support"
        ]
        .joined(separator: "\t")
    }

    func toRow() -> String {
        [
            Description.Name
        ]
        .joined(separator: "\t")
    }
}

extension BattleTech {

    func parseMechs() throws {
        guard mechs.isEmpty == false else {
            return
        }

        let files = try jsonPaths(from: mechs)

        try (
            [Mech.header()] +
            convert(files: files, type: Mech.self)
        )
        .joined(separator: "\n")
        .data(using: .utf8)?.write(to: URL(fileURLWithPath: "mechs.tsv"))
    }

}

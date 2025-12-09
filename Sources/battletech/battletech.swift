import ArgumentParser
import Foundation

@main
struct BattleTech: ParsableCommand {

    @Option(help: "weapons directory")
    var weapons: [String]

    func run() throws {
        let files = try weapons.map { path in
            (try FileManager.default.subpathsOfDirectory(atPath: path)).map {
                path + "/" + $0
            }
        }.flatMap {
            $0
        }.filter {
            $0.hasSuffix(".json")
        }
        var spreadsheet = ""

        spreadsheet += [
            "Name",
            "Category",
            "Type",
            "Sub Type",
            "Damage",
            "Tonnage",
            "Heat"
        ].joined(separator: "\t") + "\n"

        files.forEach { file in
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: file))
                let weapon = try JSONDecoder().decode(Weapon.self, from: data)
                spreadsheet += [
                    weapon.name,
                    weapon.Category,
                    weapon.WeaponType,
                    weapon.WeaponSubType,
                    String(weapon.Damage),
                    String(weapon.Tonnage),
                    String(weapon.HeatGenerated)
                ].joined(separator: "\t") + "\n"
            } catch {
            }
        }

        try spreadsheet.data(using: .utf8)?.write(to: URL(fileURLWithPath: "out.tsv"))
    }
}

struct Weapon: Decodable {
    let Category: String
    let WeaponType: String
    let WeaponSubType: String
    let HeatGenerated: Float
    let Damage: Float
    let Tonnage: Float
    let BonusValueA: String
    let BonusValueB: String
    let Description: DescriptionInfo

    enum CodingKeys: String, CodingKey {
        case Category
        case WeaponType = "Type"
        case WeaponSubType
        case HeatGenerated
        case Damage
        case Tonnage
        case BonusValueA
        case BonusValueB
        case Description
    }

    struct DescriptionInfo: Decodable {
        let Id: String

    }

    var name: String {
        return [
            Description.Id, BonusValueA, BonusValueB
        ].compactMap {
            $0.isEmpty ? nil : $0
        }.joined(separator: "")
    }
}

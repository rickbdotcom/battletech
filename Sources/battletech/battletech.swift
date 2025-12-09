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
            "Range",
            "Damage",
            "Tonnage",
            "Heat",
            "Bonus",
            "Dmg/Ton",
            "Dmg/Heat"
        ].joined(separator: "\t") + "\n"

        files.forEach { file in
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: file))
                let weapon = try JSONDecoder().decode(Weapon.self, from: data)
                spreadsheet += [
                    weapon.Description.UIName,
                    weapon.Category,
                    weapon.WeaponType,
                    weapon.WeaponSubType,
                    String(weapon.MaxRange),
                    weapon.displayDamage,
                    weapon.displayTonnage,
                    weapon.displayHeatGenerated,
                    weapon.bonus,
                    weapon.displayDamagePerTon,
                    weapon.displayDamagePerHeat
                ].joined(separator: "\t") + "\n"
            } catch {
            }
        }

        try spreadsheet.data(using: .utf8)?.write(to: URL(fileURLWithPath: "weapons.tsv"))
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
    let ShotsWhenFired: Float
    let MaxRange: Int

    var bonus: String {
        [BonusValueA, BonusValueB].joined(separator: " ")
    }
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
        case ShotsWhenFired
        case MaxRange
    }

    struct DescriptionInfo: Decodable {
        let UIName: String
    }

    var totalDamage: Float {
        Damage * ShotsWhenFired
    }

    var displayDamagePerHeat: String {
        HeatGenerated == 0 ? "No Heat" : String(format: "%.1f", totalDamage / HeatGenerated)
    }

    var displayDamagePerTon: String {
        String(format: "%.1f", totalDamage / Tonnage)
    }

    var displayDamage: String {
        String(totalDamage)
    }

    var displayTonnage: String {
        String(Tonnage)
    }

    var displayHeatGenerated: String {
        String(HeatGenerated)
    }
}

extension String {
    var emptyNil: String? {
        isEmpty ? nil : self
    }
}

// swift run battletech --weapons "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Data/StreamingAssets/data/weapon" --weapons "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Mods/Expanded Arsenal-635-5-0-3-1687981803/ExpandedArsenal/weapons" --weapons "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Mods/Expanded Arsenal-635-5-0-3-1687981803/EliteArsenal/weapons"



import ArgumentParser
import Foundation

@main
struct BattleTech: ParsableCommand {

    @Option(help: "weapons directories")
    var weapons: [String] = []

    @Option(help: "equipment directories")
    var equipment: [String] = []

    @Flag(help: "verbose")
    var verbose = false

    func run() throws {
        try parseWeapons()
        try parseEquipment()
    }
}

protocol SpreadsheetConvertible {
    static func header() -> String
    func toRow() -> String
}

func convert<T: Decodable & SpreadsheetConvertible>(files: [String], type: T.Type, verbose: Bool) -> [String] {
    Array(Set(files.compactMap { file in
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: file))
            return try JSONDecoder().decode(T.self, from: data).toRow()
        } catch {
            if verbose {
                print(file)
                print(error)
            }
            return nil
        }
    }))
}

func jsonPaths(from paths: [String]) throws -> [String] {
    try paths.map { path in
        (try FileManager.default.subpathsOfDirectory(atPath: path)).map {
            path + "/" + $0
        }
    }.flatMap {
        $0
    }.filter {
        $0.hasSuffix(".json")
    }

}

extension String {
    var emptyNil: String? {
        isEmpty ? nil : self
    }
}

// swift run battletech --weapons "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Data/StreamingAssets/data/weapon" --weapons "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Mods/Expanded Arsenal-635-5-0-3-1687981803/ExpandedArsenal/weapons" --weapons "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Mods/Expanded Arsenal-635-5-0-3-1687981803/EliteArsenal/weapons" --mechs "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Data/StreamingAssets/data/mech" --mechs "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Mods/Expanded Arsenal-635-5-0-3-1687981803/ExpandedArsenal/mech" --mechs "/Volumes/Developer/SteamLibrary/steamapps/common/BATTLETECH/BattleTech.app/Contents/Resources/Mods/Expanded Arsenal-635-5-0-3-1687981803/EliteArsenal/mech"



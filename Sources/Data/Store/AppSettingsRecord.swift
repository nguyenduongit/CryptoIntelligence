import Foundation
import GRDB

public struct AppSettingsRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName = "app_settings"
    
    public var key: String
    public var value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

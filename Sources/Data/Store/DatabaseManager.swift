import Foundation
import GRDB

public final class DatabaseManager: @unchecked Sendable {
    public static let shared = DatabaseManager()
    
    public let dbQueue: DatabaseQueue
    
    public init(inMemory: Bool = false) {
        var queue: DatabaseQueue
        do {
            if inMemory {
                queue = try DatabaseQueue()
            } else {
                let fileManager = FileManager.default
                let appSupportURL = try fileManager.url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                ).appendingPathComponent("CryptoIntelligence", isDirectory: true)
                
                try fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
                let dbURL = appSupportURL.appendingPathComponent("crypto_research.sqlite")
                
                var config = Configuration()
                config.qos = .userInitiated
                config.foreignKeysEnabled = true
                queue = try DatabaseQueue(path: dbURL.path, configuration: config)
            }
        } catch {
            print("⚠️ DatabaseManager disk initialization error: \(error). Falling back to in-memory database.")
            queue = (try? DatabaseQueue()) ?? {
                fatalError("Critical: Failed to create even in-memory SQLite database: \(error)")
            }()
        }
        
        self.dbQueue = queue
        do {
            try setupSchema()
        } catch {
            print("⚠️ DatabaseManager schema migration error: \(error)")
        }
    }
    
    private func setupSchema() throws {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1_create_tables") { db in
            // 1. Watchlist table
            try db.create(table: "watchlist", ifNotExists: true) { t in
                t.column("symbol", .text).primaryKey()
                t.column("baseAsset", .text).notNull()
                t.column("tier", .text).notNull().defaults(to: "Chưa gán")
                t.column("status", .text).notNull().defaults(to: "Theo dõi")
                t.column("sortOrder", .integer).notNull().defaults(to: 0)
                t.column("addedAt", .datetime).notNull()
            }
            
            // 2. Candles table
            try db.create(table: "candles", ifNotExists: true) { t in
                t.column("symbol", .text).notNull()
                t.column("interval", .text).notNull()
                t.column("openTime", .integer).notNull()
                t.column("open", .double).notNull()
                t.column("high", .double).notNull()
                t.column("low", .double).notNull()
                t.column("close", .double).notNull()
                t.column("volume", .double).notNull()
                t.column("closeTime", .integer).notNull().defaults(to: 0)
                t.column("quoteVolume", .double).notNull().defaults(to: 0)
                t.column("trades", .integer).notNull().defaults(to: 0)
                t.column("isClosed", .boolean).notNull().defaults(to: true)
                t.primaryKey(["symbol", "interval", "openTime"])
            }
            
            // Index for fast interval queries
            try db.create(
                index: "idx_candles_lookup",
                on: "candles",
                columns: ["symbol", "interval", "openTime"],
                ifNotExists: true
            )
            
            // 3. App Settings table
            try db.create(table: "app_settings", ifNotExists: true) { t in
                t.column("key", .text).primaryKey()
                t.column("value", .text).notNull()
            }
        }
        
        migrator.registerMigration("v2_create_drawings_table") { db in
            try db.create(table: "drawings", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("symbol", .text).notNull()
                t.column("type", .text).notNull()
                t.column("startTime", .integer).notNull()
                t.column("startPrice", .double).notNull()
                t.column("endTime", .integer)
                t.column("endPrice", .double)
                t.column("colorHex", .text).notNull().defaults(to: "#3B82F6")
                t.column("isCompleted", .boolean).notNull().defaults(to: true)
            }
            
            try db.create(
                index: "idx_drawings_symbol",
                on: "drawings",
                columns: ["symbol"],
                ifNotExists: true
            )
        }
        
        migrator.registerMigration("v3_create_research_notes_table") { db in
            try db.create(table: "research_notes", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("symbol", .text).notNull()
                t.column("title", .text).notNull()
                t.column("content", .text).notNull()
                t.column("sentiment", .text).notNull().defaults(to: "Tăng giá (Bullish)")
                t.column("tagsJson", .text).notNull().defaults(to: "[]")
                t.column("targetPrice", .double)
                t.column("stopLoss", .double)
                t.column("timeHorizon", .text).notNull().defaults(to: "Trung hạn (1-6 tháng)")
                t.column("isPinned", .boolean).notNull().defaults(to: false)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }
            
            try db.create(
                index: "idx_research_notes_symbol",
                on: "research_notes",
                columns: ["symbol"],
                ifNotExists: true
            )
        }
        
        migrator.registerMigration("v4_create_alerts_tables") { db in
            try db.execute(sql: "DROP TABLE IF EXISTS alert_logs; DROP TABLE IF EXISTS alerts;")
        }
        
        migrator.registerMigration("v5_create_portfolio_and_papertrading_tables") { db in
            try db.execute(sql: "DROP TABLE IF EXISTS portfolio_transactions; DROP TABLE IF EXISTS portfolio_holdings; DROP TABLE IF EXISTS paper_trade_positions;")
        }
        
        migrator.registerMigration("v6_create_bot_trading_tables") { db in
            try db.execute(sql: "DROP TABLE IF EXISTS bot_execution_logs; DROP TABLE IF EXISTS trading_bots;")
        }
        
        migrator.registerMigration("v7_create_trade_signals_table") { db in
            try db.execute(sql: "DROP TABLE IF EXISTS trade_signals;")
        }
        
        migrator.registerMigration("v8_cleanup_legacy_tables") { db in
            try db.execute(sql: """
                DROP TABLE IF EXISTS alerts;
                DROP TABLE IF EXISTS alert_logs;
                DROP TABLE IF EXISTS portfolio_holdings;
                DROP TABLE IF EXISTS portfolio_transactions;
                DROP TABLE IF EXISTS paper_trade_positions;
                DROP TABLE IF EXISTS trading_bots;
                DROP TABLE IF EXISTS bot_execution_logs;
                DROP TABLE IF EXISTS trade_signals;
            """)
        }
        
        migrator.registerMigration("v8_create_order_flow_tables") { db in
            try db.create(table: "flow_trades", ifNotExists: true) { t in
                t.column("venue", .text).notNull()
                t.column("symbol", .text).notNull()
                t.column("tradeId", .text).notNull()
                t.column("timestampMs", .integer).notNull()
                t.column("price", .double).notNull()
                t.column("quantity", .double).notNull()
                t.column("isTakerBuy", .boolean).notNull()
                t.primaryKey(["venue", "symbol", "tradeId"])
            }
            try db.create(index: "idx_flow_trades_retention", on: "flow_trades",
                          columns: ["timestampMs"], ifNotExists: true)
            try db.create(table: "flow_minutes", ifNotExists: true) { t in
                t.column("venue", .text).notNull()
                t.column("symbol", .text).notNull()
                t.column("minuteMs", .integer).notNull()
                t.column("priceBin", .integer).notNull()
                t.column("buyQuantity", .double).notNull()
                t.column("sellQuantity", .double).notNull()
                t.primaryKey(["venue", "symbol", "minuteMs", "priceBin"])
            }
            try db.create(index: "idx_flow_minutes_retention", on: "flow_minutes",
                          columns: ["minuteMs"], ifNotExists: true)
            try db.create(table: "flow_sessions", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("venue", .text).notNull()
                t.column("symbol", .text).notNull()
                t.column("startMs", .integer).notNull()
                t.column("lastSeenMs", .integer).notNull()
                t.column("endMs", .integer)
            }
            try db.create(index: "idx_flow_sessions_lookup", on: "flow_sessions",
                          columns: ["venue", "symbol", "startMs"], ifNotExists: true)
        }

        try migrator.migrate(dbQueue)
    }
}

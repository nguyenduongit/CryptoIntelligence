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
            try db.create(table: "alerts", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("symbol", .text).notNull()
                t.column("alertType", .text).notNull()
                t.column("targetValue", .double).notNull()
                t.column("conditionDescription", .text).notNull()
                t.column("note", .text).notNull().defaults(to: "")
                t.column("status", .text).notNull().defaults(to: "active")
                t.column("soundEnabled", .boolean).notNull().defaults(to: true)
                t.column("notificationEnabled", .boolean).notNull().defaults(to: true)
                t.column("isRepeating", .boolean).notNull().defaults(to: false)
                t.column("cooldownMinutes", .integer).notNull().defaults(to: 15)
                t.column("lastTriggeredAt", .datetime)
                t.column("createdAt", .datetime).notNull()
            }
            
            try db.create(
                index: "idx_alerts_symbol",
                on: "alerts",
                columns: ["symbol"],
                ifNotExists: true
            )
            
            try db.create(table: "alert_logs", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("alertId", .text).notNull()
                t.column("symbol", .text).notNull()
                t.column("title", .text).notNull()
                t.column("message", .text).notNull()
                t.column("triggerPrice", .double).notNull()
                t.column("triggeredAt", .datetime).notNull()
            }
            
            try db.create(
                index: "idx_alert_logs_symbol",
                on: "alert_logs",
                columns: ["symbol"],
                ifNotExists: true
            )
        }
        
        migrator.registerMigration("v5_create_portfolio_and_papertrading_tables") { db in
            // 1. Portfolio Holdings
            try db.create(table: "portfolio_holdings", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("symbol", .text).notNull()
                t.column("baseAsset", .text).notNull()
                t.column("totalQuantity", .double).notNull()
                t.column("avgBuyPriceUSD", .double).notNull()
                t.column("totalInvestedUSD", .double).notNull()
                t.column("targetPriceUSD", .double)
                t.column("stopLossPriceUSD", .double)
                t.column("notes", .text)
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
            }
            
            try db.create(
                index: "idx_portfolio_holdings_symbol",
                on: "portfolio_holdings",
                columns: ["symbol"],
                ifNotExists: true
            )
            
            // 2. Portfolio Transactions
            try db.create(table: "portfolio_transactions", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("holdingSymbol", .text).notNull()
                t.column("type", .text).notNull()
                t.column("quantity", .double).notNull()
                t.column("priceUSD", .double).notNull()
                t.column("feeUSD", .double).notNull().defaults(to: 0.0)
                t.column("timestamp", .datetime).notNull()
                t.column("notes", .text)
            }
            
            try db.create(
                index: "idx_portfolio_transactions_symbol",
                on: "portfolio_transactions",
                columns: ["holdingSymbol"],
                ifNotExists: true
            )
            
            // 3. Paper Trading Positions & Journal
            try db.create(table: "paper_trade_positions", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("symbol", .text).notNull()
                t.column("baseAsset", .text).notNull()
                t.column("side", .text).notNull()
                t.column("status", .text).notNull()
                t.column("entryPriceUSD", .double).notNull()
                t.column("exitPriceUSD", .double)
                t.column("quantity", .double).notNull()
                t.column("leverage", .double).notNull().defaults(to: 1.0)
                t.column("stopLossUSD", .double)
                t.column("takeProfitUSD", .double)
                t.column("realizedPnLUSD", .double)
                t.column("realizedReturnPercent", .double)
                t.column("notes", .text)
                t.column("entryTime", .datetime).notNull()
                t.column("exitTime", .datetime)
            }
            
            try db.create(
                index: "idx_paper_trade_positions_symbol",
                on: "paper_trade_positions",
                columns: ["symbol"],
                ifNotExists: true
            )
        }
        
        migrator.registerMigration("v6_create_bot_trading_tables") { db in
            // 1. Trading Bot Instances
            try db.create(table: "trading_bots", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("config", .text).notNull()
                t.column("status", .text).notNull().defaults(to: "Đang chạy")
                t.column("createdAt", .datetime).notNull()
                t.column("updatedAt", .datetime).notNull()
                t.column("totalTradesCount", .integer).notNull().defaults(to: 0)
                t.column("winningTradesCount", .integer).notNull().defaults(to: 0)
                t.column("totalRealizedPnLUSD", .double).notNull().defaults(to: 0.0)
                t.column("currentUnrealizedPnLUSD", .double).notNull().defaults(to: 0.0)
                t.column("totalFeesPaidUSD", .double).notNull().defaults(to: 0.0)
                t.column("peakCapitalUSD", .double).notNull().defaults(to: 0.0)
                t.column("maxDrawdownPercent", .double).notNull().defaults(to: 0.0)
                t.column("isCircuitBreakerTripped", .boolean).notNull().defaults(to: false)
            }
            
            // 2. Bot Execution Logs
            try db.create(table: "bot_execution_logs", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("botId", .text).notNull()
                t.column("botName", .text).notNull()
                t.column("symbol", .text).notNull()
                t.column("action", .text).notNull()
                t.column("side", .text).notNull()
                t.column("executionPriceUSD", .double).notNull()
                t.column("quantity", .double).notNull()
                t.column("feeUSD", .double).notNull().defaults(to: 0.0)
                t.column("slippageUSD", .double).notNull().defaults(to: 0.0)
                t.column("realizedPnLUSD", .double)
                t.column("triggerReason", .text).notNull()
                t.column("timestamp", .datetime).notNull()
            }
            
            try db.create(
                index: "idx_bot_logs_botId",
                on: "bot_execution_logs",
                columns: ["botId"],
                ifNotExists: true
            )
        }
        
        migrator.registerMigration("v7_create_trade_signals_table") { db in
            try db.create(table: "trade_signals", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("symbol", .text).notNull()
                t.column("baseAsset", .text).notNull()
                t.column("marketType", .text).notNull()
                t.column("direction", .text).notNull()
                t.column("category", .text).notNull()
                t.column("timeframe", .text).notNull().defaults(to: "4H")
                t.column("entryPriceUSD", .double).notNull()
                t.column("stopLossPriceUSD", .double).notNull()
                t.column("takeProfit1USD", .double).notNull()
                t.column("takeProfit2USD", .double).notNull()
                t.column("takeProfit3USD", .double).notNull()
                t.column("currentPriceUSD", .double).notNull()
                t.column("exitPriceUSD", .double)
                t.column("score", .integer).notNull().defaults(to: 85)
                t.column("riskRewardRatio", .double).notNull().defaults(to: 2.5)
                t.column("title", .text).notNull()
                t.column("reason", .text).notNull()
                t.column("status", .text).notNull().defaults(to: "pending")
                t.column("maxProfitPercent", .double).notNull().defaults(to: 0.0)
                t.column("maxLossPercent", .double).notNull().defaults(to: 0.0)
                t.column("realizedPnLPercent", .double)
                t.column("createdAt", .datetime).notNull()
                t.column("triggeredAt", .datetime)
                t.column("closedAt", .datetime)
            }
            
            try db.create(
                index: "idx_trade_signals_symbol",
                on: "trade_signals",
                columns: ["symbol"],
                ifNotExists: true
            )
            
            try db.create(
                index: "idx_trade_signals_status",
                on: "trade_signals",
                columns: ["status"],
                ifNotExists: true
            )
        }
        
        try migrator.migrate(dbQueue)
    }
}

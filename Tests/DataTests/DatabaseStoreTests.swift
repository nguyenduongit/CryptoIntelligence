import Testing
import Foundation
import GRDB
@testable import CryptoResearch

struct DatabaseStoreTests {
    
    @Test func testWatchlistInsertAndFetch() throws {
        let dbManager = DatabaseManager(inMemory: true)
        let item = WatchlistItem(
            symbol: "BTCUSDT",
            baseAsset: "BTC",
            tier: .core,
            status: .holding,
            sortOrder: 0
        )
        
        try dbManager.dbQueue.write { db in
            let record = WatchlistRecord(item: item)
            try record.insert(db)
        }
        
        let fetched = try dbManager.dbQueue.read { db in
            try WatchlistRecord.fetchAll(db)
        }
        
        #expect(fetched.count == 1)
        #expect(fetched[0].symbol == "BTCUSDT")
        #expect(fetched[0].tier == "Core")
        #expect(fetched[0].status == "Đang nắm giữ")
    }
    
    @Test func testCandleBatchInsertAndQuery() throws {
        let dbManager = DatabaseManager(inMemory: true)
        var candles = [Candle]()
        let baseTime: Int64 = 1700000000000
        
        for i in 0..<500 {
            let candle = Candle(
                openTime: baseTime + Int64(i * 3600 * 1000),
                open: 50000.0 + Double(i),
                high: 50100.0 + Double(i),
                low: 49900.0 + Double(i),
                close: 50050.0 + Double(i),
                volume: 100.0 + Double(i)
            )
            candles.append(candle)
        }
        
        let records = candles.map { CandleRecord(symbol: "BTCUSDT", interval: "1h", candle: $0) }
        
        try dbManager.dbQueue.write { db in
            for rec in records {
                try rec.save(db)
            }
        }
        
        let fetchedRecords = try dbManager.dbQueue.read { db in
            try CandleRecord
                .filter(Column("symbol") == "BTCUSDT" && Column("interval") == "1h")
                .order(Column("openTime").asc)
                .fetchAll(db)
        }
        
        #expect(fetchedRecords.count == 500)
        #expect(fetchedRecords[0].openTime == baseTime)
        #expect(fetchedRecords[499].open == 50499.0)
    }
    
    @Test func testWatchlistViewModelToggle() throws {
        let dbManager = DatabaseManager(inMemory: true)
        let vm = WatchlistViewModel(dbManager: dbManager)
        
        // Initial seed has BTCUSDT, ETHUSDT, SOLUSDT, BNBUSDT, DOGEUSDT
        #expect(vm.isInWatchlist(symbol: "BTCUSDT") == true)
        #expect(vm.isInWatchlist(symbol: "btcusdt") == true)
        #expect(vm.isInWatchlist(symbol: "AVAXUSDT") == false)
        
        // Toggle new symbol AVAXUSDT -> adds it
        vm.toggleWatchlist(symbol: "AVAXUSDT")
        #expect(vm.isInWatchlist(symbol: "AVAXUSDT") == true)
        let avaxItem = vm.items.first(where: { $0.symbol == "AVAXUSDT" })
        #expect(avaxItem != nil)
        #expect(avaxItem?.baseAsset == "AVAX")
        
        // Toggle again -> removes it
        vm.toggleWatchlist(symbol: "AVAXUSDT")
        #expect(vm.isInWatchlist(symbol: "AVAXUSDT") == false)
    }
}

# CryptoIntelligence (Crypto Quantitative & Research Terminal)

Ứng dụng macOS native (Swift 6, SwiftUI, GRDB) dành cho nghiên cứu và phân tích định lượng chuyên sâu thị trường tiền mã hóa, tích hợp luồng dữ liệu Binance Spot thời gian thực, chart nến Canvas 60fps+, bộ chỉ báo kỹ thuật số học thuần Swift, và hệ thống phân tích hợp lưu 5 trụ cột (Confluence Research).

---

## 🏛️ Kiến Trúc Hệ Thống & Ranh Giới Dữ Liệu

Ứng dụng phân định minh bạch giữa **Dữ liệu thật (Live Market Data)**, **Thuật toán Real-time**, và **Dữ liệu kịch bản / mô phỏng (Simulated / Research Catalog)**:

| Phân Hệ | Nguồn Dữ Liệu | Trạng Thái & Cơ Chế |
| :--- | :--- | :--- |
| **Chart Nến & Bản Vẽ** | 🟢 **Live Binance Spot** | Nến REST + WebSocket klines, SQLite Cache, SwiftUI Canvas vẽ 60fps+ với LOD tự động khi nến < 1.5px. |
| **Watchlist & Tickers 24h** | 🟢 **Live Binance Spot** | Token-bucket rate limiter < 50% trần Binance, cập nhật realtime qua WebSocket ticker stream. |
| **Ghi Chú & Kế Hoạch Đầu Tư** | 🟢 **Local SQLite (GRDB)** | Bảng `research_notes` và `drawings` lưu trữ vĩnh viễn trên máy người dùng. |
| **Phân Tích Kỹ Thuật Confluence** | 🟢 **Thuật Toán Real-Time** | `ConfluenceResearchEngine` tải nến 4H thật từ Binance, tính RSI-14, EMA20/50 cross, MACD histogram qua `IndicatorEngine`. |
| **Hồ Sơ On-Chain, Macro, Tokenomics** | 🔬 **Research Catalog + Giá Live** | Mô hình định giá MVRV, LTH/STH, lịch họp Fed, phân bổ Vesting kết hợp lớp giá live Binance có gắn nhãn `DataSourceBadge`. |

---

## 🧭 Cấu Trúc Điều Hướng (2 Tab Chính & 9 Sub-tab Nghiên Cứu)

```
CryptoIntelligence/
├── 1. 🔍 Nghiên Cứu Coin (Coin Analysis)
│   ├── Tổng Quan (Hợp Lưu Định Lượng 5 Trụ & Luận Điểm)
│   ├── Chart Kỹ Thuật (Nến Canvas + Chỉ Báo + Drawing Tool)
│   ├── Phái Sinh & Thanh Lý (Funding Rate, OI, Liquidation Walls)
│   ├── Tokenomics (Supply Ratio, Lịch Mở Khóa Vesting)
│   ├── On-Chain & Chu Kỳ (MVRV Z-Score, ETF Flows, LTH Supply)
│   ├── Smart Money (DEX Whale Swaps, CEX Netflows)
│   ├── Hồ Sơ Dự Án (Tech Architecture, Github Activity, Team)
│   ├── Bảo Mật & Pháp Lý (Audit Score, Contract Risk)
│   └── Ghi Chú Cá Nhân (Research Journal & Thesis)
├── 2. 🌐 Phân Hệ Thị Trường (Vốn Hóa, Kinh Tế Vĩ Mô, Top Biến Động, Radar Screener)
└── 3. ⚙️ Cài Đặt Hệ Thống (Settings, Database Maintenance, API Keys)
```

---

## ⚡ Quyết Định Kỹ Thuật (Key Architectural Choices)

- **Ngôn ngữ & Nền tảng**: Swift 6.0 Strict Concurrency, macOS 14+ Sonoma / macOS 15+ Sequoia.
- **Giao diện**: SwiftUI kết hợp AppKit (`NSViewRepresentable` cho event tracking cử chỉ chuột / trackpad mượt mà).
- **Trạng thái (State Management)**: `@Observable` (Observation framework) & Swift Actors (`actor BinanceCandleProvider`, `actor DatabaseManager`).
- **Engine Chỉ Báo (Indicator Arithmetic)**:
  - SMA, EMA (12, 26, 50, 200, Ribbon), Bollinger Bands, RSI, StochRSI, MACD, ATR, VWAP, Volume MA.
  - Được kiểm chứng toán học độc lập với sai số $\le 10^{-9}$ so với các thư viện chuẩn (Python `ta` / `pandas`).
- **Cơ Sở Dữ Liệu**: **GRDB.swift 7.x** (SQLite Native với Migrations bảo toàn toàn vẹn dữ liệu).

---

## 🧪 Kiểm Thử Tự Động (Testing)

Chạy toàn bộ test suite (119 tests bao gồm toán học chỉ báo, Anchored VWAP, benchmark 50,000 nến, Deribit Options, Multi-Exchange Orderbook, Portfolio Stress-Test, CRUD SQLite, rate limiter):

```bash
swift test
```

Tất cả 119 tests đều vượt qua (100% pass) với độ trễ benchmark < 1s cho 50,000 nến và pan/zoom render ở tốc độ 600+ FPS.

Build và khởi chạy ứng dụng macOS:

```bash
swift build && cp .build/debug/CryptoResearch CryptoResearch.app/Contents/MacOS/CryptoResearch && open CryptoResearch.app
```

import Foundation

public enum CryptoSector: String, CaseIterable, Identifiable, Sendable, Codable {
    case all = "Tất cả"
    case layer1 = "Layer 1"
    case layer2 = "Layer 2"
    case defi = "DeFi"
    case ai = "AI & Big Data"
    case meme = "Meme Coins"
    case rwa = "RWA"
    case depin = "DePIN & Infra"
    case gaming = "Gaming & NFT"
    case cex = "CEX / Exchange"
    case others = "Khác"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .all: return "square.grid.2x2.fill"
        case .layer1: return "network"
        case .layer2: return "layers.fill"
        case .defi: return "chart.bar.xaxis"
        case .ai: return "brain.head.profile"
        case .meme: return "face.smiling.inverse"
        case .rwa: return "building.columns.fill"
        case .depin: return "server.rack"
        case .gaming: return "gamecontroller.fill"
        case .cex: return "arrow.left.arrow.right.circle.fill"
        case .others: return "circle.grid.cross.fill"
        }
    }
    
    public static func categorize(baseAsset: String) -> CryptoSector {
        let asset = baseAsset.uppercased()
        
        // Layer 1
        if ["BTC", "ETH", "SOL", "BNB", "ADA", "AVAX", "NEAR", "SUI", "APT", "DOT", "ATOM", "FTM", "ALGO", "HBAR", "KAS", "SEI", "INJ", "TON", "TRX", "XRP", "LTC", "BCH", "ETC", "ICP", "EOS", "XTZ", "EGLD", "FLOW", "KAVA", "MINA", "KLAY", "CELO"].contains(asset) {
            return .layer1
        }
        
        // Layer 2
        if ["ARB", "OP", "MATIC", "POL", "BLAST", "STRK", "ZK", "MANTA", "METIS", "IMX", "STX", "LRC", "BOBA", "DYDX"].contains(asset) {
            return .layer2
        }
        
        // DeFi
        if ["UNI", "AAVE", "MKR", "LDO", "PENDLE", "CRV", "SNX", "COMP", "RUNE", "JUP", "RAY", "CAKE", "1INCH", "SUSHI", "BAL", "YFI", "CVX", "GMX", "ORCA", "SYN", "OSMO", "KNC", "RPL", "FXS", "ENA", "ETHFI"].contains(asset) {
            return .defi
        }
        
        // AI & Big Data
        if ["FET", "RENDER", "RNDR", "TAO", "AKT", "GRT", "OCEAN", "WLD", "ARKM", "AGIX", "IO", "AI", "NFP", "PHB", "NMR", "GLM", "TURBO", "ASI"].contains(asset) {
            return .ai
        }
        
        // Meme Coins
        if ["DOGE", "SHIB", "PEPE", "WIF", "BONK", "FLOKI", "BOME", "MEME", "POPCAT", "NEIRO", "MEW", "MYRO", "PEOPLE", "SLERF", "DOGS", "CATI", "1000SATS", "ORDI"].contains(asset) {
            return .meme
        }
        
        // RWA (Real World Assets)
        if ["ONDO", "OM", "CFG", "TRAC", "POLYX", "MPL", "GFI", "TOKEN", "PROPS"].contains(asset) {
            return .rwa
        }
        
        // DePIN & Infrastructure
        if ["FIL", "AR", "TIA", "THETA", "HNT", "POKT", "PYTH", "LINK", "BAND", "API3", "ANKR", "POWR", "STORJ", "SC", "IOTX", "JASMY", "NOS", "ALEPH"].contains(asset) {
            return .depin
        }
        
        // Gaming & NFT
        if ["GALA", "AXS", "SAND", "MANA", "BEAM", "RONIN", "RON", "PIXEL", "PORTAL", "ILV", "YGG", "ENJ", "MAGIC", "BIGTIME", "SUPER", "APE", "BLUR", "LOOKS"].contains(asset) {
            return .gaming
        }
        
        // CEX
        if ["BUSD", "FDUSD", "TUSD", "USDC", "KCS", "HT", "MX", "GT", "OKB", "WRX"].contains(asset) {
            return .cex
        }
        
        return .others
    }
}

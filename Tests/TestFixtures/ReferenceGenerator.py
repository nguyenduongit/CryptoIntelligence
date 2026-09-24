import json
import math

def generate_reference():
    with open('Tests/TestFixtures/btc_1h_raw.json', 'r') as f:
        raw_candles = json.load(f)

    candles = []
    closes = []
    volumes = []
    
    for c in raw_candles:
        candle = {
            "openTime": int(c[0]),
            "open": float(c[1]),
            "high": float(c[2]),
            "low": float(c[3]),
            "close": float(c[4]),
            "volume": float(c[5]),
            "closeTime": int(c[6]),
            "quoteVolume": float(c[7]),
            "trades": int(c[8]),
            "isClosed": True
        }
        candles.append(candle)
        closes.append(candle["close"])
        volumes.append(candle["volume"])

    n = len(closes)

    # 1. SMA(20)
    sma20 = [None] * n
    for i in range(19, n):
        sma20[i] = sum(closes[i-19:i+1]) / 20.0

    # 2. EMA(12)
    ema12 = [None] * n
    if n >= 12:
        alpha12 = 2.0 / (12 + 1)
        ema12[11] = sum(closes[0:12]) / 12.0
        for i in range(12, n):
            ema12[i] = closes[i] * alpha12 + ema12[i-1] * (1.0 - alpha12)

    # 3. Bollinger Bands (20, 2)
    boll_mid = [None] * n
    boll_upper = [None] * n
    boll_lower = [None] * n
    for i in range(19, n):
        mid = sma20[i]
        boll_mid[i] = mid
        sum_sq = sum((x - mid) ** 2 for x in closes[i-19:i+1])
        pop_std = math.sqrt(sum_sq / 20.0)
        boll_upper[i] = mid + 2.0 * pop_std
        boll_lower[i] = mid - 2.0 * pop_std

    # 4. RSI(14)
    rsi14 = [None] * n
    if n > 14:
        gains = [0.0] * n
        losses = [0.0] * n
        for i in range(1, n):
            diff = closes[i] - closes[i-1]
            if diff > 0:
                gains[i] = diff
            else:
                losses[i] = -diff
        
        avg_gain = sum(gains[1:15]) / 14.0
        avg_loss = sum(losses[1:15]) / 14.0
        if avg_loss == 0.0:
            rsi14[14] = 100.0
        elif avg_gain == 0.0:
            rsi14[14] = 0.0
        else:
            rs = avg_gain / avg_loss
            rsi14[14] = 100.0 - (100.0 / (1.0 + rs))

        for i in range(15, n):
            avg_gain = (avg_gain * 13.0 + gains[i]) / 14.0
            avg_loss = (avg_loss * 13.0 + losses[i]) / 14.0
            if avg_loss == 0.0:
                rsi14[i] = 100.0
            elif avg_gain == 0.0:
                rsi14[i] = 0.0
            else:
                rs = avg_gain / avg_loss
                rsi14[i] = 100.0 - (100.0 / (1.0 + rs))

    # 5. MACD (12, 26, 9)
    # slow EMA 26
    ema26 = [None] * n
    if n >= 26:
        alpha26 = 2.0 / (26 + 1)
        ema26[25] = sum(closes[0:26]) / 26.0
        for i in range(26, n):
            ema26[i] = closes[i] * alpha26 + ema26[i-1] * (1.0 - alpha26)

    macd_line = [None] * n
    for i in range(25, n):
        if ema12[i] is not None and ema26[i] is not None:
            macd_line[i] = ema12[i] - ema26[i]

    signal_line = [None] * n
    histogram = [None] * n
    valid_macd = [v for v in macd_line if v is not None]
    if len(valid_macd) >= 9:
        alpha9 = 2.0 / (9 + 1)
        # initial signal is SMA of first 9 macd points
        sig_val = sum(valid_macd[0:9]) / 9.0
        signal_line[25 + 8] = sig_val
        histogram[25 + 8] = macd_line[25 + 8] - sig_val
        for offset in range(9, len(valid_macd)):
            idx = 25 + offset
            sig_val = valid_macd[offset] * alpha9 + sig_val * (1.0 - alpha9)
            signal_line[idx] = sig_val
            histogram[idx] = macd_line[idx] - sig_val

    # 6. ATR(14)
    atr14 = [None] * n
    if n >= 14:
        tr = [0.0] * n
        tr[0] = candles[0]["high"] - candles[0]["low"]
        for i in range(1, n):
            h = candles[i]["high"]
            l = candles[i]["low"]
            prev_c = candles[i-1]["close"]
            tr[i] = max(h - l, abs(h - prev_c), abs(l - prev_c))
        
        curr_atr = sum(tr[0:14]) / 14.0
        atr14[13] = curr_atr
        for i in range(14, n):
            curr_atr = (curr_atr * 13.0 + tr[i]) / 14.0
            atr14[i] = curr_atr

    # 7. Volume MA(20)
    vol_ma20 = [None] * n
    for i in range(19, n):
        vol_ma20[i] = sum(volumes[i-19:i+1]) / 20.0

    output = {
        "candles": candles,
        "sma20": sma20,
        "ema12": ema12,
        "bollinger_mid": boll_mid,
        "bollinger_upper": boll_upper,
        "bollinger_lower": boll_lower,
        "rsi14": rsi14,
        "macd_line": macd_line,
        "macd_signal": signal_line,
        "macd_histogram": histogram,
        "atr14": atr14,
        "volume_ma20": vol_ma20
    }

    with open('Tests/TestFixtures/btc_1h_computed.json', 'w') as f:
        json.dump(output, f, indent=2)
    print(f"Generated reference fixture with {len(candles)} candles successfully.")

if __name__ == '__main__':
    generate_reference()

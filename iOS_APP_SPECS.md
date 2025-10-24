# iOS App Specification: GPIX Swing Trading Signal App

## Project Overview

A native iOS app that provides real-time 30-minute swing trading signals for GPIX (Goldman Sachs Equity Premium Income ETF) based on the technical analysis system developed in the Ray Dalio Economic Cycle Backtester.

## App Name Ideas
- **GPIX Signal** (simple, direct)
- **SwingAlert: GPIX Edition**
- **GPIX Trader**
- **PremiumSwing** (referencing the ETF name)

## Core Functionality

### 1. Real-Time Signal Display

**Main Screen Features:**
- Large, clear BUY/SELL/HOLD signal indicator
- Current GPIX price (real-time or 15-min delayed)
- Price change ($ and %) for the day
- **Economic Cycle Badge** (prominent, color-coded)
  - Shows current market state: Expansion/Peak/Contraction/Recovery
  - Matches colors established in web app
  - Provides context for trading decisions
- Last signal timestamp
- Time until next signal check (countdown to next 30-min bar close)

**Signal Logic:**
- **BUY Signal**: Price < Lower Bollinger Band AND RSI < 30
- **SELL Signal**: Price > Upper Bollinger Band OR RSI > 70 OR Stop Loss hit
- **HOLD**: No action (currently in position or waiting for setup)

### 2. Technical Indicators Panel

**Collapsible/Swipeable Card Showing:**
- **Bollinger Bands** (20-period, 2 std dev)
  - Upper Band value
  - Middle Band (20 SMA) value
  - Lower Band value
  - Current price position relative to bands (visual bar)

- **RSI** (14-period)
  - Current RSI value
  - Visual gauge (0-100, with 30/70 markers)
  - Color-coded: Green (<30), Yellow (30-70), Red (>70)

- **Current Trend**
  - Price above/below 20 SMA
  - Distance from SMA (%)

### 3. Price Chart

**Interactive Chart Features:**
- 30-minute candlestick chart
- Overlaid Bollinger Bands (red upper, blue middle, green lower)
- Buy/Sell signal markers on chart
- Pinch to zoom (1 day, 3 days, 5 days, 2 weeks views)
- Pan to scroll through history
- RSI subplot below main chart

**Economic Cycle Display (Two Options):**

**Option A - Status Badge Below Chart:**
- Prominent badge/pill showing current cycle state
- Color-coded by cycle:
  - 🟢 **Expansion**: #34C759 (green)
  - 🟡 **Peak**: #FF9500 (orange/yellow)
  - 🔴 **Contraction**: #FF3B30 (red)
  - 🔵 **Recovery**: #0071E3 (blue)
- Shows: "Current Market State: EXPANSION" or icon + text
- Positioned between price chart and RSI chart
- Tappable for details (GDP growth, unemployment, etc.)

**Option B - Cycle Background Overlay:**
- Colored background bands behind the price chart
- Semi-transparent colored regions marking cycle periods
- Smooth transitions between cycle changes
- Legend showing cycle colors in chart corner
- More visual/contextual but less prominent

**Recommended: Option A** for clarity and immediate visibility

**Chart Library Options:**
- Charts framework (native iOS)
- SwiftUI Charts (iOS 16+)
- Third-party: TradingView lightweight charts

### 4. Push Notifications

**Alert Types:**
- **New BUY Signal**: "🟢 BUY Signal for GPIX at $XX.XX - RSI: XX, Below BB Lower"
- **New SELL Signal**: "🔴 SELL Signal for GPIX at $XX.XX - Hit upper BB / RSI overbought"
- **Stop Loss Hit**: "⚠️ Stop Loss triggered on GPIX at $XX.XX (-2%)"
- **Custom Price Alerts**: User-set price levels

**Notification Settings:**
- Toggle each alert type on/off
- Quiet hours (e.g., no alerts 10 PM - 7 AM)
- Alert sound selection
- Badge icon on app

### 5. Position Tracking

**If User Enters Position:**
- Entry price
- Entry timestamp
- Current P&L ($ and %)
- Unrealized gain/loss
- Stop loss level (2% below entry, adjustable)
- Position duration
- Exit signal status

**Position Entry:**
- Manual entry button
- "Enter Position at Current Price"
- Custom entry price option
- Number of shares (optional)

### 6. Trade History

**Historical Record:**
- List of past trades
- Entry/Exit dates and times
- Entry/Exit prices
- Return % for each trade
- Win/Loss indicator
- Exit reason (STOP_LOSS, PROFIT_TARGET, TECHNICAL)

**Analytics:**
- Total trades
- Win rate
- Average win %
- Average loss %
- Best/worst trade
- Total P&L (if shares tracked)

### 7. Settings & Configuration

**Customizable Parameters:**
- **Bollinger Bands**: Period (default 20), Std Dev (default 2.0)
- **RSI**: Period (default 14), Oversold (default 30), Overbought (default 70)
- **Stop Loss**: Percentage (default 2%)
- **Profit Target**: Optional, percentage
- **Data Refresh Rate**: 1 min, 5 min, 15 min, 30 min
- **Market Hours Only**: Toggle (default: ON)

**Display Settings:**
- Dark mode / Light mode / Auto
- Chart color scheme
- Price display precision (2 or 4 decimal places)
- Time zone

**Account & Data:**
- API key management (Polygon.io)
- Data usage statistics
- Clear cache

### 8. Economic Filter (Optional Feature)

**Toggle to Enable:**
- Only show BUY signals during Economic Expansion
- Fetch economic cycle data from FRED API
- Display current cycle stage (Expansion/Peak/Contraction/Recovery)
- Visual indicator on main screen

**Implementation:**
- Cache economic data (updates daily)
- Show last update timestamp
- Manual refresh button

### 9. Educational Info

**Help Section:**
- What are Bollinger Bands?
- What is RSI?
- How signals are generated
- Risk disclaimer
- Link to full backtester web app

## Technical Architecture

### Data Layer

**Data Sources:**
1. **Polygon.io REST API**
   - 30-minute bars for GPIX
   - Real-time or near-real-time price updates
   - Historical data for chart

2. **FRED API** (if economic filter enabled)
   - Economic indicators
   - Daily updates sufficient

**Data Models:**
```swift
struct PriceBar {
    let timestamp: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
}

struct TechnicalIndicators {
    let bollingerUpper: Double
    let bollingerMiddle: Double
    let bollingerLower: Double
    let rsi: Double
    let atr: Double
}

enum CycleStage: String {
    case expansion = "Expansion"
    case peak = "Peak"
    case contraction = "Contraction"
    case recovery = "Recovery"

    var color: Color {
        switch self {
        case .expansion: return Color(hex: "#34C759") // Green
        case .peak: return Color(hex: "#FF9500")      // Orange
        case .contraction: return Color(hex: "#FF3B30") // Red
        case .recovery: return Color(hex: "#0071E3")  // Blue
        }
    }

    var emoji: String {
        switch self {
        case .expansion: return "🟢"
        case .peak: return "🟡"
        case .contraction: return "🔴"
        case .recovery: return "🔵"
        }
    }
}

struct EconomicCycle {
    let stage: CycleStage
    let timestamp: Date
    let gdpGrowth: Double?
    let unemployment: Double?
    let inflation: Double?
    let yieldCurve: Double?
}

struct Signal {
    let type: SignalType // .buy, .sell, .hold
    let timestamp: Date
    let price: Double
    let rsi: Double
    let reason: String
    let cycleStage: CycleStage? // Context for the signal
}

struct Position {
    let entryPrice: Double
    let entryDate: Date
    let shares: Int?
    let stopLoss: Double
    var currentPrice: Double
    var unrealizedPL: Double
    let entryCycleStage: CycleStage? // Cycle when position entered
}

struct Trade {
    let entryPrice: Double
    let exitPrice: Double
    let entryDate: Date
    let exitDate: Date
    let returnPct: Double
    let exitReason: ExitReason
    let entryCycleStage: CycleStage?
    let exitCycleStage: CycleStage?
}
```

### Calculation Engine

**Technical Indicator Calculator:**
- Reuse Python logic from `technical_indicators.py`
- Port to Swift or use Swift-compatible library
- Calculate indicators locally for speed
- Update every 30 minutes (or more frequently for responsiveness)

**Signal Generator:**
- Check conditions every minute during market hours
- Generate new signal if conditions change
- Track current state (waiting, in position, etc.)

### Networking Layer

**API Service:**
```swift
protocol MarketDataService {
    func fetchLatestBar(symbol: String) async throws -> PriceBar
    func fetchBars(symbol: String, days: Int) async throws -> [PriceBar]
    func fetchEconomicData() async throws -> EconomicCycle
}
```

**Rate Limiting:**
- Polygon.io free tier: 5 calls/minute
- Implement request queue
- Cache results appropriately
- Show API usage in settings

### Storage Layer

**Local Persistence:**
- **Core Data** or **SwiftData** (iOS 17+)
  - Store trade history
  - Store price bars for offline viewing
  - Store user positions
  - Store settings

- **UserDefaults** for:
  - App settings
  - API keys (use Keychain for security)
  - Notification preferences

- **Keychain** for:
  - API keys (encrypted storage)

### UI Layer

**SwiftUI Architecture:**
- MVVM pattern
- Combine for reactive updates
- @StateObject for view models
- @Published properties for data binding

**Key Views:**
```
ContentView (TabView)
├── SignalView (Main dashboard)
│   ├── SignalCardView (BUY/SELL/HOLD)
│   ├── PriceInfoView (Current price, change)
│   ├── IndicatorsView (BB, RSI)
│   └── ChartView (Price chart)
├── PositionView (Current position tracking)
├── HistoryView (Trade history & analytics)
└── SettingsView (Configuration)
```

### Background Updates

**Implementation Options:**

1. **Background Fetch** (iOS Standard)
   - Update every 30 minutes during market hours
   - Fetch latest bar
   - Check for new signals
   - Send notification if signal changes

2. **Silent Push Notifications**
   - Requires backend server
   - More reliable timing
   - Better for critical updates

3. **Local Notifications**
   - Schedule based on market hours
   - Reminder to check app at key times

### Notifications

**Local Notifications:**
```swift
struct SignalNotification {
    let title: String
    let body: String
    let badge: Int?
    let sound: UNNotificationSound?
}
```

**User Permission:**
- Request on first launch
- Explain value of alerts
- Allow granular control

## Design Specifications

### Color Scheme (Apple-Style)

**Light Mode:**
- Background: #F5F5F7 (light gray)
- Card Background: #FFFFFF (white)
- Primary Text: #1D1D1F (almost black)
- Secondary Text: #6E6E73 (gray)
- Accent: #0071E3 (Apple blue)

**Signals:**
- Buy: #34C759 (green)
- Sell: #FF3B30 (red)
- Hold: #FF9500 (orange)

**Chart Colors:**
- Candles Up: #34C759
- Candles Down: #FF3B30
- BB Upper: #FF3B30
- BB Middle: #0071E3
- BB Lower: #34C759
- RSI Line: #AF52DE (purple)

**Dark Mode:**
- Background: #000000 (true black for OLED)
- Card Background: #1C1C1E (dark gray)
- Primary Text: #FFFFFF (white)
- Secondary Text: #8E8E93 (light gray)
- Maintain same signal/chart colors

### Typography

**SF Pro (System Font):**
- Large Title: 34pt, Bold (Signal indicator)
- Title: 28pt, Semibold (Section headers)
- Headline: 17pt, Semibold (Card titles)
- Body: 17pt, Regular (Main content)
- Caption: 11pt, Regular (Timestamps, footnotes)

### Layout & Spacing

**Card Style:**
- Rounded corners: 16pt radius
- Padding: 16pt
- Shadow: Light drop shadow
- Separator: 1pt hairline

**Spacing:**
- Section spacing: 24pt
- Card spacing: 16pt
- Element spacing: 8pt

### Main Screen Layout (Visual Hierarchy)

```
┌─────────────────────────────────┐
│  GPIX                    $XX.XX │  ← Nav bar
├─────────────────────────────────┤
│                                 │
│     ●  BUY SIGNAL               │  ← Large signal indicator
│     $XX.XX  (+X.XX%)            │  ← Current price
│                                 │
├─────────────────────────────────┤
│  🟢 EXPANSION                   │  ← Economic cycle badge
│  Market conditions favorable    │     (prominent, color-coded)
├─────────────────────────────────┤
│                                 │
│  [Price Chart with BB]          │  ← Interactive chart
│  ┌───────────────────────┐      │     with Bollinger Bands
│  │ Candlesticks + Bands  │      │
│  │ Buy/Sell markers      │      │
│  └───────────────────────┘      │
│                                 │
│  [RSI Chart]                    │  ← RSI subplot
│  ┌───────────────────────┐      │
│  │ RSI line with 30/70   │      │
│  └───────────────────────┘      │
├─────────────────────────────────┤
│  BB Upper:  $XX.XX    RSI: XX   │  ← Key metrics
│  BB Middle: $XX.XX               │
│  BB Lower:  $XX.XX               │
├─────────────────────────────────┤
│  [ Enter Position ]             │  ← Action button
└─────────────────────────────────┘
```

**Economic Cycle Badge Design:**
- Full-width card between price info and chart
- Left side: Colored circle/emoji matching cycle
- Center: Cycle name in bold
- Right side: Small info icon (tap for details)
- Background: Subtle gradient or solid color matching cycle
- Text: High contrast for readability

## User Flow

### First Launch
1. Welcome screen with app explanation
2. Request notification permissions
3. Enter Polygon.io API key (or "Try with demo data")
4. Quick tutorial (swipe through cards)
5. Land on main signal screen

### Typical Usage Session
1. Open app → See current signal immediately
2. Check indicators if interested in details
3. Review chart for context
4. If BUY signal and user wants to trade:
   - Tap "Enter Position"
   - Confirm entry price
   - Position now tracked
5. Receive SELL notification later
6. Return to app, review signal
7. Tap "Exit Position"
8. Trade automatically logged to history

### Background Usage
1. App running in background
2. Background fetch triggers at 30-min intervals
3. New signal detected
4. Push notification sent
5. User taps notification → Opens to signal screen

## MVP Features (Phase 1)

**Must-Have for v1.0:**
1. ✅ Real-time GPIX price display
2. ✅ 30-minute signal generation (BUY/SELL/HOLD)
3. ✅ Bollinger Bands calculation and display
4. ✅ RSI calculation and display
5. ✅ Basic price chart (last 5 days, 30-min bars)
6. ✅ Push notifications for signal changes
7. ✅ Manual position tracking (entry/exit)
8. ✅ Basic settings (indicators, notifications)
9. ✅ Dark/Light mode

**Nice-to-Have for v1.0:**
- Trade history
- P&L tracking
- Chart zoom/pan
- Multiple timeframe views

## Future Enhancements (Phase 2+)

**v1.1 - Enhanced Analytics:**
- Detailed trade statistics
- Win/loss charts
- Performance over time graphs
- Export trade history to CSV

**v1.2 - Advanced Features:**
- Economic cycle filter integration
- Multiple ticker support
- Watchlist functionality
- Custom alert conditions

**v1.3 - Automation:**
- Integration with brokerage APIs (Alpaca, Interactive Brokers)
- Paper trading mode
- Auto-execute trades (with confirmation)

**v1.4 - Social/Sharing:**
- Share signals with friends
- Community leaderboard
- Trade ideas feed
- Export charts as images

**v2.0 - Apple Watch App:**
- Glanceable signal on watch face (complication)
- Quick price check
- Notification on watch
- Haptic feedback for signals

**v3.0 - Widget Support:**
- Home screen widget showing current signal
- Lock screen widget (iOS 16+)
- Live Activity for active position tracking

## Technical Requirements

### Minimum Requirements
- iOS 16.0+ (for SwiftUI improvements)
- iPhone 8 or newer
- Internet connection required
- Polygon.io API key (free tier sufficient for single user)

### Recommended
- iOS 17.0+ (for SwiftData)
- iPhone 12 or newer
- WiFi or cellular data

### Development Tools
- Xcode 15.0+
- Swift 5.9+
- SwiftUI
- Combine framework
- Core Data or SwiftData

### Third-Party Dependencies (Potential)
- **Charts**: For advanced charting (consider native first)
- **Alamofire**: For networking (or use URLSession)
- **KeychainAccess**: For secure API key storage
- **TipKit**: For in-app tutorials (iOS 17+)

## API Requirements & Costs

### Polygon.io
- **Free Tier**: 5 API calls/minute, 2 years historical data
- **Sufficient for**: Single user, 30-min updates
- **Cost if upgrade needed**: $29/month (Starter plan)

### FRED (Optional)
- **Free**: Unlimited for personal use
- **Rate Limit**: 120 calls/minute
- **More than sufficient**

### Apple Developer
- **Required**: $99/year for App Store distribution
- **Optional**: TestFlight beta testing (free with membership)

## Development Timeline Estimate

### Phase 1 - MVP (4-6 weeks)
- **Week 1**: Project setup, data models, API integration
- **Week 2**: Technical indicator calculations, signal logic
- **Week 3**: UI design, main signal screen, chart
- **Week 4**: Notifications, position tracking
- **Week 5**: Settings, polish, bug fixes
- **Week 6**: Testing, TestFlight beta

### Phase 2 - Enhancements (2-3 weeks)
- Advanced features based on user feedback
- Performance optimization
- Additional indicators or timeframes

### Phase 3 - App Store Launch (1 week)
- Screenshots, description, marketing materials
- App Store review submission
- Launch preparation

## Monetization Strategy (Optional)

### Free Version
- Core signal functionality
- Basic indicators
- 5-day chart history
- Ad-supported (banner ads)

### Premium ($4.99/month or $39.99/year)
- Ad-free
- Extended chart history (90 days)
- Trade analytics and statistics
- Economic cycle filter
- Multiple tickers (up to 5)
- Priority support

### One-Time Purchase ($29.99)
- All features unlocked
- Lifetime access
- No recurring fees

**Recommendation**: Start with free, ad-free app. Add premium features once you have user base.

## Risk Disclaimers & Legal

**Required Disclaimers:**
- "This app provides educational signals only"
- "Not financial advice"
- "Past performance doesn't guarantee future results"
- "Trading involves risk of loss"
- "Consult a financial advisor"

**Terms of Service:**
- User agrees signals are for educational purposes
- No guarantee of accuracy or profitability
- User responsible for own trading decisions
- App developer not liable for losses

**Privacy Policy:**
- What data is collected (API keys, trade history)
- How data is stored (locally on device)
- No data sharing with third parties
- User can delete all data

## Success Metrics

**App Performance:**
- Signal accuracy (% of profitable signals)
- App crashes < 0.1%
- Notification delivery rate > 95%
- Chart load time < 2 seconds

**User Engagement:**
- Daily active users
- Average session duration
- Notification opt-in rate
- Position tracking usage rate

**Signal Quality:**
- Win rate of signals
- Average return per signal
- Risk-adjusted returns (Sharpe ratio)

## File Structure (Proposed)

```
GPIXSignalApp/
├── Models/
│   ├── PriceBar.swift
│   ├── TechnicalIndicators.swift
│   ├── Signal.swift
│   ├── Position.swift
│   └── Trade.swift
├── ViewModels/
│   ├── SignalViewModel.swift
│   ├── ChartViewModel.swift
│   ├── PositionViewModel.swift
│   └── HistoryViewModel.swift
├── Views/
│   ├── ContentView.swift
│   ├── SignalView/
│   │   ├── SignalView.swift
│   │   ├── SignalCardView.swift
│   │   ├── PriceInfoView.swift
│   │   └── IndicatorsView.swift
│   ├── ChartView/
│   │   ├── ChartView.swift
│   │   └── RSIChartView.swift
│   ├── PositionView/
│   │   ├── PositionView.swift
│   │   └── PositionDetailView.swift
│   ├── HistoryView/
│   │   ├── HistoryView.swift
│   │   ├── TradeRowView.swift
│   │   └── AnalyticsView.swift
│   └── SettingsView/
│       ├── SettingsView.swift
│       └── APIKeyView.swift
├── Services/
│   ├── PolygonService.swift
│   ├── FREDService.swift
│   ├── IndicatorCalculator.swift
│   └── SignalGenerator.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions.swift
│   └── Formatters.swift
├── Persistence/
│   ├── DataController.swift
│   └── KeychainManager.swift
└── Notifications/
    ├── NotificationManager.swift
    └── BackgroundFetchManager.swift
```

## Next Steps

1. **Review & Approve Specs**
   - Discuss any changes or additions
   - Prioritize features for MVP
   - Decide on monetization strategy

2. **Create New Project Folder**
   - Set up Xcode project
   - Initialize Git repository
   - Create README from these specs

3. **Development Phases**
   - Phase 1: Data layer & calculations
   - Phase 2: UI implementation
   - Phase 3: Notifications & background
   - Phase 4: Polish & testing

4. **Beta Testing**
   - TestFlight internal testing
   - Gather feedback
   - Iterate and improve

5. **App Store Launch**
   - Prepare marketing materials
   - Submit for review
   - Launch and monitor

---

## Questions to Consider

1. **Target Audience**: Just for personal use, or eventually for other traders?
2. **Monetization**: Free app, or premium features?
3. **Features Priority**: Which features are must-have for you?
4. **Design Preference**: Minimalist vs feature-rich?
5. **Apple Watch**: Important for you, or iPhone-only first?
6. **Multiple Tickers**: Start with GPIX-only, or build for multiple from start?

Let me know when you're ready to create the new project folder and start building! 🚀

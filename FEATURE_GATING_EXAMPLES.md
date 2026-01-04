# Feature Gating with RevenueCat

This guide shows practical examples of how to restrict features to Pro subscribers in your Poop Detector app.

## Basic Feature Gating Patterns

### 1. Simple Feature Lock

```swift
struct MyFeatureView: View {
    @State private var revenueCatManager = RevenueCatManager.shared
    @State private var showPaywall = false

    var body: some View {
        VStack {
            if revenueCatManager.isProSubscriber {
                // Show the feature
                premiumFeatureContent
            } else {
                // Show locked state
                lockedFeatureContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    var premiumFeatureContent: some View {
        Text("Premium Feature Unlocked!")
    }

    var lockedFeatureContent: some View {
        VStack {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("This feature requires Pro")
                .font(.headline)

            Button("Upgrade to Pro") {
                showPaywall = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### 2. Action-Based Gating

```swift
struct CameraView: View {
    @State private var revenueCatManager = RevenueCatManager.shared
    @State private var showPaywall = false
    @State private var scanCount = 0

    let freeScanLimit = 3

    var body: some View {
        VStack {
            Button("Scan Poop") {
                handleScanAction()
            }

            if !revenueCatManager.isProSubscriber {
                Text("Free scans remaining: \(max(0, freeScanLimit - scanCount))")
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    func handleScanAction() {
        if revenueCatManager.isProSubscriber {
            // Pro users: unlimited scans
            performScan()
        } else {
            // Free users: limited scans
            if scanCount < freeScanLimit {
                scanCount += 1
                performScan()
            } else {
                // Show paywall when limit reached
                showPaywall = true
            }
        }
    }

    func performScan() {
        // Your scan logic here
    }
}
```

### 3. Feature List with Mixed Access

```swift
struct FeaturesView: View {
    @State private var revenueCatManager = RevenueCatManager.shared
    @State private var showPaywall = false

    struct Feature: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let description: String
        let requiresPro: Bool
    }

    let features = [
        Feature(icon: "camera", title: "Basic Scanning", description: "Scan up to 3 times", requiresPro: false),
        Feature(icon: "infinity", title: "Unlimited Scans", description: "Scan as much as you want", requiresPro: true),
        Feature(icon: "chart.bar", title: "Advanced Analytics", description: "Track your scan history", requiresPro: true),
        Feature(icon: "cloud", title: "Cloud Sync", description: "Sync across devices", requiresPro: true),
    ]

    var body: some View {
        List(features) { feature in
            FeatureRow(
                feature: feature,
                isUnlocked: !feature.requiresPro || revenueCatManager.isProSubscriber,
                onTap: {
                    if feature.requiresPro && !revenueCatManager.isProSubscriber {
                        showPaywall = true
                    }
                }
            )
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct FeatureRow: View {
    let feature: FeaturesView.Feature
    let isUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? .blue : .secondary)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(feature.title)
                            .font(.headline)
                        if !isUnlocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text(feature.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !isUnlocked {
                    Text("Pro")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue)
                        )
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
```

### 4. Banner Prompt Pattern

```swift
struct ScanResultView: View {
    @State private var revenueCatManager = RevenueCatManager.shared
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Show subscription banner for free users
                if !revenueCatManager.isProSubscriber {
                    SubscriptionBannerView(
                        isProUser: false,
                        onUpgrade: { showPaywall = true },
                        onManage: { }
                    )
                    .padding(.horizontal)
                }

                // Your scan results here
                scanResultsContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    var scanResultsContent: some View {
        VStack {
            Text("Scan Results")
                .font(.title)
            // Your content
        }
    }
}
```

## Advanced Patterns

### 5. Gradual Feature Degradation

```swift
struct HistoryView: View {
    @State private var revenueCatManager = RevenueCatManager.shared
    @State private var showPaywall = false
    @Query private var allEntries: [HistoryEntry]

    var displayedEntries: [HistoryEntry] {
        if revenueCatManager.isProSubscriber {
            return allEntries // Show all
        } else {
            return Array(allEntries.prefix(10)) // Show last 10 only
        }
    }

    var body: some View {
        List {
            ForEach(displayedEntries) { entry in
                HistoryCard(entry: entry)
            }

            if !revenueCatManager.isProSubscriber && allEntries.count > 10 {
                upgradeBanner
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    var upgradeBanner: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.rectangle.stack.fill")
                .font(.largeTitle)
                .foregroundStyle(.blue)

            Text("View Full History")
                .font(.headline)

            Text("\(allEntries.count - 10) more entries available")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Upgrade to Pro") {
                showPaywall = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
```

### 6. Time-Based Trial

```swift
@Observable
@MainActor
final class TrialManager {
    static let shared = TrialManager()

    private let trialDurationKey = "trialEndDate"
    private let trialDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days

    var trialEndDate: Date? {
        get {
            UserDefaults.standard.object(forKey: trialDurationKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: trialDurationKey)
        }
    }

    var isTrialActive: Bool {
        guard let endDate = trialEndDate else {
            // First launch - start trial
            trialEndDate = Date().addingTimeInterval(trialDuration)
            return true
        }
        return Date() < endDate
    }

    var trialDaysRemaining: Int {
        guard let endDate = trialEndDate else { return 7 }
        let remaining = endDate.timeIntervalSince(Date())
        return max(0, Int(ceil(remaining / (24 * 60 * 60))))
    }
}

struct FeatureWithTrialView: View {
    @State private var revenueCatManager = RevenueCatManager.shared
    @State private var trialManager = TrialManager.shared
    @State private var showPaywall = false

    var hasAccess: Bool {
        revenueCatManager.isProSubscriber || trialManager.isTrialActive
    }

    var body: some View {
        VStack {
            if hasAccess {
                premiumContent
            } else {
                expiredTrialView
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    var premiumContent: some View {
        VStack {
            if !revenueCatManager.isProSubscriber {
                // Show trial banner
                HStack {
                    Text("Trial: \(trialManager.trialDaysRemaining) days left")
                        .font(.caption)
                    Button("Upgrade") {
                        showPaywall = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
                .padding(8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }

            // Your premium content here
            Text("Premium Feature Content")
        }
    }

    var expiredTrialView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.orange)

            Text("Trial Expired")
                .font(.title.bold())

            Text("Your 7-day trial has ended. Upgrade to Pro to continue using this feature.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Upgrade to Pro") {
                showPaywall = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
```

### 7. Feature-Specific Paywall

```swift
struct ExportFeatureView: View {
    @State private var revenueCatManager = RevenueCatManager.shared
    @State private var showPaywall = false

    var body: some View {
        VStack {
            Button("Export Data") {
                if revenueCatManager.isProSubscriber {
                    exportData()
                } else {
                    showPaywall = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showPaywall) {
            // Custom paywall emphasizing export feature
            PaywallView()
        }
        .alert("Export Complete", isPresented: $showExportSuccess) {
            Button("OK") { }
        } message: {
            Text("Your data has been exported successfully")
        }
    }

    @State private var showExportSuccess = false

    func exportData() {
        // Export logic
        showExportSuccess = true
    }
}
```

## Integration with Existing Views

### Example: Adding Pro Badge to CaptureView

```swift
// In CaptureView.swift, add to titleStack:
var titleStack: some View {
    VStack(spacing: 8) {
        HStack {
            Text("Who Did the DooDoo?")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundColor(.brown)

            if revenueCatManager.isProSubscriber {
                Image(systemName: "star.circle.fill")
                    .font(.title)
                    .foregroundStyle(.yellow)
            }
        }

        if !revenueCatManager.isProSubscriber {
            Text("Free Plan • 3 scans remaining")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

## Recommendations for Poop Detector

Based on your app, here are feature suggestions to gate behind Pro:

1. **Unlimited Scans** - Free users get 3-5 scans per day
2. **Full History** - Free users see last 10 scans only
3. **Detailed Analysis** - Free users get basic info, Pro gets scientific details
4. **Cloud Backup** - Pro-only feature
5. **Ad-Free Experience** - Remove ads for Pro users
6. **Export Reports** - Export scan results as PDF (Pro only)
7. **Advanced Filters** - Filter history by animal type, date, etc. (Pro only)
8. **Comparison Mode** - Compare multiple scans side-by-side (Pro only)

## Best Practices

1. **Always Provide Value First**
   - Let users experience the app before showing paywalls
   - Demonstrate value of Pro features

2. **Clear Communication**
   - Always show what features require Pro
   - Explain why upgrading is valuable
   - Use clear "Pro" badges

3. **Soft Paywalls**
   - Don't completely block features
   - Show preview or limited version
   - Encourage upgrade naturally

4. **Graceful Degradation**
   - When subscription expires, don't delete data
   - Allow read-only access to previous scans
   - Show clear path to re-subscribe

5. **Testing**
   - Test all gating logic
   - Verify entitlement checks work
   - Test subscription expiry scenarios

## Testing Checklist

- [ ] Free user can see limited features
- [ ] Pro user can access all features
- [ ] Paywall shows when accessing Pro features
- [ ] Restore purchases works correctly
- [ ] Expired subscription reverts to free tier
- [ ] Trial period works as expected
- [ ] Subscription status updates in real-time

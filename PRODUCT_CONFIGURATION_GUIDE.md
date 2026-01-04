# Product Configuration Guide

This guide walks you through setting up products, offerings, and entitlements in RevenueCat and App Store Connect.

## Step 1: App Store Connect Configuration

### 1.1 Create In-App Purchases

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app → Features → In-App Purchases
3. Click the + button to create new products

### 1.2 Monthly Subscription

```
Product ID: monthly
Reference Name: Monthly Subscription
Type: Auto-Renewable Subscription
Subscription Group: Poop Detector Pro Subscriptions
Duration: 1 Month

Subscription Prices:
- USA: $4.99/month
- (Set prices for other countries)

Localization (English - US):
Display Name: Monthly Pro
Description: Get unlimited poop scans, full history, and all premium features with a monthly subscription.

Review Information:
Screenshot: [Upload screenshot of app]
Review Notes: Monthly subscription for premium features
```

### 1.3 Yearly Subscription

```
Product ID: yearly
Reference Name: Annual Subscription
Type: Auto-Renewable Subscription
Subscription Group: Poop Detector Pro Subscriptions
Duration: 1 Year

Subscription Prices:
- USA: $39.99/year (Save 33%!)
- (Set prices for other countries)

Localization (English - US):
Display Name: Yearly Pro
Description: Get unlimited poop scans, full history, and all premium features. Save 33% with annual billing!

Introductory Offer (Optional):
- Type: Free Trial
- Duration: 7 days
- Eligible users: New Subscribers
```

### 1.4 Lifetime Purchase

```
Product ID: lifetime
Reference Name: Lifetime Access
Type: Non-Consumable
(Alternative: Auto-Renewable Subscription with very long duration)

Price:
- USA: $99.99
- (Set prices for other countries)

Localization (English - US):
Display Name: Lifetime Pro
Description: One-time payment for lifetime access to all premium features. Never pay again!

Note: Consider using a very long subscription (like 100 years) instead of
non-consumable if you want to use RevenueCat's subscription features.
```

## Step 2: RevenueCat Dashboard Configuration

### 2.1 Create Project and App

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com)
2. Create new project: "Poop Detector"
3. Add iOS app
4. Copy your Public API Key

### 2.2 Configure Products

1. Go to Products tab
2. Import from App Store Connect (or add manually):

```
Product: monthly
Name: Monthly Pro
Type: Subscription
App Store Product ID: monthly
Status: Active
```

```
Product: yearly
Name: Yearly Pro
Type: Subscription
App Store Product ID: yearly
Status: Active
```

```
Product: lifetime
Name: Lifetime Pro
Type: Non-Subscription (or Subscription)
App Store Product ID: lifetime
Status: Active
```

### 2.3 Create Entitlement

1. Go to Entitlements tab
2. Create entitlement:

```
Entitlement ID: Poop Detector Pro
Description: Access to all pro features including unlimited scans
Products attached:
  - monthly
  - yearly
  - lifetime
```

### 2.4 Create Offering

1. Go to Offerings tab
2. Create offering:

```
Offering ID: default
Display Name: Default Offering
Description: Standard subscription offering

Packages:
┌─────────────┬──────────┬──────────────────┐
│ Identifier  │ Product  │ Duration         │
├─────────────┼──────────┼──────────────────┤
│ $rc_monthly │ monthly  │ 1 month          │
│ $rc_annual  │ yearly   │ 1 year           │
│ $rc_lifetime│ lifetime │ Lifetime         │
└─────────────┴──────────┴──────────────────┘

Set as Default: ✓
```

**Important**: RevenueCat uses special identifiers:
- `$rc_monthly` - Monthly package
- `$rc_annual` - Annual package
- `$rc_lifetime` - Lifetime package

These identifiers are recognized by the PaywallView for optimal display.

### 2.5 Create Paywall

1. Go to Paywalls tab
2. Click "Create Paywall"
3. Configure the paywall:

```
Paywall Name: Default Paywall
Template: Choose a template (e.g., "One Package Card")

Customization:
┌─────────────────────────────────────┐
│ Header                              │
├─────────────────────────────────────┤
│ Icon: 💩 (or upload custom)         │
│ Title: "Unlock Pro Features"        │
│ Subtitle: "Get unlimited scans"     │
└─────────────────────────────────────┘

Features List:
✓ Unlimited poop scans
✓ Full scan history
✓ Advanced animal matching
✓ Detailed analytics
✓ Cloud backup
✓ Ad-free experience

CTA Button: "Start Free Trial" (or "Subscribe")

Colors:
- Primary: #D2691E (Brown)
- Secondary: #FFEB3B (Yellow)
- Background: #FFF8DC (Light Yellow)

Attach to Offering: default
```

## Step 3: StoreKit Configuration File (for testing)

Create a StoreKit configuration file for local testing without real purchases:

1. In Xcode: File → New → File → StoreKit Configuration File
2. Name it: `Products.storekit`
3. Add products:

```json
{
  "identifier" : "Products",
  "nonRenewingSubscriptions" : [],
  "products" : [
    {
      "displayPrice" : "4.99",
      "familyShareable" : false,
      "internalID" : "monthly_internal",
      "localizations" : [
        {
          "description" : "Monthly subscription to Poop Detector Pro",
          "displayName" : "Monthly Pro",
          "locale" : "en_US"
        }
      ],
      "productID" : "monthly",
      "referenceName" : "Monthly Subscription",
      "type" : "Auto-Renewable"
    },
    {
      "displayPrice" : "39.99",
      "familyShareable" : false,
      "internalID" : "yearly_internal",
      "localizations" : [
        {
          "description" : "Annual subscription to Poop Detector Pro. Save 33%!",
          "displayName" : "Yearly Pro",
          "locale" : "en_US"
        }
      ],
      "productID" : "yearly",
      "referenceName" : "Annual Subscription",
      "type" : "Auto-Renewable"
    },
    {
      "displayPrice" : "99.99",
      "familyShareable" : false,
      "internalID" : "lifetime_internal",
      "localizations" : [
        {
          "description" : "One-time purchase for lifetime access",
          "displayName" : "Lifetime Pro",
          "locale" : "en_US"
        }
      ],
      "productID" : "lifetime",
      "referenceName" : "Lifetime Access",
      "type" : "Non-Consumable"
    }
  ],
  "settings" : {
    "askToBuyEnabled" : false,
    "billingGracePeriodDuration" : "PT0S",
    "locale" : "en_US",
    "storefront" : "USA"
  },
  "subscriptionGroups" : [
    {
      "id" : "poop_detector_pro",
      "localizations" : [],
      "name" : "Poop Detector Pro",
      "subscriptions" : [
        {
          "adHocOffers" : [],
          "codeOffers" : [],
          "displayPrice" : "4.99",
          "familyShareable" : false,
          "groupNumber" : 1,
          "internalID" : "monthly_internal",
          "introductoryOffer" : {
            "internalID" : "monthly_trial",
            "numberOfPeriods" : 1,
            "paymentMode" : "free",
            "subscriptionPeriod" : "P7D"
          },
          "localizations" : [
            {
              "description" : "Monthly subscription",
              "displayName" : "Monthly Pro",
              "locale" : "en_US"
            }
          ],
          "productID" : "monthly",
          "recurringSubscriptionPeriod" : "P1M",
          "referenceName" : "Monthly",
          "subscriptionGroupID" : "poop_detector_pro",
          "type" : "RecurringSubscription"
        },
        {
          "adHocOffers" : [],
          "codeOffers" : [],
          "displayPrice" : "39.99",
          "familyShareable" : false,
          "groupNumber" : 2,
          "internalID" : "yearly_internal",
          "introductoryOffer" : {
            "internalID" : "yearly_trial",
            "numberOfPeriods" : 1,
            "paymentMode" : "free",
            "subscriptionPeriod" : "P7D"
          },
          "localizations" : [
            {
              "description" : "Annual subscription",
              "displayName" : "Yearly Pro",
              "locale" : "en_US"
            }
          ],
          "productID" : "yearly",
          "recurringSubscriptionPeriod" : "P1Y",
          "referenceName" : "Yearly",
          "subscriptionGroupID" : "poop_detector_pro",
          "type" : "RecurringSubscription"
        }
      ]
    }
  ],
  "version" : {
    "major" : 2,
    "minor" : 0
  }
}
```

To use this configuration:
1. In Xcode scheme editor (Product → Scheme → Edit Scheme)
2. Select Run → Options
3. StoreKit Configuration: Select `Products.storekit`

## Step 4: Testing Configuration

### 4.1 Create Sandbox Tester

1. Go to App Store Connect → Users and Access → Sandbox Testers
2. Create a test account:
   - Email: test@example.com (use unique email)
   - Password: SecurePassword123!
   - Country: United States

### 4.2 Test Scenarios

#### Test Purchase Flow
```swift
// In your app, trigger PaywallView
// Use sandbox tester account to purchase
// Verify:
// - Purchase completes successfully
// - isProSubscriber becomes true
// - Pro features unlock
```

#### Test Restore Purchases
```swift
// Delete and reinstall app
// Go to Settings → Restore Purchases
// Sign in with same sandbox tester
// Verify:
// - Previous purchase is restored
// - Pro status returns
```

#### Test Subscription Expiry
```swift
// RevenueCat sandbox accelerates time:
// - 3 minutes = 1 month
// - 36 minutes = 1 year
//
// Purchase monthly subscription
// Wait 3 minutes
// Verify:
// - Subscription renews automatically
// - Pro status remains active
//
// Cancel subscription in sandbox
// Wait for expiry
// Verify:
// - Pro status changes to false
// - Free tier features activate
```

## Step 5: Production Checklist

Before releasing:

### API Keys
- [ ] Replace test API key with production key
- [ ] Store API key securely (not hardcoded)
- [ ] Different keys for debug/release builds

### App Store Connect
- [ ] All products approved
- [ ] Prices set for all regions
- [ ] Subscription group configured
- [ ] Tax information complete

### RevenueCat Dashboard
- [ ] Webhook configured (for backend integration)
- [ ] Products imported and active
- [ ] Entitlements configured correctly
- [ ] Offering set as default
- [ ] Paywall published

### App Configuration
- [ ] StoreKit configuration tested
- [ ] Error handling tested
- [ ] Restore purchases works
- [ ] Subscription status updates correctly
- [ ] Customer Center accessible

### Legal
- [ ] Terms of Service updated
- [ ] Privacy Policy includes subscription info
- [ ] Clear cancellation policy
- [ ] Refund policy stated

### Testing
- [ ] Test all subscription tiers
- [ ] Test introductory offers
- [ ] Test family sharing (if enabled)
- [ ] Test on multiple devices
- [ ] Test offline scenarios
- [ ] Test upgrade/downgrade flows

## Common Configuration Issues

### Issue: Products not loading
**Solution:**
- Verify products exist in App Store Connect
- Check product IDs match exactly
- Ensure at least one screenshot uploaded
- Wait 24 hours after product creation

### Issue: Purchases not working
**Solution:**
- Check Sandbox tester signed in (Settings → App Store → Sandbox Account)
- Clear StoreKit cache in simulator (Device → Erase All Content)
- Verify API key is correct
- Check app bundle ID matches

### Issue: Entitlements not activating
**Solution:**
- Verify entitlement ID matches code exactly ("Poop Detector Pro")
- Check products are attached to entitlement
- Force refresh customer info after purchase
- Check RevenueCat dashboard for customer status

### Issue: Paywall not displaying correctly
**Solution:**
- Verify offering is set as default
- Check packages are configured correctly
- Ensure proper package identifiers ($rc_monthly, etc.)
- Try refreshing offerings

## Support and Resources

### RevenueCat Resources
- [Dashboard](https://app.revenuecat.com)
- [Documentation](https://www.revenuecat.com/docs)
- [Community](https://community.revenuecat.com)

### Apple Resources
- [App Store Connect](https://appstoreconnect.apple.com)
- [In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [StoreKit Documentation](https://developer.apple.com/documentation/storekit)

### Testing Tools
- [Revenue Cat Sandbox Testing](https://www.revenuecat.com/docs/test-and-launch/sandbox)
- [StoreKit Testing in Xcode](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)

## Price Recommendations

Based on market research for similar apps:

### Pricing Strategy
```
Monthly:  $4.99  (Good for casual users)
Yearly:   $39.99 (33% discount - best value)
Lifetime: $99.99 (For committed users)

Free Tier: 3-5 scans per day
```

### Introductory Offers
```
Monthly: 7-day free trial
Yearly:  7-day free trial + 20% off first year ($31.99)
```

### Promotional Offers
```
Win-back: 50% off for 3 months (lapsed subscribers)
Upgrade: 20% off lifetime (for yearly subscribers)
```

## Analytics to Track

Monitor these metrics in RevenueCat:
- Conversion rate (free to paid)
- Trial to paid conversion
- MRR (Monthly Recurring Revenue)
- Churn rate
- LTV (Lifetime Value)
- Popular products (monthly vs yearly vs lifetime)

Set up these events:
```swift
// Track paywall views
Purchases.shared.logEvent(.paywallView)

// Track purchase attempts
Purchases.shared.logEvent(.purchaseAttempt)

// Track successful purchases (automatic)
// Track subscription renewals (automatic)
```

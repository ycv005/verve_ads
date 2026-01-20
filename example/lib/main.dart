import 'package:flutter/material.dart';
import 'package:verve_ads/verve_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Verve SDK
  final verveAds = VerveAds();
  final config = VerveConfig(
    appToken: 'YOUR_APP_TOKEN_HERE',
    testMode: true, // Enable test mode for development
    locationTrackingEnabled: true,
    coppaEnabled: false,
    age: '28',
    gender: 'male',
    keywords: 'technology,games,education',
  );

  final initResponse = await verveAds.initialize(config);
  debugPrint(
    'SDK Initialization: ${initResponse.isSuccess ? "✓ Success" : "✗ Failed"}',
  );
  if (!initResponse.isSuccess) {
    debugPrint('Error: ${initResponse.errorMessage}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verve Ads Plugin Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final verveAds = VerveAds();
  String _statusMessage = 'Ready';
  VerveAd? _currentAd;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSdkStatus();
  }

  Future<void> _checkSdkStatus() async {
    try {
      final isInit = await verveAds.isInitialized();
      final version = await verveAds.getSdkVersion();

      setState(() {
        _statusMessage =
            'SDK ${isInit ? 'Initialized' : 'Not Initialized'} - v$version';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _requestBannerAd() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting banner ad...';
    });

    final adRequest = AdRequest(
      placementId: 'placement_banner_1',
      adFormat: AdFormat.banner,
      timeoutMs: 10000,
    );

    final response = await verveAds.requestAd(adRequest);

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _currentAd = response.data;
        _statusMessage =
            'Banner Ad Received: ${response.data!.title ?? "Untitled"}';
      } else {
        _statusMessage =
            'Failed: ${response.errorMessage} (${response.statusCode.code})';
      }
    });
  }

  Future<void> _requestNativeAd() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting native ad...';
    });

    final adRequest = AdRequest(
      placementId: 'placement_native_1',
      adFormat: AdFormat.native,
      timeoutMs: 15000,
      customParameters: {'zone': 'premium', 'inventory_type': 'highvalue'},
    );

    final response = await verveAds.requestAd(adRequest);

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _currentAd = response.data;
        _statusMessage =
            'Native Ad Received: ${response.data!.title ?? "Untitled"}';
      } else {
        _statusMessage =
            'Failed: ${response.errorMessage} (${response.statusCode.code})';
      }
    });
  }

  Future<void> _requestInterstitialAd() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Requesting interstitial ad...';
    });

    final adRequest = AdRequest(
      placementId: 'placement_interstitial_1',
      adFormat: AdFormat.interstitial,
    );

    final response = await verveAds.requestAd(adRequest);

    setState(() {
      _isLoading = false;
      if (response.isSuccess && response.data != null) {
        _currentAd = response.data;
        _statusMessage = 'Interstitial Ad Received';
        // Auto-show interstitial
        _showCurrentAd();
      } else {
        _statusMessage =
            'Failed: ${response.errorMessage} (${response.statusCode.code})';
      }
    });
  }

  Future<void> _showCurrentAd() async {
    if (_currentAd == null) {
      _showSnackbar('No ad loaded');
      return;
    }

    final response = await verveAds.showAd(_currentAd!.adId);

    if (response.isSuccess) {
      _showSnackbar('Ad displayed successfully');
    } else {
      _showSnackbar('Failed to show ad: ${response.errorMessage}');
    }
  }

  Future<void> _setUserTargeting() async {
    final response = await verveAds.setTargetingParams(
      age: '30',
      gender: 'male',
      keywords: 'sports,tech,travel',
    );

    if (response.isSuccess) {
      _showSnackbar('✓ Targeting parameters updated');
    } else {
      _showSnackbar('✗ Failed to update targeting: ${response.errorMessage}');
    }
  }

  Future<void> _setTestMode(bool enabled) async {
    final response = await verveAds.setTestMode(enabled);

    if (response.isSuccess) {
      _showSnackbar('Test mode ${enabled ? "enabled" : "disabled"}');
    } else {
      _showSnackbar('Failed to set test mode: ${response.errorMessage}');
    }
  }

  Future<void> _checkConsent() async {
    final hasConsent = await verveAds.getUserConsentStatus();
    _showSnackbar('User consent: $hasConsent');
  }

  Future<void> _setConsent(bool consent) async {
    final response = await verveAds.setUserConsentStatus(consent);
    if (response.isSuccess) {
      _showSnackbar('Consent updated to: $consent');
    }
  }

  Future<void> _getDiagnostics() async {
    final diagnostics = await verveAds.getDiagnostics();
    final msg = 'Diagnostics: ${diagnostics.toString()}';
    _showSnackbar(msg);
  }

  Future<void> _clearCache() async {
    final response = await verveAds.clearAdCache();
    if (response.isSuccess) {
      _showSnackbar('✓ Ad cache cleared');
    } else {
      _showSnackbar('✗ Failed to clear cache: ${response.errorMessage}');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verve Ads Demo'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ad Requests Section
            const Text(
              'Request Ads',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _requestBannerAd,
              icon: const Icon(Icons.image),
              label: const Text('Request Banner Ad'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _requestNativeAd,
              icon: const Icon(Icons.art_track),
              label: const Text('Request Native Ad'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _requestInterstitialAd,
              icon: const Icon(Icons.fullscreen),
              label: const Text('Request Interstitial'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _currentAd == null ? null : _showCurrentAd,
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Show Current Ad'),
            ),
            const SizedBox(height: 24),

            // Targeting Section
            const Text(
              'User Targeting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _setUserTargeting,
              icon: const Icon(Icons.person),
              label: const Text('Set Targeting Params'),
            ),
            const SizedBox(height: 24),

            // Privacy Section
            const Text(
              'Privacy & Compliance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _setTestMode(true),
              icon: const Icon(Icons.bug_report),
              label: const Text('Enable Test Mode'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _setTestMode(false),
              icon: const Icon(Icons.check_circle),
              label: const Text('Disable Test Mode'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _checkConsent,
              icon: const Icon(Icons.privacy_tip),
              label: const Text('Check Consent Status'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _setConsent(true),
              icon: const Icon(Icons.thumb_up),
              label: const Text('Grant Consent'),
            ),
            const SizedBox(height: 24),

            // Debugging Section
            const Text(
              'Debugging',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _getDiagnostics,
              icon: const Icon(Icons.info),
              label: const Text('Get Diagnostics'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _clearCache,
              icon: const Icon(Icons.clear),
              label: const Text('Clear Ad Cache'),
            ),
            const SizedBox(height: 24),

            // Ad Display Card
            if (_currentAd != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Ad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_currentAd!.imageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _currentAd!.imageUrl!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 200,
                                  color: Colors.grey.shade300,
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (_currentAd!.title != null)
                        Text(
                          _currentAd!.title!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (_currentAd!.description != null) ...[
                        const SizedBox(height: 8),
                        Text(_currentAd!.description!),
                      ],
                      if (_currentAd!.ctaText != null) ...[
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _showCurrentAd,
                          child: Text(_currentAd!.ctaText!),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

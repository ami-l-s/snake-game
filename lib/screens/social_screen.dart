import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/iap_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  final _storage = StorageService.instance;
  final _iap = IAPService.instance;
  bool _isPurchasing = false;

  // ─── Rewarded Ad ──────────────────────────────────────────────────────────
  RewardedAd? _rewardedAd;
  bool _isAdLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  // ─── Load rewarded ad ─────────────────────────────────────────────────────
  void _loadRewardedAd() {
    setState(() => _isAdLoading = true);
    RewardedAd.load(
      adUnitId: AppConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          if (mounted) setState(() => _isAdLoading = false);
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          if (mounted) setState(() => _isAdLoading = false);
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  // ─── Watch ad → earn 2 coins ──────────────────────────────────────────────
  Future<void> _handleWatchAdForCoins(BuildContext context) async {
    if (_rewardedAd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not ready yet — please try again in a moment.'),
        ),
      );
      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd(); // pre-load next ad immediately
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ad failed to show: $error')),
          );
        }
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) async {
        // ✅ User completed the ad — grant 2 coins
        await _storage.addCoins(2);
        if (context.mounted) {
          setState(() {}); // refresh coin balance display
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🪙 +2 Coins! Thanks for watching.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  // ─── Purchase handler ─────────────────────────────────────────────────────
  Future<void> _handleRemoveAds(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Remove Ads',
            style: GoogleFonts.nunito(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
        content: Text(
          'Pay KES 150 once to remove all ads permanently and get 200 bonus coins!\n\n'
          'This is a one-time purchase — no subscription.',
          style: GoogleFonts.nunito(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Buy',
                style: GoogleFonts.nunito(
                    color: AppTheme.accent, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    setState(() => _isPurchasing = true);
    await _iap.buy(AppConstants.iapVipId);
    if (context.mounted) setState(() => _isPurchasing = false);
  }

  // ─── Restore handler ──────────────────────────────────────────────────────
  Future<void> _handleRestorePurchases(BuildContext context) async {
    setState(() => _isPurchasing = true);
    await _iap.restorePurchases();
    if (context.mounted) {
      setState(() => _isPurchasing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_storage.isVip
            ? 'Purchase restored — ads removed!'
            : 'No previous purchase found.'),
      ));
    }
  }

  // ─── Coin purchase handlers ───────────────────────────────────────────────
  Future<void> _handleBuyCoins(String productId, int amount) async {
    setState(() => _isPurchasing = true);
    await _iap.buyCoins(productId);
    if (mounted) setState(() => _isPurchasing = false);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final adsRemoved = _storage.isVip;
    final isPurchasing = _isPurchasing;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('Social & Shop',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: GoogleFonts.nunito(
                  fontSize: 14, fontWeight: FontWeight.w700),
              tabs: const [
                Tab(text: 'Social'),
                Tab(text: 'Shop'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ── Social Tab ──────────────────────────────────────────
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset('Assets/Amilabstech.png',
                                fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Amilabs Technologies',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Building tools for everyday Kenyans',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 28),

                      // ── Contact ─────────────────────────────────────────
                      _SectionLabel('Contact Us'),
                      const SizedBox(height: 10),
                      _LinkTile(
                        icon: Icons.language_rounded,
                        label: 'Website',
                        value: 'amilabstech.com',
                        url: 'https://amilabstech.com',
                      ),
                      _LinkTile(
                        icon: Icons.email_rounded,
                        label: 'Support Email',
                        value: 'support@amilabstech.com',
                        url: 'mailto:support@amilabstech.com',
                      ),
                      _LinkTile(
                        icon: Icons.shield_rounded,
                        label: 'Privacy Policy',
                        value: 'amilabstech.com/privacy-policy',
                        url: 'https://amilabstech.com/privacy-policy',
                      ),
                      const SizedBox(height: 24),

                      // ── Social ──────────────────────────────────────────
                      _SectionLabel('Follow Us'),
                      const SizedBox(height: 10),
                      _SocialTile(
                        label: 'YouTube',
                        handle: '@amilabstech',
                        url: 'https://youtube.com/@amilabstech?si=Qbt8Kk4BdZsVwUGQ',
                        asset: 'Assets/youtube.png',
                        color: const Color(0xFFFF0000),
                      ),
                      _SocialTile(
                        label: 'TikTok',
                        handle: '@amilabstech',
                        url: 'https://www.tiktok.com/@amilabstech?_r=1&_t=ZS-95AK28k9e1V',
                        asset: 'Assets/ticktock.png',
                        color: const Color(0xFF010101),
                      ),
                      _SocialTile(
                        label: 'Instagram',
                        handle: '@amilabstech',
                        url: 'https://www.instagram.com/amilabstech?igsh=enpzZDZtMDB5a2M2',
                        asset: 'Assets/instagram.png',
                        color: const Color(0xFFE1306C),
                      ),
                      _SocialTile(
                        label: 'X / Twitter',
                        handle: '@Amilabstech',
                        url: 'https://x.com/Amilabstech',
                        asset: 'Assets/x.png',
                        color: const Color(0xFF000000),
                      ),
                      _SocialTile(
                        label: 'Facebook',
                        handle: 'Amilabstech',
                        url: 'https://www.facebook.com/Amilabstech',
                        asset: 'Assets/facebook.png',
                        color: const Color(0xFF1877F2),
                      ),
                      _SocialTile(
                        label: 'LinkedIn',
                        handle: 'Amilabs Technologies Ltd',
                        url: 'https://www.linkedin.com/company/amilabs-technologies-ltd',
                        asset: 'Assets/linkedin.png',
                        color: const Color(0xFF0A66C2),
                      ),
                      _SocialTile(
                        label: 'GitHub',
                        handle: 'Amilabs-Technologies',
                        url: 'https://github.com/Amilabs-Technologies',
                        asset: 'Assets/github.png',
                        color: const Color(0xFF333333),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '❤️ Made with love in Kenya',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                            color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),

                  // ── Shop Tab ────────────────────────────────────────────
                  ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Coin balance card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🪙',
                                style: TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${_storage.coins} Coins',
                                    style: GoogleFonts.nunito(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.accent)),
                                Text('Earn by playing or buying',
                                    style: GoogleFonts.nunito(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Remove Ads banner ──────────────────────────────
                      if (!adsRemoved) ...[
                        GestureDetector(
                          onTap: isPurchasing
                              ? null
                              : () => _handleRemoveAds(context),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isPurchasing ? 0.5 : 1.0,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppTheme.accent
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                    child: isPurchasing
                                        ? const Padding(
                                            padding: EdgeInsets.all(8),
                                            child:
                                                CircularProgressIndicator(
                                                    strokeWidth: 2),
                                          )
                                        : Icon(Icons.block_rounded,
                                            color: AppTheme.accent,
                                            size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isPurchasing
                                            ? 'Processing…'
                                            : 'Remove Ads + 200 Coins',
                                        style: GoogleFonts.nunito(
                                            color: AppTheme.accent,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        'One-time purchase • KES 150',
                                        style: GoogleFonts.nunito(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (!isPurchasing)
                                    Icon(Icons.chevron_right_rounded,
                                        color: AppTheme.accent, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                _handleRestorePurchases(context),
                            child: Text(
                              'Restore previous purchase',
                              style: GoogleFonts.nunito(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.success.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppTheme.success
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: AppTheme.success, size: 20),
                              const SizedBox(width: 12),
                              Text(
                                'Ads removed — thank you!',
                                style: GoogleFonts.nunito(
                                    color: AppTheme.success,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),

                      // ── Free Coins via Rewarded Ad ─────────────────────
                      _SectionLabel('Free Coins'),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: (_isAdLoading || isPurchasing)
                            ? null
                            : () => _handleWatchAdForCoins(context),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity:
                              (_isAdLoading || isPurchasing) ? 0.5 : 1.0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppTheme.gridLine),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.amber
                                        .withValues(alpha: 0.15),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: _isAdLoading
                                      ? const Padding(
                                          padding: EdgeInsets.all(8),
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.amber),
                                        )
                                      : const Icon(
                                          Icons.play_circle_filled_rounded,
                                          color: Colors.amber,
                                          size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isAdLoading
                                          ? 'Loading ad…'
                                          : 'Watch Ad → +2 Coins',
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'Free • watch a short ad',
                                      style: GoogleFonts.nunito(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                if (!_isAdLoading)
                                  Icon(Icons.chevron_right_rounded,
                                      color: AppTheme.accent, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Coin Packs ─────────────────────────────────────
                      _SectionLabel('Coin Packs'),
                      const SizedBox(height: 10),
                      _CoinTile(
                        emoji: '🪙',
                        title: '10 Coins',
                        subtitle: 'KES 10',
                        onBuy: () => _handleBuyCoins(
                            AppConstants.iapCoinsPack1, 10),
                      ),
                      const SizedBox(height: 8),
                      _CoinTile(
                        emoji: '💰',
                        title: '100 Coins',
                        subtitle: 'KES 100',
                        onBuy: () => _handleBuyCoins(
                            AppConstants.iapCoinsPack2, 100),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.nunito(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label, value, url;
  const _LinkTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.gridLine),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.accent),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.nunito(
                        color: AppTheme.textSecondary, fontSize: 11)),
                Text(value,
                    style: GoogleFonts.nunito(
                        color: AppTheme.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            const Spacer(),
            Icon(Icons.open_in_new_rounded,
                size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  final String label, handle, url, asset;
  final Color color;
  const _SocialTile({
    required this.label,
    required this.handle,
    required this.url,
    required this.asset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.gridLine),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.asset(asset, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.nunito(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(handle,
                    style: GoogleFonts.nunito(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Icon(Icons.open_in_new_rounded,
                size: 14, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _CoinTile extends StatelessWidget {
  final String emoji, title, subtitle;
  final VoidCallback onBuy;
  const _CoinTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onBuy,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.gridLine),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.nunito(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: GoogleFonts.nunito(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: AppTheme.accent),
          ],
        ),
      ),
    );
  }
}
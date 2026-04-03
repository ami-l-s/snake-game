import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../game/game_controller.dart';
import '../models/game_models.dart';
import '../services/ad_service.dart';
import '../services/iap_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class ShopScreen extends StatefulWidget {
  final GameController controller;
  final bool startOnSkins;
  final bool startOnEarn;

  const ShopScreen({
    super.key,
    required this.controller,
    this.startOnSkins = false,
    this.startOnEarn = false,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final storage = StorageService.instance;
  final iap = IAPService.instance;

  @override
  void initState() {
    super.initState();
    int initial = 0;
    if (widget.startOnSkins) initial = 1;
    if (widget.startOnEarn) initial = 2;
    _tabController = TabController(length: 4, vsync: this, initialIndex: initial);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text('🛍️ Shop',
            style: GoogleFonts.nunito(
                fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'VIP'),
            Tab(text: 'Skins'),
            Tab(text: 'Earn'),
            Tab(text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _VIPTab(storage: storage, iap: iap, onRefresh: () => setState(() {})),
          _SkinsTab(
              storage: storage,
              controller: widget.controller,
              onRefresh: () => setState(() {})),
          _EarnTab(storage: storage, onRefresh: () => setState(() {})),
          const _AboutTab(),
        ],
      ),
    );
  }
}

// ─── VIP & Coins Tab ──────────────────────────────────────────────────────────
class _VIPTab extends StatelessWidget {
  final StorageService storage;
  final IAPService iap;
  final VoidCallback onRefresh;

  const _VIPTab(
      {required this.storage, required this.iap, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Coin balance
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${storage.coins} Coins',
                      style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accent)),
                  Text('Earn by playing, watching ads, or buying',
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // VIP banner + subscription option
          if (!storage.isVip) ...[
            _ShopCard(
              emoji: '👑',
              title: 'Snake VIP (one-time)',
              subtitle:
                  'Buy once: unlock no ads + premium skins + 200 bonus coins (200 shillings)',
              price: iap.getPrice(AppConstants.iapVipId),
              color: AppTheme.accent,
              onBuy: () async {
                final success = await iap.buy(AppConstants.iapVipId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    success
                        ? 'VIP purchase started! Please confirm in store.'
                        : 'Failed to start VIP purchase.',
                    style: GoogleFonts.nunito(),
                  ),
                  backgroundColor:
                      success ? AppTheme.success : AppTheme.danger,
                  duration: const Duration(seconds: 2),
                ));
              },
            ),
            const SizedBox(height: 10),
            _ShopCard(
              emoji: '✨',
              title: 'Premium Subscription',
              subtitle:
                  'Monthly premium rails: no ads + all skins + daily 20 coins (200 shillings)',
              price: iap.getPrice(AppConstants.iapVipSubscriptionId),
              color: AppTheme.secondary,
              onBuy: () async {
                final success = await iap.buy(AppConstants.iapVipSubscriptionId);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    success
                        ? 'Subscription purchase started! Please confirm in store.'
                        : 'Failed to start subscription.',
                    style: GoogleFonts.nunito(),
                  ),
                  backgroundColor:
                      success ? AppTheme.success : AppTheme.danger,
                  duration: const Duration(seconds: 2),
                ));
              },
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accent)),
              child: Row(children: [
                const Text('👑', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Text('You are VIP! Thanks! 💜',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accent)),
              ]),
            ),

          const SizedBox(height: 20),
          Text('Coin Packs',
              style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 10),

          _ShopCard(
            emoji: '🪙',
            title: '10 Coins',
            subtitle: '10 shillings',
            price: iap.getPrice(AppConstants.iapCoinsPack1),
            color: AppTheme.primary,
            onBuy: () async {
              final success = await iap.buyCoins(AppConstants.iapCoinsPack1);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  success
                      ? '10-coin pack purchase started.'
                      : 'Failed to start purchase for 10 coins.',
                  style: GoogleFonts.nunito(),
                ),
                backgroundColor:
                    success ? AppTheme.success : AppTheme.danger,
                duration: const Duration(seconds: 2),
              ));
            },
          ),
          const SizedBox(height: 8),
          _ShopCard(
            emoji: '💰',
            title: '100 Coins',
            subtitle: '80 shillings',
            price: iap.getPrice(AppConstants.iapCoinsPack2),
            color: AppTheme.secondary,
            onBuy: () async {
              final success = await iap.buyCoins(AppConstants.iapCoinsPack2);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  success
                      ? '100-coin pack purchase started.'
                      : 'Failed to start purchase for 100 coins.',
                  style: GoogleFonts.nunito(),
                ),
                backgroundColor:
                    success ? AppTheme.success : AppTheme.danger,
                duration: const Duration(seconds: 2),
              ));
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => iap.restorePurchases(),
            child: Text('Restore Purchases',
                style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final String emoji, title, subtitle, price;
  final Color color;
  final VoidCallback onBuy;

  const _ShopCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.color,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(width: 12),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          Text(subtitle,
              style: GoogleFonts.nunito(
                  fontSize: 11, color: AppTheme.textSecondary),
              overflow: TextOverflow.ellipsis,
              maxLines: 2),
        ])),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 90),
          child: ElevatedButton(
            onPressed: onBuy,
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text(
              price,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ]),
    );
  }
}

// ─── Skins Tab ────────────────────────────────────────────────────────────────
class _SkinsTab extends StatelessWidget {
  final StorageService storage;
  final GameController controller;
  final VoidCallback onRefresh;

  const _SkinsTab(
      {required this.storage,
      required this.controller,
      required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final free = allSkins.where((s) => s.unlockType == SkinUnlockType.free).toList();
    final adSkins = allSkins.where((s) => s.unlockType == SkinUnlockType.watchAds).toList();
    final coinSkins = allSkins.where((s) => s.unlockType == SkinUnlockType.coins).toList();
    final vipSkins = allSkins.where((s) => s.unlockType == SkinUnlockType.vip).toList();

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _skinSection(context, '🆓 Free', free),
        const SizedBox(height: 8),
        _skinSection(context, '📺 Watch Ads to Unlock', adSkins),
        const SizedBox(height: 8),
        _skinSection(context, '🪙 Buy with Coins', coinSkins),
        const SizedBox(height: 8),
        _skinSection(context, '👑 VIP Exclusive', vipSkins),
      ],
    );
  }

  Widget _skinSection(
      BuildContext context, String title, List<SnakeSkin> skins) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title,
            style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5)),
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.88,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: skins.length,
        itemBuilder: (context, i) => _SkinCard(
          skin: skins[i],
          storage: storage,
          controller: controller,
          onRefresh: onRefresh,
        ),
      ),
    ]);
  }
}

class _SkinCard extends StatefulWidget {
  final SnakeSkin skin;
  final StorageService storage;
  final GameController controller;
  final VoidCallback onRefresh;

  const _SkinCard(
      {required this.skin,
      required this.storage,
      required this.controller,
      required this.onRefresh});

  @override
  State<_SkinCard> createState() => _SkinCardState();
}

class _SkinCardState extends State<_SkinCard> {
  bool _loadingAd = false;

  Future<void> _handleTap() async {
    final skin = widget.skin;
    final storage = widget.storage;
    final isUnlocked = storage.isSkinUnlocked(skin.id);

    if (isUnlocked) {
      await storage.setSelectedSkin(skin.id);
      widget.controller.setSkin(skin);
      widget.onRefresh();
      return;
    }

    switch (skin.unlockType) {
      case SkinUnlockType.vip:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Get VIP to unlock ${skin.name}! 👑',
              style: GoogleFonts.nunito()),
          backgroundColor: AppTheme.accent,
        ));
        break;

      case SkinUnlockType.coins:
        if (storage.coins >= skin.price) {
          await storage.spendCoins(skin.price);
          await storage.unlockSkin(skin.id);
          await storage.setSelectedSkin(skin.id);
          widget.controller.setSkin(skin);
          widget.onRefresh();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Need ${skin.price} coins — you have ${storage.coins} 🪙',
                style: GoogleFonts.nunito()),
            backgroundColor: AppTheme.danger,
          ));
        }
        break;

      case SkinUnlockType.watchAds:
        if (_loadingAd) return;
        setState(() => _loadingAd = true);
        final rewarded = await AdService.instance.showRewardedAd();
        if (!mounted) return;
        setState(() => _loadingAd = false);
        if (rewarded) {
          final watched = await storage.incrementSkinAdWatch(skin.id);
          if (watched >= skin.adsRequired) {
            await storage.unlockSkin(skin.id);
            await storage.setSelectedSkin(skin.id);
            widget.controller.setSkin(skin);
            widget.onRefresh();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${skin.name} unlocked! 🎉',
                  style: GoogleFonts.nunito()),
              backgroundColor: AppTheme.success,
            ));
          } else {
            widget.onRefresh();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  '${watched}/${skin.adsRequired} ads watched — keep going!',
                  style: GoogleFonts.nunito()),
              backgroundColor: AppTheme.primary,
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Ad not ready, try again soon!',
                style: GoogleFonts.nunito()),
            backgroundColor: AppTheme.danger,
          ));
        }
        break;

      case SkinUnlockType.free:
        await storage.unlockSkin(skin.id);
        await storage.setSelectedSkin(skin.id);
        widget.controller.setSkin(skin);
        widget.onRefresh();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = widget.skin;
    final storage = widget.storage;
    final isUnlocked = storage.isSkinUnlocked(skin.id);
    final isSelected = storage.selectedSkin == skin.id;
    final watched = storage.skinAdWatches(skin.id);

    return GestureDetector(
      onTap: _handleTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.accent
                : AppTheme.primary.withValues(alpha: 0.25),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(skin.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 6),
          Text(skin.name,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _Dot(skin.headColor),
            _Dot(skin.bodyColor),
            _Dot(skin.tailColor),
          ]),
          const SizedBox(height: 6),
          if (isSelected)
            _badge('✓ Active', AppTheme.accent, AppTheme.background)
          else if (isUnlocked)
            _badge('✅ Owned', AppTheme.success.withValues(alpha: 0.15), AppTheme.success)
          else if (skin.unlockType == SkinUnlockType.vip)
            _badge('👑 VIP', AppTheme.accent.withValues(alpha: 0.15), AppTheme.accent)
          else if (skin.unlockType == SkinUnlockType.coins)
            _badge('🪙 ${skin.price}', AppTheme.primary.withValues(alpha: 0.15), AppTheme.accent)
          else if (skin.unlockType == SkinUnlockType.watchAds)
            _loadingAd
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : _badge(
                    '📺 ${watched}/${skin.adsRequired} ads',
                    AppTheme.success.withValues(alpha: 0.15),
                    AppTheme.success),
        ]),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text,
            style: GoogleFonts.nunito(
                fontSize: 11, fontWeight: FontWeight.w800, color: fg)),
      );
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);
  @override
  Widget build(BuildContext context) => Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─── Earn Coins Tab ───────────────────────────────────────────────────────────
class _EarnTab extends StatefulWidget {
  final StorageService storage;
  final VoidCallback onRefresh;

  const _EarnTab({required this.storage, required this.onRefresh});

  @override
  State<_EarnTab> createState() => _EarnTabState();
}

class _EarnTabState extends State<_EarnTab> {
  bool _loading = false;

  Future<void> _watchAd() async {
    if (_loading) return;
    if (!AdService.instance.isRewardedAdReady) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Ad not ready yet, try again in a moment!',
            style: GoogleFonts.nunito()),
        backgroundColor: AppTheme.danger,
      ));
      return;
    }
    setState(() => _loading = true);
    final rewarded = await AdService.instance.showRewardedAd();
    if (rewarded) {
      await widget.storage.addCoins(AppConstants.coinsPerAd);
      widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('+${AppConstants.coinsPerAd} coins earned! 🪙',
              style: GoogleFonts.nunito()),
          backgroundColor: AppTheme.success,
        ));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Balance
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3))),
          child: Column(children: [
            const Text('🪙', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text('${widget.storage.coins}',
                style: GoogleFonts.nunito(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accent)),
            Text('Your Coins',
                style: GoogleFonts.nunito(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ]),
        ),
        const SizedBox(height: 24),

        Text('Ways to Earn',
            style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 14),

        // Watch ad card
        _EarnCard(
          icon: '📺',
          title: 'Watch an Ad',
          subtitle: 'Watch a short video and earn ${AppConstants.coinsPerAd} coins instantly',
          reward: '+${AppConstants.coinsPerAd} 🪙',
          rewardColor: AppTheme.success,
          buttonLabel: _loading ? 'Loading…' : 'Watch Now',
          buttonColor: AppTheme.success,
          onTap: _loading ? null : _watchAd,
          isLoading: _loading,
        ),
        const SizedBox(height: 12),

        // Play game card
        _EarnCard(
          icon: '🎮',
          title: 'Play the Game',
          subtitle: 'Earn 2 coins per food eaten, 20 coins for golden food',
          reward: '2–20 🪙',
          rewardColor: AppTheme.primary,
          buttonLabel: null,
          buttonColor: AppTheme.primary,
          onTap: null,
        ),
        const SizedBox(height: 12),

        // Golden food tip
        _EarnCard(
          icon: '⭐',
          title: 'Catch Golden Food',
          subtitle: 'Rare golden food gives 20 coins and 10 points!',
          reward: '+20 🪙',
          rewardColor: AppTheme.accent,
          buttonLabel: null,
          buttonColor: AppTheme.accent,
          onTap: null,
        ),
        const SizedBox(height: 12),

        // Double coins power-up
        _EarnCard(
          icon: '🪙',
          title: '2x Coins Power-Up',
          subtitle: 'Grab the coin power-up on the board to double earnings for 10s',
          reward: '2× 🪙',
          rewardColor: const Color(0xFFFFB347),
          buttonLabel: null,
          buttonColor: const Color(0xFFFFB347),
          onTap: null,
        ),

        const SizedBox(height: 24),
        Text(
          'Coins are used to unlock skins in the Skins tab.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
              fontSize: 12, color: AppTheme.textSecondary),
        ),
      ]),
    );
  }
}

class _EarnCard extends StatelessWidget {
  final String icon, title, subtitle, reward;
  final Color rewardColor, buttonColor;
  final String? buttonLabel;
  final VoidCallback? onTap;
  final bool isLoading;

  const _EarnCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.rewardColor,
    required this.buttonColor,
    required this.buttonLabel,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: buttonColor.withValues(alpha: 0.25))),
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary)),
              Text(subtitle,
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text(reward,
                  style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: rewardColor)),
            ])),
        if (buttonLabel != null) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 90,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(buttonLabel!,
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
            ),
          ),
        ],
      ]),
    );
  }
}

// ─── About Tab ────────────────────────────────────────────────────────────────
class _AboutTab extends StatelessWidget {
  const _AboutTab();

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        const Text('🐍', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 8),
        Text(AppConstants.appName,
            style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary)),
        Text('v${AppConstants.version} by ${AppConstants.companyName}',
            style: GoogleFonts.nunito(
                fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        Text('Find us online',
            style: GoogleFonts.nunito(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _SocialBtn(emoji: '🌐', label: 'Website', url: AppConstants.website),
            _SocialBtn(emoji: '🐦', label: 'Twitter', url: AppConstants.twitter),
            _SocialBtn(emoji: '📸', label: 'Instagram', url: AppConstants.instagram),
            _SocialBtn(emoji: '▶️', label: 'YouTube', url: AppConstants.youtube),
            _SocialBtn(emoji: '💻', label: 'GitHub', url: AppConstants.github),
            _SocialBtn(emoji: '📧', label: 'Support', url: 'mailto:${AppConstants.supportEmail}'),
          ],
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextButton(
            onPressed: () => _launch(AppConstants.privacyPolicy),
            child: Text('Privacy Policy',
                style: GoogleFonts.nunito(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ),
          Text('•', style: GoogleFonts.nunito(color: AppTheme.textSecondary)),
          TextButton(
            onPressed: () => _launch(AppConstants.termsOfService),
            child: Text('Terms of Service',
                style: GoogleFonts.nunito(
                    color: AppTheme.textSecondary, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 8),
        Text('❤️ Made with love by Amilabstech\nThank you for playing!',
            style: GoogleFonts.nunito(
                fontSize: 13, color: AppTheme.textSecondary),
            textAlign: TextAlign.center),
      ]),
    );
  }
}

class _SocialBtn extends StatelessWidget {
  final String emoji, label, url;
  const _SocialBtn({required this.emoji, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) await launchUrl(uri);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ]),
      ),
    );
  }
}


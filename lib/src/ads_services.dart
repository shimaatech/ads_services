import 'dart:math';

import 'package:firebase_admob/firebase_admob.dart';
import 'admob_config.dart';

class AdsServices {
  final AdmobConfig admobConfig;
  final Random _random = Random();
  final Map<int, MobileAd> _loadedAds = Map();

  DateTime _lastInterstitialTime;

  AdsServices(String appId, this.admobConfig) {
    FirebaseAdMob.instance.initialize(appId: appId);
  }

  BannerAd _createBannerAd(int id, [MobileAdListener listener, AdSize size]) {
    return BannerAd(
      adUnitId: admobConfig.getAdDescriptor(id).unitId,
      size: size,
      targetingInfo: admobConfig.targetingInfo,
      listener: listener,
    );
  }

  InterstitialAd _createInterstitialAd(int adId, [MobileAdListener listener]) {
    return InterstitialAd(
        adUnitId: admobConfig.getAdDescriptor(adId).unitId,
        targetingInfo: admobConfig.targetingInfo,
        listener: listener);
  }

  Future<bool> _showAd(
    MobileAd ad, {
    double probability = 1.0,
    double anchorOffset = 0.0,
    AnchorType anchorType = AnchorType.bottom,
  }) async {
    if (ad is InterstitialAd && !_canShowInterstitial()) {
      return false;
    }
    if (_random.nextDouble() <= probability) {
      if (ad is InterstitialAd) {
        _lastInterstitialTime = DateTime.now();
      }
      await ad.load();
      return ad.show(anchorType: anchorType, anchorOffset: anchorOffset);
    }
    return false;
  }

  bool _canShowInterstitial() {
    if (_lastInterstitialTime == null) {
      return true;
    }
    return DateTime.now().difference(_lastInterstitialTime).inSeconds >
        admobConfig.interstitialInterval;
  }

  Future<bool> showAd(int adId,
      {double probability = 1.0,
      double anchorOffset = 0.0,
      AnchorType anchorType = AnchorType.bottom,
      MobileAdListener listener,
      AdSize size}) {
    MobileAd ad =
        _loadedAds.putIfAbsent(adId, () => _createAd(adId, listener, size));
    return _showAd(ad,
        probability: probability,
        anchorOffset: anchorOffset,
        anchorType: anchorType);
  }

  Future<bool> disposeAd(int adId) async {
    if (_loadedAds.containsKey(adId)) {
      bool result = await _loadedAds[adId]?.dispose();
      _loadedAds.remove(adId);
      return result;
    }
    return false;
  }

  Future<bool> hideAllBanners() async {
    for (int adId in _loadedAds.keys) {
      if (_loadedAds[adId] is BannerAd) {
        await disposeAd(adId);
      }
    }
    return true;
  }

  MobileAd _createAd(int adId, listener, AdSize size) {
    final AdType adType = admobConfig.getAdDescriptor(adId).type;
    switch (adType) {
      case AdType.banner:
        return _createBannerAd(adId, listener, size);
      case AdType.interstitial:
        return _createInterstitialAd(adId, listener);
    }
    throw Exception('Unsupported ad type: $adType');
  }
}

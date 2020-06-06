import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';

enum AdType {
  banner,
  interstitial,
}

class AdDescriptor {
  final int id;
  final AdType type;
  final String unitId;

  const AdDescriptor(this.id, this.type, this.unitId);

}

class AdmobConfig {
  final String appId;
  final Map<int, AdDescriptor> _androidAds;
  final Map<int, AdDescriptor> _iosAds;
  final int interstitialInterval;
  final MobileAdTargetingInfo targetingInfo;

  AdmobConfig(
    this.appId,
    List<AdDescriptor> androidAds,
    List<AdDescriptor> iosAds, {
    this.interstitialInterval = 10,
    this.targetingInfo,
  })  : assert(appId != null),
        assert(androidAds != null && androidAds.isNotEmpty),
        assert(iosAds != null && iosAds.isNotEmpty),
        assert(androidAds.length == iosAds.length),
        _androidAds = _createAdsMap(androidAds),
        _iosAds = _createAdsMap(iosAds);

  AdDescriptor getAdDescriptor(int id) {
    if (Platform.isAndroid) {
      return _androidAds[id];
    } else if (Platform.isIOS) {
      return _iosAds[id];
    }

    throw UnsupportedError('Unsupported platform ${Platform.operatingSystem}');
  }

  static Map<int, AdDescriptor> _createAdsMap(List<AdDescriptor> adDescriptors) {
    return Map.fromIterable(adDescriptors, key: (e) => e.id, value: (e) => e);
  }
}

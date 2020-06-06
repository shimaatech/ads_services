import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:firebase_admob/firebase_admob.dart';

part 'admob_config.g.dart';

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

abstract class AdmobConfig implements Built<AdmobConfig, AdmobConfigBuilder> {
  AdmobConfig._();

  String get appId;

  BuiltSet<AdDescriptor> get androidAds;

  BuiltSet<AdDescriptor> get iosAds;

  int get interstitialInterval;

  MobileAdTargetingInfo get targetingInfo;

  factory AdmobConfig([void Function(AdmobConfigBuilder) updates]) =
      _$AdmobConfig;

  AdDescriptor getAdDescriptor(int id) {
    BuiltSet<AdDescriptor> ads = Platform.isAndroid ? androidAds : iosAds;
    return ads.firstWhere((e) => e.id == id,
        orElse: () => throw UnsupportedError(
            'Unsupported platform ${Platform.operatingSystem}'));
  }
}

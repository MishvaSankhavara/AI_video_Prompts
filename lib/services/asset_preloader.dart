import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/common_utils.dart';
import 'package:flutter/services.dart';

class AssetPreloader {
  /// Preloads all image assets using the modern AssetManifest API
  static Future<void> preloadAssets(BuildContext context) async {
    try {
      // Load the asset manifest using the modern Flutter API
      final AssetManifest assetManifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);

      // Get all assets and filter to find only image assets
      final imageAssets = assetManifest
          .listAssets()
          .where(
            (String key) =>
                key.startsWith('assets/') &&
                (key.endsWith('.png') ||
                    key.endsWith('.jpg') ||
                    key.endsWith('.jpeg') ||
                    key.endsWith('.webp') ||
                    key.endsWith('.gif')),
          )
          .toList();

      if (imageAssets.isEmpty) {
        CommonUtils.printLog(
          'flutter: Preloaded 0 image assets (None found in manifest).',
        );
        return;
      }

      // Precache each image in parallel for faster loading
      final futures = imageAssets.map(
        (asset) => precacheImage(AssetImage(asset), context),
      );
      await Future.wait(futures);

      CommonUtils.printLog('flutter: Preloaded ${imageAssets.length} image assets.');
    } catch (e) {
      CommonUtils.printLog('flutter: Error preloading assets: $e');
    }
  }
}

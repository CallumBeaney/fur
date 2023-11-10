import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

/// Using a future here because it appears that the registerSingleton method does not complete before returning to the main function and calling runapp. This causes an initial exception before successfully updating.
Future<void> setupSingleton() async {
  final List<AssetImage> pastelDogs = await getImageAssetList('assets/pastel/');
  final List<AssetImage> digiDogs = await getImageAssetList('assets/digi/');
  final List<AssetImage> motoDogs = await getImageAssetList('assets/moto/');

  pastelDogs.shuffle();
  digiDogs.shuffle();
  motoDogs.shuffle();

  insertListHalfway(pastelDogs, digiDogs);
  pastelDogs.addAll(motoDogs);
  pastelDogs.insert(0, const AssetImage('../assets/splash/splash.jpg'));

  locator.registerSingleton<List<AssetImage>>(pastelDogs);
  return;
}

void insertListHalfway(List<AssetImage> originalList, List<AssetImage> insertionList) {
  final insertionIndex = originalList.length ~/ 2;
  originalList.insertAll(insertionIndex, insertionList);
}

/// If any non-images are in your assets directory, you're going to break this. MacOS auto-loads .DS_Store files into directories when viewed in Finder. In theory if you the assets directory in Terminal and run `rm .DS_Store` and then `defaults write com.apple.desktopservices.DSDontWriteNetworkStores -bool true` this will stop that happening. In practice Apple once again produce in me petty rage
Future<List<AssetImage>> getImageAssetList(String path) async {
  /// this JSON manifest may be deprecated for a BIN file soon.
  /// see: https://stackoverflow.com/a/76949663/18022338
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final List<String> assetsList = manifest
      .listAssets()
      .where((string) => string.startsWith(path) && (!string.endsWith('.DS_Store')))
      .toList();
  List<AssetImage> returnList = assetsList.map((e) => AssetImage(e)).toList();

  return returnList;
}

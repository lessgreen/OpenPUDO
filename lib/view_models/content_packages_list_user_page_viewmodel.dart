import 'package:flutter/cupertino.dart';
import 'package:html_unescape/html_unescape_small.dart';
import 'package:qui_green/commons/alert_dialog.dart';
import 'package:qui_green/models/package_summary.dart';
import 'package:qui_green/models/pudo_package.dart';
import 'package:qui_green/resources/routes_enum.dart';
import 'package:qui_green/singletons/network/network_manager.dart';
import 'package:qui_green/commons/utilities/localization.dart';

class ContentPackagesListUserPageViewModel with ChangeNotifier {
  BuildContext context;

  ContentPackagesListUserPageViewModel(this.context) {
    _fetchPackages().then(
      (response) {
        if (response is List<PackageSummary>) {
          _availablePackages = response;
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  final ScrollController scrollController = ScrollController();
  bool _canFetchMore = true;
  final int _fetchLimit = 20;
  List<PackageSummary> _availablePackages = [];
  String? errorDescription;

  List<PackageSummary> get filteredPackagesList => _availablePackages.where((element) => _handlePackageSearch(searchedValue, element)).toList();

  String _searchedValue = "";

  String get searchedValue => _searchedValue;

  set searchedValue(String newVal) {
    _searchedValue = newVal;
    notifyListeners();
  }

  refreshDidTriggered() {
    _availablePackages.clear();
    notifyListeners();
    _fetchPackages().then(
      (response) {
        if (response is List<PackageSummary>) {
          _availablePackages = response;

          notifyListeners();
        }
      },
    );
  }

  Future<dynamic> _fetchPackages({bool? appendMode = false}) {
    errorDescription = null;
    notifyListeners();
    return NetworkManager.instance.getMyPackages(limit: _fetchLimit, offset: _availablePackages.length, history: true).then((response) {
      if (response is List<PackageSummary>) {
        _canFetchMore = (response.length == _fetchLimit);
        if (!scrollController.hasListeners) {
          scrollController.addListener(_scrollListener);
        }
      } else if (appendMode == false) {
        if (response is ErrorDescription) {
          errorDescription = HtmlUnescape().convert(response.value.first.toString());
          notifyListeners();
        } else {
          errorDescription = 'unknownDescription'.localized(context, 'generic');
          notifyListeners();
        }
      }
      return response;
    }).catchError(
      (onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError),
    );
  }

  onPackageCard(PackageSummary package) {
    NetworkManager.instance.getPackageDetails(packageId: package.packageId).then(
      (response) {
        if (response is PudoPackage) {
          Navigator.of(context).pushNamed(Routes.packagePickup, arguments: response).then(
                (value) => refreshDidTriggered(),
              );
        } else {
          SAAlertDialog.displayAlertWithClose(
            context,
            'genericErrorTitle'.localized(context, 'general'),
            'unknownDescription'.localized(context, 'generic'),
          );
        }
      },
    ).catchError((onError) => SAAlertDialog.displayAlertWithClose(context, 'genericErrorTitle'.localized(context, 'general'), onError));
  }

  void _scrollListener() {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels != 0 && !NetworkManager.instance.networkActivity.value && _canFetchMore) {
        _fetchPackages(appendMode: true).then(
          (response) {
            if (response is List<PackageSummary>) {
              _availablePackages.addAll(response);
              notifyListeners();
            }
          },
        );
      }
    }
  }

  bool _handlePackageSearch(String search, PackageSummary package) {
    if (search.isEmpty) {
      return true;
    }
    List<String> splittedSearch = search.toLowerCase().split(" ");
    String plainName = (package.packageName ?? "").toLowerCase();
    //Search by name
    for (String splitSearch in splittedSearch) {
      if (plainName.contains(splitSearch)) {
        return true;
      }
    }
    //Search by id
    for (String splitSearch in splittedSearch) {
      if ("ac${package.userId ?? 0}".contains(splitSearch)) {
        return true;
      }
    }
    return false;
  }
}

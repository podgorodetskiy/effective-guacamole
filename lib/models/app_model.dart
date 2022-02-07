import 'package:flutter/foundation.dart';
import 'package:msal_js/msal_js.dart';
import 'package:web_test/api/repositories/account_repository.dart';
import 'package:web_test/api/dto/account_response.dart';
import 'package:web_test/api/repositories/address_repository.dart';

const String clientId = 'bca1ed50-0cda-46b2-b2ec-4f5125fe7447';
const List<String> scopes = ['https://orgc01e1d97.crm4.dynamics.com/.default'];

class AppModel extends ChangeNotifier {
  static const int _pageSize = 10;

  final _publicClientApp = PublicClientApplication(
    Configuration()
      ..auth = (BrowserAuthOptions()
        ..clientId = clientId
        ..redirectUri = 'http://213.183.51.216:8090')
      ..system = (BrowserSystemOptions()
        ..loggerOptions = (LoggerOptions()
          ..loggerCallback = _loggerCallback
          ..logLevel = LogLevel.verbose)),
  );

  late AccountRepository _accountRepository;
  late AddressRepository _addressRepository;
  bool _isListRepresentation = true;
  String? _searchText;
  String? _selectedStateOrProvince;
  AccountState? _accountState;

  String? accessToken;

  final List<Account> accountsList = <Account>[];
  final List<String> statesList = <String>[];
  bool isLoading = false;
  String? nextPageUrl;

  Function(String, String, Map<String, Function()?>)? showDialog;

  AccountState? get accountState => _accountState;

  set accountState(AccountState? val) {
    if (_accountState == val) {
      return;
    }
    _accountState = val;
    reloadAccounts();
  }

  String? get searchText => _searchText;

  set searchText(val) {
    _searchText = val;
    reloadAccounts();
  }

  String? get selectedStateOrProvince => _selectedStateOrProvince;

  set selectedStateOrProvince(val) {
    if (_selectedStateOrProvince == val) {
      return;
    }
    if (val == "") {
      _selectedStateOrProvince = null;
    } else {
      _selectedStateOrProvince = val;
    }
    reloadAccounts();
  }

  bool get isListRepresentation => _isListRepresentation;

  set isListRepresentation(val) {
    _isListRepresentation = val;
    notifyListeners();
  }

  Future<void> login() async {
    try {
      final response =
          await _publicClientApp.loginPopup(PopupRequest()..scopes = scopes);

      accessToken = response.accessToken;

      _accountRepository = AccountRepository(response.accessToken);
      _addressRepository = AddressRepository(response.accessToken);
      isLoading = true;
      notifyListeners();
      await initAccounts();
      await initStates();
      isLoading = false;
      notifyListeners();

      debugPrint('Popup login successful.');
    } on AuthException catch (ex) {
      debugPrint('MSAL: ${ex.errorCode}:${ex.errorMessage}');
    } on Exception catch (ex) {
      debugPrint('Exception: $ex');
    }
  }

  Future<void> initAccounts() async {
    try {
      var accountsResponse = await _accountRepository.getAccounts(
          maxPageSize: _pageSize,
          searchText: searchText,
          stateOrProvince: _selectedStateOrProvince,
          accountState: accountState);
      accountsList.clear();
      accountsList.addAll(accountsResponse.value);
      nextPageUrl = accountsResponse.odataNextLink;
    } on Exception {
      showDialog?.call(
        "Error",
        "Error occurred while getting accounts",
        {"Cancel": null, "Retry": () => reloadAccounts()},
      );
    }
  }

  Future<void> initStates() async {
    statesList.clear();
    statesList.addAll(await _addressRepository.getStates());
  }

  Future<void> reloadAccounts() async {
    isLoading = true;
    accountsList.clear();
    notifyListeners();
    await initAccounts();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadNextPage() async {
    if (nextPageUrl != null) {
      isLoading = true;
      notifyListeners();
      var nextAccounts = await _accountRepository.getNextAccounts(
          maxPageSize: _pageSize, nextPageUrl: nextPageUrl!);
      accountsList.addAll(nextAccounts.value);
      nextPageUrl = nextAccounts.odataNextLink;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _publicClientApp.logoutPopup();

    accountsList.clear();
    searchText = "";
    nextPageUrl = null;
    isLoading = false;
    accessToken = null;
    notifyListeners();
  }
}

void _loggerCallback(LogLevel level, String message, bool containsPii) {
  if (containsPii) {
    return;
  }

  debugPrint('MSAL: [$level] $message');
}

import 'package:web_test/api/api_helper.dart';

import '../dto/account_response.dart';
import 'base_repository.dart';

class AccountRepository extends BaseRepository {
  AccountRepository(String authToken) : super(authToken: authToken);

  final api = ApiHelper();

  Future<AccountResponse> getAccounts(
      {int maxPageSize = 5000,
      String? searchText,
      String? stateOrProvince,
      AccountState? accountState}) async {
    var requestPath = _constructRequest(
        searchText: searchText,
        stateOrProvince: stateOrProvince,
        accountState: accountState);
    var accounts =
        await api.getByPath(requestPath, makeHeader(maxPageSize: maxPageSize));
    return AccountResponse.fromJson(accounts);
  }

  Future<AccountResponse> getNextAccounts(
      {int maxPageSize = 5000, required String nextPageUrl}) async {
    return AccountResponse.fromJson(
        await api.getByUrl(nextPageUrl, makeHeader(maxPageSize: maxPageSize)));
  }

  String _constructRequest(
      {String? searchText,
      String? stateOrProvince,
      AccountState? accountState}) {
    var request = "accounts?\$select=${Account.requestFields}";
    var filters = <String>[];
    if (searchText != null) {
      filters.add("(contains(name,'$searchText') "
          "or contains(accountnumber,'$searchText'))");
    }
    if (stateOrProvince != null) {
      filters.add("address1_stateorprovince eq '$stateOrProvince'");
    }
    if (accountState != null) {
      filters.add("statecode eq ${accountState.index}");
    }

    var filterQuery =
        filters.isEmpty ? "" : "&\$filter=" + filters.join(" and ");

    return request + filterQuery;
  }
}

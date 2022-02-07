import 'dart:convert';

AccountResponse accountResponseFromJson(String str) => AccountResponse.fromJson(json.decode(str));

String accountResponseToJson(AccountResponse data) => json.encode(data.toJson());

class AccountResponse {
  AccountResponse({
    required this.odataContext,
    required this.value,
    this.odataNextLink,
  });

  final String odataContext;
  final List<Account> value;
  final String? odataNextLink;

  factory AccountResponse.fromJson(Map<String, dynamic> json) => AccountResponse(
    odataContext: json["@odata.context"],
    value: List<Account>.from(json["value"].map((x) => Account.fromJson(x))),
    odataNextLink: json["@odata.nextLink"],
  );

  Map<String, dynamic> toJson() => {
    "@odata.context": odataContext,
    "value": List<dynamic>.from(value.map((x) => x.toJson())),
    "@odata.nextLink": odataNextLink,
  };
}

class Account {
  Account({
    required this.odataEtag,
    required this.name,
    required this.accountId,
    required this.stateOrProvince,
    required this.stateCode,
    this.accountNumber,
  });

  static const String requestFields = "name,accountnumber,address1_stateorprovince,statecode";

  final String odataEtag;
  final String name;
  final String accountId;
  final String stateOrProvince;
  final AccountState stateCode;
  final String? accountNumber;

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    odataEtag: json["@odata.etag"],
    name: json["name"],
    accountId: json["accountid"],
    stateOrProvince: json["address1_stateorprovince"],
    stateCode: AccountState.values[json["statecode"]],
    accountNumber: json["accountnumber"],
  );

  Map<String, dynamic> toJson() => {
    "@odata.etag": odataEtag,
    "name": name,
    "accountid": accountId,
    "accountnumber": accountNumber,
    "address1_stateorprovince": stateOrProvince,
    "statecode": stateCode.index,
  };
}

enum AccountState { active, inactive }

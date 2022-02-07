
class AddressResponse {
  AddressResponse({
    required this.odataContext,
    required this.addresses,
  });

  final String odataContext;
  final List<Address> addresses;

  factory AddressResponse.fromJson(Map<String, dynamic> json) => AddressResponse(
    odataContext: json["@odata.context"],
    addresses: List<Address>.from(json["value"].map((x) => Address.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "@odata.context": odataContext,
    "value": List<dynamic>.from(addresses.map((x) => x.toJson())),
  };
}

class Address {
  Address({
    required this.stateOrProvince,
  });

  final String stateOrProvince;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    stateOrProvince: json["stateorprovince"],
  );

  Map<String, dynamic> toJson() => {
    "stateorprovince": stateOrProvince,
  };
}
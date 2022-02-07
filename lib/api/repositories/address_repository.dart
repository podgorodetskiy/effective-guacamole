import 'package:web_test/api/api_helper.dart';
import 'package:web_test/api/dto/address_response.dart';
import 'package:web_test/api/repositories/base_repository.dart';

class AddressRepository extends BaseRepository {
  AddressRepository(String authToken) : super(authToken: authToken);

  final api = ApiHelper();

  Future<List<String>> getStates() async {
    var statesJson = await api.getByPath(
        "customeraddresses?\$apply=filter(stateorprovince ne null)/groupby((stateorprovince))",
        makeHeader());
    return AddressResponse.fromJson(statesJson)
        .addresses
        .map((a) => a.stateOrProvince)
        .toList();
  }
}

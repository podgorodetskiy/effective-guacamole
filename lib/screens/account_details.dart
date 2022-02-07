import 'package:flutter/material.dart';
import 'package:web_test/api/dto/account_response.dart';
import 'package:web_test/utils/ui.dart';

class AccountDetails extends StatefulWidget {
  const AccountDetails(this.account, {Key? key}) : super(key: key);
  final Account account;

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetails> with Dialogs {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
      ),
      body: Center(
        child: Column(
          children: [
            Wrap(children: [Text("Name: ${widget.account.name}")]),
            Wrap(children: [Text("Account number: ${widget.account.accountNumber ?? "N/A"}")]),
            Wrap(children: [Text("State/Province: ${widget.account.stateOrProvince}")]),
            Wrap(children: [Text("Status: ${widget.account.stateCode.name}")]),
          ],
        ),
      ),
    );
  }

}
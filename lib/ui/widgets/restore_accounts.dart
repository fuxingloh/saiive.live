import 'package:defichainwallet/crypto/chain.dart';
import 'package:defichainwallet/crypto/database/wallet_db.dart';
import 'package:defichainwallet/crypto/model/wallet_account.dart';
import 'package:defichainwallet/crypto/wallet/impl/hdWallet.dart';
import 'package:defichainwallet/crypto/wallet/impl/wallet.dart';
import 'package:defichainwallet/crypto/wallet/wallet-restore.dart';
import 'package:defichainwallet/crypto/wallet/wallet.dart';
import 'package:defichainwallet/generated/l10n.dart';
import 'package:defichainwallet/service_locator.dart';
import 'package:flutter/material.dart';

class RestoreAccountsScreen extends StatefulWidget {
  final ChainType chain;

  RestoreAccountsScreen(this.chain);

  @override
  State<StatefulWidget> createState() {
    return _RestoreAccountsScreen();
  }
}

class _RestoreAccountsScreen extends State<RestoreAccountsScreen> {
  Future<List<WalletAccount>> searchAccounts(ChainType chain) async {
    var result = await _searchAccounts(chain);

    var isFirst = true;
    for (var element in result) {
      await WalletDatabase.instance.addAccount(
          name: element.name,
          account: element.account,
          chain: chain,
          isSelected: isFirst);

      isFirst = false;
    }

    if (result.length == 0) {
      await WalletDatabase.instance.addAccount(
          name: ChainHelper.chainTypeString(chain), account: 0, chain: chain);
    }
    
    return result;
  }

  Future<List<WalletAccount>> _searchAccounts(ChainType chain) async {
    final ret = await WalletRestore.restore(chain);

    return ret;
  }

  Widget _buildAccountEntry(WalletAccount account) {
    return Row(children: <Widget>[
      Icon(
        Icons.arrow_right,
        size: 19.0,
        color: Theme.of(context).accentColor,
      ),
      Padding(
          padding: EdgeInsets.only(left: 5),
          child: Text(account.name,
              style: TextStyle(
                  color: Theme.of(context).accentColor, fontSize: 15)))
    ]);
  }

  Widget _buildAccountListWrap(
      BuildContext context, List<WalletAccount> accounts) {
    return Column(children: <Widget>[
      Text(
        S.of(context).wallet_restore_accountsFound,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
      SizedBox(height: 20),
      _buildAccountListEntry(accounts),
      SizedBox(height: 20),
      Text(
        S.of(context).wallet_restore_accountsAdded,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15),
      ),
      SizedBox(height: 20),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 0),
          child: Expanded(
              child: RaisedButton(
            child: Text(S.of(context).next),
            onPressed: () async {
              Navigator.of(context).pushReplacementNamed("/home");
            },
          )))
    ]);
  }

  Widget _buildAccountListEntry(List<WalletAccount> accounts) {
    if (accounts.isEmpty) {
      return Text(S.of(context).wallet_restore_noAccountFound);
    } else {
      final height = MediaQuery.of(context).size.height;
      return SingleChildScrollView(
          child: SizedBox(
              height: height * 0.3,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return _buildAccountEntry(account);
                  })));
    }
  }

  Widget _buildRestoreRunner(BuildContext context) {
    return FutureBuilder<List<WalletAccount>>(
      future: searchAccounts(widget.chain),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<WalletAccount> data = snapshot.data;
          return Container(child: _buildAccountListWrap(context, data));
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Theme.of(context).accentColor, //change your color here
          ),
          backgroundColor: Theme.of(context).backgroundColor,
          brightness: Brightness.light,
          elevation: 0,
        ),
        body: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 0),
              child: Container(
                  child: Column(children: [
                SizedBox(height: 20),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      S.of(context).wallet_restore_loading,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    )),
                Padding(
                    padding: EdgeInsets.all(20),
                    child: _buildRestoreRunner(context))
              ])))
        ]));
  }
}

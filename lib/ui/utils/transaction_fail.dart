import 'package:saiive.live/crypto/errors/TransactionError.dart';
import 'package:saiive.live/generated/l10n.dart';
import 'package:saiive.live/helper/logger/LogHelper.dart';
import 'package:saiive.live/network/network_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class TransactionFailScreen extends StatefulWidget {
  final String text;

  final String additional;
  final dynamic error;

  TransactionFailScreen(this.text, {this.additional, this.error});

  @override
  _TransactionFailScreenState createState() => _TransactionFailScreenState();
}

class _TransactionFailScreenState extends State<TransactionFailScreen> {
  String _errorText;

  String _copyText;

  transformError() {
    if (widget.error == null) {
      return;
    }
    var stackTrace = "";
    if (widget.error is Error) {
      stackTrace = (widget.error as Error).stackTrace.toString();
    }

    if (widget.error is HttpException) {
      final httpError = widget.error as HttpException;
      _errorText = httpError.error.error;
      _copyText = _errorText + "\r\n" + stackTrace;
    } else if (widget.error is TransactionError) {
      final txError = widget.error as TransactionError;
      _errorText = txError.error;

      _copyText = txError.copyText() + "\r\n" + stackTrace;
    } else {
      _errorText = widget.error.toString();
      _copyText = _errorText + "\r\n" + stackTrace;
    }

    LogHelper.instance.e(_errorText);
  }

  @override
  Widget build(BuildContext context) {
    transformError();

    return Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).wallet_operation_failed,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        body: Center(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline_outlined, size: 50),
          Text(
            widget.text,
            style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.w800),
          ),
          if (widget.additional != null && widget.additional.isNotEmpty)
            Text(
              widget.additional,
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
          if (widget.error != null) SizedBox(height: 30),
          if (widget.error != null)
            Text(
              _errorText,
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          if (widget.error != null) SizedBox(height: 30),
          Text(S.of(context).wallet_operation_share, style: TextStyle(fontSize: 30, color: Colors.white)),
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () async {
                  await Share.share(_copyText, subject: "Error");
                },
                child: Icon(Icons.share, size: 26.0, color: Colors.white),
              ))
        ])));
  }
}

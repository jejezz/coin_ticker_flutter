import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

import 'package:coin_ticker_flutter/coin_data.dart';

const String kApiKey = "49DFA34E-5961-440E-9ED8-A41B4DB30D94";
const String kCoinApiHost = "https://rest.coinapi.io/v1/exchangerate/";

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  Map<String, double> coinRate = {};
  String selectedCurrency = 'USD';

  @override
  void initState() {
    super.initState();
    for (String coin in cryptoList) {
      coinRate[coin] = 0.0;
    }
  }

  DropdownButton<String> androidPicker() {
    List<DropdownMenuItem<String>> dropDownMenuItems = [];
    for (String item in currenciesList) {
      dropDownMenuItems.add(DropdownMenuItem(child: Text(item), value: item));
    }

    return DropdownButton<String>(
      value: selectedCurrency,
      items: dropDownMenuItems,
      onChanged: (value) {
        selectedCurrency = value;
        requestCoinPrice();
      },
    );
  }

  CupertinoPicker iOSPicker() {
    List<Text> pickerItems = [];
    for (String item in currenciesList) {
      pickerItems.add(
        Text(
          item,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.0,
            color: Colors.white,
          ),
        ),
      );
    }

    return CupertinoPicker(
      backgroundColor: Colors.lightBlue,
      itemExtent: 32.0,
      onSelectedItemChanged: (selectedIndex) {
        //print(selectedIndex);
        selectedCurrency = currenciesList[selectedIndex];
        requestCoinPrice();
      },
      children: pickerItems,
    );
  }

  String getCoinRate(String coin) {
    if (this.coinRate[coin] != null && this.coinRate[coin] != 0)
      return '1 $coin = ${coinRate[coin].toStringAsFixed(1)} $selectedCurrency';
    else
      return '1 $coin = ? $selectedCurrency';
  }

  List<Widget> createCoinWidgets() {
    List<Widget> coinCards = [];
    for (String coin in cryptoList) {
      coinCards.add(Padding(
        padding: EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
        child: Card(
          color: Colors.lightBlueAccent,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
            child: Text(
              getCoinRate(coin),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ));
    }

    return coinCards;
  }

  Future<void> requestCoinPrice() async {
    // initialize first
    for (String coin in cryptoList) {
      setState(() {
        this.coinRate[coin] = 0.0;
      });
    }

    for (String coin in cryptoList) {
      var hostUri =
          kCoinApiHost + "$coin/$selectedCurrency" + "?apikey=$kApiKey";
      print(hostUri);
      http.Response response = await http.get(Uri.parse(hostUri));
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          var decodedBody = jsonDecode(response.body);
          coinRate[decodedBody['asset_id_base']] = decodedBody["rate"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🤑 Coin Ticker'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: createCoinWidgets(),
          ),
          Container(
            height: 150.0,
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 30.0),
            color: Colors.lightBlue,
            child: Platform.isIOS ? iOSPicker() : androidPicker(),
          ),
        ],
      ),
    );
  }
}

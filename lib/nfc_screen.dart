import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc/services/nfc_service.dart';

class NFCScreen extends StatefulWidget {
  const NFCScreen({super.key});

  @override
  State<NFCScreen> createState() => _NFCScreenState();
}

class _NFCScreenState extends State<NFCScreen> {
  String text = "empty data";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(text , style: const TextStyle(color: Colors.black),),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () async {

                    NFCServices nfcServices = NFCServices(context : context);
                    nfcServices.readNFCCard().then((value) {
                      text = value;
                      setState(() {});
                    });
                  },
                  child: Text('read')),
              TextButton(
                  onPressed: () {
                    NFCServices nfcServices = NFCServices(context: context);

                    nfcServices.writeUriData("github.com/AmrAbdElHamed26").then((value) {
                      print(value);
                    });
                  },
                  child: Text('write')),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;

abstract class BaseNfcReader {
  Future<void> readNfcCard() ;

}
class NfcReader {
  String? _id;
  String _result = "empty";

  // Function to read NFC card
  Future<void> readNfcCard() async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();

      // Extract ID
      _id = tag.id;

      // Handle different NFC tag types or standards
      if (tag.standard == "ISO 14443-4 (Type B)") {
        String result1 = await FlutterNfcKit.transceive("00B0950000");
        String result2 =
        await FlutterNfcKit.transceive("00A4040009A00000000386980701");
        _result = '1: $result1\n2: $result2\n';
      } else if (tag.type == NFCTagType.iso18092) {
        String result1 = await FlutterNfcKit.transceive("060080080100");
        _result = '1: $result1\n';
      } else if (tag.ndefAvailable ?? false) {
        var ndefRecords = await FlutterNfcKit.readNDEFRecords();
        var ndefString = '';
        for (int i = 0; i < ndefRecords.length; i++) {
          ndefString += '${i + 1}: ${ndefRecords[i]}\n';
        }
        _result = ndefString;
      } else if (tag.type == NFCTagType.webusb) {
        var r = await FlutterNfcKit.transceive("00A4040006D27600012401");

      }

      // Pretend that we are working
      await FlutterNfcKit.finish(iosAlertMessage: "Finished!");
    } catch (e) {
      _id = null;
      _result = 'error';
    }


  }

  // Getter for the last read NFC tag ID
  String? get lastReadId => _id;

  // Getter for the result of the last NFC reading operation
  String? get lastResult => _result;

  String extractTextData() {
    if(_result.isEmpty)return "none";

    int textIndex = _result.indexOf("uri=");


    if (textIndex != -1) {
      String extractedText = _result.substring(textIndex + 5).trim();
      return extractedText;
    } else {
      return "none";
    }
  }

  Future<void> writeData(String data) async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();

      if (tag.ndefAvailable ?? false) {
        ndef.TextRecord newRecord = ndef.TextRecord(
          encoding: ndef.TextEncoding.values[0],
          language: 'en',
          text: data,
        );

        await FlutterNfcKit.writeNDEFRecords([newRecord]);

        _result = 'Write Successful';
      } else {
        _result = 'error: NDEF not supported';
      }
    } catch (e) {
      _result = 'error: $e';
    } finally {
      await FlutterNfcKit.finish();
    }

  }

  Future<void> writeUri(String data) async {
    try {
      NFCTag tag = await FlutterNfcKit.poll();

      if (tag.ndefAvailable ?? false) {
        ndef.UriRecord newRecord = ndef.UriRecord(
          prefix:'https://' ,
          content:data ,
        );

        await FlutterNfcKit.writeNDEFRecords([newRecord]);
        _result = 'Write Successful';

      } else {

      }
    } catch (e) {

    } finally {
      await FlutterNfcKit.finish();
    }
  }

  void close(){
    FlutterNfcKit.finish();
  }
}
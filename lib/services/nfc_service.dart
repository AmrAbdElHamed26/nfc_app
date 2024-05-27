import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;
import 'package:nfc/app_constants.dart';

abstract class BaseNFCServices {
  Future<dynamic> readNFCCard();

  Future<dynamic> writeTextData(String data);

  Future<dynamic> writeUriData(String url);
}

class NFCServices extends BaseNFCServices {
  NFCServices({required this.context});

  final BuildContext context;

  @override
  Future<bool> _NFCAvailability() async {
    var availability = await FlutterNfcKit.nfcAvailability;

    if (NFCAvailability.not_supported == availability) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("NFC not supported"),
      ));
    } else if (NFCAvailability.disabled == availability) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("open NFC service"),
      ));
    }

    NFCTag tag = await FlutterNfcKit.poll();
    return tag.ndefAvailable ?? false;
  }

  @override
  Future<dynamic> readNFCCard() async {
    if (await _NFCAvailability()) {
      var ndefRecords = await FlutterNfcKit.readNDEFRecords();
      if (ndefRecords[0] is ndef.TextRecord) {
        return (ndefRecords[0] as ndef.TextRecord).text ??
            AppConstants.errorNFC;
      } else if (ndefRecords[0] is ndef.UriRecord) {
        return (ndefRecords[0] as ndef.UriRecord).uriString ??
            AppConstants.errorNFC;
      }
    } else {
      return AppConstants.errorNFC;
    }
  }

  @override
  Future writeTextData(String data) async {
    try {
      if (await _NFCAvailability()) {
        ndef.TextRecord newRecord = ndef.TextRecord(
          encoding: ndef.TextEncoding.values[1],
          // [TextEncoding.UTF8, TextEncoding.UTF16]
          language: 'en',
          text: data,
        );

        await FlutterNfcKit.writeNDEFRecords([newRecord]);

        return AppConstants.writingUsingNFCSuccessfully;
      } else {
        return AppConstants.NFCNotSupported;
      }
    } catch (e) {
      return AppConstants.errorNFC;
    }
  }

  @override
  Future writeUriData(String url) async {
    if (await _NFCAvailability()) {
      ndef.UriRecord newRecord = ndef.UriRecord(
        prefix: 'https://',
        content: url,
      );
      await FlutterNfcKit.writeNDEFRecords([newRecord]);
      return AppConstants.writingUsingNFCSuccessfully;
    } else {
      return AppConstants.NFCNotSupported;
    }
  }
}

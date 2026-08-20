import 'dart:developer' as dev;
import 'dart:io';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  // BluetoothInfo? _selectedDevice;

  Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }

  Future<List<BluetoothInfo>> getDevices() async {
    try {
      final bool hasPermission = await requestPermissions();
      if (!hasPermission) return [];

      final bool isBluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      if (!isBluetoothEnabled) return [];

      return await PrintBluetoothThermal.pairedBluetooths;
    } catch (e) {
      dev.log('Error getting devices: $e');
      return [];
    }
  }

  Future<bool> requestPermissions() async {
    if (Platform.isWindows) return true;
    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<bool> hasPermissions() async {
    if (Platform.isWindows) return true;
    final statusScan = await Permission.bluetoothScan.status;
    final statusConnect = await Permission.bluetoothConnect.status;
    final statusLocation = await Permission.location.status;

    return statusScan.isGranted &&
        statusConnect.isGranted &&
        statusLocation.isGranted;
  }

  Future<bool> connect(BluetoothInfo device) async {
    try {
      final bool alreadyConnected = await isConnected();
      if (alreadyConnected) {
        await disconnect();
      }

      final bool success = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );

      return success;
    } catch (e) {
      dev.log('Printer connection error: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
  }

  Future<String> printReceipt({
    required String tableName,
    required String startTime,
    required String endTime,
    required String duration,
    required double totalAmount,
    double rawAmount = 0.0,
    double discountPercentage = 0.0,
    double discountAmount = 0.0,
    String? barcode,
    List<String>? players,
  }) async {
    if (!await isConnected()) return "Printer birikmedik!";

    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.reset();

      // Header
      bytes += generator.text(
        _sanitize('Sanly Timer'),
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      bytes += generator.feed(1);

      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        _sanitize('CHECK INFORMATION'),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Info Rows
      bytes += generator.row([
        PosColumn(text: _sanitize('Place:'), width: 6),
        PosColumn(
          text: _sanitize(tableName),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      if (players != null && players.isNotEmpty) {
        bytes += generator.text(
          _sanitize('Players: ${players.join(", ")}'),
          styles: const PosStyles(align: PosAlign.left),
        );
      }

      bytes += generator.row([
        PosColumn(text: _sanitize('Start date:'), width: 6),
        PosColumn(
          text: _sanitize(startTime),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: _sanitize('End date:'), width: 6),
        PosColumn(
          text: _sanitize(endTime),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: _sanitize('Duration:'), width: 6),
        PosColumn(
          text: _sanitize(duration),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );

      if (discountAmount > 0) {
        bytes += generator.row([
          PosColumn(text: _sanitize('Price:'), width: 6),
          PosColumn(
            text: _sanitize('${rawAmount.toStringAsFixed(2)} TMT'),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
        bytes += generator.row([
          PosColumn(text: _sanitize('Discount:'), width: 6),
          PosColumn(
            text: _sanitize('-${discountAmount.toStringAsFixed(2)} TMT'),
            width: 6,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
        bytes += generator.text(
          '--------------------------------',
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      // Total
      bytes += generator.text(
        _sanitize('TOTAL: ${totalAmount.toStringAsFixed(2)} TMT'),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size1,
        ),
      );

      bytes += generator.feed(1);
      bytes += generator.text(
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        '--------------------------------',
        styles: const PosStyles(align: PosAlign.center),
      );

      if (barcode != null && barcode.length >= 12) {
        bytes += generator.feed(1);
        try {
          bytes += generator.barcode(
            Barcode.code128(barcode.codeUnits),
            align: PosAlign.center,
            height: 75,
          );
        } catch (e) {
          dev.log('Barcode print error: $e');
        }
      }

      //bytes += generator.text(_sanitize('Geline minnetdar!'), styles: const PosStyles(align: PosAlign.center));

      bytes += generator.feed(3);
      bytes += generator.cut();

      final success = await PrintBluetoothThermal.writeBytes(bytes);
      return success
          ? "Cap edildi!"
          : "Çap etmekde ýalňyşlyk döräp (write error)";
    } catch (e) {
      dev.log('Print error: $e');
      return "Yalnyslyk: $e";
    }
  }

  Future<String> printTest() async {
    if (!await isConnected()) return "Printer birikmedik!";
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];
      bytes += generator.text(
        _sanitize('Test Print - Sanly Timer'),
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.feed(2);
      bytes += generator.cut();
      final success = await PrintBluetoothThermal.writeBytes(bytes);
      return success ? "Cap edildi!" : "Printere maglumat iberip bolmady";
    } catch (e) {
      dev.log('Test print error: $e');
      return "Yalnyslyk: $e";
    }
  }

  /// Converts special characters (Turkmen, Cyrillic) to Latin equivalents
  /// and removes any non-ASCII characters that might crash the printer.
  String _sanitize(String text) {
    String result = text;

    // Turkmen special characters mapping
    final Map<String, String> replacements = {
      'ň': 'n', 'Ň': 'N',
      'ý': 'y', 'Ý': 'Y',
      'ž': 'z', 'Ž': 'Z',
      'ä': 'a', 'Ä': 'A',
      'ö': 'o', 'Ö': 'O',
      'ü': 'u', 'Ü': 'U',
      'ç': 'c', 'Ç': 'C',
      'ş': 's', 'Ş': 'S',
      // Cyrillic (common characters transliteration)
      'а': 'a',
      'б': 'b',
      'в': 'v',
      'г': 'g',
      'д': 'd',
      'е': 'e',
      'ё': 'yo',
      'ж': 'zh',
      'з': 'z',
      'и': 'i',
      'й': 'y',
      'к': 'k',
      'л': 'l',
      'м': 'm',
      'н': 'n',
      'о': 'o',
      'п': 'p',
      'р': 'r',
      'с': 's',
      'т': 't',
      'у': 'u',
      'ф': 'f',
      'х': 'kh',
      'ц': 'ts',
      'ч': 'ch',
      'ш': 'sh',
      'щ': 'shh',
      'ъ': '',
      'ы': 'y',
      'ь': '',
      'э': 'e',
      'ю': 'yu',
      'я': 'ya',
      'А': 'A',
      'Б': 'B',
      'В': 'V',
      'Г': 'G',
      'Д': 'D',
      'Е': 'E',
      'Ё': 'Yo',
      'Ж': 'Zh',
      'З': 'Z',
      'И': 'I',
      'Й': 'Y',
      'К': 'K',
      'Л': 'L',
      'М': 'M',
      'Н': 'N',
      'О': 'O',
      'П': 'P',
      'Р': 'R',
      'С': 'S',
      'Т': 'T',
      'У': 'U',
      'Ф': 'F',
      'Х': 'Kh',
      'Ц': 'Ts',
      'Ч': 'Ch',
      'Ш': 'Sh',
      'Щ': 'Shh',
      'Ъ': '',
      'Ы': 'Y',
      'Ь': '',
      'Э': 'E',
      'Ю': 'Yu',
      'Я': 'Ya',
    };

    replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });

    // Final safety check: remove any characters that are not ASCII (0-127)
    // This prevents the "Invalid argument (string): Contains invalid characters" error
    return result.replaceAll(RegExp(r'[^\x00-\x7F]'), '');
  }
}

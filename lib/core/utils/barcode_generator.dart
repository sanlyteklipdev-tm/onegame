class BarcodeGenerator {
  static String generateAkhasapPayload(Duration duration) {
    const String prefix = '2';
    const String plu = '000001';
    double hours = duration.inMinutes / 60.0;

    int weightUnits = (hours * 1000).round();

    String weightStr = weightUnits.toString().padLeft(5, '0');

    String payloadWithoutChecksum = prefix + plu + weightStr;

    return payloadWithoutChecksum;
  }
}

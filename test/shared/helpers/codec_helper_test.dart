import 'package:flutter_test/flutter_test.dart';
import 'package:nebx/nebx.dart';

class GraticuleTest {
  double longitude;
  double latitude;

  GraticuleTest._({required this.longitude, required this.latitude});

  factory GraticuleTest.fromJson(Map<String, dynamic> jsonObject) {
    return GraticuleTest._(
      longitude: double.parse((jsonObject["longitude"] ?? 0).toString()),
      latitude: double.parse((jsonObject["latitude"] ?? 0).toString()),
    );
  }
}

void main() {
  const double longitude = 106.827194;
  const double latitude = -6.175372;


  group("Json Codec", () {
    const String singleJsonResponse =
        "{\"longitude\":$longitude,\"latitude\":$latitude}";
    const String arrayJsonResponse =
        "[{\"longitude\":$longitude,\"latitude\":$latitude},{\"longitude\":$longitude,\"latitude\":$latitude}]";

    const Map<String, dynamic> graticuleObject = {
      "longitude": longitude,
      "latitude": latitude,
    };

    test("Should decode single data json", () {
      final decoded = CodecHelper.decodeJson(singleJsonResponse);
      final GraticuleTest graticule = GraticuleTest.fromJson(decoded);

      expect(graticule.latitude, latitude);
      expect(graticule.longitude, longitude);
    });

    test("Should decode json list", () {
      final decodedList = CodecHelper.decodeJson<List>(arrayJsonResponse);
      final List<GraticuleTest> graticuleList =
      decodedList.map((i) => GraticuleTest.fromJson(i)).toList();

      expect(graticuleList.length, 2);

      for (var i in graticuleList) {
        expect(i.longitude, longitude);
        expect(i.latitude, latitude);
      }
    });

    test("Should encode single json", () {
      final encoded = CodecHelper.encodeJson(graticuleObject);
      expect(encoded, singleJsonResponse);
    });

    test("Should encode list json", () {
      final encoded = CodecHelper.encodeJson([graticuleObject, graticuleObject]);
      expect(encoded, arrayJsonResponse);
    });
  });

  group("Xml Codec", () {
    const String singleXmlResponse =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><root><data><longitude>$longitude<\/longitude><latitude>$latitude<\/latitude><\/data><\/root>";
    const String arrayXmlResponse =
        "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><root><data><longitude>$longitude<\/longitude><latitude>$latitude<\/latitude><\/data><data><longitude>$longitude<\/longitude><latitude>$latitude<\/latitude><\/data><\/root>";

    test("Should decode single data xml", () {
      final decoded = CodecHelper.decodeXml(singleXmlResponse)["root"]["data"];
      final GraticuleTest graticule = GraticuleTest.fromJson(decoded);

      expect(graticule.latitude, latitude);
      expect(graticule.longitude, longitude);
    });

    test("Should decode xml list", () {
      final decodedList =
      CodecHelper.decodeXml<Map<String, dynamic>>(arrayXmlResponse)["root"]
      ["data"] as List;
      final List<GraticuleTest> graticuleList =
      decodedList.map((i) => GraticuleTest.fromJson(i)).toList();

      expect(graticuleList.length, 2);

      for (var i in graticuleList) {
        expect(i.longitude, longitude);
        expect(i.latitude, latitude);
      }
    });
  });
}

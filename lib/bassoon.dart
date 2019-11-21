library bassoon;

import "dart:convert";
import "dart:typed_data";

import "src/serializer.dart";
import "src/deserializer.dart";
import "src/buffers.dart";

class BassoonEncoder extends Converter<Object, Uint8List> {
  @override
  Uint8List convert(Object input) {
    return BassoonSerializer(input).convert();
  }
}

class BassoonDecoder extends Converter<List<int>, Object> {
  @override
  Object convert(List<int> input) {
    return BassoonDeserializer(BufferReader(input)).convert();
  }
}

import "dart:convert";
import "dart:typed_data";

import "buffers.dart";
import "constants.dart";

class BassoonSerializer {
  BassoonSerializer(this.root);

  Uint8List convert() {
    _addObject(root);
    BufferBuilder outer = BufferBuilder();
    outer.addByte(MagicNumber.versionOne);
    outer.addByte(TypeId.stringTableId);
    outer.addVarInt(strings.position);
    if (strings.position > 0) outer.add(strings.finishAndClear());
    outer.add(builder.finishAndClear());
    return outer.finishAndClear();
  }

  void _addObject(Object obj) {
    if (obj is Map) {
      _addMap(obj);
    } else if (obj is Iterable) {
      _addIterable(obj);
    } else if (obj is int) {
      _addInt(obj);
    } else if (obj is double) {
      _addDouble(obj);
    } else if (obj is bool) {
      _addBool(obj);
    } else if (obj is String) {
      _addString(obj);
    } else if (obj == null) {
      _addNull();
    }
  }

  void _addMap(Map map) {
    builder.addByte(TypeId.mapId);
    builder.addVarInt(map.length);
    for (MapEntry entry in map.entries) {
      _addObject(entry.key);
      _addObject(entry.value);
    }
  }

  void _addIterable(Iterable it) {
    if (it is! List) it = it.toList(growable: false);
    builder.addByte(TypeId.listId);
    builder.addVarInt(it.length);
    it.forEach(_addObject);
  }

  void _addInt(int i) {
    builder.addByte(TypeId.intId);
    builder.addVarInt(i);
  }

  void _addDouble(double d) {
    builder.addByte(TypeId.doubleId);
    ByteData data = ByteData(8);
    data.setFloat64(0, d, Endian.big);
    builder.add(data.buffer.asUint8List());
  }

  void _addBool(bool b) {
    builder.addByte(b ? TypeId.trueId : TypeId.falseId);
  }

  void _addNull() {
    builder.addByte(TypeId.nullId);
  }

  void _addString(String s) {
    builder.addByte(TypeId.stringId);
    int offset = _stringOffsets[s];
    if (offset == null) {
      offset = _stringOffsets[s] = strings.position;
      List<int> bytes = utf8.encode(s);
      strings.addVarInt(bytes.length);
      strings.add(bytes);
    }
    builder.addVarInt(offset);
  }

  final Object root;
  final BufferBuilder builder = BufferBuilder();
  final BufferBuilder strings = BufferBuilder();
  final Map<String, int> _stringOffsets = {};
}

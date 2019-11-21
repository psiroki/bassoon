import "dart:convert";
import "dart:typed_data";

import "buffers.dart";
import "constants.dart";
import "exceptions.dart";

class BassoonDeserializer {
  BassoonDeserializer(this.reader);

  Object convert() {
    int versionMagic = reader.readByte();
    if (versionMagic != MagicNumber.versionOne) {
      throw UnknownVersionIdException(versionMagic);
    }
    int typeId = reader.readByte();
    if (typeId != TypeId.stringTableId) {
      throw UnknownTypeIdException(typeId, reader.position - 1);
    }
    int length = reader.readVarInt();
    Uint8List stringBytes = reader.readBytes(length);
    _strings = BufferReader(stringBytes);
    return _readObject();
  }

  Object _readObject() {
    int typeId = reader.readByte();
    switch (typeId) {
      case TypeId.falseId:
      case TypeId.trueId:
        return typeId == TypeId.trueId;
      case TypeId.intId:
        return reader.readVarInt();
      case TypeId.doubleId:
        return _readDouble();
      case TypeId.nullId:
        return null;
      case TypeId.stringId:
        return _readString();
      case TypeId.listId:
        return _readList();
      case TypeId.mapId:
        return _readMap();
      default:
        throw UnknownTypeIdException(typeId, reader.position - 1);
    }
  }

  double _readDouble() {
    Uint8List bytes = reader.readBytes(8);
    return bytes.buffer
        .asByteData(bytes.offsetInBytes, bytes.lengthInBytes)
        .getFloat64(0, Endian.big);
  }

  String _readString() {
    int offset = reader.readVarInt();
    if (offset < 0) throw Exception(crumbs.join("."));
    String cached = _stringCache[offset];
    if (cached != null) return cached;
    _strings.position = offset;
    int length = _strings.readVarInt();
    Uint8List bytes = _strings.readBytes(length);
    return _stringCache[offset] = utf8.decode(bytes);
  }

  List _readList() {
    final int length = reader.readVarInt();
    List<Object> result = List(length);
    for (int i = 0; i < length; ++i) {
      crumbs.add("[$i]");
      result[i] = _readObject();
      crumbs.removeLast();
    }
    return result;
  }

  Map _readMap() {
    final int length = reader.readVarInt();
    bool allKeyString = true;
    Map result = {};
    for (int i = 0; i < length; ++i) {
      Object key = _readObject();
      crumbs.add(key);
      Object value = _readObject();
      crumbs.removeLast();
      if (key is! String) allKeyString = false;
      result[key] = value;
    }
    return allKeyString ? Map<String, Object>.from(result) : result;
  }

  final BufferReader reader;
  Map<int, String> _stringCache = {};
  List<Object> crumbs = [];
  BufferReader _strings;
}

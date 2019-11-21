import "dart:typed_data";

class BufferBuilder {
  void add(List<int> bytes) {
    addRange(bytes, 0, bytes.length);
  }

  void addRange(List<int> bytes, int start, int end) {
    final int length = end - start;
    _backing ??= Uint8List(length + _chunkSize);
    int insertion = _prepare(length);
    _backing.setRange(insertion, insertion + length, bytes, start);
  }

  void addByte(int byte) {
    int at = _prepare(1);
    _backing[at] = byte;
  }

  void addVarInt(int val) {
    int bitsLeft = val.bitLength;
    if (bitsLeft % 7 == 0 && val > 0) ++bitsLeft;
    int bytesNeeded = (bitsLeft + 6) ~/ 7;
    if (bytesNeeded == 0) bytesNeeded = 1;
    int at = _prepare(bytesNeeded);
    while (true) {
      int thisByte = val & 0x7f;
      val = val >> 7;
      bitsLeft -= 7;
      if (bitsLeft <= 0) {
        _backing[at] = thisByte;
        break;
      } else {
        _backing[at] = thisByte | 0x80;
      }
      ++at;
    }
  }

  void addInt64(int val) {
    int at = _prepare(8);
    for (int i = 0; i < 8; ++i) {
      _backing[at++] = (val >> 56 - (i << 3)) & 0xff;
    }
  }

  int get position => _pos;

  Uint8List finishAndClear() {
    Uint8List result = Uint8List.fromList(_backing.sublist(0, _pos));
    _backing = null;
    _pos = 0;
    return result;
  }

  int _prepare(int size) {
    int start = _pos;
    _preallocate(size);
    _pos += size;
    return start;
  }

  void _preallocate(int size) {
    if (_backing == null) {
      _backing = Uint8List(size + _chunkSize);
    } else if (_backing.length < _pos + size) {
      Uint8List newBacking = Uint8List(_backing.length + size + _chunkSize);
      newBacking.setRange(0, _pos, _backing);
      _backing = newBacking;
    }
  }

  Uint8List _backing;
  int _pos = 0;

  static const int _chunkSize = 256;
}

Uint8List _castOrConvertToBytes(List<int> bytes) {
  if (bytes is Uint8List) return bytes;
  if (bytes is TypedData) {
    TypedData data = bytes as TypedData;
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
  return Uint8List.fromList(bytes);
}

class BufferReader {
  BufferReader(Uint8List bytes)
      : _backing =
            bytes.buffer.asByteData(bytes.offsetInBytes, bytes.lengthInBytes);

  factory BufferReader.fromBytes(List<int> bytes) =>
      BufferReader(_castOrConvertToBytes(bytes));

  int get position => _pos;

  set position(int val) => _pos = val;

  bool get hasRemaining => _pos < _backing.lengthInBytes;

  Uint8List readBytes(int size) {
    Uint8List result = _range(_pos, _pos + size);
    _pos += size;
    return result;
  }

  int readByte() => _backing.getUint8(_pos++);

  int readVarInt() {
    int val = 0;
    int bitsRead = 0;
    while (true) {
      int byte = readByte();
      int masked = byte & 0x7f;
      val |= masked << bitsRead;
      bitsRead += 7;
      if (byte & 0x80 == 0) {
        if (byte & 0x40 != 0) {
          // sign extend
          val |= -1 << bitsRead;
        }
        break;
      }
    }
    return val;
  }

  int readInt64() {
    int start = _pos;
    _pos += 8;
    return _backing.getUint64(start, Endian.big);
  }

  Uint8List _range(int start, int end) =>
      _backing.buffer.asUint8List(_backing.offsetInBytes + start, end - start);

  final ByteData _backing;
  int _pos = 0;
}

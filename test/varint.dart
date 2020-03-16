import "package:test/test.dart";

import "package:bassoon/src/buffers.dart";

void main() {
  test("negative", () {
    BufferBuilder builder = BufferBuilder();
    builder.addVarInt(-123456);
    List<int> bytes = builder.finishAndClear();
    print(bytes.map((e) => e.toRadixString(16).padLeft(2, "0")).join(", "));
    expect(bytes, [0xc0, 0xbb, 0x78]);
    expect(BufferReader(bytes).readVarInt(), -123456);
  });
  test("positive", () {
    BufferBuilder builder = BufferBuilder();
    builder.addVarInt(123456);
    List<int> bytes = builder.finishAndClear();
    print(bytes.map((e) => e.toRadixString(16).padLeft(2, "0")).join(", "));
    expect(bytes, [0xc0, 0xc4, 0x07]);
    expect(BufferReader(bytes).readVarInt(), 123456);
  });
  test("edge cases", () {
    BufferBuilder builder = BufferBuilder();
    builder.addVarInt(127);
    List<int> bytes = builder.finishAndClear();
    print(bytes.map((e) => e.toRadixString(16).padLeft(2, "0")).join(", "));
    expect(bytes, [0xff, 0]);
    expect(BufferReader(bytes).readVarInt(), 127);
  });
}

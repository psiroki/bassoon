import "package:test/test.dart";

import "package:bassoon/bassoon.dart";

void main() {
  test("empty", () {
    Object result = BassoonDecoder().convert(BassoonEncoder().convert({}));
    expect(result, TypeMatcher<Map<String, Object>>());
    Map obj = result;
    expect(obj.length, 0);
  });
  test("simple", () {
    Map<String, Object> map = {"one": 1, "two": true, "three": null};
    Object result = BassoonDecoder().convert(BassoonEncoder().convert(map));
    expect(result, TypeMatcher<Map<String, Object>>());
    Map obj = result;
    expect(obj, map);
  });
  test("bit", () {
    Map<String, Object> map = {
      "one": [
        {
          "two": {
            "three": [3.7, "bar"],
          },
        },
        {
          "two": {
            "three": [null, "four"],
          },
        },
      ],
    };
    Object result = BassoonDecoder().convert(BassoonEncoder().convert(map));
    expect(result, TypeMatcher<Map<String, Object>>());
    Map obj = result;
    expect(obj, map);
  });
}

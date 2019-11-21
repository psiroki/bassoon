class TypeId {
  static const int nullId = 0x00;
  static const int intId = 0x10;
  static const int doubleId = 0x11;
  static const int falseId = 0x30;
  static const int trueId = 0x31;
  static const int stringId = 0x40;
  static const int mapId = 0x50;
  static const int listId = 0x60;
  static const int stringTableId = 0x70;
}

class MagicNumber {
  static const int versionOne = 0xb1;
}

abstract class BassoonException implements Exception {}

class UnknownTypeIdException implements BassoonException {
  UnknownTypeIdException(this.typeId, this.position);

  @override
  String toString() => "Unrecognized or unexpected type id: "
      "${typeId.toRadixString(16)} at $position";

  final int typeId;
  final int position;
}

class UnknownVersionIdException implements BassoonException {
  UnknownVersionIdException(this.versionId);

  @override
  String toString() =>
      "Unrecognized or unexpected type id: ${versionId.toRadixString(16)}";

  final int versionId;
}

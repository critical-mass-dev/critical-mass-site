class Pledge {
  String compactId;
  int pledgeThreshold;

  Pledge(this.compactId, this.pledgeThreshold);
}

class User {
  List<Pledge> pledgedCompacts = [];
  List<String> createdCompactIds = [];
  // TODO: add preferences
}

class Compact {
  CompactSummary summary;
  String description;

  Compact(this.summary, this.description);
}

class CompactSummary {
  String title;
  String creatorEmail;
  DateTime creationTs;
  int numActivated;
  int numUnactivated;
  String id;

  int get numPledged => numUnactivated + numActivated;

  CompactSummary(
    this.title,
    this.creatorEmail,
    this.creationTs,
    this.numActivated,
    this.numUnactivated,
    this.id,
  );
}


class User {
  final String displayName;
  final String email;
  final String photoUrl;
  final String uid;
  bool firstRun;
  
  User({
    this.displayName,
    this.email,
    this.photoUrl,
    this.uid,
  });

  set updateFirstRun(bool value) {
    firstRun = value;
  }
}

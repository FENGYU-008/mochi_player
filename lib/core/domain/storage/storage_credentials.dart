/// Authentication data for one storage source.
class StorageCredentials {
  final String username;
  final String password;

  const StorageCredentials({this.username = '', this.password = ''});

  @override
  bool operator ==(Object other) {
    return other is StorageCredentials && other.username == username && other.password == password;
  }

  @override
  int get hashCode => Object.hash(username, password);
}

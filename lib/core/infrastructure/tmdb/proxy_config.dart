class ProxyConfig {
  const ProxyConfig._();

  static String? buildHttpProxy(String proxyUrl) {
    final uri = parseProxyUri(proxyUrl);
    if (uri == null) return null;
    return 'PROXY ${uri.host}:${uri.port}';
  }

  static Uri? parseProxyUri(String proxyUrl) {
    final value = proxyUrl.trim();
    if (value.isEmpty) return null;

    final normalized = value.contains('://') ? value : 'http://$value';
    final uri = Uri.tryParse(normalized);
    if (uri == null || uri.host.isEmpty || uri.port == 0) return null;

    return uri;
  }
}

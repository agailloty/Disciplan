/// Personal access tokens used by MCP clients (Mistral, ChatGPT, Claude Desktop, ...).
/// The raw token value is only returned by the creation endpoint, never afterwards.
class McpTokenDto {
  final String id;
  final String name;
  final String scopes;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;

  McpTokenDto({
    required this.id,
    required this.name,
    required this.scopes,
    required this.createdAt,
    this.lastUsedAt,
    this.revokedAt,
  });

  bool get isRevoked => revokedAt != null;
  bool get canWrite => scopes == 'read+write';

  factory McpTokenDto.fromJson(Map<String, dynamic> json) => McpTokenDto(
        id: json['id'] as String,
        name: json['name'] as String,
        scopes: json['scopes'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUsedAt: json['lastUsedAt'] == null
            ? null
            : DateTime.parse(json['lastUsedAt'] as String),
        revokedAt: json['revokedAt'] == null
            ? null
            : DateTime.parse(json['revokedAt'] as String),
      );
}

/// Response of the token creation endpoint: the only place the raw token ever appears.
class CreatedMcpToken {
  final String id;
  final String name;
  final String scopes;
  final String token;

  CreatedMcpToken({
    required this.id,
    required this.name,
    required this.scopes,
    required this.token,
  });

  factory CreatedMcpToken.fromJson(Map<String, dynamic> json) => CreatedMcpToken(
        id: json['id'] as String,
        name: json['name'] as String,
        scopes: json['scopes'] as String,
        token: json['token'] as String,
      );
}

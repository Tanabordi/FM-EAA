import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../data/remote/api_client.dart';

/// Circular Avatar displaying user photo or 2-letter initials
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double radius;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.radius = 24,
  });

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final runes = parts[0].runes.toList();
      if (runes.isEmpty) return '?';
      return String.fromCharCode(runes[0]).toUpperCase();
    }
    final runes0 = parts[0].runes.toList();
    final runes1 = parts[1].runes.toList();
    final first = runes0.isNotEmpty ? String.fromCharCode(runes0[0]) : '';
    final second = runes1.isNotEmpty ? String.fromCharCode(runes1[0]) : '';
    return (first + second).toUpperCase();
  }

  Widget _buildFallback(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: EdgeInsets.all(radius * 0.2),
          child: Text(
            initials,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.7,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return _buildFallback(context);
    }

    // Handle base64 data URLs
    if (avatarUrl!.startsWith('data:image')) {
      try {
        final commaIndex = avatarUrl!.indexOf(',');
        if (commaIndex != -1) {
          final bytes = base64Decode(avatarUrl!.substring(commaIndex + 1));
          return ClipOval(
            child: Image.memory(
              bytes,
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallback(context),
            ),
          );
        }
      } catch (_) {
        return _buildFallback(context);
      }
    }

    final isHttp = avatarUrl!.startsWith('http://') || avatarUrl!.startsWith('https://');

    if (isHttp) {
      String targetUrl = avatarUrl!;
      if (kIsWeb) {
        final isLocal = targetUrl.contains('localhost:') || targetUrl.contains('127.0.0.1:');
        if (!isLocal && !targetUrl.contains('/api/users/avatar-proxy')) {
          targetUrl = '${ApiClient.baseUrl}/users/avatar-proxy?url=${Uri.encodeComponent(targetUrl)}';
        }
      }

      return ClipOval(
        child: Image.network(
          targetUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _buildFallback(context);
          },
        ),
      );
    }

    if (kIsWeb) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        ),
      );
    }

    return ClipOval(
      child: Image.file(
        File(avatarUrl!),
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(context),
      ),
    );
  }
}

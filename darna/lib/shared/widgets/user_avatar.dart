import 'dart:convert';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? data;
  final String name;
  final double radius;

  const UserAvatar({
    super.key,
    this.data,
    required this.name,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (data != null && data!.isNotEmpty) {
      try {
        image = MemoryImage(base64Decode(data!));
      } catch (_) {
        image = null;
      }
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: image,
      child: image == null
          ? Text(
              name.isEmpty ? '?' : name[0].toUpperCase(),
              style: TextStyle(fontSize: radius * 0.8),
            )
          : null,
    );
  }
}
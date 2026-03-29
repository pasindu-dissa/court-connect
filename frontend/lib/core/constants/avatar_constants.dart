class AvatarConstants {
  // Paste your Cloudinary default profile avatar URL here.
  static const String defaultProfileAvatarUrl =
      'https://res.cloudinary.com/dbocyft4g/image/upload/v1773862697/profile_avatar_qct17p.jpg';

  static String avatarUrl(String? imageUrl) {
    if (imageUrl == null) return defaultProfileAvatarUrl;
    final trimmed = imageUrl.trim();
    return trimmed.isEmpty ? defaultProfileAvatarUrl : trimmed;
  }
}

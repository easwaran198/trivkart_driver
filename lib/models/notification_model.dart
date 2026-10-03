class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final String linkUrl;
  final bool isRead;
  final String createdAt;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.linkUrl,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      linkUrl: json['link_url'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class NotificationsModel {
  final int unreadCount;
  final List<NotificationItem> notifications;

  NotificationsModel({
    required this.unreadCount,
    required this.notifications,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) {
    var rawList = json['notifications'] as List? ?? [];
    List<NotificationItem> items =
        rawList.map((e) => NotificationItem.fromJson(e as Map<String, dynamic>)).toList();

    return NotificationsModel(
      unreadCount: json['unread_count'] is int
          ? json['unread_count']
          : int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0,
      notifications: items,
    );
  }
}

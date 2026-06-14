class NotificationDataPayload {
  final String actionType;
  final String? referenceId;
  final String? url;
  final Map<String, dynamic>? additionalContext;

  const NotificationDataPayload({
    required this.actionType,
    this.referenceId,
    this.url,
    this.additionalContext,
  });

  factory NotificationDataPayload.fromJson(Map<String, dynamic> json) {
    return NotificationDataPayload(
      actionType:
          (json['actionType'] ?? json['type'] ?? json['referenceType'] ?? '')
              .toString(),
      referenceId: json['referenceId']?.toString(),
      url: json['url']?.toString(),
      additionalContext: json['additionalContext'] as Map<String, dynamic>?,
    );
  }
}

class NotificationModel {
  final String id;
  final String? userId;
  final String title;
  final String body;
  final NotificationDataPayload? dataPayload;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    this.dataPayload,
    this.isRead = false,
    required this.createdAt,
    this.updatedAt,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      dataPayload: dataPayload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final bodyContent =
        (json['body'] ?? json['content'] ?? json['message'] ?? '').toString();

    final createdAtStr = (json['createdAt'] ?? DateTime.now().toIso8601String())
        .toString();
    final updatedAtStr = (json['updatedAt'] ?? json['readAt'] ?? createdAtStr)
        .toString();
    final payload = json['dataPayload'] is Map<String, dynamic>
        ? json['dataPayload'] as Map<String, dynamic>
        : <String, dynamic>{
            if (json['type'] != null) 'type': json['type'],
            if (json['referenceId'] != null) 'referenceId': json['referenceId'],
            if (json['referenceType'] != null)
              'referenceType': json['referenceType'],
          };

    return NotificationModel(
      id: (json['id'] ?? json['notificationId'] ?? '').toString(),
      userId: json['userId']?.toString(),
      title: (json['title'] ?? 'Thông báo').toString(),
      body: bodyContent,
      dataPayload: payload.isNotEmpty
          ? NotificationDataPayload.fromJson(payload)
          : null,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(createdAtStr).toLocal(),
      updatedAt: DateTime.parse(updatedAtStr).toLocal(),
    );
  }
}

class NotificationListResponse {
  final List<NotificationModel> items;
  final NotificationMeta meta;

  const NotificationListResponse({required this.items, required this.meta});

  factory NotificationListResponse.fromApiPayload(
    dynamic payload, {
    required int page,
    required int limit,
  }) {
    if (payload is List) {
      final items = payload
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
      return NotificationListResponse(
        items: items,
        meta: NotificationMeta(
          itemCount: items.length,
          totalItems: items.length,
          itemsPerPage: limit,
          totalPages: 1,
          currentPage: page,
        ),
      );
    }
    if (payload is Map<String, dynamic>) {
      return NotificationListResponse.fromJson(payload);
    }
    return NotificationListResponse(
      items: const [],
      meta: NotificationMeta(
        itemCount: 0,
        totalItems: 0,
        itemsPerPage: limit,
        totalPages: 1,
        currentPage: page,
      ),
    );
  }

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    final hasMeta = json.containsKey('meta') && json['meta'] != null;
    final hasItems = json.containsKey('items') && json['items'] != null;

    List<NotificationModel> parsedItems = [];
    if (hasItems) {
      parsedItems = (json['items'] as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    NotificationMeta parsedMeta;
    if (hasMeta) {
      parsedMeta = NotificationMeta.fromJson(
        json['meta'] as Map<String, dynamic>,
      );
    } else {
      // Fallback for empty state where pagination is flattened in the response
      parsedMeta = NotificationMeta(
        itemCount: 0,
        totalItems: json['total'] as int? ?? 0,
        itemsPerPage: json['limit'] as int? ?? 15,
        totalPages: json['totalPages'] as int? ?? 0,
        currentPage: json['page'] as int? ?? 1,
      );
    }

    return NotificationListResponse(items: parsedItems, meta: parsedMeta);
  }
}

class NotificationMeta {
  final int itemCount;
  final int totalItems;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  const NotificationMeta({
    required this.itemCount,
    required this.totalItems,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory NotificationMeta.fromJson(Map<String, dynamic> json) {
    return NotificationMeta(
      itemCount: (json['itemCount'] ?? 0) as int,
      totalItems: (json['totalItems'] ?? 0) as int,
      itemsPerPage: (json['itemsPerPage'] ?? 15) as int,
      totalPages: (json['totalPages'] ?? 0) as int,
      currentPage: (json['currentPage'] ?? 1) as int,
    );
  }
}

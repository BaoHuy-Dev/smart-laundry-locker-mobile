class CourierRejectDto {
  final String dispatchId;
  final String? reason;

  const CourierRejectDto({required this.dispatchId, this.reason});

  factory CourierRejectDto.fromJson(Map<String, dynamic> json) {
    return CourierRejectDto(
      dispatchId: json['dispatchId'] as String? ?? '',
      reason: json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'dispatchId': dispatchId, 'reason': reason};
}

import 'package:equatable/equatable.dart';

class CourierTodayStats extends Equatable {
  final int completedToday;
  final int deliveringToday;

  const CourierTodayStats({
    required this.completedToday,
    required this.deliveringToday,
  });

  @override
  List<Object?> get props => [completedToday, deliveringToday];
}

part of 'notifications_bloc.dart';

sealed class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class InitializeNotificationsEvent extends NotificationsEvent {
  final int userId;

  const InitializeNotificationsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

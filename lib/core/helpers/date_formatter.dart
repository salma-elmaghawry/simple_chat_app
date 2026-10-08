import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// A message that was just sent has no server time yet, so use now.
DateTime _toDate(Timestamp? timestamp) => timestamp?.toDate() ?? DateTime.now();

// How many calendar days ago, ignoring the time (yesterday 11 PM = 1).
int _daysAgo(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return today.difference(DateTime(date.year, date.month, date.day)).inDays;
}

// "10:00 AM".
String formatTime(Timestamp? timestamp) {
  return DateFormat('hh:mm a').format(_toDate(timestamp));
}

// Day separator inside a chat: "Today", "Yesterday", "Monday", "12 Oct 2026".
String formatDayHeader(Timestamp? timestamp) {
  final date = _toDate(timestamp);
  final days = _daysAgo(date);
  if (days == 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return DateFormat('EEEE').format(date);
  return DateFormat('d MMM yyyy').format(date);
}

// Chats list: time for today, then "Yesterday", "Mon", "12/10/2026".
String formatChatListDate(Timestamp? timestamp) {
  final date = _toDate(timestamp);
  final days = _daysAgo(date);
  if (days == 0) return formatTime(timestamp);
  if (days == 1) return 'Yesterday';
  if (days < 7) return DateFormat('EEE').format(date);
  return DateFormat('dd/MM/yyyy').format(date);
}

bool isSameDay(Timestamp? a, Timestamp? b) {
  final x = _toDate(a), y = _toDate(b);
  return x.year == y.year && x.month == y.month && x.day == y.day;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// "10:00 AM". A message that was just sent has no server time yet, so use now.
String formatTime(Timestamp? timestamp) {
  final date = timestamp?.toDate() ?? DateTime.now();
  return DateFormat('hh:mm a').format(date);
}

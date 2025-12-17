// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../calendar_event_data.dart';
import '../extensions.dart';

/// Widget that renders pause events as background overlays.
///
/// Pause events are painted as light-gray background bands covering their
/// time ranges. This widget should be placed in a Stack before EventGenerator
/// to ensure proper z-ordering (background pause layer < grid < normal events).
class PauseEventBackground<T extends Object?> extends StatelessWidget {
  /// Height of display area
  final double height;

  /// Width of display area
  final double width;

  /// List of all events (including pause events)
  final List<CalendarEventData<T>> allEvents;

  /// Defines height of single minute in day/week view page.
  final double heightPerMinute;

  /// Defines date for which events will be displayed.
  final DateTime date;

  /// First hour displayed in the layout
  final int startHour;

  /// This field will be used to set end hour for day and week view
  final int endHour;

  /// Background color for pause events. Default is light gray.
  final Color pauseBackgroundColor;

  /// Widget that renders pause events as background overlays.
  const PauseEventBackground({
    Key? key,
    required this.height,
    required this.width,
    required this.allEvents,
    required this.heightPerMinute,
    required this.date,
    required this.startHour,
    this.endHour = 24,
    this.pauseBackgroundColor = const Color(0xFFE0E0E0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter pause events
    final pauseEvents = allEvents.where((event) => event.isPause).toList();

    if (pauseEvents.isEmpty) {
      return SizedBox.shrink();
    }

    return CustomPaint(
      size: Size(width, height),
      painter: _PauseEventPainter<T>(
        pauseEvents: pauseEvents,
        heightPerMinute: heightPerMinute,
        date: date,
        startHour: startHour,
        endHour: endHour,
        pauseBackgroundColor: pauseBackgroundColor,
      ),
    );
  }
}

class _PauseEventPainter<T extends Object?> extends CustomPainter {
  final List<CalendarEventData<T>> pauseEvents;
  final double heightPerMinute;
  final DateTime date;
  final int startHour;
  final int endHour;
  final Color pauseBackgroundColor;

  _PauseEventPainter({
    required this.pauseEvents,
    required this.heightPerMinute,
    required this.date,
    required this.startHour,
    required this.endHour,
    required this.pauseBackgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pauseBackgroundColor
      ..style = PaintingStyle.fill;

    // Normalize the current date (view column date) to midnight for comparison
    final viewDate = date.withoutTime;

    for (final event in pauseEvents) {
      if (event.startTime == null || event.endTime == null) {
        debugPrint(
            '[PausePainter] Skipping event ${event.title}: missing startTime or endTime');
        continue;
      }

      // Normalize event date to midnight for comparison
      final eventDate = event.date.withoutTime;

      // DEBUG: Log view date and event info
      debugPrint(
          '[PausePainter] View date: ${viewDate.year}-${viewDate.month.toString().padLeft(2, '0')}-${viewDate.day.toString().padLeft(2, '0')}');
      debugPrint(
          '[PausePainter] Event date: ${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}, '
          'startTime: ${event.startTime!.hour}:${event.startTime!.minute.toString().padLeft(2, '0')}, '
          'endTime: ${event.endTime!.hour}:${event.endTime!.minute.toString().padLeft(2, '0')}');

      // CRITICAL: Only paint if the event's date matches the view column date exactly
      // The app creates separate CalendarEventData per day, so each event should match its day
      final datesMatch = viewDate.year == eventDate.year &&
          viewDate.month == eventDate.month &&
          viewDate.day == eventDate.day;

      if (!datesMatch) {
        debugPrint(
            '[PausePainter] Skipping: event date does not match view date');
        continue; // Event doesn't belong to this day column, skip
      }

      // Use the event's startTime and endTime directly for this day
      // The app already creates per-day slices with correct times
      int startMinutes = event.startTime!.hour * 60 + event.startTime!.minute;
      int endMinutes = event.endTime!.hour * 60 + event.endTime!.minute;

      // Handle endTime that might be 23:59:59 - convert to 24:00 (end of day)
      if (endMinutes == 23 * 60 + 59) {
        endMinutes = 24 * 60;
      }

      debugPrint(
          '[PausePainter] Computed paint range: ${startMinutes ~/ 60}:${(startMinutes % 60).toString().padLeft(2, '0')} → '
          '${endMinutes ~/ 60}:${(endMinutes % 60).toString().padLeft(2, '0')}');

      // Calculate top position (offset from startHour)
      final startMinutesFromStartHour = startMinutes - (startHour * 60);
      final endMinutesFromStartHour = endMinutes - (startHour * 60);

      // Only paint if the event overlaps with the visible time range
      if (endMinutesFromStartHour <= 0 ||
          startMinutesFromStartHour >= (endHour - startHour) * 60) {
        debugPrint(
            '[PausePainter] Skipping: outside visible time range (${startHour}:00-${endHour}:00)');
        continue;
      }

      // Calculate top and bottom positions, clamped to visible area
      final top = math.max(0.0, startMinutesFromStartHour * heightPerMinute);
      final bottom = math.min(
        size.height,
        endMinutesFromStartHour * heightPerMinute,
      );

      final rectHeight = bottom - top;

      if (rectHeight > 0) {
        // Draw the background rectangle
        final rect = Rect.fromLTWH(0, top, size.width, rectHeight);
        canvas.drawRect(rect, paint);
        debugPrint(
            '[PausePainter] ✓ PAINTED: rect from ${top.toStringAsFixed(1)} to ${bottom.toStringAsFixed(1)} (height: ${rectHeight.toStringAsFixed(1)})');
      } else {
        debugPrint('[PausePainter] Skipping: rectHeight <= 0');
      }
    }
  }

  @override
  bool shouldRepaint(_PauseEventPainter<T> oldDelegate) {
    return pauseEvents != oldDelegate.pauseEvents ||
        heightPerMinute != oldDelegate.heightPerMinute ||
        date != oldDelegate.date ||
        startHour != oldDelegate.startHour ||
        endHour != oldDelegate.endHour ||
        pauseBackgroundColor != oldDelegate.pauseBackgroundColor;
  }
}

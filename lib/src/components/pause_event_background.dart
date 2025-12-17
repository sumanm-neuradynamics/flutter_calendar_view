// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../calendar_event_data.dart';

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

    for (final event in pauseEvents) {
      if (event.startTime == null || event.endTime == null) {
        continue;
      }

      // For multi-day events, calculate the time range for the current date
      int startMinutes;
      int endMinutes;

      if (event.isRangingEvent) {
        // Event spans multiple days
        if (date.isAtSameMomentAs(event.date)) {
          // First day: start from event.startTime, end at midnight (24:00)
          startMinutes = event.startTime!.hour * 60 + event.startTime!.minute;
          endMinutes = 24 * 60; // End of day
        } else if (date.isAtSameMomentAs(event.endDate)) {
          // Last day: start from midnight (00:00), end at event.endTime
          startMinutes = 0;
          endMinutes = event.endTime!.hour * 60 + event.endTime!.minute;
        } else if (date.isAfter(event.date) && date.isBefore(event.endDate)) {
          // Middle day(s): full day coverage
          startMinutes = 0;
          endMinutes = 24 * 60;
        } else {
          continue; // Not on this date
        }
      } else {
        // Single day event
        startMinutes = event.startTime!.hour * 60 + event.startTime!.minute;
        endMinutes = event.endTime!.hour * 60 + event.endTime!.minute;
      }

      // Calculate top position (offset from startHour)
      final startMinutesFromStartHour = startMinutes - (startHour * 60);
      final endMinutesFromStartHour = endMinutes - (startHour * 60);

      // Only paint if the event overlaps with the visible time range
      if (endMinutesFromStartHour <= 0 ||
          startMinutesFromStartHour >= (endHour - startHour) * 60) {
        continue;
      }

      // Calculate top and bottom positions
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

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
    // Filter pause events - recompute every build, no caching
    final pauseEvents = allEvents.where((event) => event.isPause).toList();

    if (pauseEvents.isEmpty) {
      return SizedBox.shrink();
    }

    // Use date as key to ensure widget identity changes when date changes
    // This prevents stale overlays from previous weeks/days
    return CustomPaint(
      key: ValueKey('pause_${date.year}_${date.month}_${date.day}'),
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

  /// Converts DateTime time to minutes from midnight (0-1440)
  int _toMinutes(DateTime time) {
    return time.hour * 60 + time.minute;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = pauseBackgroundColor
      ..style = PaintingStyle.fill;

    // Normalize the view column date to midnight for strict comparison
    final columnDate = date.withoutTime;
    final columnDateStr =
        '${columnDate.year}-${columnDate.month.toString().padLeft(2, '0')}-${columnDate.day.toString().padLeft(2, '0')}';

    debugPrint(
        '[PausePainter] ===== Painting for column date: $columnDateStr =====');

    for (final event in pauseEvents) {
      if (event.startTime == null || event.endTime == null) {
        debugPrint(
            '[PausePainter] SKIP: Event "${event.title}" missing startTime or endTime');
        continue;
      }

      // Normalize event date to midnight for strict comparison
      final eventDate = event.date.withoutTime;
      final eventDateStr =
          '${eventDate.year}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}';

      // STRICT DATE MATCH: Only paint if event.date exactly matches column date
      final datesMatch = columnDate.year == eventDate.year &&
          columnDate.month == eventDate.month &&
          columnDate.day == eventDate.day;

      if (!datesMatch) {
        debugPrint(
            '[PausePainter] SKIP: Event date ($eventDateStr) != column date ($columnDateStr)');
        continue; // Event doesn't belong to this day column, skip immediately
      }

      // Convert times to minutes from midnight (0-1440)
      int minutesFrom = _toMinutes(event.startTime!);
      int minutesTo = _toMinutes(event.endTime!);

      // Handle 23:59:59 case - normalize to 1440 (end of day)
      if (event.endTime!.hour == 23 && event.endTime!.minute == 59) {
        minutesTo = 1440;
      }

      // CLAMP: Ensure minutes are within valid range [0, 1440]
      minutesFrom = math.max(0, math.min(1440, minutesFrom));
      minutesTo = math.max(0, math.min(1440, minutesTo));

      // VALIDATE: Skip if invalid range
      if (minutesTo <= minutesFrom) {
        debugPrint(
            '[PausePainter] SKIP: Invalid time range (minutesTo=$minutesTo <= minutesFrom=$minutesFrom)');
        continue;
      }

      // Log computed paint range
      final fromStr =
          '${minutesFrom ~/ 60}:${(minutesFrom % 60).toString().padLeft(2, '0')}';
      final toStr =
          '${minutesTo ~/ 60}:${(minutesTo % 60).toString().padLeft(2, '0')}';
      debugPrint(
          '[PausePainter] Event date: $eventDateStr, minutesFrom: $minutesFrom ($fromStr), minutesTo: $minutesTo ($toStr)');

      // Calculate position relative to startHour
      final startMinutesFromStartHour = minutesFrom - (startHour * 60);
      final endMinutesFromStartHour = minutesTo - (startHour * 60);

      // Check if event overlaps with visible time range
      final visibleRangeMinutes = (endHour - startHour) * 60;
      if (endMinutesFromStartHour <= 0 ||
          startMinutesFromStartHour >= visibleRangeMinutes) {
        debugPrint(
            '[PausePainter] SKIP: Outside visible range (${startHour}:00-${endHour}:00, ${visibleRangeMinutes}min)');
        continue;
      }

      // Calculate top and bottom positions, clamped to visible area
      final top = math.max(0.0, startMinutesFromStartHour * heightPerMinute);
      final bottom =
          math.min(size.height, endMinutesFromStartHour * heightPerMinute);
      final rectHeight = bottom - top;

      if (rectHeight > 0) {
        // Draw the background rectangle
        final rect = Rect.fromLTWH(0, top, size.width, rectHeight);
        canvas.drawRect(rect, paint);
        debugPrint(
            '[PausePainter] ✓ PAINTED: rect(top=${top.toStringAsFixed(1)}, bottom=${bottom.toStringAsFixed(1)}, height=${rectHeight.toStringAsFixed(1)})');
      } else {
        debugPrint(
            '[PausePainter] SKIP: rectHeight <= 0 (top=$top, bottom=$bottom)');
      }
    }

    debugPrint(
        '[PausePainter] ===== Finished painting for column date: $columnDateStr =====');
  }

  @override
  bool shouldRepaint(_PauseEventPainter<T> oldDelegate) {
    // Always repaint if any property changes to prevent stale overlays
    final dateChanged = date.year != oldDelegate.date.year ||
        date.month != oldDelegate.date.month ||
        date.day != oldDelegate.date.day;

    final shouldRepaint =
        pauseEvents.length != oldDelegate.pauseEvents.length ||
            heightPerMinute != oldDelegate.heightPerMinute ||
            dateChanged ||
            startHour != oldDelegate.startHour ||
            endHour != oldDelegate.endHour ||
            pauseBackgroundColor != oldDelegate.pauseBackgroundColor;

    // Also check if event contents changed (compare first event's date/time if available)
    if (!shouldRepaint &&
        pauseEvents.isNotEmpty &&
        oldDelegate.pauseEvents.isNotEmpty) {
      final firstNew = pauseEvents.first;
      final firstOld = oldDelegate.pauseEvents.first;
      final newDate = firstNew.date.withoutTime;
      final oldDate = firstOld.date.withoutTime;
      if (newDate.year != oldDate.year ||
          newDate.month != oldDate.month ||
          newDate.day != oldDate.day ||
          firstNew.startTime?.hour != firstOld.startTime?.hour ||
          firstNew.startTime?.minute != firstOld.startTime?.minute ||
          firstNew.endTime?.hour != firstOld.endTime?.hour ||
          firstNew.endTime?.minute != firstOld.endTime?.minute) {
        return true;
      }
    }

    return shouldRepaint;
  }
}

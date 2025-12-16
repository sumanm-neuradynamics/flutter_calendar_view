// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../../calendar_view.dart';
import '../components/_internal_components.dart';
import '../extensions.dart';
import '../painters.dart';

/// A single page for week view.
class InternalWeekViewPage<T extends Object?> extends StatefulWidget {
  /// Width of the page.
  final double width;

  /// Height of the page.
  final double height;

  /// Dates to display on page.
  final List<DateTime> dates;

  /// Builds tile for a single event.
  final EventTileBuilder<T> eventTileBuilder;

  /// A calendar controller that controls all the events and rebuilds widget
  /// if event(s) are added or removed.
  final EventController<T> controller;

  /// A builder to build time line.
  final DateWidgetBuilder timeLineBuilder;

  /// Settings for hour indicator lines.
  final HourIndicatorSettings hourIndicatorSettings;

  /// Custom painter for hour line.
  final CustomHourLinePainter hourLinePainter;

  /// Settings for half hour indicator lines.
  final HourIndicatorSettings halfHourIndicatorSettings;

  /// Settings for quarter hour indicator lines.
  final HourIndicatorSettings quarterHourIndicatorSettings;

  /// Flag to display live line.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final LiveTimeIndicatorSettings liveTimeIndicatorSettings;

  ///  Height occupied by one minute time span.
  final double heightPerMinute;

  /// Width of timeline.
  final double timeLineWidth;

  /// Offset of timeline.
  final double timeLineOffset;

  /// Height occupied by one hour time span.
  final double hourHeight;

  /// Arranger to arrange events.
  final EventArranger<T> eventArranger;

  /// Flag to display vertical line or not.
  final bool showVerticalLine;

  /// Offset for vertical line offset.
  final double verticalLineOffset;

  /// Builder for week day title.
  final DateWidgetBuilder weekDayBuilder;

  /// Builder for week number.
  final WeekNumberBuilder weekNumberBuilder;

  /// Builds custom PressDetector widget
  final DetectorBuilder weekDetectorBuilder;

  /// Height of week title.
  final double weekTitleHeight;

  /// Width of week title.
  final double weekTitleWidth;

  /// Background color of week title
  final Color? weekTitleBackgroundColor;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

  /// Called when user long press on event tile.
  final CellTapCallback<T>? onTileLongTap;

  /// Called when user double tap on any event tile.
  final CellTapCallback<T>? onTileDoubleTap;

  /// Defines which days should be displayed in one week.
  ///
  /// By default all the days will be visible.
  /// Sequence will be monday to sunday.
  final List<WeekDays> weekDays;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  final EventScrollConfiguration scrollConfiguration;

  /// Display full day events.
  final FullDayEventBuilder<T> fullDayEventBuilder;

  final ScrollController weekViewScrollController;

  /// First hour displayed in the layout
  final int startHour;

  /// If true this will show week day at bottom position.
  final bool showWeekDayAtBottom;

  /// Flag to display half hours
  final bool showHalfHours;

  /// Flag to display quarter hours
  final bool showQuarterHours;

  /// Emulate vertical line offset from hour line starts.
  final double emulateVerticalOffsetBy;

  /// This field will be used to set end hour for week view
  final int endHour;

  /// Title of the full day events row
  final String fullDayHeaderTitle;

  /// Defines full day events header text config
  final FullDayHeaderTextConfig fullDayHeaderTextConfig;

  /// Scroll listener to set every page's last offset
  final void Function(ScrollController) scrollListener;

  /// Last scroll offset of week view page.
  final double lastScrollOffset;

  /// Flag to keep scrollOffset of pages on page change
  final bool keepScrollOffset;

  /// Use this field to disable the calendar scrolling
  final ScrollPhysics? scrollPhysics;

  /// This method will be called when user taps on timestamp in timeline.
  final TimestampCallback? onTimestampTap;

  /// Use this to change background color of week view page
  final Color? backgroundColor;

  /// Opacity for full-width events that span all day columns.
  final double fullWidthEventOpacity;

  /// Border radius for full-width events.
  final double fullWidthEventBorderRadius;

  /// Border styling for full-width events.
  final Border? fullWidthEventBorder;

  /// A single page for week view.
  const InternalWeekViewPage({
    Key? key,
    required this.showVerticalLine,
    required this.weekTitleHeight,
    required this.weekDayBuilder,
    required this.weekNumberBuilder,
    required this.width,
    required this.dates,
    required this.eventTileBuilder,
    required this.controller,
    required this.timeLineBuilder,
    required this.hourIndicatorSettings,
    required this.hourLinePainter,
    required this.halfHourIndicatorSettings,
    required this.quarterHourIndicatorSettings,
    required this.showLiveLine,
    required this.liveTimeIndicatorSettings,
    required this.heightPerMinute,
    required this.timeLineWidth,
    required this.timeLineOffset,
    required this.height,
    required this.hourHeight,
    required this.eventArranger,
    required this.verticalLineOffset,
    required this.weekTitleWidth,
    required this.weekTitleBackgroundColor,
    required this.onTileTap,
    required this.onTileLongTap,
    required this.onDateLongPress,
    required this.onDateTap,
    required this.weekDays,
    required this.minuteSlotSize,
    required this.scrollConfiguration,
    required this.startHour,
    required this.fullDayEventBuilder,
    required this.weekDetectorBuilder,
    required this.showWeekDayAtBottom,
    required this.showHalfHours,
    required this.showQuarterHours,
    required this.emulateVerticalOffsetBy,
    required this.onTileDoubleTap,
    required this.endHour,
    required this.onTimestampTap,
    this.fullDayHeaderTitle = '',
    required this.fullDayHeaderTextConfig,
    required this.scrollPhysics,
    required this.scrollListener,
    required this.weekViewScrollController,
    this.lastScrollOffset = 0.0,
    this.keepScrollOffset = false,
    this.backgroundColor,
    this.fullWidthEventOpacity = 0.6,
    this.fullWidthEventBorderRadius = 0.0,
    this.fullWidthEventBorder,
  }) : super(key: key);

  @override
  _InternalWeekViewPageState<T> createState() =>
      _InternalWeekViewPageState<T>();
}

class _InternalWeekViewPageState<T extends Object?>
    extends State<InternalWeekViewPage<T>> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      initialScrollOffset: widget.lastScrollOffset,
    );
    scrollController.addListener(_scrollControllerListener);
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_scrollControllerListener)
      ..dispose();
    super.dispose();
  }

  void _scrollControllerListener() {
    widget.scrollListener(scrollController);
  }

  @override
  Widget build(BuildContext context) {
    final filteredDates = _filteredDate();
    final themeColor = context.weekViewColors;

    return Container(
      color: widget.backgroundColor ?? themeColor.pageBackgroundColor,
      height: widget.height + widget.weekTitleHeight,
      width: widget.width,
      child: Column(
        verticalDirection: widget.showWeekDayAtBottom
            ? VerticalDirection.up
            : VerticalDirection.down,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: widget.width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    height: widget.weekTitleHeight,
                    width: widget.timeLineWidth +
                        widget.hourIndicatorSettings.offset,
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: widget.weekTitleBackgroundColor ??
                        themeColor.weekDayTileColor,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(
                          filteredDates.length,
                          (index) => SizedBox(
                            height: widget.weekTitleHeight,
                            width: widget.weekTitleWidth,
                            child: widget.weekDayBuilder(
                              filteredDates[index],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1,
            height: 1,
            color: themeColor.borderColor,
          ),
          SizedBox(
            width: widget.width,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: themeColor.borderColor,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: widget.timeLineWidth +
                        widget.hourIndicatorSettings.offset,
                    child: widget.fullDayHeaderTitle.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 1,
                            ),
                            child: Text(
                              widget.fullDayHeaderTitle,
                              textAlign:
                                  widget.fullDayHeaderTextConfig.textAlign,
                              maxLines: widget.fullDayHeaderTextConfig.maxLines,
                              overflow:
                                  widget.fullDayHeaderTextConfig.textOverflow,
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
                  ...List.generate(
                    filteredDates.length,
                    (index) {
                      final fullDayEventList = widget.controller
                          .getFullDayEvent(filteredDates[index]);
                      return Container(
                        width: widget.weekTitleWidth,
                        child: fullDayEventList.isEmpty
                            ? null
                            : widget.fullDayEventBuilder.call(
                                fullDayEventList,
                                widget.dates[index],
                              ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.keepScrollOffset
                  ? scrollController
                  : widget.weekViewScrollController,
              physics: widget.scrollPhysics,
              child: SizedBox(
                height: widget.height,
                width: widget.width,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(widget.width, widget.height),
                      painter: widget.hourLinePainter(
                        widget.hourIndicatorSettings.color,
                        widget.hourIndicatorSettings.height,
                        widget.timeLineWidth +
                            widget.hourIndicatorSettings.offset,
                        widget.heightPerMinute,
                        widget.showVerticalLine,
                        widget.verticalLineOffset,
                        widget.hourIndicatorSettings.lineStyle,
                        widget.hourIndicatorSettings.dashWidth,
                        widget.hourIndicatorSettings.dashSpaceWidth,
                        widget.emulateVerticalOffsetBy,
                        widget.startHour,
                        widget.endHour,
                      ),
                    ),
                    if (widget.showHalfHours)
                      CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: HalfHourLinePainter(
                          lineColor: widget.halfHourIndicatorSettings.color,
                          lineHeight: widget.halfHourIndicatorSettings.height,
                          offset: widget.timeLineWidth +
                              widget.halfHourIndicatorSettings.offset,
                          minuteHeight: widget.heightPerMinute,
                          lineStyle: widget.halfHourIndicatorSettings.lineStyle,
                          dashWidth: widget.halfHourIndicatorSettings.dashWidth,
                          dashSpaceWidth:
                              widget.halfHourIndicatorSettings.dashSpaceWidth,
                          startHour: widget.halfHourIndicatorSettings.startHour,
                          endHour: widget.endHour,
                        ),
                      ),
                    if (widget.showQuarterHours)
                      CustomPaint(
                        size: Size(widget.width, widget.height),
                        painter: QuarterHourLinePainter(
                          lineColor: widget.quarterHourIndicatorSettings.color,
                          lineHeight:
                              widget.quarterHourIndicatorSettings.height,
                          offset: widget.timeLineWidth +
                              widget.quarterHourIndicatorSettings.offset,
                          minuteHeight: widget.heightPerMinute,
                          lineStyle:
                              widget.quarterHourIndicatorSettings.lineStyle,
                          dashWidth:
                              widget.quarterHourIndicatorSettings.dashWidth,
                          dashSpaceWidth: widget
                              .quarterHourIndicatorSettings.dashSpaceWidth,
                        ),
                      ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: widget.weekTitleWidth * filteredDates.length,
                        height: widget.height,
                        child: Row(
                          children: [
                            ...List.generate(
                              filteredDates.length,
                              (index) => Container(
                                decoration: widget.showVerticalLine
                                    ? BoxDecoration(
                                        // To apply different colors to the timeline
                                        // and cells, use the background color for the timeline.
                                        // Additionally, set the `color` property here with an alpha value
                                        // to see horizontal & vertical lines

                                        border: Border(
                                          right: BorderSide(
                                            color:
                                                themeColor.verticalLinesColor,
                                            width: widget
                                                .hourIndicatorSettings.height,
                                          ),
                                        ),
                                      )
                                    : null,
                                height: widget.height,
                                width: widget.weekTitleWidth,
                                child: Stack(
                                  children: [
                                    widget.weekDetectorBuilder(
                                      width: widget.weekTitleWidth,
                                      height: widget.height,
                                      heightPerMinute: widget.heightPerMinute,
                                      date: widget.dates[index],
                                      minuteSlotSize: widget.minuteSlotSize,
                                    ),
                                    EventGenerator<T>(
                                      height: widget.height,
                                      date: filteredDates[index],
                                      onTileTap: widget.onTileTap,
                                      onTileLongTap: widget.onTileLongTap,
                                      onTileDoubleTap: widget.onTileDoubleTap,
                                      width: widget.weekTitleWidth,
                                      eventArranger: widget.eventArranger,
                                      eventTileBuilder: widget.eventTileBuilder,
                                      scrollNotifier:
                                          widget.scrollConfiguration,
                                      startHour: widget.startHour,
                                      events: widget.controller
                                          .getEventsOnDay(
                                            filteredDates[index],
                                            includeFullDayEvents: false,
                                          )
                                          .where((e) => !e.isFullWidth)
                                          .toList(),
                                      heightPerMinute: widget.heightPerMinute,
                                      endHour: widget.endHour,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    _buildFullWidthEvents(filteredDates, themeColor),
                    TimeLine(
                      timeLineWidth: widget.timeLineWidth,
                      hourHeight: widget.hourHeight,
                      height: widget.height,
                      timeLineOffset: widget.timeLineOffset,
                      timeLineBuilder: widget.timeLineBuilder,
                      startHour: widget.startHour,
                      showHalfHours: widget.showHalfHours,
                      showQuarterHours: widget.showQuarterHours,
                      liveTimeIndicatorSettings:
                          widget.liveTimeIndicatorSettings,
                      endHour: widget.endHour,
                      onTimestampTap: widget.onTimestampTap,
                    ),
                    if (widget.showLiveLine &&
                        widget.liveTimeIndicatorSettings.height > 0)
                      LiveTimeIndicator(
                        liveTimeIndicatorSettings:
                            widget.liveTimeIndicatorSettings,
                        width: widget.width,
                        height: widget.height,
                        heightPerMinute: widget.heightPerMinute,
                        timeLineWidth: widget.timeLineWidth,
                        startHour: widget.startHour,
                        endHour: widget.endHour,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DateTime> _filteredDate() {
    final output = <DateTime>[];

    final weekDays = widget.weekDays.toList();

    for (final date in widget.dates) {
      if (weekDays.any((weekDay) => weekDay.index + 1 == date.weekday)) {
        output.add(date);
      }
    }

    return output;
  }

  /// Builds full-width events that span all day columns.
  Widget _buildFullWidthEvents(
      List<DateTime> filteredDates, dynamic themeColor) {
    // Collect all full-width events for the week, avoiding duplicates
    final fullWidthEventsSet = <CalendarEventData<T>>{};
    for (final date in filteredDates) {
      final events = widget.controller.getEventsOnDay(
        date,
        includeFullDayEvents: false,
      );
      fullWidthEventsSet.addAll(events.where((e) => e.isFullWidth));
    }

    final fullWidthEvents = fullWidthEventsSet.toList();
    if (fullWidthEvents.isEmpty) {
      return SizedBox.shrink();
    }

    // Calculate the width for full-width events (all day columns)
    final fullWidth = widget.weekTitleWidth * filteredDates.length;
    final startOffset =
        widget.timeLineWidth + widget.hourIndicatorSettings.offset;

    return Positioned(
      left: startOffset,
      top: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        width: fullWidth,
        height: widget.height,
        child: Stack(
          children: fullWidthEvents.map((event) {
            return _buildFullWidthEventBar(event, fullWidth);
          }).toList(),
        ),
      ),
    );
  }

  /// Builds a single full-width event bar.
  Widget _buildFullWidthEventBar(
    CalendarEventData<T> event,
    double fullWidth,
  ) {
    if (event.startTime == null || event.endTime == null) {
      return SizedBox.shrink();
    }

    final startHourInMinutes = widget.startHour * 60;
    final startMinutes = event.startTime!.getTotalMinutes - startHourInMinutes;
    final endMinutes = event.endTime!.getTotalMinutes - startHourInMinutes;

    // Calculate top position
    final top = startMinutes * widget.heightPerMinute;

    // Calculate height
    final height = (endMinutes - startMinutes) * widget.heightPerMinute;

    // Ensure the event is within visible range
    if (endMinutes <= 0 ||
        startMinutes >= (widget.endHour - widget.startHour) * 60) {
      return SizedBox.shrink();
    }

    // Clip start/end if event extends beyond visible range
    final clippedTop = startMinutes < 0 ? 0.0 : top;
    final clippedHeight = endMinutes > (widget.endHour - widget.startHour) * 60
        ? ((widget.endHour - widget.startHour) * 60 - startMinutes) *
            widget.heightPerMinute
        : height;

    return Positioned(
      top: clippedTop,
      left: 0,
      right: 0,
      height: clippedHeight,
      child: GestureDetector(
        onTap: () => widget.onTileTap?.call([event], event.date),
        onLongPress: () => widget.onTileLongTap?.call([event], event.date),
        onDoubleTap: () => widget.onTileDoubleTap?.call([event], event.date),
        child: Container(
          decoration: BoxDecoration(
            color: event.color.withOpacity(widget.fullWidthEventOpacity),
            borderRadius:
                BorderRadius.circular(widget.fullWidthEventBorderRadius),
            border: widget.fullWidthEventBorder,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: widget.eventTileBuilder(
            event.date,
            [event],
            Rect.fromLTWH(0, 0, fullWidth, clippedHeight),
            event.startTime!,
            event.endTime!,
          ),
        ),
      ),
    );
  }
}

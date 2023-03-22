import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/binding.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:intl/src/intl/date_format.dart';

import 'package:euphony/app_state.dart';


int DATE_PICKER_START_YEAR = 1900;
int DATE_PICKER_END_YEAR = 2100;

List<String> _MONTH_NAMES = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];
List<String> _WEEKDAY_NAMES = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday'
];
List<String> _REPEAT_OPTIONS = [
  'Never',
  'Daily',
  'Weekly',
  'Monthly',
  'Yearly'
];
List<String> _REPEAT_UNTIL_OPTIONS = [
  'Never',
  'Until',
  'Count'
];
/// These are for monthly repeating events, eg. the n-th tuesday of every month.
List<String> _WEEK_POSITIONS = [
  'First',
  'Second',
  'Third',
  'Fourth',
  'Last'
];


class EuphonyCalendar extends StatefulWidget {
  @override
  State<EuphonyCalendar> createState() => _EuphonyCalendarState();
}

class _EuphonyCalendarState extends State<EuphonyCalendar> {
  late List<String> _subjectCollection;
  late List<Appointment> _appointments;
  late _EventDataSource _events;

  Appointment? _selected_appointment;
  String _subject = '';
  bool _is_all_day = false;
  late List<DateTime> _visible_dates;

  final List<CalendarView> _selectable_calendar_views = [
    CalendarView.day,
    CalendarView.week,
    CalendarView.month
  ];
  final CalendarController calendar_controller = CalendarController();

  CalendarView _view = CalendarView.month;

  @override
  void initState() {
    _appointments = _getAppointmentDetails();
    calendar_controller.view = _view;
    _events = _EventDataSource(_appointments);

    _selected_appointment = null;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Widget calendar = Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          secondary: Theme.of(context).colorScheme.background
        )
      ),
      child: _defineEditableCalendar(
        calendar_controller,
        _events,
        _onCalendarTapped,
        _onViewChanged
      )
    );
    return Container(
      color: Theme.of(context).cardColor,
      child: calendar
    );
  }

  List<Appointment> _getAppointmentDetails() {
    final List<Appointment> appointmentCollection = <Appointment>[];

    // TODO: fetch stuff from the database

    return appointmentCollection;
  }

  SfCalendar _defineEditableCalendar([
      CalendarController? calendar_controller,
      _EventDataSource? calendar_data_source,
      dynamic calendarClickedCallback,
      ViewChangedCallback? viewChangedCallback,
      dynamic scheduleViewBuilder]) {
    return SfCalendar(
      controller: calendar_controller,
      showNavigationArrow: true,
      allowedViews: _selectable_calendar_views,
      showDatePickerButton: true,
      dataSource: calendar_data_source,
      onTap: calendarClickedCallback,
      onViewChanged: viewChangedCallback,
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment
      ),
      timeSlotViewSettings: const TimeSlotViewSettings(
        minimumAppointmentDuration: Duration()
      ),
    );
  }

  void _onCalendarTapped(CalendarTapDetails tapDetails) {
    final CalendarElement target_element = tapDetails.targetElement;

    if (
      target_element == CalendarElement.header ||
      target_element == CalendarElement.resourceHeader
    ) {
      return;
    }

    _selected_appointment = null;

    if (calendar_controller.view == CalendarView.month) {
      calendar_controller.view = CalendarView.day;
    } else {
      if (
        tapDetails.appointments != null &&
        target_element == CalendarElement.appointment
      ) {
        final dynamic appointment = tapDetails.appointments![0];
        if (appointment is Appointment) {
          _selected_appointment = appointment;
        }
      }

      final DateTime selected_date = tapDetails.date!;
      final bool is_appointment_tapped = target_element == CalendarElement.appointment;
      showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          final List<Appointment> appointment = <Appointment> [];
          Appointment? new_appointment;

          if (_selected_appointment == null) {
            bool _is_all_day = target_element == CalendarElement.allDayPanel;
            _subject = '';
            final DateTime date = tapDetails.date!;

            new_appointment = Appointment(
              startTime: date,
              endTime: date.add(const Duration()),
              isAllDay: _is_all_day,
              subject: _subject == '' ? '(No title)' : _subject,
            );
            appointment.add(new_appointment);

            _events.appointments.add(appointment[0]);

            SchedulerBinding.instance.addPostFrameCallback(
              (Duration duration) {
                _events.notifyListeners(
                  CalendarDataSourceAction.add,
                  appointment
                );
              }
            );

            _selected_appointment = new_appointment;
          }

          return WillPopScope(
            onWillPop: () async {
              if (new_appointment != null) {
                _events.appointments.removeAt(
                  _events.appointments.indexOf(new_appointment)
                );
                _events.notifyListeners(
                  CalendarDataSourceAction.remove,
                  <Appointment>[new_appointment]
                );
              }
              return true;
            },
            child: Center(
              child: Container(
                alignment: Alignment.center,
                child: Theme(
                  data: Theme.of(context),
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: is_appointment_tapped ?
                      AppointmentDetails(
                        context,
                        target_element,
                        selected_date,
                        _selected_appointment!,
                        _events,
                        _visible_dates
                      ) :
                      PopupAppointmentEditor(
                        new_appointment,
                        appointment,
                        _events,
                        _selected_appointment!,
                        _visible_dates
                      )
                  )
                )
              ),
            )
          );
        }
      );
    }
  }

  void _onViewChanged(ViewChangedDetails viewChangedDetails) {
    _visible_dates = viewChangedDetails.visibleDates;
    if (_view == calendar_controller.view ||
        (_view != CalendarView.month &&
            calendar_controller.view != CalendarView.month)) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      setState(() {
        _view = calendar_controller.view!;

        /// Update the current view when the calendar view changed to
        /// month view or from month view.
      });
    });
  }


}



class _EventDataSource extends CalendarDataSource {
  _EventDataSource(this.source);

  List<Appointment> source;

  @override
  List<dynamic> get appointments => source;
}



Widget AppointmentDetails(
  BuildContext context,
  CalendarElement target_element,
  DateTime selected_date,
  Appointment selected_appointment,
  CalendarDataSource events,
  List<DateTime> visible_dates
) {
  final List<Appointment> appointment_collection = <Appointment>[];

  Widget appointment_details = ListView(
    padding: EdgeInsets.zero,
    children: [
      ListTile(
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.pop(context);
                showDialog<Widget>(
                    context: context,
                    builder: (BuildContext context) {
                      return Placeholder();
                    });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                if (selected_appointment.appointmentType == AppointmentType.normal) {
                  Navigator.pop(context);
                  events.appointments!
                      .removeAt(events.appointments!.indexOf(selected_appointment));
                  events.notifyListeners(CalendarDataSourceAction.remove,
                      <Appointment>[selected_appointment]);
                } else {
                  Navigator.pop(context);
                  showDialog<Widget>(
                      context: context,
                      builder: (BuildContext context) {
                        return Placeholder();
                      });
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ]
        )
      )
    ]
  );

  return Placeholder();
}



class PopupAppointmentEditor extends StatefulWidget {
  const PopupAppointmentEditor(
    this.new_appointment,
    this.appointment,
    this.events,
    this.selected_appointment,
    this.visible_dates
  );

  final Appointment? new_appointment;
  final List<Appointment> appointment;
  final CalendarDataSource events;
  final Appointment selected_appointment;
  final List<DateTime> visible_dates;

  @override
  State<StatefulWidget> createState() => _PopupAppointmentEditorState();

}

class _PopupAppointmentEditorState extends State<PopupAppointmentEditor> {

  late DateTime _start_date;
  late DateTime _end_date;
  late TimeOfDay _start_time;
  late TimeOfDay _end_time;

  bool _is_all_day = false;
  String _subject = '';
  String? _notes;
  String? _location;

  List<Object>? _resourceIds;
  List<CalendarResource> _selectedResources = [];
  List<CalendarResource> _unSelectedResources = [];

  @override
  void initState() {
    _updateAppointmentProperties();
    super.initState();
  }

  @override
  void didUpdateWidget(PopupAppointmentEditor old_widget) {
    super.didUpdateWidget(old_widget);
  }

  void _updateAppointmentProperties() {
    _start_date = widget.selected_appointment.startTime;
    _end_date = widget.selected_appointment.endTime;
    _is_all_day = widget.selected_appointment.isAllDay;
    _subject = widget.selected_appointment.subject == '(No title)'
        ? ''
        : widget.selected_appointment.subject;
    _notes = widget.selected_appointment.notes;
    _location = widget.selected_appointment.location;

    _resourceIds = widget.selected_appointment.resourceIds?.sublist(0);

    _start_time = TimeOfDay(hour: _start_date.hour, minute: _start_date.minute);
    _end_time = TimeOfDay(hour: _end_date.hour, minute: _end_date.minute);
    _selectedResources =
        _getSelectedResources(_resourceIds, widget.events.resources);
    _unSelectedResources =
        _getUnSelectedResources(_selectedResources, widget.events.resources);
  }

  @override
  Widget build(BuildContext context) {

    final Widget start_date_picker = RawMaterialButton(
      onPressed: () async {
        final DateTime? date = await showDatePicker(
          context: context,
          initialDate: _start_date,
          firstDate: DateTime(DATE_PICKER_START_YEAR),
          lastDate: DateTime(DATE_PICKER_END_YEAR),
          builder: (BuildContext context, Widget? child) {
            return Container(
              child: child!
            );
          }
        );

        if (date != null && date != _start_date) {
          setState(
            () {
              final Duration difference = _end_date.difference(_start_date);
              _start_date = DateTime(
                date.year,
                date.month,
                date.day,
                _start_time.hour,
                _start_time.minute
              );
              _end_date = _start_date.add(difference);
              _end_time = TimeOfDay(
                hour: _end_date.hour,
                minute: _end_date.minute
              );
            }
          );
        }

      },
      child: Text(
        DateFormat('MMM dd, yyyy').format(_start_date),
      )
    );

    final Widget start_time_picker = RawMaterialButton(
      onPressed: () async {
        final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime:
            TimeOfDay(hour: _start_time.hour, minute: _start_time.minute),
            builder: (BuildContext context, Widget? child) {
              /// Theme widget used to apply the theme and primary color to the
              /// time picker.
              return Container(
                /// The themedata created based
                /// on the selected theme and primary color.
                child: child!,
              );
            });

        if (time != null && time != _start_time) {
          setState(() {
            _start_time = time;
            final Duration difference = _end_date.difference(_start_date);
            _start_date = DateTime(_start_date.year, _start_date.month,
                _start_date.day, _start_time.hour, _start_time.minute);
            _end_date = _start_date.add(difference);
            _end_time = TimeOfDay(hour: _end_date.hour, minute: _end_date.minute);
          });
        }
      },
      child: Text(
        DateFormat('hh:mm a').format(_start_date),
        style: TextStyle(fontWeight: FontWeight.w500),
        textAlign: TextAlign.left,
      ),
    );

    final Widget end_time_picker = RawMaterialButton(
      onPressed: () async {
        final TimeOfDay? time = await showTimePicker(
            context: context,
            initialTime:
            TimeOfDay(hour: _end_time.hour, minute: _end_time.minute),
            builder: (BuildContext context, Widget? child) {
              /// Theme widget used to apply the theme and primary color to the
              /// date picker.
              return Container(
                /// The themedata created based
                /// on the selected theme and primary color.
                child: child!,
              );
            });

        if (time != null && time != _end_time) {
          setState(() {
            _end_time = time;
            final Duration difference = _end_date.difference(_start_date);
            _end_date = DateTime(_end_date.year, _end_date.month, _end_date.day,
                _end_time.hour, _end_time.minute);
            if (_end_date.isBefore(_start_date)) {
              _start_date = _end_date.subtract(difference);
              _start_time =
                  TimeOfDay(hour: _start_date.hour, minute: _start_date.minute);
            }
          });
        }
      },
      child: Text(
        DateFormat('hh:mm a').format(_end_date),
        style: TextStyle(fontWeight: FontWeight.w500),
        textAlign: TextAlign.left,
      ),
    );

    final Widget end_date_picker = RawMaterialButton(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      onPressed: () async {
        final DateTime? date = await showDatePicker(
            context: context,
            initialDate: _end_date,
            firstDate: DateTime(DATE_PICKER_START_YEAR),
            lastDate: DateTime(DATE_PICKER_END_YEAR),
            builder: (BuildContext context, Widget? child) {
              /// Theme widget used to apply the theme and primary color to the
              /// date picker.
              return Container(
                /// The themedata created based
                /// on the selected theme and primary color.
                child: child!,
              );
            });

        if (date != null && date != _start_date) {
          setState(() {
            final Duration difference = _end_date.difference(_start_date);
            _end_date = DateTime(date.year, date.month, date.day, _end_time.hour,
                _end_time.minute);
            if (_end_date.isBefore(_start_date)) {
              _start_date = _end_date.subtract(difference);
              _start_time =
                  TimeOfDay(hour: _start_date.hour, minute: _start_date.minute);
            }
          });
        }
      },
      child: Text(DateFormat('MMM dd, yyyy').format(_end_date),
          style:
          TextStyle(fontWeight: FontWeight.w500),
          textAlign: TextAlign.left),
    );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
            height: 50,
            child: ListTile(
              trailing: IconButton(
                icon: Icon(Icons.close),
                splashRadius: 20,
                onPressed: () {
                  if (widget.new_appointment != null &&
                      widget.events.appointments!
                          .contains(widget.new_appointment)) {
                    /// To remove the created appointment, when the appointment editor
                    /// closed without saving the appointment.
                    widget.events.appointments!.removeAt(widget
                        .events.appointments!
                        .indexOf(widget.new_appointment));
                    widget.events.notifyListeners(CalendarDataSourceAction.remove,
                        <Appointment>[widget.new_appointment!]);
                  }

                  Navigator.pop(context);
                },
              ),
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            height: 50,
            child: ListTile(
              leading: const Text(''),
              title: TextField(
                autofocus: true,
                controller: TextEditingController(text: _subject),
                onChanged: (String value) {
                  _subject = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400),
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          width: 2.0)),
                  hintText: 'Add title and time',
                ),
              ),
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            height: 50,
            child: ListTile(
              leading: Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.access_time,
                    size: 20,
                  )),
              title: _is_all_day
                  ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    start_date_picker,
                    const Text(' - '),
                    end_date_picker,
                    const Text(''),
                    const Text(''),
                  ])
                  : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    start_date_picker,
                    start_time_picker,
                    const Text(' - '),
                    end_time_picker,
                    end_date_picker,
                  ]),
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            height: 50,
            child: ListTile(
              leading: Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.location_on,
                    size: 20,
                  )),
              title: TextField(
                controller: TextEditingController(text: _location),
                onChanged: (String value) {
                  _location = value;
                },
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  hintText: 'Add location',
                ),
              ),
            )),
        Container(
            margin: const EdgeInsets.only(bottom: 5),
            height: 50,
            child: ListTile(
              leading: Container(
                  width: 30,
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.subject,
                    size: 20,
                  )),
              title: TextField(
                controller: TextEditingController(text: _notes),
                onChanged: (String value) {
                  _notes = value;
                },
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 15,
                ),
                decoration: const InputDecoration(
                  filled: true,
                  contentPadding: EdgeInsets.fromLTRB(5, 10, 10, 10),
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  hintText: 'Add description',
                ),
              ),
            )),
        SizedBox(
          height: 50,
          child: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: RawMaterialButton(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog<Widget>(
                          context: context,
                          builder: (BuildContext context) {
                            final Appointment selected_appointment = Appointment(
                              startTime: _start_date,
                              endTime: _end_date,
                              notes: _notes,
                              isAllDay: _is_all_day,
                              location: _location,
                              subject:
                              _subject == '' ? '(No title)' : _subject,
                            );
                            return WillPopScope(
                              onWillPop: () async {
                                if (widget.new_appointment != null) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.new_appointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[widget.new_appointment!]);
                                }
                                return true;
                              },
                              child: AppointmentEditor(
                                selected_appointment,
                                widget.events,
                                widget.appointment,
                                widget.visible_dates,
                                widget.new_appointment,
                              ),
                            );
                          });
                    },
                    child: Text(
                      'MORE OPTIONS',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: RawMaterialButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    onPressed: () {
                      if (widget.selected_appointment != null ||
                          widget.new_appointment != null) {
                        if (widget.events.appointments!.isNotEmpty &&
                            widget.events.appointments!
                                .contains(widget.selected_appointment)) {
                          widget.events.appointments!.removeAt(widget
                              .events.appointments!
                              .indexOf(widget.selected_appointment));
                          widget.events.notifyListeners(
                              CalendarDataSourceAction.remove,
                              <Appointment>[widget.selected_appointment]);
                        }
                        if (widget.appointment.isNotEmpty &&
                            widget.appointment
                                .contains(widget.new_appointment)) {
                          widget.appointment.removeAt(widget.appointment
                              .indexOf(widget.new_appointment!));
                        }
                      }

                      widget.appointment.add(Appointment(
                        startTime: _start_date,
                        endTime: _end_date,
                        notes: _notes,
                        isAllDay: _is_all_day,
                        location: _location,
                        subject: _subject == '' ? '(No title)' : _subject,
                      ));

                      widget.events.appointments!.add(widget.appointment[0]);

                      widget.events.notifyListeners(
                          CalendarDataSourceAction.add, widget.appointment);

                      Navigator.pop(context);
                    },
                    child: const Text(
                      'SAVE',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          )
        )
      ]
    );
    throw UnimplementedError();
  }
}



class AppointmentEditor extends StatefulWidget {
  /// Holds the information of appointments
  const AppointmentEditor(
    this.selected_appointment,
    this.events,
    this.appointment,
    this.visibleDates,
    [this.newAppointment]
  );

  /// new appointment value
  final Appointment? newAppointment;

  /// List of appointments
  final List<Appointment> appointment;

  /// Selected appointment value
  final Appointment selected_appointment;

  /// Holds the Events values
  final CalendarDataSource events;

  /// The visible dates collection
  final List<DateTime> visibleDates;

  @override
  _AppointmentEditorState createState() => _AppointmentEditorState();
}

class _AppointmentEditorState extends State<AppointmentEditor> {
  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  bool _isAllDay = false;
  String _subject = '';
  String? _notes;
  String? _location;
  bool _isTimeZoneEnabled = false;
  List<Object>? _resourceIds;
  List<CalendarResource> _selectedResources = <CalendarResource>[];
  List<CalendarResource> _unSelectedResources = <CalendarResource>[];

  late String _selectedRecurrenceType, _selectedRecurrenceRange, _ruleType;
  int? _count, _interval, _month, _week, _lastDay;
  late int _dayOfWeek, _weekNumber, _dayOfMonth;
  late double _padding, _margin;
  late DateTime _selectedDate, _firstDate;
  RecurrenceProperties? _recurrenceProperties;
  late RecurrenceType _recurrenceType;
  late RecurrenceRange _recurrenceRange;
  List<WeekDays>? _days;
  IconData? _monthDayRadio, _weekDayRadio, _lastDayRadio;
  Color? _weekIconColor, _monthIconColor, _lastDayIconColor;
  String? _monthName, _weekNumberText, _dayOfWeekText;

  @override
  void initState() {
    _updateAppointmentProperties();
    super.initState();
  }

  @override
  void didUpdateWidget(AppointmentEditor oldWidget) {
    _updateAppointmentProperties();
    super.didUpdateWidget(oldWidget);
  }

  /// Updates the required editor's default field
  void _updateAppointmentProperties() {
    _startDate = widget.selected_appointment.startTime;
    _endDate = widget.selected_appointment.endTime;
    _isAllDay = widget.selected_appointment.isAllDay;
    _subject = widget.selected_appointment.subject == '(No title)'
        ? ''
        : widget.selected_appointment.subject;
    _notes = widget.selected_appointment.notes;
    _location = widget.selected_appointment.location;

    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
    _selectedDate = _startDate.add(const Duration(days: 30));
    _firstDate = _startDate;
    _month = _startDate.month;
    _monthName = _MONTH_NAMES[_month! - 1];
    _dayOfMonth = _startDate.day;
    _weekNumber = _getWeekNumber(_startDate);
    _weekNumberText = _WEEK_POSITIONS[_weekNumber == -1 ? 4 : _weekNumber - 1];
    _dayOfWeek = _startDate.weekday;
    _dayOfWeekText = _WEEKDAY_NAMES[_dayOfWeek - 1];
    if (_days == null) {
      _webInitialWeekdays(_startDate.weekday);
    }
    _recurrenceProperties = widget.selected_appointment.recurrenceRule != null &&
        widget.selected_appointment.recurrenceRule!.isNotEmpty
        ? SfCalendar.parseRRule(
        widget.selected_appointment.recurrenceRule!, _startDate)
        : null;
    _recurrenceProperties == null
        ? _neverRule()
        : _updateWebRecurrenceProperties();
  }

  void _updateWebRecurrenceProperties() {
    _recurrenceType = _recurrenceProperties!.recurrenceType;
    _week = _recurrenceProperties!.week;
    _weekNumber = _recurrenceProperties!.week == 0
        ? _weekNumber
        : _recurrenceProperties!.week;
    _lastDay = _recurrenceProperties!.dayOfMonth;
    if (_lastDay != -1) {
      _dayOfMonth = _recurrenceProperties!.dayOfMonth == 1
          ? _startDate.day
          : _recurrenceProperties!.dayOfMonth;
    }
    switch (_recurrenceType) {
      case RecurrenceType.daily:
        _dailyRule();
        break;
      case RecurrenceType.weekly:
        _days = _recurrenceProperties!.weekDays;
        _weeklyRule();
        break;
      case RecurrenceType.monthly:
        _monthlyRule();
        break;
      case RecurrenceType.yearly:
        _month = _recurrenceProperties!.month;
        _yearlyRule();
        break;
    }
    _recurrenceRange = _recurrenceProperties!.recurrenceRange;
    switch (_recurrenceRange) {
      case RecurrenceRange.noEndDate:
        _noEndDateRange();
        break;
      case RecurrenceRange.endDate:
        final Appointment? parentAppointment =
        widget.events.getPatternAppointment(widget.selected_appointment, '')
        as Appointment?;
        _firstDate = parentAppointment!.startTime;
        _endDateRange();
        break;
      case RecurrenceRange.count:
        _countRange();
        break;
    }
  }

  void _neverRule() {
    setState(() {
      _recurrenceProperties = null;
      _selectedRecurrenceType = 'Never';
      _selectedRecurrenceRange = 'Never';
      _padding = 0;
      _margin = 0;
      _ruleType = '';
    });
  }

  void _dailyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.daily;
      _ruleType = 'Day(s)';
      _selectedRecurrenceType = 'Daily';
      _padding = 6;
      _margin = 0;
    });
  }

  void _weeklyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.weekly;
      _selectedRecurrenceType = 'Weekly';
      _ruleType = 'Week(s)';
      _recurrenceProperties!.weekDays = _days!;
      _padding = 0;
      _margin = 6;
    });
  }

  void _monthlyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _monthDayIcon();
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
        if (_lastDay != null && _lastDay == -1) {
          _monthLastDayIcon();
        } else if (_week != null && _week != 0) {
          _monthWeekIcon();
        } else {
          _monthDayIcon();
        }
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.monthly;
      _selectedRecurrenceType = 'Monthly';
      _ruleType = 'Month(s)';
      _padding = 0;
      _margin = 6;
    });
  }

  void _yearlyRule() {
    setState(() {
      if (_recurrenceProperties == null) {
        _recurrenceProperties = RecurrenceProperties(startDate: _startDate);
        _monthDayIcon();
        _interval = 1;
      } else {
        _interval = _recurrenceProperties!.interval;
        _monthName = _MONTH_NAMES[_month! - 1];
        if (_lastDay != null && _lastDay == -1) {
          _monthLastDayIcon();
        } else if (_week != null && _week != 0) {
          _monthWeekIcon();
        } else {
          _monthDayIcon();
        }
      }
      _recurrenceProperties!.recurrenceType = RecurrenceType.yearly;
      _selectedRecurrenceType = 'Yearly';
      _ruleType = 'Year(s)';
      _recurrenceProperties!.month = _month!;
      _padding = 0;
      _margin = 6;
    });
  }

  void _noEndDateRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.noEndDate;
    _selectedRecurrenceRange = 'Never';
  }

  void _endDateRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.endDate;
    _selectedDate = _recurrenceProperties!.endDate ??
        _startDate.add(const Duration(days: 30));
    _selectedRecurrenceRange = 'Until';
    _recurrenceProperties!.endDate = _selectedDate;
  }

  void _countRange() {
    _recurrenceProperties!.recurrenceRange = RecurrenceRange.count;
    _count = _recurrenceProperties!.recurrenceCount == 0
        ? 10
        : _recurrenceProperties!.recurrenceCount;
    _selectedRecurrenceRange = 'Count';
    _recurrenceProperties!.recurrenceCount = _count!;
  }

  void _addInterval() {
    setState(() {
      if (_interval! >= 999) {
        _interval = 999;
      } else {
        _interval = _interval! + 1;
      }
      _recurrenceProperties!.interval = _interval!;
    });
  }

  int _getWeekNumber(DateTime startDate) {
    int weekOfMonth;
    weekOfMonth = (startDate.day / 7).ceil();
    if (weekOfMonth == 5) {
      return -1;
    }
    return weekOfMonth;
  }

  void _removeInterval() {
    setState(() {
      if (_interval! > 1) {
        _interval = _interval! - 1;
      }
      _recurrenceProperties!.interval = _interval!;
    });
  }

  void _monthWeekIcon() {
    setState(() {
      _weekNumberText = _WEEK_POSITIONS[_weekNumber == -1 ? 4 : _weekNumber - 1];
      _dayOfWeekText = _WEEKDAY_NAMES[_dayOfWeek - 1];
      _recurrenceProperties!.week = _weekNumber;
      _recurrenceProperties!.dayOfWeek = _dayOfWeek;
      _lastDayRadio = Icons.radio_button_unchecked;
      _monthDayRadio = Icons.radio_button_unchecked;
      _weekDayRadio = Icons.radio_button_checked;
    });
  }

  void _monthDayIcon() {
    setState(() {
      _recurrenceProperties!.dayOfWeek = 0;
      _recurrenceProperties!.week = 0;
      _recurrenceProperties!.dayOfMonth = _dayOfMonth;
      _monthDayRadio = Icons.radio_button_checked;
      _weekDayRadio = Icons.radio_button_unchecked;
      _lastDayRadio = Icons.radio_button_unchecked;
    });
  }

  void _monthLastDayIcon() {
    setState(() {
      _recurrenceProperties!.dayOfWeek = 0;
      _recurrenceProperties!.week = 0;
      _recurrenceProperties!.dayOfMonth = -1;
      _lastDayRadio = Icons.radio_button_checked;
      _monthDayRadio = Icons.radio_button_unchecked;
      _weekDayRadio = Icons.radio_button_unchecked;
    });
  }

  void _addDay() {
    setState(() {
      if (_dayOfMonth < 31) {
        _dayOfMonth = _dayOfMonth + 1;
      }
      _monthDayIcon();
    });
  }

  void _removeDay() {
    setState(() {
      if (_dayOfMonth > 1) {
        _dayOfMonth = _dayOfMonth - 1;
      }
      _monthDayIcon();
    });
  }

  void _addCount() {
    setState(() {
      if (_count! >= 999) {
        _count = 999;
      } else {
        _count = _count! + 1;
      }
      _recurrenceProperties!.recurrenceCount = _count!;
    });
  }

  void _removeCount() {
    setState(() {
      if (_count! > 1) {
        _count = _count! - 1;
      }
      _recurrenceProperties!.recurrenceCount = _count!;
    });
  }

  void _webSelectWeekDays(WeekDays day) {
    switch (day) {
      case WeekDays.sunday:
        if (_days!.contains(WeekDays.sunday) && _days!.length > 1) {
          _days!.remove(WeekDays.sunday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.sunday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.monday:
        if (_days!.contains(WeekDays.monday) && _days!.length > 1) {
          _days!.remove(WeekDays.monday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.monday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.tuesday:
        if (_days!.contains(WeekDays.tuesday) && _days!.length > 1) {
          _days!.remove(WeekDays.tuesday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.tuesday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.wednesday:
        if (_days!.contains(WeekDays.wednesday) && _days!.length > 1) {
          _days!.remove(WeekDays.wednesday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.wednesday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.thursday:
        if (_days!.contains(WeekDays.thursday) && _days!.length > 1) {
          _days!.remove(WeekDays.thursday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.thursday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.friday:
        if (_days!.contains(WeekDays.friday) && _days!.length > 1) {
          _days!.remove(WeekDays.friday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.friday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
      case WeekDays.saturday:
        if (_days!.contains(WeekDays.saturday) && _days!.length > 1) {
          _days!.remove(WeekDays.saturday);
          _recurrenceProperties!.weekDays = _days!;
        } else {
          _days!.add(WeekDays.saturday);
          _recurrenceProperties!.weekDays = _days!;
        }
        break;
    }
  }

  void _webInitialWeekdays(int day) {
    switch (_startDate.weekday) {
      case DateTime.monday:
        _days = <WeekDays>[WeekDays.monday];
        break;
      case DateTime.tuesday:
        _days = <WeekDays>[WeekDays.tuesday];
        break;
      case DateTime.wednesday:
        _days = <WeekDays>[WeekDays.wednesday];
        break;
      case DateTime.thursday:
        _days = <WeekDays>[WeekDays.thursday];
        break;
      case DateTime.friday:
        _days = <WeekDays>[WeekDays.friday];
        break;
      case DateTime.saturday:
        _days = <WeekDays>[WeekDays.saturday];
        break;
      case DateTime.sunday:
        _days = <WeekDays>[WeekDays.sunday];
        break;
    }
  }

  /// Return the resource editor to edit the resource collection for an
  /// appointment
  Widget _getResourceEditor(TextStyle hintTextStyle) {
    if (_selectedResources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 25, bottom: 5),
        child: Text(
          'Add people',
          style: hintTextStyle,
        ),
      );
    }

    final List<Widget> chipWidgets = <Widget>[];
    for (int i = 0; i < _selectedResources.length; i++) {
      final CalendarResource selectedResource = _selectedResources[i];
      chipWidgets.add(Chip(
        padding: EdgeInsets.zero,
        avatar: CircleAvatar(
          backgroundImage: selectedResource.image,
          child: selectedResource.image == null
              ? Text(selectedResource.displayName[0])
              : null,
        ),
        label: Text(selectedResource.displayName),
        onDeleted: () {
          _selectedResources.removeAt(i);
          _resourceIds!.removeAt(i);
          setState(() {});
        },
      ));
    }

    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: chipWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
        height: widget.events.resources != null &&
            widget.events.resources!.isNotEmpty
            ? widget.selected_appointment.recurrenceId == null
            ? _isTimeZoneEnabled || _selectedRecurrenceType != 'Never'
            ? 640
            : 580
            : _isTimeZoneEnabled || _selectedRecurrenceType != 'Never'
            ? 560
            : 480
            : widget.selected_appointment.recurrenceId == null
            ? _isTimeZoneEnabled || _selectedRecurrenceType != 'Never'
            ? 560
            : 500
            : _isTimeZoneEnabled || _selectedRecurrenceType != 'Never'
            ? 480
            : 420,
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        title: Text(
                          widget.selected_appointment != null &&
                              widget.newAppointment == null
                              ? 'Edit appointment'
                              : 'New appointment',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            if (widget.newAppointment != null &&
                                widget.events.appointments!
                                    .contains(widget.newAppointment)) {
                              /// To remove the created appointment when the pop-up closed
                              /// without saving the appointment.
                              widget.events.appointments!.removeAt(widget
                                  .events.appointments!
                                  .indexOf(widget.newAppointment));
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.remove,
                                  <Appointment>[widget.newAppointment!]);
                            }

                            Navigator.pop(context);
                          },
                        ),
                      )),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 2, bottom: 2),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Title',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.start,
                                    ),
                                    TextField(
                                      autofocus: true,
                                      controller:
                                      TextEditingController(text: _subject),
                                      onChanged: (String value) {
                                        _subject = value;
                                      },
                                      keyboardType: TextInputType.multiline,
                                      maxLines: null,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: const UnderlineInputBorder(),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2.0)),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 2, bottom: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.start,
                                  ),
                                  TextField(
                                    controller:
                                    TextEditingController(text: _location),
                                    onChanged: (String value) {
                                      _location = value;
                                    },
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: const UnderlineInputBorder(),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2.0)
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 5, bottom: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Start',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300),
                                        textAlign: TextAlign.start,
                                      ),
                                      TextField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: (_isAllDay
                                                ? DateFormat('MM/dd/yyyy')
                                                : DateFormat('MM/dd/yy h:mm a'))
                                                .format(_startDate)),
                                        onChanged: (String value) {
                                          _startDate = DateTime.parse(value);
                                          _startTime = TimeOfDay(
                                              hour: _startDate.hour,
                                              minute: _startDate.minute);
                                        },
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffix: SizedBox(
                                            height: 20,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                              children: <Widget>[
                                                ButtonTheme(
                                                    minWidth: 50.0,
                                                    child: MaterialButton(
                                                      elevation: 0,
                                                      focusElevation: 0,
                                                      highlightElevation: 0,
                                                      disabledElevation: 0,
                                                      hoverElevation: 0,
                                                      onPressed: () async {
                                                        final DateTime? date =
                                                        await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                            _startDate,
                                                            firstDate:
                                                            DateTime(1900),
                                                            lastDate:
                                                            DateTime(2100),
                                                            builder:
                                                                (BuildContext
                                                            context,
                                                                Widget?
                                                                child) {
                                                              return Container(
                                                                child: child!,
                                                              );
                                                            });

                                                        if (date != null &&
                                                            date != _startDate) {
                                                          setState(() {
                                                            final Duration
                                                            difference =
                                                            _endDate.difference(
                                                                _startDate);
                                                            _startDate = DateTime(
                                                                date.year,
                                                                date.month,
                                                                date.day,
                                                                _startTime.hour,
                                                                _startTime.minute);
                                                            _endDate = _startDate
                                                                .add(difference);
                                                            _endTime = TimeOfDay(
                                                                hour: _endDate.hour,
                                                                minute: _endDate
                                                                    .minute);
                                                          });
                                                        }
                                                      },
                                                      shape: const CircleBorder(),
                                                      padding: EdgeInsets.zero,
                                                      child: Icon(
                                                        Icons.date_range,
                                                        size: 20,
                                                      ),
                                                    )),
                                                if (_isAllDay)
                                                  const SizedBox(
                                                    width: 0,
                                                    height: 0,
                                                  )
                                                else
                                                  ButtonTheme(
                                                      minWidth: 50.0,
                                                      child: MaterialButton(
                                                        elevation: 0,
                                                        focusElevation: 0,
                                                        highlightElevation: 0,
                                                        disabledElevation: 0,
                                                        hoverElevation: 0,
                                                        shape: const CircleBorder(),
                                                        padding: EdgeInsets.zero,
                                                        onPressed: () async {
                                                          final TimeOfDay? time =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime: TimeOfDay(
                                                                  hour:
                                                                  _startTime
                                                                      .hour,
                                                                  minute:
                                                                  _startTime
                                                                      .minute),
                                                              builder: (BuildContext
                                                              context,
                                                                  Widget?
                                                                  child) {
                                                                return Container(
                                                                  child: child!,
                                                                );
                                                              });

                                                          if (time != null &&
                                                              time != _startTime) {
                                                            setState(() {
                                                              _startTime = time;
                                                              final Duration
                                                              difference =
                                                              _endDate.difference(
                                                                  _startDate);
                                                              _startDate = DateTime(
                                                                  _startDate.year,
                                                                  _startDate.month,
                                                                  _startDate.day,
                                                                  _startTime.hour,
                                                                  _startTime
                                                                      .minute);
                                                              _endDate = _startDate
                                                                  .add(difference);
                                                              _endTime = TimeOfDay(
                                                                  hour:
                                                                  _endDate.hour,
                                                                  minute: _endDate
                                                                      .minute);
                                                            });
                                                          }
                                                        },
                                                        child: Icon(
                                                          Icons.access_time,
                                                          size: 20,
                                                        ),
                                                      ))
                                              ],
                                            ),
                                          ),
                                          border: const UnderlineInputBorder(),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 2.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 5, right: 5, top: 5, bottom: 2),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text('End',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w300),
                                          textAlign: TextAlign.start),
                                      TextField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                            text: (_isAllDay
                                                ? DateFormat('MM/dd/yyyy')
                                                : DateFormat('MM/dd/yy h:mm a'))
                                                .format(_endDate)),
                                        onChanged: (String value) {
                                          _endDate = DateTime.parse(value);
                                          _endTime = TimeOfDay(
                                              hour: _endDate.hour,
                                              minute: _endDate.minute);
                                        },
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffix: SizedBox(
                                            height: 20,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                ButtonTheme(
                                                    minWidth: 50.0,
                                                    child: MaterialButton(
                                                      elevation: 0,
                                                      focusElevation: 0,
                                                      highlightElevation: 0,
                                                      disabledElevation: 0,
                                                      hoverElevation: 0,
                                                      shape: const CircleBorder(),
                                                      padding: EdgeInsets.zero,
                                                      onPressed: () async {
                                                        final DateTime? date =
                                                        await showDatePicker(
                                                            context: context,
                                                            initialDate:
                                                            _endDate,
                                                            firstDate:
                                                            DateTime(1900),
                                                            lastDate:
                                                            DateTime(2100),
                                                            builder:
                                                                (BuildContext
                                                            context,
                                                                Widget?
                                                                child) {
                                                              return Container(
                                                                child: child!,
                                                              );
                                                            });

                                                        if (date != null &&
                                                            date != _endDate) {
                                                          setState(() {
                                                            final Duration
                                                            difference =
                                                            _endDate.difference(
                                                                _startDate);
                                                            _endDate = DateTime(
                                                                date.year,
                                                                date.month,
                                                                date.day,
                                                                _endTime.hour,
                                                                _endTime.minute);
                                                            if (_endDate.isBefore(
                                                                _startDate)) {
                                                              _startDate =
                                                                  _endDate.subtract(
                                                                      difference);
                                                              _startTime = TimeOfDay(
                                                                  hour: _startDate
                                                                      .hour,
                                                                  minute: _startDate
                                                                      .minute);
                                                            }
                                                          });
                                                        }
                                                      },
                                                      child: Icon(
                                                        Icons.date_range,
                                                        size: 20,
                                                      ),
                                                    )),
                                                if (_isAllDay)
                                                  const SizedBox(
                                                    width: 0,
                                                    height: 0,
                                                  )
                                                else
                                                  ButtonTheme(
                                                      minWidth: 50.0,
                                                      child: MaterialButton(
                                                        elevation: 0,
                                                        focusElevation: 0,
                                                        highlightElevation: 0,
                                                        disabledElevation: 0,
                                                        hoverElevation: 0,
                                                        shape: const CircleBorder(),
                                                        padding: EdgeInsets.zero,
                                                        onPressed: () async {
                                                          final TimeOfDay? time =
                                                          await showTimePicker(
                                                              context: context,
                                                              initialTime: TimeOfDay(
                                                                  hour: _endTime
                                                                      .hour,
                                                                  minute: _endTime
                                                                      .minute),
                                                              builder: (BuildContext
                                                              context,
                                                                  Widget?
                                                                  child) {
                                                                return Container(
                                                                  child: child!,
                                                                );
                                                              });

                                                          if (time != null &&
                                                              time != _endTime) {
                                                            setState(() {
                                                              _endTime = time;
                                                              final Duration
                                                              difference =
                                                              _endDate.difference(
                                                                  _startDate);
                                                              _endDate = DateTime(
                                                                  _endDate.year,
                                                                  _endDate.month,
                                                                  _endDate.day,
                                                                  _endTime.hour,
                                                                  _endTime.minute);
                                                              if (_endDate.isBefore(
                                                                  _startDate)) {
                                                                _startDate = _endDate
                                                                    .subtract(
                                                                    difference);
                                                                _startTime = TimeOfDay(
                                                                    hour: _startDate
                                                                        .hour,
                                                                    minute:
                                                                    _startDate
                                                                        .minute);
                                                              }
                                                            });
                                                          }
                                                        },
                                                        child: Icon(
                                                          Icons.access_time,
                                                                                                                    size: 20,
                                                        ),
                                                      ))
                                              ],
                                            ),
                                          ),
                                          border: const UnderlineInputBorder(),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 2.0)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ))),
                  Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      child: ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Checkbox(
                              value: _isAllDay,
                              onChanged: (bool? value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() {
                                  _isAllDay = value;
                                  if (_isAllDay) {
                                    _isTimeZoneEnabled = false;
                                  }
                                });
                              },
                            ),
                            Text(
                              'All day',
                              style: TextStyle(
                                  fontSize: 12,
                                                                    fontWeight: FontWeight.w300),
                            ),
                            Container(width: 10)
                          ],
                        ),
                      )),
                  Visibility(
                    visible: widget.selected_appointment.recurrenceId == null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 5, top: 2, bottom: 2),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'Repeat',
                                        style: TextStyle(
                                            fontSize: 12,
                                                                                        fontWeight: FontWeight.w300),
                                        textAlign: TextAlign.start,
                                      ),
                                      TextField(
                                        mouseCursor:
                                        MaterialStateMouseCursor.clickable,
                                        controller: TextEditingController(
                                            text: _selectedRecurrenceType),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          suffix: SizedBox(
                                              height: 28,
                                              child: DropdownButton<String>(
                                                  focusColor:
                                                  Colors.transparent,
                                                  isExpanded: true,
                                                  underline: Container(),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                      FontWeight.w400),
                                                  value:
                                                  _selectedRecurrenceType,
                                                  items: _REPEAT_OPTIONS
                                                      .map((String item) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: item,
                                                      child: Text(item),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? value) {
                                                    if (value == 'Weekly') {
                                                      _weeklyRule();
                                                    } else if (value ==
                                                        'Monthly') {
                                                      _monthlyRule();
                                                    } else if (value ==
                                                        'Yearly') {
                                                      _yearlyRule();
                                                    } else if (value ==
                                                        'Daily') {
                                                      _dailyRule();
                                                    } else if (value ==
                                                        'Never') {
                                                      _neverRule();
                                                    }
                                                  })),
                                          border: const UnderlineInputBorder(),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 2.0)),
                                        ),
                                      )
                                    ]),
                              )),
                          Expanded(
                            flex: 3,
                            child: Visibility(
                                visible: _selectedRecurrenceType != 'Never',
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 2),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Repeat every',
                                          style: TextStyle(
                                              fontSize: 12,
                                                                                            fontWeight: FontWeight.w300),
                                          textAlign: TextAlign.start,
                                        ),
                                        TextField(
                                          textAlignVertical:
                                          TextAlignVertical.bottom,
                                          controller: TextEditingController
                                              .fromValue(TextEditingValue(
                                              text: _interval.toString(),
                                              selection:
                                              TextSelection.collapsed(
                                                  offset: _interval
                                                      .toString()
                                                      .length))),
                                          onChanged: (String value) {
                                            if (value != null &&
                                                value.isNotEmpty) {
                                              _interval = int.parse(value);
                                              if (_interval == 0) {
                                                _interval = 1;
                                              } else if (_interval! >= 999) {
                                                _interval = 999;
                                              }
                                            } else if (value.isEmpty ||
                                                value == null) {
                                              _interval = 1;
                                            }
                                            _recurrenceProperties!.interval =
                                            _interval!;
                                          },
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          maxLines: null,
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            // isCollapsed: true,
                                            contentPadding:
                                            const EdgeInsets.only(
                                                top: 15, bottom: 5),
                                            suffixIconConstraints:
                                            const BoxConstraints(
                                              maxHeight: 35,
                                            ),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Material(
                                                    child: IconButton(
                                                        icon: Icon(
                                                            Icons
                                                                .arrow_drop_down_outlined
                                                        ),
                                                        padding:
                                                        const EdgeInsets
                                                            .only(
                                                          bottom: 3,
                                                        ),
                                                        onPressed:
                                                        _removeInterval),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 5),
                                                    child: Material(
                                                        child: IconButton(
                                                            icon: Icon(
                                                              Icons
                                                                  .arrow_drop_up_outlined,
                                                            ),
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 3),
                                                            onPressed:
                                                            _addInterval))),
                                              ],
                                            ),
                                            border:
                                            const UnderlineInputBorder(),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    width: 2.0)),
                                          ),
                                        )
                                      ],
                                    ))),
                          ),
                          Expanded(
                              child: Container(
                                  padding: const EdgeInsets.only(top: 15),
                                  child: Text('  ' + _ruleType,
                                      style: TextStyle(
                                          fontSize: 13,
                                                                                    fontWeight: FontWeight.w400)))),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                      visible: _selectedRecurrenceType != 'Never',
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: _selectedRecurrenceType == 'Weekly' ? 4 : 0,
                              child: Visibility(
                                  visible: _selectedRecurrenceType == 'Weekly',
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 6, right: 5, top: 2, bottom: 2),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Repeat On',
                                          style: TextStyle(
                                              fontSize: 12,
                                                                                            fontWeight: FontWeight.w300),
                                          textAlign: TextAlign.start,
                                        ),
                                        Padding(
                                            padding:
                                            const EdgeInsets.only(top: 10),
                                            child: Wrap(
                                              spacing: 3.0,
                                              runSpacing: 10.0,
                                              crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                              children: <Widget>[
                                                Tooltip(
                                                  message: 'Sunday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.sunday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      disabledForegroundColor:
                                                      Colors.black26,
                                                      disabledBackgroundColor:
                                                      Colors.black26,
                                                      side: BorderSide(),
                                                      shape:
                                                      const CircleBorder(),
                                                      padding:
                                                      const EdgeInsets.all(
                                                          15),
                                                    ),
                                                    child: const Text('S'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Monday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.monday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      disabledForegroundColor:
                                                      Colors.black26,
                                                      disabledBackgroundColor:
                                                      Colors.black26,
                                                      side: BorderSide(),
                                                      shape:
                                                      const CircleBorder(),
                                                      padding:
                                                      const EdgeInsets.all(
                                                          15),
                                                    ),
                                                    child: const Text('M'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Tuesday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.tuesday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      disabledForegroundColor:
                                                      Colors.black26,
                                                      disabledBackgroundColor:
                                                      Colors.black26,
                                                      side: BorderSide(),
                                                      shape:
                                                      const CircleBorder(),
                                                      padding:
                                                      const EdgeInsets.all(
                                                          15),
                                                    ),
                                                    child: const Text('T'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Wednesday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.wednesday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      disabledForegroundColor:
                                                      Colors.black26,
                                                      disabledBackgroundColor:
                                                      Colors.black26,
                                                      side: BorderSide(),
                                                      shape:
                                                      const CircleBorder(),
                                                      padding:
                                                      const EdgeInsets.all(
                                                          15),
                                                    ),
                                                    child: const Text('W'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Thursday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.thursday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      disabledForegroundColor:
                                                      Colors.black26,
                                                      disabledBackgroundColor:
                                                      Colors.black26,
                                                      side: BorderSide(),
                                                      shape:
                                                      const CircleBorder(),
                                                      padding:
                                                      const EdgeInsets.all(
                                                          15),
                                                    ),
                                                    child: const Text('T'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Friday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.friday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      disabledForegroundColor:
                                                      Colors.black26,
                                                      disabledBackgroundColor:
                                                      Colors.black26,
                                                      side: BorderSide(),
                                                      shape:
                                                      const CircleBorder(),
                                                      padding:
                                                      const EdgeInsets.all(
                                                          15),
                                                    ),
                                                    child: const Text('F'),
                                                  ),
                                                ),
                                                Tooltip(
                                                  message: 'Saturday',
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _webSelectWeekDays(
                                                            WeekDays.saturday);
                                                      });
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      disabledForegroundColor:
                                                      Colors.black26,
                                                      disabledBackgroundColor:
                                                      Colors.black26,
                                                      side: BorderSide(),
                                                      shape:
                                                      const CircleBorder(),
                                                      padding:
                                                      const EdgeInsets.all(
                                                          15),
                                                    ),
                                                    child: const Text('S'),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  )),
                            ),
                            Expanded(
                              flex: _selectedRecurrenceType == 'Yearly' ? 4 : 0,
                              child: Visibility(
                                visible: _selectedRecurrenceType == 'Yearly',
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 2, bottom: 2),
                                    child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Repeat On',
                                            style: TextStyle(
                                                fontSize: 12,
                                                                                                fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.start,
                                          ),
                                          TextField(
                                            mouseCursor:
                                            MaterialStateMouseCursor
                                                .clickable,
                                            controller: TextEditingController(
                                                text: _monthName),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              suffix: SizedBox(
                                                height: 27,
                                                child: DropdownButton<String>(
                                                    focusColor:
                                                    Colors.transparent,
                                                    isExpanded: true,
                                                    underline: Container(),
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                                                                                fontWeight:
                                                        FontWeight.w400),
                                                    value: _monthName,
                                                    items: _MONTH_NAMES
                                                        .map((String item) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: item,
                                                        child: Text(item),
                                                      );
                                                    }).toList(),
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        if (value ==
                                                            'January') {
                                                          _monthName =
                                                          'January';
                                                          _month = 1;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'February') {
                                                          _monthName =
                                                          'February';
                                                          _month = 2;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'March') {
                                                          _monthName = 'March';
                                                          _month = 3;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'April') {
                                                          _monthName = 'April';
                                                          _month = 4;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'May') {
                                                          _monthName = 'May';
                                                          _month = 5;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'June') {
                                                          _monthName = 'June';
                                                          _month = 6;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'July') {
                                                          _monthName = 'July';
                                                          _month = 7;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'August') {
                                                          _monthName = 'August';
                                                          _month = 8;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'September') {
                                                          _monthName =
                                                          'September';
                                                          _month = 9;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'October') {
                                                          _monthName =
                                                          'October';
                                                          _month = 10;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'November') {
                                                          _monthName =
                                                          'November';
                                                          _month = 11;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        } else if (value ==
                                                            'December') {
                                                          _monthName =
                                                          'December';
                                                          _month = 12;
                                                          _recurrenceProperties!
                                                              .month = _month!;
                                                        }
                                                      });
                                                    }),
                                              ),
                                              border:
                                              const UnderlineInputBorder(),
                                              focusedBorder:
                                              UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 2.0)),
                                            ),
                                          ),
                                        ])),
                              ),
                            ),
                            Expanded(
                              flex:
                              _selectedRecurrenceType == 'Monthly' ? 4 : 0,
                              child: Visibility(
                                visible: _selectedRecurrenceType == 'Monthly',
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 5, top: 2, bottom: 2),
                                    child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Repeat On',
                                            style: TextStyle(
                                                fontSize: 12,
                                                                                                fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.start,
                                          ),
                                          Row(children: <Widget>[
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10),
                                                child: IconButton(
                                                  onPressed: () {
                                                    _monthDayIcon();
                                                  },
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 2),
                                                  alignment:
                                                  Alignment.centerLeft,
                                                  icon: Icon(_monthDayRadio),
                                                  color: _monthIconColor,
                                                  iconSize: 20,
                                                )),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  right: 10, top: 10),
                                              child: Text(
                                                'Day',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                                                                        fontWeight:
                                                    FontWeight.w400),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                  padding:
                                                  const EdgeInsets.only(
                                                      left: 5, bottom: 5),
                                                  child: TextField(
                                                    controller: TextEditingController
                                                        .fromValue(TextEditingValue(
                                                        text: _dayOfMonth
                                                            .toString(),
                                                        selection: TextSelection
                                                            .collapsed(
                                                            offset: _dayOfMonth
                                                                .toString()
                                                                .length))),
                                                    onChanged: (String value) {
                                                      if (value != null &&
                                                          value.isNotEmpty) {
                                                        _dayOfMonth =
                                                            int.parse(value);
                                                        if (_dayOfMonth <= 1) {
                                                          _dayOfMonth = 1;
                                                        } else if (_dayOfMonth >=
                                                            31) {
                                                          _dayOfMonth = 31;
                                                        }
                                                      } else if (value
                                                          .isEmpty) {
                                                        _dayOfMonth =
                                                            _startDate.day;
                                                      }
                                                      _recurrenceProperties!
                                                          .dayOfWeek = 0;
                                                      _recurrenceProperties!
                                                          .week = 0;
                                                      _recurrenceProperties!
                                                          .dayOfMonth =
                                                          _dayOfMonth;
                                                      _monthDayRadio = Icons
                                                          .radio_button_checked;
                                                      _weekDayRadio = Icons
                                                          .radio_button_unchecked;
                                                    },
                                                    keyboardType:
                                                    TextInputType.number,
                                                    inputFormatters: <
                                                        TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                                                                                fontWeight:
                                                        FontWeight.w400),
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      suffix: SizedBox(
                                                        height: 25,
                                                        child: Row(
                                                          mainAxisSize:
                                                          MainAxisSize.min,
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                          children: <Widget>[
                                                            Material(
                                                              child: IconButton(
                                                                padding:
                                                                EdgeInsets
                                                                    .zero,
                                                                icon: Icon(
                                                                    Icons
                                                                        .arrow_drop_down_outlined),
                                                                onPressed: () {
                                                                  _removeDay();
                                                                },
                                                              ),
                                                            ),
                                                            Material(
                                                              child: IconButton(
                                                                padding:
                                                                EdgeInsets
                                                                    .zero,
                                                                icon: Icon(
                                                                  Icons
                                                                      .arrow_drop_up_outlined
                                                                ),
                                                                onPressed: () {
                                                                  _addDay();
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      border:
                                                      const UnderlineInputBorder(),
                                                      focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              width: 2.0)),
                                                    ),
                                                  )),
                                            ),
                                          ]),
                                        ])),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Visibility(
                                  visible: _selectedRecurrenceType != 'Never',
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: _padding, top: 2, bottom: 2),
                                    margin: EdgeInsets.only(left: _margin),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text('End',
                                            style: TextStyle(
                                                fontSize: 12,
                                                                                                fontWeight: FontWeight.w300),
                                            textAlign: TextAlign.start),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: _selectedRecurrenceType ==
                                                    'Monthly'
                                                    ? 9
                                                    : 0),
                                            child: Row(
                                                crossAxisAlignment:
                                                _selectedRecurrenceType ==
                                                    'Monthly'
                                                    ? CrossAxisAlignment
                                                    .center
                                                    : CrossAxisAlignment
                                                    .start,
                                                mainAxisSize:
                                                _selectedRecurrenceType ==
                                                    'Monthly'
                                                    ? MainAxisSize.max
                                                    : MainAxisSize.min,
                                                children: <Widget>[
                                                  Expanded(
                                                      flex: 3,
                                                      child: Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                              bottom: 6),
                                                          child: TextField(
                                                            mouseCursor:
                                                            MaterialStateMouseCursor
                                                                .clickable,
                                                            controller:
                                                            TextEditingController(
                                                                text:
                                                                _selectedRecurrenceRange),
                                                            decoration:
                                                            InputDecoration(
                                                              isDense: true,
                                                              suffix: SizedBox(
                                                                height: 27,
                                                                child: DropdownButton<
                                                                    String>(
                                                                    focusColor:
                                                                    Colors
                                                                        .transparent,
                                                                    isExpanded:
                                                                    true,
                                                                    underline:
                                                                    Container(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        13,
                                                                        fontWeight: FontWeight
                                                                            .w400),
                                                                    value:
                                                                    _selectedRecurrenceRange,
                                                                    items: _REPEAT_UNTIL_OPTIONS
                                                                        .map((String
                                                                    item) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                        item,
                                                                        child: Text(
                                                                            item),
                                                                      );
                                                                    }).toList(),
                                                                    onChanged:
                                                                        (String?
                                                                    value) {
                                                                      setState(
                                                                              () {
                                                                            if (value ==
                                                                                'Never') {
                                                                              _noEndDateRange();
                                                                            } else if (value ==
                                                                                'Count') {
                                                                              _countRange();
                                                                            } else if (value ==
                                                                                'Until') {
                                                                              _endDateRange();
                                                                            }
                                                                          });
                                                                    }),
                                                              ),
                                                              border:
                                                              const UnderlineInputBorder(),
                                                              focusedBorder: UnderlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      width:
                                                                      2.0)),
                                                            ),
                                                          ))),
                                                  Expanded(
                                                      flex:
                                                      _selectedRecurrenceRange ==
                                                          'Count'
                                                          ? 3
                                                          : 0,
                                                      child: Visibility(
                                                        visible:
                                                        _selectedRecurrenceRange ==
                                                            'Count',
                                                        child: Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 9),
                                                            child: TextField(
                                                              textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                              controller: TextEditingController.fromValue(TextEditingValue(
                                                                  text: _count
                                                                      .toString(),
                                                                  selection: TextSelection.collapsed(
                                                                      offset: _count
                                                                          .toString()
                                                                          .length))),
                                                              onChanged: (String
                                                              value) async {
                                                                if (value !=
                                                                    null &&
                                                                    value
                                                                        .isNotEmpty) {
                                                                  _count =
                                                                      int.parse(
                                                                          value);
                                                                  if (_count ==
                                                                      0) {
                                                                    _count = 1;
                                                                  } else if (_count! >=
                                                                      999) {
                                                                    _count =
                                                                    999;
                                                                  }
                                                                  _recurrenceProperties!
                                                                      .recurrenceRange =
                                                                      RecurrenceRange
                                                                          .count;
                                                                  _selectedRecurrenceRange =
                                                                  'Count';
                                                                  _recurrenceProperties!
                                                                      .recurrenceCount =
                                                                  _count!;
                                                                } else if (value
                                                                    .isEmpty ||
                                                                    value ==
                                                                        null) {
                                                                  _noEndDateRange();
                                                                }
                                                              },
                                                              keyboardType:
                                                              TextInputType
                                                                  .number,
                                                              inputFormatters: <
                                                                  TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly
                                                              ],
                                                              maxLines: null,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                              decoration:
                                                              InputDecoration(
                                                                isDense: true,
                                                                contentPadding:
                                                                EdgeInsets.only(
                                                                    top: _selectedRecurrenceType ==
                                                                        'Monthly'
                                                                        ? 13
                                                                        : 18,
                                                                    bottom:
                                                                    10),
                                                                suffixIconConstraints:
                                                                const BoxConstraints(
                                                                    maxHeight:
                                                                    30),
                                                                suffixIcon: Row(
                                                                  mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                                  children: <
                                                                      Widget>[
                                                                    IconButton(
                                                                        icon:
                                                                        Icon(
                                                                          Icons
                                                                              .arrow_drop_down
                                                                        ),
                                                                        padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                        onPressed:
                                                                        _removeCount),
                                                                    IconButton(
                                                                        padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                        icon: Icon(
                                                                            Icons
                                                                                .arrow_drop_up),
                                                                        onPressed:
                                                                        _addCount),
                                                                  ],
                                                                ),
                                                                border:
                                                                const UnderlineInputBorder(),
                                                                focusedBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                        2.0)),
                                                              ),
                                                            )),
                                                      )),
                                                  Expanded(
                                                      flex:
                                                      _selectedRecurrenceRange ==
                                                          'Until'
                                                          ? 3
                                                          : 0,
                                                      child: Visibility(
                                                          visible:
                                                          _selectedRecurrenceRange ==
                                                              'Until',
                                                          child: Container(
                                                            padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 9),
                                                            child: TextField(
                                                              textAlignVertical:
                                                              TextAlignVertical
                                                                  .top,
                                                              readOnly: true,
                                                              controller: TextEditingController(
                                                                  text: DateFormat(
                                                                      'MM/dd/yyyy')
                                                                      .format(
                                                                      _selectedDate)),
                                                              onChanged: (String
                                                              value) {
                                                                _selectedDate =
                                                                    DateTime.parse(
                                                                        value);
                                                              },
                                                              keyboardType:
                                                              TextInputType
                                                                  .datetime,
                                                              maxLines: null,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                              decoration:
                                                              InputDecoration(
                                                                isDense: true,
                                                                contentPadding: EdgeInsets.only(
                                                                    top: _selectedRecurrenceType ==
                                                                        'Monthly'
                                                                        ? 10
                                                                        : 15,
                                                                    bottom: _selectedRecurrenceType ==
                                                                        'Monthly'
                                                                        ? 10
                                                                        : 13),
                                                                suffixIconConstraints:
                                                                const BoxConstraints(
                                                                    maxHeight:
                                                                    30),
                                                                suffixIcon:
                                                                ButtonTheme(
                                                                    minWidth:
                                                                    30.0,
                                                                    child:
                                                                    MaterialButton(
                                                                      elevation:
                                                                      0,
                                                                      focusElevation:
                                                                      0,
                                                                      highlightElevation:
                                                                      0,
                                                                      disabledElevation:
                                                                      0,
                                                                      hoverElevation:
                                                                      0,
                                                                      onPressed:
                                                                          () async {
                                                                        final DateTime? pickedDate = await showDatePicker(
                                                                            context: context,
                                                                            initialDate: _selectedDate,
                                                                            firstDate: _startDate.isBefore(_firstDate) ? _startDate : _firstDate,
                                                                            currentDate: _selectedDate,
                                                                            lastDate: DateTime(2050),
                                                                            builder: (BuildContext context, Widget? child) {
                                                                              return Container(
                                                                                child: child!,
                                                                              );
                                                                            });
                                                                        if (pickedDate ==
                                                                            null) {
                                                                          return;
                                                                        }
                                                                        setState(() {
                                                                          _selectedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
                                                                          _recurrenceProperties!.endDate = _selectedDate;
                                                                        });
                                                                      },
                                                                      shape:
                                                                      const CircleBorder(),
                                                                      padding:
                                                                      const EdgeInsets.all(10.0),
                                                                      child:
                                                                      Icon(
                                                                        Icons.date_range,
                                                                        size:
                                                                        20,
                                                                      ),
                                                                    )),
                                                                border:
                                                                const UnderlineInputBorder(),
                                                                focusedBorder: UnderlineInputBorder(
                                                                    borderSide: BorderSide(
                                                                        width:
                                                                        2.0)),
                                                              ),
                                                            ),
                                                          ))),
                                                  Spacer(
                                                      flex: _selectedRecurrenceType ==
                                                          'Daily'
                                                          ? _selectedRecurrenceRange ==
                                                          'Never'
                                                          ? 8
                                                          : 6
                                                          : _selectedRecurrenceRange ==
                                                          'Never'
                                                          ? 2
                                                          : 1)
                                                ])),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      )),
                  Visibility(
                    visible: _selectedRecurrenceType == 'Yearly',
                    child: SizedBox(
                      width: 284,
                      height: 50,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                                child: Row(children: <Widget>[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 12),
                                    width: 50,
                                    child: IconButton(
                                      onPressed: () {
                                        _monthDayIcon();
                                      },
                                      icon: Icon(_monthDayRadio),
                                      color: _monthIconColor,
                                      iconSize: 20,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text('  Day   ',
                                        style: TextStyle(
                                            fontSize: 13,
                                                                                        fontWeight: FontWeight.w400)),
                                  ),
                                  SizedBox(
                                    width: 208,
                                    height: 28,
                                    child: TextField(
                                      controller: TextEditingController.fromValue(
                                          TextEditingValue(
                                              text: _dayOfMonth.toString(),
                                              selection: TextSelection.collapsed(
                                                  offset: _dayOfMonth
                                                      .toString()
                                                      .length))),
                                      onChanged: (String value) {
                                        if (value != null && value.isNotEmpty) {
                                          _dayOfMonth = int.parse(value);
                                          if (_dayOfMonth == 0) {
                                            _dayOfMonth = _startDate.day;
                                          } else if (_dayOfMonth >= 31) {
                                            _dayOfMonth = 31;
                                          }
                                        } else if (value.isEmpty || value == null) {
                                          _dayOfMonth = _startDate.day;
                                        }
                                        _recurrenceProperties!.dayOfWeek = 0;
                                        _recurrenceProperties!.week = 0;
                                        _recurrenceProperties!.dayOfMonth =
                                            _dayOfMonth;
                                        _monthDayRadio = Icons.radio_button_checked;
                                        _weekDayRadio =
                                            Icons.radio_button_unchecked;
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      maxLines: null,
                                      style: TextStyle(
                                          fontSize: 13,
                                                                                    fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        suffix: SizedBox(
                                          height: 25,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                            children: <Widget>[
                                              Material(
                                                child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                        Icons
                                                            .arrow_drop_down_outlined),
                                                    onPressed: _removeDay),
                                              ),
                                              Material(
                                                child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    icon: Icon(
                                                      Icons.arrow_drop_up_outlined,
                                                                                                          ),
                                                    onPressed: _addDay),
                                              ),
                                            ],
                                          ),
                                        ),
                                        border: const UnderlineInputBorder(),
                                        focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                                width: 2.0)),
                                      ),
                                    ),
                                  ),
                                  _lastDayOfMonth(),
                                ])),
                          ]),
                    ),
                  ),
                  Visibility(
                      visible: _selectedRecurrenceType == 'Monthly' ||
                          _selectedRecurrenceType == 'Yearly',
                      child: Container(
                        padding: const EdgeInsets.only(top: 10),
                        width: 284,
                        height: 40,
                        child: Row(children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            width: 50,
                            child: IconButton(
                              onPressed: () {
                                _monthWeekIcon();
                              },
                              icon: Icon(_weekDayRadio),
                              color: _weekIconColor,
                              iconSize: 20,
                            ),
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                width: 102,
                                child: TextField(
                                  mouseCursor:
                                  MaterialStateMouseCursor.clickable,
                                  controller: TextEditingController(
                                      text: _weekNumberText),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    suffix: SizedBox(
                                      height: 25,
                                      child: DropdownButton<String>(
                                          focusColor: Colors.transparent,
                                          isExpanded: true,
                                          value: _weekNumberText,
                                          underline: Container(),
                                          style: TextStyle(
                                              fontSize: 13,
                                                                                            fontWeight: FontWeight.w400),
                                          items:
                                          _WEEK_POSITIONS.map((String item) {
                                            return DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item),
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              if (value == 'First') {
                                                _weekNumberText = 'First';
                                                _weekNumber = 1;
                                                _recurrenceProperties!.week =
                                                    _weekNumber;
                                                _monthWeekIcon();
                                              } else if (value == 'Second') {
                                                _weekNumberText = 'Second';
                                                _weekNumber = 2;
                                                _recurrenceProperties!.week =
                                                    _weekNumber;
                                                _monthWeekIcon();
                                              } else if (value == 'Third') {
                                                _weekNumberText = 'Third';
                                                _weekNumber = 3;
                                                _recurrenceProperties!.week =
                                                    _weekNumber;
                                                _monthWeekIcon();
                                              } else if (value == 'Fourth') {
                                                _weekNumberText = 'Fourth';
                                                _weekNumber = 4;
                                                _recurrenceProperties!.week =
                                                    _weekNumber;
                                                _monthWeekIcon();
                                              } else if (value == 'Last') {
                                                _weekNumberText = 'Last';
                                                _weekNumber = -1;
                                                _recurrenceProperties!.week =
                                                    _weekNumber;
                                                _monthWeekIcon();
                                              }
                                            });
                                          }),
                                    ),
                                    border: const UnderlineInputBorder(),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2.0)),
                                  ),
                                ),
                              ),
                              Container(
                                width: 127,
                                margin: const EdgeInsets.only(left: 10),
                                child: TextField(
                                  mouseCursor:
                                  MaterialStateMouseCursor.clickable,
                                  controller: TextEditingController(
                                      text: _dayOfWeekText),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    suffix: SizedBox(
                                      height: 25,
                                      child: DropdownButton<String>(
                                          focusColor: Colors.transparent,
                                          isExpanded: true,
                                          value: _dayOfWeekText,
                                          underline: Container(),
                                          style: TextStyle(
                                              fontSize: 13,
                                                                                            fontWeight: FontWeight.w400),
                                          items: _WEEKDAY_NAMES.map((String item) {
                                            return DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item),
                                            );
                                          }).toList(),
                                          onChanged: (String? value) {
                                            setState(() {
                                              if (value == 'Sunday') {
                                                _dayOfWeekText = 'Sunday';
                                                _dayOfWeek = 7;
                                                _recurrenceProperties!
                                                    .dayOfWeek = _dayOfWeek;
                                                _monthWeekIcon();
                                              } else if (value == 'Monday') {
                                                _dayOfWeekText = 'Monday';
                                                _dayOfWeek = 1;
                                                _recurrenceProperties!
                                                    .dayOfWeek = _dayOfWeek;
                                                _monthWeekIcon();
                                              } else if (value == 'Tuesday') {
                                                _dayOfWeekText = 'Tuesday';
                                                _dayOfWeek = 2;
                                                _recurrenceProperties!
                                                    .dayOfWeek = _dayOfWeek;
                                                _monthWeekIcon();
                                              } else if (value == 'Wednesday') {
                                                _dayOfWeekText = 'Wednesday';
                                                _dayOfWeek = 3;
                                                _recurrenceProperties!
                                                    .dayOfWeek = _dayOfWeek;
                                                _monthWeekIcon();
                                              } else if (value == 'Thursday') {
                                                _dayOfWeekText = 'Thursday';
                                                _dayOfWeek = 4;
                                                _recurrenceProperties!
                                                    .dayOfWeek = _dayOfWeek;
                                                _monthWeekIcon();
                                              } else if (value == 'Friday') {
                                                _dayOfWeekText = 'Friday';
                                                _dayOfWeek = 5;
                                                _recurrenceProperties!
                                                    .dayOfWeek = _dayOfWeek;
                                                _monthWeekIcon();
                                              } else if (value == 'Saturday') {
                                                _dayOfWeekText = 'Saturday';
                                                _dayOfWeek = 6;
                                                _recurrenceProperties!
                                                    .dayOfWeek = _dayOfWeek;
                                                _monthWeekIcon();
                                              }
                                            });
                                          }),
                                    ),
                                    border: const UnderlineInputBorder(),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 2.0)),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _selectedRecurrenceType == 'Monthly',
                                child: _lastDayOfMonth(),
                              ),
                            ],
                          ),
                        ]),
                      )),
                  Container(
                    height: 5,
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Description',
                          style: TextStyle(
                              fontSize: 12,
                                                            fontWeight: FontWeight.w300),
                          textAlign: TextAlign.start,
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: TextField(
                              controller: TextEditingController(text: _notes),
                              onChanged: (String value) {
                                _notes = value;
                              },
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                  fontSize: 13,
                                                                    fontWeight: FontWeight.w400),
                              decoration: InputDecoration(
                                isDense: true,
                                border: const UnderlineInputBorder(),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2.0)),
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RawMaterialButton(
                          onPressed: () {
                            if (widget.newAppointment != null) {
                              widget.events.appointments!.removeAt(widget
                                  .events.appointments!
                                  .indexOf(widget.newAppointment));
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.remove,
                                  <Appointment>[widget.newAppointment!]);
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            'CANCEL',
                            style: TextStyle(
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: RawMaterialButton(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          onPressed: () {
                            if ((widget.selected_appointment.recurrenceRule !=
                                null &&
                                widget.selected_appointment.recurrenceRule!
                                    .isNotEmpty) ||
                                widget.selected_appointment.recurrenceId !=
                                    null) {
                              if (!_canAddRecurrenceAppointment(
                                  widget.visibleDates,
                                  widget.events,
                                  widget.selected_appointment,
                                  _startDate)) {
                                showDialog<Widget>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WillPopScope(
                                          onWillPop: () async {
                                            return true;
                                          },
                                          child: Container(
                                            child: AlertDialog(
                                                title: const Text('Alert'),
                                                content: const Text(
                                                    'Two occurrences of the same event cannot occur on the same day'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('OK'),
                                                  ),
                                                ]),
                                          ));
                                    });
                                return;
                              }
                            }

                            /// Add conditional code here recurrence can add re
                            if (widget.selected_appointment.appointmentType !=
                                AppointmentType.normal &&
                                widget.selected_appointment.recurrenceId ==
                                    null) {
                              if (widget.selected_appointment
                                  .recurrenceExceptionDates ==
                                  null) {
                                widget.events.appointments!.removeAt(widget
                                    .events.appointments!
                                    .indexOf(widget.selected_appointment));
                                widget.events.notifyListeners(
                                    CalendarDataSourceAction.remove,
                                    <Appointment>[widget.selected_appointment]);
                                final Appointment newAppointment = Appointment(
                                  startTime: _startDate,
                                  endTime: _endDate,
                                  notes: _notes,
                                  isAllDay: _isAllDay,
                                  location: _location,
                                  subject:
                                  _subject == '' ? '(No title)' : _subject,
                                  resourceIds: _resourceIds,
                                  id: widget.selected_appointment.id,
                                  recurrenceRule: _recurrenceProperties ==
                                      null ||
                                      _selectedRecurrenceType == 'Never' ||
                                      widget.selected_appointment
                                          .recurrenceId !=
                                          null
                                      ? null
                                      : SfCalendar.generateRRule(
                                      _recurrenceProperties!,
                                      _startDate,
                                      _endDate),
                                );
                                widget.events.appointments!.add(newAppointment);
                                widget.events.notifyListeners(
                                    CalendarDataSourceAction.add,
                                    <Appointment>[newAppointment]);
                                Navigator.pop(context);
                              } else {
                                final Appointment recurrenceAppointment =
                                Appointment(
                                  startTime: _startDate,
                                  endTime: _endDate,
                                  notes: _notes,
                                  isAllDay: _isAllDay,
                                  location: _location,
                                  subject:
                                  _subject == '' ? '(No title)' : _subject,
                                  resourceIds: _resourceIds,
                                  id: widget.selected_appointment.id,
                                  recurrenceRule: _recurrenceProperties ==
                                      null ||
                                      _selectedRecurrenceType == 'Never' ||
                                      widget.selected_appointment
                                          .recurrenceId !=
                                          null
                                      ? null
                                      : SfCalendar.generateRRule(
                                      _recurrenceProperties!,
                                      _startDate,
                                      _endDate),
                                );
                                showDialog<Widget>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return WillPopScope(
                                          onWillPop: () async {
                                            return true;
                                          },
                                          child: Container(
                                              child: _editExceptionSeries(
                                                  context,
                                                  widget.selected_appointment,
                                                  recurrenceAppointment,
                                                  widget.events)));
                                    });
                              }
                            } else if (widget
                                .selected_appointment.recurrenceId !=
                                null) {
                              final Appointment? parentAppointment =
                              widget.events.getPatternAppointment(
                                  widget.selected_appointment, '')
                              as Appointment?;
                              widget.events.appointments!.removeAt(widget
                                  .events.appointments!
                                  .indexOf(parentAppointment));
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.remove,
                                  <Appointment>[parentAppointment!]);
                              parentAppointment.recurrenceExceptionDates != null
                                  ? parentAppointment.recurrenceExceptionDates!
                                  .add(widget.selected_appointment.startTime)
                                  : parentAppointment.recurrenceExceptionDates =
                              <DateTime>[
                                widget.selected_appointment.startTime
                              ];
                              widget.events.appointments!
                                  .add(parentAppointment);
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.add,
                                  <Appointment>[parentAppointment]);
                              if (widget.selected_appointment != null ||
                                  widget.newAppointment != null) {
                                if (widget.events.appointments!.isNotEmpty &&
                                    widget.events.appointments!
                                        .contains(widget.selected_appointment)) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.selected_appointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[
                                        widget.selected_appointment
                                      ]);
                                }
                                if (widget.appointment.isNotEmpty &&
                                    widget.appointment
                                        .contains(widget.newAppointment)) {
                                  widget.appointment.removeAt(widget.appointment
                                      .indexOf(widget.newAppointment!));
                                }

                                if (widget.newAppointment != null &&
                                    widget.events.appointments!.isNotEmpty &&
                                    widget.events.appointments!
                                        .contains(widget.newAppointment)) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.newAppointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[widget.newAppointment!]);
                                }
                              }
                              widget.appointment.add(Appointment(
                                startTime: _startDate,
                                endTime: _endDate,
                                notes: _notes,
                                isAllDay: _isAllDay,
                                location: _location,
                                subject:
                                _subject == '' ? '(No title)' : _subject,
                                resourceIds: _resourceIds,
                                id: widget.selected_appointment.id,
                                recurrenceId:
                                widget.selected_appointment.recurrenceId,
                              ));
                              widget.events.appointments!
                                  .add(widget.appointment[0]);
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.add,
                                  widget.appointment);
                              Navigator.pop(context);
                            } else {
                              if (widget.selected_appointment != null ||
                                  widget.newAppointment != null) {
                                if (widget.events.appointments!.isNotEmpty &&
                                    widget.events.appointments!
                                        .contains(widget.selected_appointment)) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.selected_appointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[
                                        widget.selected_appointment
                                      ]);
                                }
                                if (widget.appointment.isNotEmpty &&
                                    widget.appointment
                                        .contains(widget.newAppointment)) {
                                  widget.appointment.removeAt(widget.appointment
                                      .indexOf(widget.newAppointment!));
                                }

                                if (widget.newAppointment != null &&
                                    widget.events.appointments!.isNotEmpty &&
                                    widget.events.appointments!
                                        .contains(widget.newAppointment)) {
                                  widget.events.appointments!.removeAt(widget
                                      .events.appointments!
                                      .indexOf(widget.newAppointment));
                                  widget.events.notifyListeners(
                                      CalendarDataSourceAction.remove,
                                      <Appointment>[widget.newAppointment!]);
                                }
                              }
                              widget.appointment.add(Appointment(
                                startTime: _startDate,
                                endTime: _endDate,
                                notes: _notes,
                                isAllDay: _isAllDay,
                                location: _location,
                                subject:
                                _subject == '' ? '(No title)' : _subject,
                                resourceIds: _resourceIds,
                                id: widget.selected_appointment.id,
                                recurrenceId:
                                widget.selected_appointment.recurrenceId,
                                recurrenceRule: _recurrenceProperties == null ||
                                    _selectedRecurrenceType == 'Never' ||
                                    widget.selected_appointment
                                        .recurrenceId !=
                                        null
                                    ? null
                                    : SfCalendar.generateRRule(
                                    _recurrenceProperties!,
                                    _startDate,
                                    _endDate),
                              ));
                              widget.events.appointments!
                                  .add(widget.appointment[0]);
                              widget.events.notifyListeners(
                                  CalendarDataSourceAction.add,
                                  widget.appointment);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'SAVE',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _lastDayOfMonth() {
    return Row(children: <Widget>[
      Container(
          padding: const EdgeInsets.only(top: 10),
          child: IconButton(
            onPressed: () {
              _monthLastDayIcon();
            },
            padding: const EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            icon: Icon(_lastDayRadio),
            color: _lastDayIconColor,
            iconSize: 20,
          )),
      Container(
        padding: const EdgeInsets.only(right: 10, top: 10),
        child: Text(
          'Last day of month',
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ),
    ]);
  }
}

bool _canAddRecurrenceAppointment(
    List<DateTime> visibleDates,
    CalendarDataSource dataSource,
    Appointment occurrenceAppointment,
    DateTime startTime) {
  final Appointment parentAppointment = dataSource.getPatternAppointment(
      occurrenceAppointment, '')! as Appointment;
  final List<DateTime> recurrenceDates =
  SfCalendar.getRecurrenceDateTimeCollection(
      parentAppointment.recurrenceRule ?? '', parentAppointment.startTime,
      specificStartDate: visibleDates[0],
      specificEndDate: visibleDates[visibleDates.length - 1]);

  for (int i = 0; i < dataSource.appointments!.length; i++) {
    final Appointment calendarApp = dataSource.appointments![i] as Appointment;
    if (calendarApp.recurrenceId != null &&
        calendarApp.recurrenceId == parentAppointment.id) {
      recurrenceDates.add(calendarApp.startTime);
    }
  }

  if (parentAppointment.recurrenceExceptionDates != null) {
    for (int i = 0;
    i < parentAppointment.recurrenceExceptionDates!.length;
    i++) {
      recurrenceDates.remove(parentAppointment.recurrenceExceptionDates![i]);
    }
  }

  recurrenceDates.sort();
  bool canAddRecurrence = isSameDate(occurrenceAppointment.startTime, startTime);
  if (!_isDateInDateCollection(recurrenceDates, startTime)) {
    final int currentRecurrenceIndex =
    recurrenceDates.indexOf(occurrenceAppointment.startTime);
    if (currentRecurrenceIndex == 0 || currentRecurrenceIndex == recurrenceDates.length - 1) {
      canAddRecurrence = true;
    } else if (currentRecurrenceIndex < 0) {
      canAddRecurrence = false;
    } else {
      final DateTime previousRecurrence =
      recurrenceDates[currentRecurrenceIndex - 1];
      final DateTime nextRecurrence =
      recurrenceDates[currentRecurrenceIndex + 1];
      canAddRecurrence = (isDateWithInDateRange(
          previousRecurrence, nextRecurrence, startTime) &&
          !isSameDate(previousRecurrence, startTime) &&
          !isSameDate(nextRecurrence, startTime)) ||
          canAddRecurrence;
    }
  }

  return canAddRecurrence;
}

bool _isDateInDateCollection(List<DateTime>? dates, DateTime date) {
  if (dates == null || dates.isEmpty) {
    return false;
  }

  for (final DateTime currentDate in dates) {
    if (isSameDate(currentDate, date)) {
      return true;
    }
  }

  return false;
}

Widget _editExceptionSeries(
    BuildContext context,
    Appointment selectedAppointment,
    Appointment recurrenceAppointment,
    CalendarDataSource events) {

  return Dialog(
    child: Container(
      width: 400,
      height: 200,
      padding: const EdgeInsets.only(left: 20, top: 10),
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        Container(
          width: 360,
          height: 50,
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                  flex: 8,
                  child: Text(
                    'Alert',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400),
                  )),
              Expanded(
                flex: 2,
                child: IconButton(
                  splashRadius: 15,
                  tooltip: 'Close',
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
        Container(
            width: 360,
            height: 80,
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
                'Do you want to cancel the changes made to specific instances of this series and match it to the whole series again?',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300))),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            RawMaterialButton(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              onPressed: () {
                Navigator.pop(context);
                final List<DateTime>? exceptionDates =
                    selectedAppointment.recurrenceExceptionDates;
                for (int i = 0; i < exceptionDates!.length; i++) {
                  final Appointment? changedOccurrence =
                  events.getOccurrenceAppointment(
                      selectedAppointment, exceptionDates[i], '');
                  if (changedOccurrence != null) {
                    events.appointments!.removeAt(
                        events.appointments!.indexOf(changedOccurrence));
                    events.notifyListeners(CalendarDataSourceAction.remove,
                        <Appointment>[changedOccurrence]);
                  }
                }
                events.appointments!.removeAt(
                    events.appointments!.indexOf(selectedAppointment));
                events.notifyListeners(CalendarDataSourceAction.remove,
                    <Appointment>[selectedAppointment]);
                events.appointments!.add(recurrenceAppointment);
                events.notifyListeners(CalendarDataSourceAction.add,
                    <Appointment>[recurrenceAppointment]);
                Navigator.pop(context);
              },
              child: const Text(
                'YES',
                style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: 20,
            ),
            RawMaterialButton(
              onPressed: () {
                Navigator.pop(context);
                recurrenceAppointment.recurrenceExceptionDates =
                    selectedAppointment.recurrenceExceptionDates;
                recurrenceAppointment.recurrenceRule =
                    selectedAppointment.recurrenceRule;
                events.appointments!.removeAt(
                    events.appointments!.indexOf(selectedAppointment));
                events.notifyListeners(CalendarDataSourceAction.remove,
                    <Appointment>[selectedAppointment]);
                events.appointments!.add(recurrenceAppointment);
                events.notifyListeners(CalendarDataSourceAction.add,
                    <Appointment>[recurrenceAppointment]);
                Navigator.pop(context);
              },
              child: Text(
                'NO',
                style: TextStyle(
                    fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: 20,
            ),
            RawMaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                    fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              width: 20,
            ),
          ],
        ),
      ]),
    ),
  );
}

/// Returns the resource from the id passed.
CalendarResource _getResourceFromId(
    Object resourceId, List<CalendarResource> resourceCollection) {
  return resourceCollection
      .firstWhere((CalendarResource resource) => resource.id == resourceId);
}

/// Returns the selected resources based on the id collection passed
List<CalendarResource> _getSelectedResources(
    List<Object>? resourceIds, List<CalendarResource>? resourceCollection) {
  final List<CalendarResource> selectedResources = <CalendarResource>[];
  if (resourceIds == null ||
      resourceIds.isEmpty ||
      resourceCollection == null ||
      resourceCollection.isEmpty) {
    return selectedResources;
  }

  for (int i = 0; i < resourceIds.length; i++) {
    final CalendarResource resourceName =
    _getResourceFromId(resourceIds[i], resourceCollection);
    selectedResources.add(resourceName);
  }

  return selectedResources;
}

/// Returns the available resource, by filtering the resource collection from
/// the selected resource collection.
List<CalendarResource> _getUnSelectedResources(
    List<CalendarResource>? selectedResources,
    List<CalendarResource>? resourceCollection) {
  if (selectedResources == null ||
      selectedResources.isEmpty ||
      resourceCollection == null ||
      resourceCollection.isEmpty) {
    return resourceCollection ?? <CalendarResource>[];
  }

  final List<CalendarResource> collection = resourceCollection.sublist(0);
  for (int i = 0; i < resourceCollection.length; i++) {
    final CalendarResource resource = resourceCollection[i];
    for (int j = 0; j < selectedResources.length; j++) {
      final CalendarResource selectedResource = selectedResources[j];
      if (resource.id == selectedResource.id) {
        collection.remove(resource);
      }
    }
  }

  return collection;
}

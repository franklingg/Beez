import 'package:beez/constants/app_colors.dart';
import 'package:beez/models/event_model.dart';
import 'package:beez/presentation/event/event_screen.dart';
import 'package:beez/presentation/navigation/tab_navigation_widget.dart';
import 'package:beez/presentation/shared/top_bar_widget.dart';
import 'package:beez/providers/event_provider.dart';
import 'package:beez/providers/user_provider.dart';
import 'package:beez/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class MyEventsScreen extends StatefulWidget {
  static const String name = 'my_events';
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  List<EventModel> shownEvents = [];
  DateTime? selectedDay;
  DateTime focusedDay = DateTime.now().startOfMonth();
  int? highlightIndex;
  @override
  void initState() {
    super.initState();
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // FIXME: delete
    // final mockEvents = List<EventModel>.generate(
    //     11,
    //     (index) => EventModel.initialize(
    //         '',
    //         Timestamp.fromDate(
    //             DateTime(2023, 04, 26).add(Duration(days: index * 4))),
    //         "Evento $index",
    //         '',
    //         ''));

    setState(() {
      shownEvents.addAll(eventProvider.allEvents
          .where((event) => event.creator == userProvider.currentUserId));
      shownEvents.addAll(eventProvider.allEvents.where(
          (event) => event.interested.contains(userProvider.currentUserId)));
      // FIXME: delete
      // shownEvents.addAll(mockEvents);
      shownEvents.sort((e1, e2) => e1.date.compareTo(e2.date));
      reorderEvents();
    });
  }

  void reorderEvents() {
    final List<List<EventModel>> result;
    if (selectedDay != null) {
      result = shownEvents.split((event) =>
          (event.date.toDate().getDateOnly() == selectedDay!.getDateOnly()));
    } else {
      shownEvents.sort((e1, e2) => e1.date.compareTo(e2.date));
      result = shownEvents.split((event) =>
          (event.date.toDate().isAfter(focusedDay.startOfMonth()) ||
              event.date
                  .toDate()
                  .isAtSameMomentAs(focusedDay.startOfMonth())) &&
          (event.date.toDate().isBefore(focusedDay.endOfMonth()) ||
              event.date.toDate().isAtSameMomentAs(focusedDay.endOfMonth())));
    }
    setState(() {
      highlightIndex = result[0].isNotEmpty ? result[0].length - 1 : null;
      shownEvents = [...result[0], ...result[1]];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Consumer<UserProvider>(
            builder: (_, userProvider, __) => Scaffold(
                appBar: TopBar(),
                body: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: AppColors.darkYellow),
                              borderRadius: BorderRadius.circular(8)),
                          child: TableCalendar(
                            locale: 'pt_BR',
                            daysOfWeekHeight: 20,
                            startingDayOfWeek: StartingDayOfWeek.monday,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                            },
                            onPageChanged: (newFocusedDay) {
                              setState(() {
                                focusedDay = newFocusedDay;
                                selectedDay = null;
                              });
                              reorderEvents();
                            },
                            holidayPredicate: (day) => shownEvents.any(
                                (event) =>
                                    event.date.toDate().getDateOnly() ==
                                    day.getDateOnly()),
                            headerStyle: HeaderStyle(
                                headerPadding: EdgeInsets.zero,
                                titleCentered: true,
                                titleTextStyle: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                titleTextFormatter: (date, locale) {
                                  return DateFormat.MMMM(locale)
                                      .format(date)
                                      .toCapitalized();
                                  // return DateFormat("MMMM/y", locale)
                                  //     .format(date)
                                  //     .toCapitalized();
                                },
                                leftChevronIcon: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: AppColors.grey),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.chevron_left),
                                ),
                                rightChevronIcon: Container(
                                  height: 32,
                                  width: 32,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: AppColors.grey),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: const Icon(Icons.chevron_right),
                                )),
                            rowHeight: 43,
                            daysOfWeekStyle: DaysOfWeekStyle(
                                weekdayStyle: const TextStyle(
                                    color: AppColors.mediumGrey),
                                weekendStyle: const TextStyle(
                                    color: AppColors.mediumGrey),
                                dowTextFormatter: (date, locale) {
                                  final weekDays = DateFormat.E(locale)
                                      .dateSymbols
                                      .SHORTWEEKDAYS;
                                  return weekDays[
                                          date.weekday == 7 ? 0 : date.weekday]
                                      .toCapitalized();
                                }),
                            firstDay: DateTime(2010),
                            lastDay: DateTime(2030),
                            focusedDay: focusedDay,
                            weekNumbersVisible: false,
                            onDaySelected: (pickedDay, focusedDay) {
                              setState(() {
                                selectedDay =
                                    pickedDay == selectedDay ? null : pickedDay;
                              });
                              reorderEvents();
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                return Center(
                                    child: Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                      height: 1.45,
                                      fontSize: selectedDay == day ? 18 : 15),
                                ));
                              },
                              holidayBuilder: (context, day, focusedDay) {
                                final isUserEvent = shownEvents.any((event) =>
                                    event.date.toDate().getDateOnly() ==
                                        day.getDateOnly() &&
                                    event.creator ==
                                        userProvider.currentUserId);
                                return Center(
                                    child: Container(
                                        width: selectedDay == day ? 32 : 30,
                                        height: selectedDay == day ? 32 : 30,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            color: isUserEvent
                                                ? AppColors.blue
                                                : AppColors.yellow),
                                        child: Center(
                                            child: Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                              height: 1.45,
                                              fontSize:
                                                  selectedDay == day ? 18 : 15,
                                              color: isUserEvent
                                                  ? AppColors.white
                                                  : AppColors.black),
                                        ))));
                              },
                            ),
                            calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.yellow,
                                      width: selectedDay?.getDateOnly() ==
                                              DateTime.now().getDateOnly()
                                          ? 2
                                          : 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                todayTextStyle: TextStyle(
                                    color: AppColors.brown,
                                    fontSize: selectedDay?.getDateOnly() ==
                                            DateTime.now().getDateOnly()
                                        ? 18
                                        : 15)),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                CircleAvatar(
                                    radius: 5,
                                    backgroundColor: AppColors.yellow),
                                SizedBox(width: 6),
                                Text(
                                  "Eventos de Interesse",
                                  style: TextStyle(fontSize: 11, height: 1),
                                )
                              ],
                            ),
                            const SizedBox(width: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                CircleAvatar(
                                    radius: 5, backgroundColor: AppColors.blue),
                                SizedBox(width: 6),
                                Text(
                                  "Meus Eventos",
                                  style: TextStyle(fontSize: 11, height: 1),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                              itemCount: shownEvents.length,
                              itemBuilder: (context, index) {
                                final isUserEvent =
                                    shownEvents[index].creator ==
                                        userProvider.currentUserId;
                                return GestureDetector(
                                  onTap: () {
                                    GoRouter.of(context).pushNamed(
                                        EventScreen.name,
                                        queryParams: {
                                          'id': shownEvents[index].id
                                        });
                                  },
                                  child: Container(
                                    decoration: index == highlightIndex
                                        ? const BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: AppColors.shadow)))
                                        : null,
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 7),
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: isUserEvent
                                                  ? AppColors.blue
                                                  : AppColors.yellow),
                                          child: Text(
                                            DateFormat("dd/MM").format(
                                                shownEvents[index]
                                                    .date
                                                    .toDate()),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: isUserEvent
                                                    ? AppColors.white
                                                    : AppColors.black),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(shownEvents[index].name,
                                            style:
                                                const TextStyle(fontSize: 16))
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        )
                      ]),
                ),
                bottomNavigationBar: const TabNavigation())));
  }
}

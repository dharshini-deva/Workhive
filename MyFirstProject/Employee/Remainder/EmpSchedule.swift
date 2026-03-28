//
//  EmpSchedule.swift
//  WorkHive
//
//  FINAL – Calendar + API Reminders Integration
//

import SwiftUI

struct ScheduleView: View {

    // 🔹 VIEW MODEL
    @StateObject private var reminderViewModel = ReminderViewModel()

    @Binding var path: NavigationPath

    // MARK: - Calendar State
    @State private var currentDate = Date()
    @State private var selectedDate = Date()

    private let calendar = Calendar.current
    private let days = ["S", "M", "T", "W", "T", "F", "S"]

    // MARK: - FILTERED REMINDERS FOR SELECTED DATE
    private var selectedDateReminders: [ReminderItem] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selected = formatter.string(from: selectedDate)

        return reminderViewModel.reminders.filter {
            $0.start_date == selected || $0.repeat_everyday == 1
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                headerView
                weekDaysView
                calendarGrid

                // ➕ Add Reminder Button
                Button {
                    path.append(AppRoute.empschedule)
                } label: {
                    Text("Add Reminder")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                // 🔔 REMINDERS BELOW CALENDAR
                remindersList
                    .padding(.bottom, 30)
            }
        }
        .background(Color.white)
        .onAppear {
            reminderViewModel.fetchReminders()
        }
    }
}

// MARK: - HEADER
private extension ScheduleView {

    var headerView: some View {
        HStack {
            Text("Schedule")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            HStack(spacing: 12) {
                Button { changeMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                }

                Text(monthYearString)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Button { changeMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

// MARK: - WEEK DAYS
private extension ScheduleView {

    var weekDaysView: some View {
        HStack {
            ForEach(days, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - CALENDAR GRID
private extension ScheduleView {

    var calendarGrid: some View {

        let dates = generateDates()

        return LazyVGrid(
            columns: Array(repeating: GridItem(.flexible()), count: 7),
            spacing: 14
        ) {
            ForEach(dates.indices, id: \.self) { index in
                if let date = dates[index] {

                    Text("\(calendar.component(.day, from: date))")
                        .font(.subheadline)
                        .frame(width: 34, height: 34)
                        .background(
                            Circle()
                                .fill(
                                    calendar.isDate(date, inSameDayAs: selectedDate)
                                    ? Color.yellow
                                    : Color.clear
                                )
                        )
                        .foregroundColor(
                            calendar.isDate(date, inSameDayAs: selectedDate)
                            ? .white
                            : .black
                        )
                        .onTapGesture {
                            selectedDate = date
                        }

                } else {
                    Color.clear
                        .frame(width: 34, height: 34)
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - REMINDERS LIST (API)
private extension ScheduleView {

    var remindersList: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Reminders")
                .font(.headline)
                .padding(.horizontal)

            if selectedDateReminders.isEmpty {
                Text("No reminders for selected date")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
            } else {
                ForEach(selectedDateReminders) { reminder in
                    HStack {

                        VStack(alignment: .leading, spacing: 6) {
                            Text(reminder.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Text("\(reminder.start_time) - \(reminder.end_time)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Image(systemName: "bell.fill")
                            .foregroundColor(.yellow)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - HELPERS
private extension ScheduleView {

    var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = newDate
        }
    }

    func generateDates() -> [Date?] {

        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        let firstOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: currentDate)
        )!

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1

        var dates: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
            dates.append(date)
        }

        return dates
    }
}

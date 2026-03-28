//
//  AddReminder.swift
//  WorkHive
//
//  Created by SAIL01 on 15/12/25.
//  Final: Single-day selection & Start-date-only logic
//

import SwiftUI

struct AddReminderView: View {
    @StateObject private var viewModel = ReminderViewModel()

    @Binding var path: NavigationPath
    

    // MARK: - Form State
    @State private var title: String = ""
    @State private var description: String = ""

    // Date & Time
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()          // 🔒 Auto-managed
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()

    // ✅ Single Day Selection (ID based)
    @State private var selectedDayId: Int?

    @State private var repeatEveryday: Bool = false

    // Days with UNIQUE IDs (fixes T / S issue)
    private let days: [(id: Int, label: String)] = [
        (1, "M"),
        (2, "T"),
        (3, "W"),
        (4, "T"),
        (5, "F"),
        (6, "S"),
        (7, "S")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {

                // MARK: - Header
                Text("Add Reminder")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                // MARK: - Title
                inputField(
                    title: "Title",
                    placeholder: "Enter the Title",
                    text: $title
                )

                // MARK: - Description
                descriptionField

                // MARK: - Dates
                HStack(spacing: 14) {

                    // Employee selects ONLY Start Date
                    datePickerField(
                        title: "Start Date",
                        selection: $startDate
                    )

                    // End Date selection
                    datePickerField(
                        title: "End Date",
                        selection: $endDate
                    )
                }

                // MARK: - Time
                HStack(spacing: 14) {
                    timePickerField(
                        title: "Start Time",
                        selection: $startTime
                    )

                    timePickerField(
                        title: "End Time",
                        selection: $endTime
                    )
                }

                // MARK: - Select Day (ONLY ONE)
                selectDayView

                // MARK: - Repeat Everyday
                repeatToggle

                // MARK: - Create Button
                Button(action: {
                    viewModel.createReminder(
                        title: title,
                        description: description,
                        startDate: startDate,
                        endDate: endDate, // ✅ Pass endDate
                        startTime: startTime,
                        endTime: endTime,
                        selectedDayId: selectedDayId,
                        repeatEveryday: repeatEveryday,
                        path: $path
                    )
                }) {
                    Text("Create Reminder")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#FDB913"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 8)


                Spacer(minLength: 30)
            }
            .padding()
        }
        .background(Color.white)

        // 🔁 Keep End Date synced

        .alert(viewModel.isSuccess ? "Success" : "Error",
               isPresented: $viewModel.showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.alertMessage)
        }

    }
}

// MARK: - Description
extension AddReminderView {

    var descriptionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Description")
                .font(.headline)

            TextEditor(text: $description)
                .frame(height: 120)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
                .overlay(
                    Group {
                        if description.isEmpty {
                            Text("Describe your issue")
                                .foregroundColor(.gray.opacity(0.6))
                                .padding(.leading, 16)
                                .padding(.top, 14)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
}

// MARK: - Select Day (Single Selection)
extension AddReminderView {

    var selectDayView: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Select Day")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(days, id: \.id) { day in
                    Text(day.label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(
                                    selectedDayId == day.id
                                    ? Color.yellow
                                    : Color.yellow.opacity(0.15)
                                )
                        )
                        .foregroundColor(
                            selectedDayId == day.id
                            ? .black
                            : .yellow
                        )
                        .onTapGesture {
                            selectedDayId = day.id   // ✅ ONLY ONE
                        }
                }
            }
        }
    }
}

// MARK: - Repeat Toggle
extension AddReminderView {

    var repeatToggle: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: $repeatEveryday)
                .labelsHidden()

            Text("Repeat Everyday")
                .font(.subheadline)
        }
        .padding(.top, 4)
    }
}

// MARK: - Reusable Inputs
extension AddReminderView {

    func inputField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            TextField(placeholder, text: text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
        }
    }

    func datePickerField(
        title: String,
        selection: Binding<Date>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            DatePicker(
                "",
                selection: selection,
                displayedComponents: .date
            )
            .labelsHidden()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3))
            )
        }
    }



    func timePickerField(
        title: String,
        selection: Binding<Date>
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)

            DatePicker(
                "",
                selection: selection,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3))
            )
        }
    }
}

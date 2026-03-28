import SwiftUI

struct EditableProfileField: View {
    let title: String
    @Binding var text: String
    var isEditing: Bool
    var keyboardType: UIKeyboardType = .default
    var isDate: Bool = false
    @Binding var date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            
            if isEditing {
                if isDate {
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .id(Calendar.current) // Fix for some SwiftUI DatePicker glitches
                } else {
                    TextField(title, text: $text)
                        .keyboardType(keyboardType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                }
            } else {
                Text(isDate ? formatDate(date) : text)
                    .font(.body)
                    .fontWeight(.medium)
            }
            Divider()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

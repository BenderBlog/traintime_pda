//
//  EventItem.swift
//  ClasstableWidgetExtension
//
//  Created by sprt on 2024/1/14.
//
// Event view
//

import Foundation
import SwiftUI

private let formatHourMinute = "HH:mm"
private let myDateFormatter = DateFormatter()

struct EventItem: View {
    var event : TimeLineStructItems
    
    internal init(_ event: TimeLineStructItems) {
        self.event = event
    }
    
    @Environment(\.colorScheme) private var colourScheme
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        myDateFormatter.dateFormat = formatHourMinute
        let string : String
        switch(event.type) {
            case .course: string = "课\n程"
            case .exam: string = "考\n试"
            case .experiment: string = "实\n验"
        }
        return HStack {
            Text(string).font(Font.custom("MyFont", size: 12))
            RoundedRectangle(cornerRadius: 120).frame(width: 6).padding(.vertical, 6)
            VStack(alignment: .leading) {
                if (widgetFamily == .systemSmall) {
                    Text(event.name)
                        .font(.subheadline.weight(.medium))
                    Text("\(myDateFormatter.string(from: event.start_time)) \(event.place)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading) {
                            Text(event.name)
                                .font(.subheadline.weight(.medium))
                            Text("\(event.teacher) \(event.place)")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("\(myDateFormatter.string(from: event.start_time))")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text("\(myDateFormatter.string(from: event.end_time))")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
            Spacer(minLength: .zero)
        }
        .foregroundColor(colors[event.colorIndex % colors.count])
        .blendMode(colourScheme == .light ? .plusDarker : .plusLighter)
        .padding(.horizontal, 8)
        .background {
            colors[event.colorIndex % colors.count].opacity(0.125)
                .blendMode(colourScheme == .light ? .normal : .hardLight)
        }
        .frame(maxHeight: 42)
        .clipShape(ContainerRelativeShape())
    }
}
/*
struct EventItem_Previews: PreviewProvider {
    static var previews: some View {
        EventItem(TimeLineStructItems(
            name: "形势与政策",
            teacher: "哲学dark师",
            place: "C-666",
            start_time: Date(),
            end_time:  Date()
        ), color: Color.blue
        )
    }
}
*/


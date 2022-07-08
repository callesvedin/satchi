//
//  TimeFormatter.swift
//  Satchi
//
//  Created by Carl-Johan Svedin on 2022-07-06.
//

import Foundation

struct TimeFormatter {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        return dateFormatter
    }()


    private static let secondsTimeFormatter:DateComponentsFormatter = {
        let elapsedTimeFormatter = DateComponentsFormatter()
        elapsedTimeFormatter.unitsStyle = .abbreviated
        elapsedTimeFormatter.zeroFormattingBehavior = .dropAll
        elapsedTimeFormatter.allowedUnits = [.hour, .minute, .second]
        return elapsedTimeFormatter
    }()

    private static let minutesTimeFormatter:DateComponentsFormatter = {
        let elapsedTimeFormatter = DateComponentsFormatter()
        elapsedTimeFormatter.unitsStyle = .abbreviated
        elapsedTimeFormatter.zeroFormattingBehavior = .dropAll
        elapsedTimeFormatter.allowedUnits = [.hour, .minute]
        return elapsedTimeFormatter
    }()

    public static func shortTimeWithSecondsFor(seconds:Double) -> String {
        let r = TimeFormatter.secondsTimeFormatter.string(from: seconds) ?? "-"
        return r
    }

    public static func shortTimeWithMinutesFor(seconds:Double) -> String {
        let r = TimeFormatter.minutesTimeFormatter.string(from: seconds) ?? "-"
        return r
    }

    public static func dateStringFrom(date:Date?) -> String {
        guard let date = date else {return "-"}
        return dateFormatter.string(from: date)
    }

}

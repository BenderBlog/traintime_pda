import Flutter
import UIKit
import XCTest

final class RunnerTests: XCTestCase {
  private func assertLocalDate(
    _ date: Date,
    year: Int,
    month: Int,
    day: Int,
    hour: Int,
    minute: Int,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current
    let components = calendar.dateComponents(
      [.year, .month, .day, .hour, .minute],
      from: date
    )

    XCTAssertEqual(components.year, year, file: file, line: line)
    XCTAssertEqual(components.month, month, file: file, line: line)
    XCTAssertEqual(components.day, day, file: file, line: line)
    XCTAssertEqual(components.hour, hour, file: file, line: line)
    XCTAssertEqual(components.minute, minute, file: file, line: line)
  }

  func testCustomClassParsesDartLocalDateTimes() throws {
    let json = #"""
      {
        "id": "tr-1",
        "start_time": "2026-07-01T08:30:00.000",
        "end_time": "2026-07-01T11:17:00.000"
      }
      """#.data(using: .utf8)!

    let range = try JSONDecoder().decode(CustomClassTimeRange.self, from: json)

    assertLocalDate(range.startTime, year: 2026, month: 7, day: 1, hour: 8, minute: 30)
    assertLocalDate(range.endTime, year: 2026, month: 7, day: 1, hour: 11, minute: 17)
  }

  func testExamParsesSpaceSeparatedLocalDateTimes() throws {
    let json = #"""
      {
        "subject": "线性代数A",
        "typeStr": "期末考试",
        "startTimeStr": "2026-06-26 13:00:00",
        "endTimeStr": "2026-06-26 15:00:00",
        "time": "2026-06-26 13:00-15:00",
        "place": "A-523",
        "seat": null
      }
      """#.data(using: .utf8)!

    let subject = try JSONDecoder().decode(Subject.self, from: json)

    assertLocalDate(subject.startTime, year: 2026, month: 6, day: 26, hour: 13, minute: 0)
    assertLocalDate(subject.endTime, year: 2026, month: 6, day: 26, hour: 15, minute: 0)
  }

  func testPhysicsExperimentParsesDartLocalDateTimes() throws {
    let json = #"""
      {
        "name": "电流场模拟静电场实验",
        "classroom": "F222",
        "timeRanges": [
          {
            "$1": "2026-03-27T15:55:00.000",
            "$2": "2026-03-27T18:10:00.000"
          }
        ],
        "teacher": "武颖丽"
      }
      """#.data(using: .utf8)!

    let experiment = try JSONDecoder().decode(ExperimentData.self, from: json)
    let range = try XCTUnwrap(experiment.timeRanges.first)

    assertLocalDate(range.0, year: 2026, month: 3, day: 27, hour: 15, minute: 55)
    assertLocalDate(range.1, year: 2026, month: 3, day: 27, hour: 18, minute: 10)
  }
}

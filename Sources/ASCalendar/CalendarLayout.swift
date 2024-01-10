//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import SwiftUI
import OSLog

extension View {
    func calendarLayout(startAt: Date, endAt: Date) -> some View {
        layoutValue(key: CalendarLayoutData.self, value: CalendarLayoutData(startAt: startAt, endAt: endAt))
    }
}

struct CalendarLayoutData: LayoutValueKey {
    var startAt: Date
    var endAt: Date
    
    static var defaultValue: CalendarLayoutData?
}

struct CalendarLineLayout: Layout {
    var minDate: Date
    var maxDate: Date
    var titleHeight: CGFloat
    var cellHeight: CGFloat
    var spacing: CGFloat
    
    private struct LineCache {
        var line: Int
        var cells: [CellCache]
        
        var maxX: CGFloat {
            cells.reduce(0, { result, cell in max(result, cell.point.x+cell.size.width) } )
        }
        
        struct CellCache {
            var point: CGPoint
            var size: CGSize
            
            func isContained(position: CGPoint) -> Bool {
                point.x <= position.x && position.x < point.x+size.width
            }
        }
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var lines: [LineCache] = [LineCache(line: 1, cells: [])]
        let cellDatas = getCellDatas(size: bounds.size, subviews: subviews)
        for cellData in cellDatas {
            let requiredPoint = getRequiredCellPoint(size: bounds.size, startAt: cellData.layoutData.startAt)
            let (isPositionExit, containedLines) = isPositionExit(position: requiredPoint, lines: lines)
            
            var position: CGPoint = .zero
            var currentLine: Int = 0
            var size: CGSize = .zero
            if isPositionExit {
                let availableLines = getMaxLines(size: bounds.size)
                if containedLines.count >= availableLines {
                    if let matchedLine = lines.sorted(by: { $0.maxX < $1.maxX }).first,
                        let index = lines.firstIndex(where: { $0.line == matchedLine.line }),
                        matchedLine.maxX <= requiredPoint.x + cellData.width {
                        
                        position = CGPoint(x: matchedLine.maxX, y: 0)
                        size = CGSize(width: cellData.width-(matchedLine.maxX-requiredPoint.x),
                                      height: cellHeight)
                        currentLine = matchedLine.line
                        lines[index].cells.append(.init(point: position,
                                                        size: size))
                        
                    } else {
                        os_log(.error, log: .default, "CalendarLineLayout: Can't found matched line")
                    }
                } else if let matchedLine = lines.sorted(by: { $0.maxX < $1.maxX }).first,
                          let index = lines.firstIndex(where: { $0.line == matchedLine.line }),
                          matchedLine.maxX <= requiredPoint.x {
                    position = CGPoint(x: max(matchedLine.maxX, requiredPoint.x), y: 0)
                    size = CGSize(width: cellData.width,
                                  height: cellHeight)
                    currentLine = matchedLine.line
                    lines[index].cells.append(.init(point: position,
                                                    size: size))
                } else {
                    let maxLine = lines.reduce(0, { result, line in max(result, line.line) })
                    position = requiredPoint
                    currentLine = maxLine+1
                    size = CGSize(width: cellData.width,
                                  height: cellHeight)
                    lines.append(LineCache(line: currentLine,
                                           cells: [.init(point: requiredPoint,
                                                         size: size)]))
                }
            } else if let index = lines.firstIndex(where: { $0.line == 0 }) {
                position = requiredPoint
                size = CGSize(width: cellData.width,
                              height: cellHeight)
                currentLine = lines[index].line
                lines[index].cells.append(.init(point: requiredPoint,
                                                size: size))
            } else {
                position = requiredPoint
                size = CGSize(width: cellData.width,
                              height: cellHeight)
                currentLine = 0
                lines.append(LineCache(line: currentLine,
                                       cells: [.init(point: requiredPoint,
                                                     size: size)]))
            }
            cellData.subview.place(at: CGPoint(x: bounds.minX+position.x,
                                               y: bounds.minY + titleHeight + (spacing+cellHeight)*CGFloat(currentLine)),
                                   anchor: .topLeading,
                                   proposal: ProposedViewSize(size))
        }
    }
    
    private func getMaxLines(size: CGSize) -> Int {
        let remainHeight = max(0, size.height-(titleHeight+cellHeight))
        let availableLines = Int(remainHeight/(cellHeight+spacing))+1
        return availableLines
    }
    
    private func isPositionExit(position: CGPoint, lines: [LineCache]) -> (isExit: Bool, lines: [Int]) {
        let matchedLines = lines.filter { line in
            line.cells.contains(where: { cell in cell.isContained(position: position) }
        )}
        return (!matchedLines.isEmpty, matchedLines.map { $0.line })
    }
    
    private func getCellDatas(size: CGSize, subviews: Subviews) -> [(subview: Subviews.Element, layoutData: CalendarLayoutData, width: CGFloat)] {
        subviews.compactMap { subview in
            guard let layoutData = subview[CalendarLayoutData.self] else { return nil }
            let cellWidth = getCellWidth(size: size, layoutData: layoutData)
            return (subview, layoutData, cellWidth)
        }
    }
    
    private func getCellWidth(size: CGSize, layoutData: CalendarLayoutData) -> CGFloat {
        let calendar = Calendar.current
        let dayDifference = Calendar.current.dateComponents([.day],
                                                            from: calendar.startOfDay(for: max(layoutData.startAt, minDate)),
                                                            to: calendar.startOfDay(for: min(layoutData.endAt, maxDate))).day ?? 1
        let minCellWidth = getMinCellWidth(size: size)
        return minCellWidth*CGFloat(dayDifference+1)
    }
    
    private func getRequiredCellPoint(size: CGSize, startAt: Date) -> CGPoint {
        let calendar = Calendar.current
        let dayDifference = Calendar.current.dateComponents([.day],
                                                            from: calendar.startOfDay(for: minDate),
                                                            to: calendar.startOfDay(for: startAt)).day ?? 1
        let minCellWidth = getMinCellWidth(size: size)
        return CGPoint(x: minCellWidth*CGFloat(max(dayDifference, 0)), y: .zero)
    }
    
    private func getMinCellWidth(size: CGSize) -> CGFloat {
        size.width/7
    }
}

//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import Foundation
import SwiftUI
import OSLog

struct WeekEventsLayout: Layout {
    var startAt: Date
    var endAt: Date
    var spacing: CGFloat
    var titleSpcaing: CGFloat
    var dateCellConfig: ASCalendarConfiguration.DateCellConfiguration
    var eventCellConfig: ASCalendarConfiguration.EventCellConfiguration
    
    private struct LineCache {
        var line: Int
        var cells: [CellCache]
        var maxX: CGFloat {
            cells.reduce(0, { result, cell in max(result, cell.maxX) })
        }
        
        struct CellCache {
            var subview: Subviews.Element
            var data: EventDateLayoutData
            var position: CGPoint
            var size: CGSize
            var maxX: CGFloat {
                position.x+size.width
            }
            
            func isPositionContained(position point: CGPoint) -> Bool {
                position.x <= point.x && point.x <= maxX
            }
        }
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        return proposal.replacingUnspecifiedDimensions()
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxLine = getMaxLine(size: bounds.size)
        var lines: [LineCache] = [LineCache(line: 0, cells: [])]
        
        let cells = getDefaultCells(size: bounds.size, subviews: subviews)
        
        for cell in cells {
            if let avaliableLine = getAvaliableLine(cell: cell, lines: lines, maxLine: maxLine) {
                var cellCache = cell
                if let lineCacheIndex = lines.firstIndex(where: { $0.line == avaliableLine }) {
                    cellCache.size = getAvailableSize(line: lines[lineCacheIndex], cell: cell)
                    cellCache.position = getAvailablePosition(line: lines[lineCacheIndex], cell: cell)
                    lines[lineCacheIndex].cells.append(cellCache)
                } else {
                    var newLine = LineCache(line: lines.count, cells: [])
                    cellCache.size = getAvailableSize(line: newLine, cell: cell)
                    cellCache.position = getAvailablePosition(line: newLine, cell: cell)
                    newLine.cells.append(cellCache)
                    lines.append(newLine)
                }
            }
        }
        
        for line in lines {
            for cell in line.cells {
                cell.subview.place(at: CGPoint(x: bounds.minX+cell.position.x, 
                                               y: bounds.minY+dateCellConfig.titleHeight+titleSpcaing+(spacing+eventCellConfig.height)*CGFloat(line.line)),
                                   anchor: .topLeading,
                                   proposal: ProposedViewSize(cell.size))
            }
        }
        
        let remainedCells = cells.filter { cell in !lines.contains(where: { line in line.cells.contains(where: { $0.subview == cell.subview } )})}
        for remainedCell in remainedCells {
            remainedCell.subview.place(at: .zero, proposal: ProposedViewSize.zero)
        }
    }
    
    private func getMaxLine(size: CGSize) -> Int {
        let remainHeight = max(0, size.height-(dateCellConfig.titleHeight+eventCellConfig.height))
        let minimumCellSpace = eventCellConfig.height+spacing
        return Int(remainHeight/minimumCellSpace)+1
    }
    
    private func getAvaliableLine(cell: LineCache.CellCache, lines: [LineCache], maxLine: Int) -> Int? {
        let includedLines = lines.filter { line in
            line.cells.contains(where: { lineCell in lineCell.isPositionContained(position: cell.position) })
        }
        let isPositionExit = !includedLines.isEmpty
        guard isPositionExit else { return 0 }
        let isOverflow = includedLines.count >= maxLine
        if isOverflow {
            guard let availableLine = includedLines.sorted(by: { $0.maxX < $1.maxX }).first else { return nil }
            let hasSpaceAvailable = availableLine.maxX <= cell.maxX
            if hasSpaceAvailable {
                // 여유공간이 있는 라인에 추가
                return availableLine.line
            } else {
                return nil
            }
        } else {
            // 새로운 라인에 추가
            return includedLines.count
        }
    }
    
    private func getAvailablePosition(line: LineCache, cell: LineCache.CellCache) -> CGPoint {
        let isPositionContained = line.cells.contains(where: { lineCell in lineCell.isPositionContained(position: cell.position) })
        
        if isPositionContained {
            return CGPoint(x: line.maxX, y: .zero)
        } else {
            return CGPoint(x: cell.position.x, y: .zero)
        }
    }
    
    private func getAvailableSize(line: LineCache, cell: LineCache.CellCache) -> CGSize {
        let isPositionContained = line.cells.contains(where: { lineCell in
            lineCell.isPositionContained(position: cell.position)
        })
        
        if isPositionContained {
            let avaiilableWidth = cell.maxX-line.maxX
            return CGSize(width: avaiilableWidth, height: cell.size.height)
        } else {
            return cell.size
        }
    }
    
    private func getDefaultCells(size: CGSize, subviews: Subviews) -> [LineCache.CellCache] {
        subviews.compactMap { subview in
            guard let data = subview[EventDateLayoutData.self] else { return nil }
            return LineCache.CellCache(subview: subview,
                                       data: data,
                                       position: getRequiredCellPosition(size: size, data: data),
                                       size: getCellSize(size: size, data: data))
        }
    }
    
    private func getRequiredCellPosition(size: CGSize, data: EventDateLayoutData) -> CGPoint {
        let calendar = Calendar.current
        let cellStartAt = max(calendar.startOfDay(for: data.startAt), startAt)
        let dayDifference = calendar.dateComponents([.day], from: startAt, to: cellStartAt).day ?? 0
        let dayCellWidth = getDayCellWidth(size: size)
        let xPosition = CGFloat(dayDifference)*dayCellWidth
        return CGPoint(x: xPosition, y: .zero)
    }
    
    private func getCellSize(size: CGSize, data: EventDateLayoutData) -> CGSize {
        let calendar = Calendar.current
        let cellStartAt = max(calendar.startOfDay(for: data.startAt), startAt)
        let cellEndAt = min(calendar.startOfDay(for: data.endAt), endAt)
        guard let duration = calendar.dateComponents([.day], from: cellStartAt, to: cellEndAt).day else { return .zero }
        let dayCellWidth = getDayCellWidth(size: size)
        let cellWidth = CGFloat(duration+1)*dayCellWidth
        return CGSize(width: cellWidth, height: eventCellConfig.height)
    }
    
    private func getDayCellWidth(size: CGSize) -> CGFloat {
        size.width/7
    }
}

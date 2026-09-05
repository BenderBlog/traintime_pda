// Copyright 2026 Traintime PDA Authors.
// SPDX-License-Identifier: MPL-2.0

import Foundation

/// 当前日期的卡片布局采样。
///
/// 只记录不随滚动位置变化的高度，表冠每帧不需要重新传递 frame。
struct DayCourseLayoutMetrics: Equatable {
    var cardHeights: [String: CGFloat] = [:]
}

/// 日视图卡片高度持久化格式。
private struct PersistedDayCourseLayoutCache: Codable, Sendable {
    let schemaVersion: Int
    let signature: String
    let cardHeights: [String: Double]
}

enum DayCourseLayoutCacheConfiguration {
    static let schemaVersion = 1
    static let persistenceDelayNanoseconds: UInt64 = 1_500_000_000
}

/// 保存日视图已经测量的卡片高度，但不发布变化，避免重绘父页面。
///
/// 相邻页在进入屏幕前就完成采样；横向跨页时只切换当前日期指针，不再临时
/// 挂载一组测量视图。缓存是普通引用状态，不会让表冠每个像素都触发父页面
/// 更新。高度按当前快照修订、语言、内容宽度及动态字体环境持久化；任何
/// 条件变化都舍弃旧值，避免局部同步或字号变化后仍用旧高度计算位移。
@MainActor
final class DayCourseLayoutTracker {
    private let defaults: UserDefaults
    private var metrics = DayCourseLayoutMetrics()
    private var activeSignature: String?
    private var persistenceTask: Task<Void, Never>?
    private var persistenceDirty = false
    private var persistenceSuspended = false
    private var cacheGeneration = 0

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func update(metrics: DayCourseLayoutMetrics) {
        var changed = false
        for (courseID, height) in metrics.cardHeights {
            guard height.isFinite, height > 0 else { continue }
            let normalizedHeight = max(1, height)
            if let oldHeight = self.metrics.cardHeights[courseID],
                abs(oldHeight - normalizedHeight) <= 0.25
            {
                continue
            }
            self.metrics.cardHeights[courseID] = normalizedHeight
            changed = true
        }
        if changed {
            persistenceDirty = true
            schedulePersistence()
        }
    }

    /// 按当前课表和布局环境恢复磁盘缓存；签名相同的重复调用没有开销。
    func configure(signature: String) {
        let generation = defaults.integer(forKey: WatchPersistentCacheKey.invalidationGeneration)
        guard activeSignature != signature || cacheGeneration != generation else { return }
        cacheGeneration = generation
        persistenceTask?.cancel()
        persistenceTask = nil
        persistenceDirty = false
        activeSignature = signature
        metrics = DayCourseLayoutMetrics()

        guard
            let cache = try? WatchCacheCoding.load(
                PersistedDayCourseLayoutCache.self,
                key: WatchPersistentCacheKey.dayCourseLayout,
                defaults: defaults
            ),
            cache.schemaVersion
                == DayCourseLayoutCacheConfiguration.schemaVersion,
            cache.signature == signature
        else {
            return
        }
        metrics.cardHeights = cache.cardHeights.filter { $0.value.isFinite && $0.value > 0 }
            .mapValues { value in
                CGFloat(value)
            }
    }

    /// 交互期间不排队新的编码和写盘；已启动的后台编码不能提交旧结果。
    func suspendPersistence() {
        persistenceSuspended = true
        persistenceTask?.cancel()
        persistenceTask = nil
    }

    /// 页面停止交互后再补写尚未落盘的测量值。
    func resumePersistence() {
        persistenceSuspended = false
        guard persistenceDirty else { return }
        schedulePersistence()
    }

    /// 合并相邻三页测量结果后延迟写盘，连续翻页期间绝不执行磁盘编码。
    private func schedulePersistence() {
        guard !persistenceSuspended else { return }
        persistenceTask?.cancel()
        persistenceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(
                nanoseconds: DayCourseLayoutCacheConfiguration
                    .persistenceDelayNanoseconds
            )
            guard !Task.isCancelled else { return }
            await self?.persist()
        }
    }

    /// 在后台编码高度缓存，回到主线程后再原子写入最新签名的数据。
    private func persist() async {
        guard let activeSignature, !metrics.cardHeights.isEmpty else { return }
        let cache = PersistedDayCourseLayoutCache(
            schemaVersion: DayCourseLayoutCacheConfiguration.schemaVersion,
            signature: activeSignature,
            cardHeights: metrics.cardHeights.mapValues { value in
                Double(value)
            }
        )
        do {
            let data = try await Task.detached(priority: .utility) {
                try WatchCacheCoding.encode(cache)
            }.value
            guard !Task.isCancelled,
                !persistenceSuspended,
                self.activeSignature == activeSignature,
                cacheGeneration
                    == defaults.integer(forKey: WatchPersistentCacheKey.invalidationGeneration)
            else { return }
            WatchCacheCoding.persist(
                data,
                key: WatchPersistentCacheKey.dayCourseLayout,
                defaults: defaults
            )
        } catch {
            return
        }
        persistenceDirty = false
        persistenceTask = nil
    }

    deinit { persistenceTask?.cancel() }

    /// 将连续的“课程索引”插值成内容纵向位移。
    ///
    /// 使用每张卡片的真实高度而不是猜测固定高度，课程名换行、
    /// 考试座位等内容导致卡片高度不同时也不会在提交下一项时跳动。
    func contentOffset(
        for position: Double,
        courses: [WatchCourse],
        spacing: CGFloat
    ) -> CGFloat {
        guard courses.count > 1 else { return 0 }
        let boundedPosition = min(
            Double(courses.count - 1),
            max(0, position)
        )
        let lowerIndex = Int(floor(boundedPosition))
        let upperIndex = min(courses.count - 1, lowerIndex + 1)
        let fraction = CGFloat(boundedPosition - Double(lowerIndex))
        let fallbackHeight = averageMeasuredHeight ?? 72
        let offsets = courseTopOffsets(
            courses: courses,
            spacing: spacing,
            fallbackHeight: fallbackHeight
        )
        return offsets[lowerIndex]
            + (offsets[upperIndex] - offsets[lowerIndex]) * fraction
    }

    /// 把统一的内容纵向偏移反算成连续课程位置。
    ///
    /// 手指和表冠都通过这一坐标互相接续：手指拖动不再维护一套独立的
    /// ScrollView 锚点，放手后表冠会从屏幕当前所见位置继续移动。
    func position(
        forContentOffset contentOffset: CGFloat,
        courses: [WatchCourse],
        spacing: CGFloat
    ) -> Double {
        guard courses.count > 1 else { return 0 }
        let offsets = courseTopOffsets(
            courses: courses,
            spacing: spacing,
            fallbackHeight: averageMeasuredHeight ?? 72
        )
        guard let first = offsets.first,
            let last = offsets.last
        else {
            return 0
        }
        if contentOffset >= first { return 0 }
        if contentOffset <= last { return Double(courses.count - 1) }

        for lowerIndex in 0..<(offsets.count - 1) {
            let upperOffset = offsets[lowerIndex]
            let lowerOffset = offsets[lowerIndex + 1]
            guard contentOffset <= upperOffset,
                contentOffset >= lowerOffset
            else {
                continue
            }
            let distance = upperOffset - lowerOffset
            let fraction =
                distance > 0
                ? (upperOffset - contentOffset) / distance
                : 0
            return Double(lowerIndex) + Double(fraction)
        }
        return 0
    }

    /// 当前卡片栈的真实内容高度，用于触摸结束后的底边贴合。
    func contentHeight(
        courses: [WatchCourse],
        spacing: CGFloat
    ) -> CGFloat {
        guard !courses.isEmpty else { return 0 }
        let fallbackHeight = averageMeasuredHeight ?? 72
        let cardHeight = courses.reduce(CGFloat.zero) { partial, course in
            partial + (metrics.cardHeights[course.id] ?? fallbackHeight)
        }
        return cardHeight + CGFloat(max(0, courses.count - 1)) * spacing
    }

    /// 以第一张卡片为原点，计算每张卡片顶边对应的内容偏移。
    private func courseTopOffsets(
        courses: [WatchCourse],
        spacing: CGFloat,
        fallbackHeight: CGFloat
    ) -> [CGFloat] {
        var result = [CGFloat]()
        result.reserveCapacity(courses.count)
        var accumulatedHeight: CGFloat = 0
        for course in courses {
            result.append(-accumulatedHeight)
            accumulatedHeight += (metrics.cardHeights[course.id] ?? fallbackHeight) + spacing
        }
        return result
    }

    /// 首帧采样未完成时使用已有卡片的平均高度作为短暂回退。
    private var averageMeasuredHeight: CGFloat? {
        guard !metrics.cardHeights.isEmpty else { return nil }
        return metrics.cardHeights.values.reduce(0, +)
            / CGFloat(metrics.cardHeights.count)
    }
}

package org.cgsdream.recos.root.widget

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.*
import androidx.compose.ui.platform.InspectorInfo
import androidx.compose.ui.platform.InspectorValueInfo
import androidx.compose.ui.platform.debugInspectorInfo
import androidx.compose.ui.unit.Constraints
import androidx.compose.ui.unit.Density

enum class JustifyContent {
    FlexStart,
    FlexEnd,
    Center,
    SpaceBetween,
    SpaceAround,
    SpaceEvenly
}

enum class AlignItems {
    FlexStart,
    FlexEnd,
    Center,
    Baseline,
    Stretch
}

enum class AlignContent {
    FlexStart,
    FlexEnd,
    Center,
    SpaceBetween,
    SpaceAround,
    SpaceEvenly,
    Stretch
}

enum class AlignSelf {
    Auto,
    FlexStart,
    FlexEnd,
    Center,
    Baseline,
    Stretch
}

enum class FlexWrap {
    Wrap,
    WrapReverse,
    NoWrap
}

enum class FlexDirection {
    Row,
    RowReverse,
    Column,
    ColumnReverse
}

@Composable
fun FlexBox(
    modifier: Modifier = Modifier,
    flexDirection: FlexDirection = FlexDirection.Column,
    justifyContent: JustifyContent = JustifyContent.FlexStart,
    alignItems: AlignItems = AlignItems.FlexStart,
    alignContent: AlignContent = AlignContent.FlexStart,
    flexWrap: FlexWrap = FlexWrap.NoWrap,
    content: @Composable FlexScope.() -> Unit
) {
    val measurePolicy = flexBoxMeasurePolicy(flexDirection, justifyContent, alignItems, alignContent, flexWrap)
    Layout(
        content = { FlexScope.content() },
        measurePolicy = measurePolicy,
        modifier = modifier
    )
}

interface FlexScope {
    companion object : FlexScope {
        var ORDER_DEFAULT = 1
        var FLEX_GROW_DEFAULT = 0f
        var FLEX_SHRINK_DEFAULT = 1f
        var FLEX_SHRINK_NOT_SET = 0f
        var FLEX_BASIS_PERCENT_DEFAULT = -1f
    }

    fun Modifier.order(order: Int) = this.then(
        FlexItemOrderModifier(
            order = order,
            inspectorInfo = debugInspectorInfo {
                name = "order"
                value = order
            }
        )
    )

    fun Modifier.flex(
        grow: Float,
        shrink: Float = FLEX_SHRINK_DEFAULT,
        basis: Float = FLEX_BASIS_PERCENT_DEFAULT
    ) = this.then(
        FlexItemFlexModifier(
            grow = grow,
            shrink = shrink,
            basis = basis,
            inspectorInfo = debugInspectorInfo {
                name = "flex"
                value = "$grow $shrink $basis"
            }
        )
    )

    fun Modifier.alignSelf(alignSelf: AlignSelf) = this.then(
        FlexItemAlignSelfModifier(
            alignSelf = alignSelf,
            inspectorInfo = debugInspectorInfo {
                name = "alignSelf"
                value = alignSelf
            }
        )
    )

    fun Modifier.wrapBefore(wrapBefore: Boolean) = this.then(
        FlexItemWrapBeforeModifier(
            wrapBefore = wrapBefore,
            inspectorInfo = debugInspectorInfo {
                name = "wrapBefore"
                value = wrapBefore
            }
        )
    )
}

/**
 * Parent data associated with children.
 */
internal data class FlexItemParentData(
    var order: Int = FlexScope.ORDER_DEFAULT,
    var flexGrow: Float = FlexScope.FLEX_GROW_DEFAULT,
    var flexShrink: Float = FlexScope.FLEX_SHRINK_DEFAULT,
    var alignSelf: AlignSelf = AlignSelf.Auto,
    var flexBasisPercent: Float = FlexScope.FLEX_BASIS_PERCENT_DEFAULT,
    var wrapBefore: Boolean = false
)

internal val IntrinsicMeasurable.data: FlexItemParentData?
    get() = parentData as? FlexItemParentData

internal val FlexItemParentData?.order: Int
    get() = this?.order ?: FlexScope.ORDER_DEFAULT

internal val FlexItemParentData?.flexGrow: Float
    get() = this?.flexGrow ?: FlexScope.FLEX_GROW_DEFAULT

internal val FlexItemParentData?.flexShrink: Float
    get() = this?.flexShrink ?: FlexScope.FLEX_SHRINK_DEFAULT

internal val FlexItemParentData?.alignSelf: AlignSelf
    get() = this?.alignSelf ?: AlignSelf.Auto

internal val FlexItemParentData?.flexBasisPercent: Float
    get() = this?.flexBasisPercent ?: FlexScope.FLEX_BASIS_PERCENT_DEFAULT

internal val FlexItemParentData?.wrapBefore: Boolean
    get() = this?.wrapBefore ?: false

internal class FlexItemOrderModifier(
    var order: Int,
    inspectorInfo: InspectorInfo.() -> Unit
) : ParentDataModifier, InspectorValueInfo(inspectorInfo) {
    override fun Density.modifyParentData(parentData: Any?): FlexItemParentData {
        return ((parentData as? FlexItemParentData) ?: FlexItemParentData()).also {
            it.order = order
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        val otherModifier = other as? FlexItemParentData ?: return false
        return order == otherModifier.order
    }

    override fun hashCode(): Int = order.hashCode()

    override fun toString(): String =
        "FlexItemOrderModifier(order=$order)"
}

internal class FlexItemFlexModifier(
    var grow: Float,
    var shrink: Float,
    var basis: Float,
    inspectorInfo: InspectorInfo.() -> Unit
) : ParentDataModifier, InspectorValueInfo(inspectorInfo) {
    override fun Density.modifyParentData(parentData: Any?): FlexItemParentData {
        return ((parentData as? FlexItemParentData) ?: FlexItemParentData()).also {
            it.flexGrow = grow
            it.flexShrink = shrink
            it.flexBasisPercent = basis
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        val otherModifier = other as? FlexItemFlexModifier ?: return false
        return grow == otherModifier.grow && shrink == other.shrink && basis == other.basis
    }

    override fun hashCode(): Int {
        var result = grow.hashCode()
        result = 31 * result + shrink.hashCode()
        result = 31 * result + basis.hashCode()
        return result
    }

    override fun toString(): String =
        "FlexItemFlexModifier(grow=$grow, shrink=$shrink, basis=$basis)"
}

internal class FlexItemAlignSelfModifier(
    var alignSelf: AlignSelf,
    inspectorInfo: InspectorInfo.() -> Unit
) : ParentDataModifier, InspectorValueInfo(inspectorInfo) {
    override fun Density.modifyParentData(parentData: Any?): FlexItemParentData {
        return ((parentData as? FlexItemParentData) ?: FlexItemParentData()).also {
            it.alignSelf = alignSelf
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        val otherModifier = other as? FlexItemAlignSelfModifier ?: return false
        return alignSelf == otherModifier.alignSelf
    }

    override fun hashCode(): Int = alignSelf.hashCode()

    override fun toString(): String =
        "FlexItemAlignSelfModifier(alignSelf=$alignSelf)"
}

internal class FlexItemWrapBeforeModifier(
    var wrapBefore: Boolean,
    inspectorInfo: InspectorInfo.() -> Unit
) : ParentDataModifier, InspectorValueInfo(inspectorInfo) {
    override fun Density.modifyParentData(parentData: Any?): FlexItemParentData {
        return ((parentData as? FlexItemParentData) ?: FlexItemParentData()).also {
            it.wrapBefore = wrapBefore
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        val otherModifier = other as? FlexItemWrapBeforeModifier ?: return false
        return wrapBefore == otherModifier.wrapBefore
    }

    override fun hashCode(): Int = wrapBefore.hashCode()

    override fun toString(): String =
        "FlexItemWrapBeforeModifier(wrapBefore=$wrapBefore)"
}


private class FlexLine(var startIndex: Int) {
    var mainTotalSize = 0
    var maxCrossSize = 0
    var itemCount = 0
    var totalFlexGrow = 0f
    var totalFlexShrink = 0f
    var maxBaseline = 0
    var sumCrossSizeBefore = 0
    var anyItemsHaveFlexGrow = false
    var anyItemsHaveFlexShrink = false

    fun handleAlignItems(item: FlexItem, alignItems: AlignItems) {
        val alignSelf = item.measurable.data.alignSelf
        if (alignSelf != AlignSelf.Auto) {
            when (alignSelf) {
                AlignSelf.FlexEnd -> {
                    item.crossStart = maxCrossSize - item.intrinsicsCrossSize
                }
                AlignSelf.Center, AlignSelf.Baseline -> {
                    item.crossStart = (maxCrossSize - item.intrinsicsCrossSize) / 2
                }
                AlignSelf.Stretch -> {
                    item.intrinsicsCrossSize = maxCrossSize
                    item.crossStart = 0
                }
                else -> {
                    item.crossStart = 0
                }
            }
        } else {
            when (alignItems) {
                AlignItems.FlexEnd -> {
                    item.crossStart = maxCrossSize - item.intrinsicsCrossSize
                }
                AlignItems.Center, AlignItems.Baseline -> {
                    item.crossStart = (maxCrossSize - item.intrinsicsCrossSize) / 2
                }
                AlignItems.Stretch -> {
                    item.intrinsicsCrossSize = maxCrossSize
                    item.crossStart = 0
                }
                else -> {
                    item.crossStart = 0
                }
            }
        }
    }
}

private class FlexItem(val measurable: Measurable) {
    var intrinsicsMainSize: Int = 0
    var intrinsicsCrossSize: Int = 0
    var mainStart: Int = 0
    var crossStart: Int = 0
    var placeable: Placeable? = null

    fun measure(isRow: Boolean) {
        placeable = measurable.measure(
            Constraints.fixed(
                if (isRow) intrinsicsMainSize else intrinsicsCrossSize,
                if (isRow) intrinsicsCrossSize else intrinsicsMainSize
            )
        )
    }
}

@Composable
internal fun flexBoxMeasurePolicy(
    flexDirection: FlexDirection,
    justifyContent: JustifyContent,
    alignItems: AlignItems,
    alignContent: AlignContent,
    flexWrap: FlexWrap
) = remember(flexDirection, justifyContent, alignItems, alignContent, flexWrap) {
    MeasurePolicy { measurables, constraints ->
        val isRow = flexDirection == FlexDirection.Row || flexDirection == FlexDirection.RowReverse
        val constraintsMainMaxSize = if (isRow) constraints.maxWidth else constraints.maxHeight
        val constraintsCrossMaxSize = if (isRow) constraints.maxHeight else constraints.maxWidth
        val constraintsMainMinSize = if (isRow) constraints.minWidth else constraints.minHeight
        val constraintsCrossMinSize = if (isRow) constraints.minHeight else constraints.minWidth
        val isMainAxisBounded = if (isRow) constraints.hasBoundedWidth else constraints.hasBoundedHeight
        val isCrossAxisBounded = if (isRow) constraints.hasBoundedHeight else constraints.hasBoundedWidth
        val isMainAxisFixed = if (isRow) constraints.hasFixedWidth else constraints.hasFixedHeight
        val isCrossAxisFixed = if (isRow) constraints.hasFixedHeight else constraints.hasFixedWidth

        val orderedFlexItems = measurables.sortedBy { it.data.order }.map { FlexItem(it) }
        val flexParentData = Array(orderedFlexItems.size) { orderedFlexItems[it].measurable.data }
        val flexLines = arrayListOf<FlexLine>()
        var measuredMaxMainSize = 0
        var measuredMaxCrossSize = 0

        fun FlexLine.shouldWrap(flexParentData: FlexItemParentData?, nextMainSize: Int): Boolean {
            if (flexParentData.wrapBefore) {
                return true
            }
            if (flexWrap == FlexWrap.NoWrap) {
                return false
            }
            return mainTotalSize + nextMainSize > constraintsMainMaxSize
        }

        fun addFlexLine(flexLine: FlexLine, itemCount: Int) {
            if (itemCount > 0) {
                measuredMaxCrossSize += flexLine.maxCrossSize
                flexLine.itemCount = itemCount
                measuredMaxMainSize = measuredMaxMainSize.coerceAtLeast(flexLine.mainTotalSize)
                flexLines.add(flexLine)
            }
        }


        var flexLine = FlexLine(0)
        for (i in orderedFlexItems.indices) {
            val flexItem = orderedFlexItems[i]
            val parentData = flexParentData[i]
            if (parentData.flexBasisPercent != FlexScope.FLEX_BASIS_PERCENT_DEFAULT && isMainAxisBounded) {
                val mainSize = (parentData.flexBasisPercent * constraintsMainMaxSize).toInt()
                flexItem.intrinsicsMainSize = mainSize
                if (isRow) {
                    flexItem.intrinsicsCrossSize = flexItem.measurable.minIntrinsicHeight(mainSize)
                } else {
                    flexItem.intrinsicsCrossSize = flexItem.measurable.minIntrinsicWidth(mainSize)
                }
            } else {
                if (isRow) {
                    flexItem.intrinsicsMainSize = flexItem.measurable.maxIntrinsicWidth(constraintsCrossMinSize).coerceAtMost(constraintsMainMaxSize)
                    flexItem.intrinsicsCrossSize = flexItem.measurable.minIntrinsicHeight(flexItem.intrinsicsMainSize)
                } else {
                    flexItem.intrinsicsMainSize = flexItem.measurable.maxIntrinsicHeight(constraintsCrossMinSize).coerceAtMost(constraintsMainMaxSize)
                    flexItem.intrinsicsCrossSize = flexItem.measurable.minIntrinsicWidth(flexItem.intrinsicsMainSize)
                }
            }

            if (flexLine.shouldWrap(parentData, flexItem.intrinsicsMainSize)) {
                addFlexLine(flexLine, i - flexLine.startIndex)
                flexLine = FlexLine(i)
                flexLine.sumCrossSizeBefore = measuredMaxCrossSize
            }
            flexLine.totalFlexShrink += parentData.flexShrink
            flexLine.totalFlexGrow += parentData.flexGrow
            flexLine.anyItemsHaveFlexGrow =
                flexLine.anyItemsHaveFlexGrow or (parentData.flexGrow != FlexScope.FLEX_GROW_DEFAULT)
            flexLine.anyItemsHaveFlexShrink =
                flexLine.anyItemsHaveFlexShrink or (parentData.flexShrink != FlexScope.FLEX_SHRINK_NOT_SET)
            flexLine.mainTotalSize += flexItem.intrinsicsMainSize
            flexLine.maxCrossSize = flexLine.maxCrossSize.coerceAtLeast(flexItem.intrinsicsCrossSize)
        }
        if (orderedFlexItems.size > flexLine.startIndex) {
            addFlexLine(flexLine, orderedFlexItems.size - flexLine.startIndex)
        }

        if (isMainAxisBounded) {
            flexLines.forEach {
                if (constraintsMainMaxSize > it.mainTotalSize && it.anyItemsHaveFlexGrow) {
                    val spaceRemain = constraintsMainMaxSize - it.mainTotalSize
                    val growTotal = it.totalFlexGrow
                    val growCell = spaceRemain / growTotal
                    for (j in 0 until it.itemCount) {
                        val flexGrow = flexParentData[it.startIndex + j].flexGrow
                        if (flexGrow != FlexScope.FLEX_GROW_DEFAULT) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.intrinsicsMainSize += (growCell * flexGrow).toInt()
                            if (isRow) {
                                item.intrinsicsCrossSize = item.measurable.minIntrinsicHeight(item.intrinsicsMainSize)
                            } else {
                                item.intrinsicsCrossSize = item.measurable.minIntrinsicWidth(item.intrinsicsMainSize)
                            }
                        }
                    }
                    it.mainTotalSize = constraintsMainMaxSize
                    measuredMaxMainSize = constraintsMainMaxSize
                } else if (constraintsMainMaxSize < it.mainTotalSize && it.anyItemsHaveFlexShrink) {
                    val shrinkExtra = it.mainTotalSize - constraintsMainMaxSize
                    val shrinkTotal = it.totalFlexShrink
                    val shrinkCell = shrinkExtra / shrinkTotal
                    for (j in 0 until it.itemCount) {
                        val flexShrink = flexParentData[it.startIndex + j].flexShrink
                        if (flexShrink != FlexScope.FLEX_SHRINK_NOT_SET) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.intrinsicsMainSize = 0.coerceAtLeast(item.intrinsicsMainSize - (shrinkCell * flexShrink).toInt())
                            if (isRow) {
                                item.intrinsicsCrossSize = item.measurable.minIntrinsicHeight(item.intrinsicsMainSize)
                            } else {
                                item.intrinsicsCrossSize = item.measurable.minIntrinsicWidth(item.intrinsicsMainSize)
                            }
                        }
                    }
                    it.mainTotalSize = constraintsMainMaxSize
                    measuredMaxMainSize = constraintsMainMaxSize
                }
            }
        }

        val justifyContentMainSize = if (isMainAxisFixed) constraintsMainMaxSize else measuredMaxMainSize.coerceAtMost(constraintsMainMaxSize)
        flexLines.forEach {
            if (it.mainTotalSize < justifyContentMainSize) {
                val spaceRemain = justifyContentMainSize - it.mainTotalSize
                when (justifyContent) {
                    JustifyContent.Center -> {
                        var start = spaceRemain / 2
                        for (j in 0 until it.itemCount) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.mainStart = start
                            start += item.intrinsicsMainSize
                        }
                    }
                    JustifyContent.FlexEnd -> {
                        var start = spaceRemain
                        for (j in 0 until it.itemCount) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.mainStart = start
                            start += item.intrinsicsMainSize
                        }
                    }
                    JustifyContent.SpaceBetween -> {
                        if (it.itemCount > 1) {
                            val spaceCount = it.itemCount - 1
                            val spaceSize = spaceRemain / spaceCount
                            var start = 0
                            for (j in 0 until it.itemCount) {
                                val item = orderedFlexItems[it.startIndex + j]
                                item.mainStart = start
                                start += item.intrinsicsMainSize + spaceSize
                            }
                        }
                    }
                    JustifyContent.SpaceAround -> {
                        val spaceCount = it.itemCount * 2
                        val spaceSize = spaceRemain / spaceCount
                        var start = spaceSize
                        for (j in 0 until it.itemCount) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.mainStart = start
                            start += item.intrinsicsMainSize + spaceSize * 2
                        }
                    }
                    JustifyContent.SpaceEvenly -> {
                        val spaceCount = it.itemCount + 1
                        val spaceSize = spaceRemain / spaceCount
                        var start = spaceSize
                        for (j in 0 until it.itemCount) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.mainStart = start
                            start += item.intrinsicsMainSize + spaceSize
                        }
                    }
                    else -> {
                        var start = 0
                        for (j in 0 until it.itemCount) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.mainStart = start
                            start += item.intrinsicsMainSize
                        }
                    }
                }
            } else {
                var start = 0
                for (j in 0 until it.itemCount) {
                    val item = orderedFlexItems[it.startIndex + j]
                    item.mainStart = start
                    start += item.intrinsicsMainSize
                }
            }
        }

        if (isCrossAxisFixed && measuredMaxCrossSize < constraintsCrossMaxSize) {
            val spaceRemain = constraintsCrossMaxSize - measuredMaxCrossSize
            if (flexLines.size > 1) {
                when (alignContent) {
                    AlignContent.FlexEnd, AlignContent.Center -> {
                        var sumCrossSizeBefore = if (alignContent == AlignContent.FlexEnd) spaceRemain else (spaceRemain / 2)
                        for (i in flexLines.indices) {
                            flexLines[i].sumCrossSizeBefore = sumCrossSizeBefore
                            sumCrossSizeBefore += flexLines[i].maxCrossSize
                        }
                    }
                    AlignContent.SpaceBetween -> {
                        val spaceCount = flexLines.size - 1
                        val spaceSize = spaceRemain / spaceCount
                        var sumCrossSizeBefore = 0
                        for (i in flexLines.indices) {
                            flexLines[i].sumCrossSizeBefore = sumCrossSizeBefore
                            sumCrossSizeBefore += flexLines[i].maxCrossSize + spaceSize
                        }
                    }
                    AlignContent.SpaceAround -> {
                        val spaceCount = flexLines.size * 2
                        val spaceSize = spaceRemain / spaceCount
                        var sumCrossSizeBefore = spaceSize
                        for (i in flexLines.indices) {
                            flexLines[i].sumCrossSizeBefore = sumCrossSizeBefore
                            sumCrossSizeBefore += flexLines[i].maxCrossSize + spaceSize * 2
                        }
                    }
                    AlignContent.SpaceEvenly -> {
                        val spaceCount = flexLines.size + 1
                        val spaceSize = spaceRemain / spaceCount
                        var sumCrossSizeBefore = spaceSize
                        for (i in flexLines.indices) {
                            flexLines[i].sumCrossSizeBefore = sumCrossSizeBefore
                            sumCrossSizeBefore += flexLines[i].maxCrossSize + spaceSize
                        }
                    }
                    AlignContent.Stretch -> {
                        val expendSize = spaceRemain / flexLines.size
                        var sumCrossSizeBefore = 0
                        for (i in flexLines.indices) {
                            val flexLine = flexLines[i]
                            flexLine.sumCrossSizeBefore = sumCrossSizeBefore
                            flexLine.maxCrossSize += expendSize
                            for (j in 0 until flexLine.itemCount) {
                                orderedFlexItems[flexLine.startIndex + j].intrinsicsCrossSize = flexLine.maxCrossSize
                            }
                            sumCrossSizeBefore += flexLines[i].maxCrossSize
                        }
                    }
                    else -> {
                        // do nothing.
                    }
                }
            } else {
                flexLines.getOrNull(0)?.maxCrossSize = constraintsCrossMaxSize
            }
        }

        flexLines.forEach {
            for (j in 0 until it.itemCount) {
                val item = orderedFlexItems[it.startIndex + j]
                it.handleAlignItems(item, alignItems)
                item.measure(isRow)
            }
        }

        val layoutWidth = if (constraints.hasFixedWidth) {
            constraints.maxWidth
        } else constraints.minWidth.coerceAtLeast(
            if (isRow) measuredMaxMainSize else measuredMaxCrossSize
        )
        val layoutHeight = if (constraints.hasFixedHeight) {
            constraints.maxHeight
        } else constraints.minWidth.coerceAtLeast(
            if (isRow) measuredMaxCrossSize else measuredMaxMainSize
        )
        layout(layoutWidth, layoutHeight) {
            when (flexDirection) {
                FlexDirection.Row -> {
                    flexLines.forEach { flexLine ->
                        for (i in 0 until flexLine.itemCount) {
                            val item = orderedFlexItems[flexLine.startIndex + i]
                            item.placeable?.place(item.mainStart, flexLine.sumCrossSizeBefore + item.crossStart)
                        }
                    }
                }
                FlexDirection.RowReverse -> {
                    flexLines.forEach { flexLine ->
                        for (i in 0 until flexLine.itemCount) {
                            val item = orderedFlexItems[flexLine.startIndex + i]
                            item.placeable?.place(
                                layoutWidth - item.mainStart - item.intrinsicsMainSize,
                                flexLine.sumCrossSizeBefore + item.crossStart
                            )
                        }
                    }
                }
                FlexDirection.Column -> {
                    flexLines.forEach { flexLine ->
                        for (i in 0 until flexLine.itemCount) {
                            val item = orderedFlexItems[flexLine.startIndex + i]
                            item.placeable?.place(flexLine.sumCrossSizeBefore + item.crossStart, item.mainStart)
                        }
                    }
                }
                FlexDirection.ColumnReverse -> {
                    flexLines.forEach { flexLine ->
                        for (i in 0 until flexLine.itemCount) {
                            val item = orderedFlexItems[flexLine.startIndex + i]
                            item.placeable?.place(
                                flexLine.sumCrossSizeBefore + item.crossStart,
                                layoutHeight - item.mainStart - item.intrinsicsMainSize
                            )
                        }
                    }
                }
            }
        }
    }
}
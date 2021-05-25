package org.cgsdream.recos.root.widget

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.Layout
import androidx.compose.ui.layout.Measurable
import androidx.compose.ui.layout.MeasurePolicy
import androidx.compose.ui.layout.Placeable

/**
 * Do not support shrink, grow is used as weight
 * Do not support AlignItems.Stretch,AlignContent.Stretch,AlignSelf.Stretch
 */
@Composable
fun MiniFlexBox(
    modifier: Modifier = Modifier,
    flexDirection: FlexDirection = FlexDirection.Column,
    justifyContent: JustifyContent = JustifyContent.FlexStart,
    alignItems: AlignItems = AlignItems.FlexStart,
    alignContent: AlignContent = AlignContent.FlexStart,
    flexWrap: FlexWrap = FlexWrap.NoWrap,
    content: @Composable FlexScope.() -> Unit
) {
    val measurePolicy = miniFlexBoxMeasurePolicy(flexDirection, justifyContent, alignItems, alignContent, flexWrap)
    Layout(
        content = { FlexScope.content() },
        measurePolicy = measurePolicy,
        modifier = modifier
    )
}

private class MiniFlexItem(val measurable: Measurable) {
    var mainStart: Int = 0
    var crossStart: Int = 0
    lateinit var placeable: Placeable
}

private class MiniFlexLine(var startIndex: Int) {
    var mainTotalSize = 0
    var maxCrossSize = 0
    var itemCount = 0
    var maxBaseline = 0
    var sumCrossSizeBefore = 0

    fun handleAlignItems(item: MiniFlexItem, alignItems: AlignItems, isRow: Boolean) {
        val crossSize = if (isRow) item.placeable.height else item.placeable.width
        val alignSelf = item.measurable.data.alignSelf
        if (alignSelf != AlignSelf.Auto) {
            when (alignSelf) {
                AlignSelf.FlexEnd -> {
                    item.crossStart = maxCrossSize - crossSize
                }
                AlignSelf.Center, AlignSelf.Baseline -> {
                    item.crossStart = (maxCrossSize - crossSize) / 2
                }
                else -> {
                    item.crossStart = 0
                }
            }
        } else {
            when (alignItems) {
                AlignItems.FlexEnd -> {
                    item.crossStart = maxCrossSize - crossSize
                }
                AlignItems.Center, AlignItems.Baseline -> {
                    item.crossStart = (maxCrossSize - crossSize) / 2
                }
                else -> {
                    item.crossStart = 0
                }
            }
        }
    }
}

@Composable
internal fun miniFlexBoxMeasurePolicy(
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

        val orderedFlexItems = measurables.sortedBy { it.data.order }.map { MiniFlexItem(it) }
        val flexParentData = Array(orderedFlexItems.size) { orderedFlexItems[it].measurable.data }
        val flexLines = arrayListOf<MiniFlexLine>()
        var measuredMaxMainSize = 0
        var measuredMaxCrossSize = 0

        fun MiniFlexLine.shouldWrap(flexParentData: FlexItemParentData?, nextMainSize: Int): Boolean {
            if (flexWrap == FlexWrap.NoWrap) {
                return false
            }
            if (flexParentData.wrapBefore) {
                return true
            }
            return mainTotalSize + nextMainSize > constraintsMainMaxSize
        }

        fun addFlexLine(flexLine: MiniFlexLine, itemCount: Int) {
            if (itemCount > 0) {
                measuredMaxCrossSize += flexLine.maxCrossSize
                flexLine.itemCount = itemCount
                measuredMaxMainSize = measuredMaxMainSize.coerceAtLeast(flexLine.mainTotalSize)
                flexLines.add(flexLine)
            }
        }

        var flexLine = MiniFlexLine(0)
        if(flexWrap == FlexWrap.NoWrap){
            var totalGrow: Float = 0f
            val growList = arrayListOf<MiniFlexItem>()
            var usedSpace: Int = 0
            val normalChildConstraints = constraints.copy(minWidth = 0, minHeight = 0)
            for (i in orderedFlexItems.indices) {
                val flexItem = orderedFlexItems[i]
                val parentData = flexParentData[i]
                if(parentData.flexGrow > 0){
                    totalGrow += parentData.flexGrow
                    growList.add(flexItem)
                }else{
                    if (parentData.flexBasisPercent != FlexScope.FLEX_BASIS_PERCENT_DEFAULT && isMainAxisBounded) {
                        val mainSize = (parentData.flexBasisPercent * constraintsMainMaxSize).toInt()
                        if (isRow) {
                            flexItem.placeable = flexItem.measurable.measure(constraints.copy(minWidth = mainSize, maxWidth = mainSize, minHeight = 0))
                        } else {
                            flexItem.placeable = flexItem.measurable.measure(constraints.copy(minWidth = 0, minHeight = mainSize, maxHeight = mainSize))
                        }
                    } else {
                        flexItem.placeable = flexItem.measurable.measure(normalChildConstraints)

                    }
                    usedSpace += if(isRow) flexItem.placeable.width else flexItem.placeable.height
                    flexLine.mainTotalSize += if (isRow) flexItem.placeable.width else flexItem.placeable.height
                    flexLine.maxCrossSize = flexLine.maxCrossSize.coerceAtLeast(if (isRow) flexItem.placeable.height else flexItem.placeable.width)
                }
            }
            if(growList.size > 0){
                if(usedSpace < constraintsMainMaxSize){
                    val cell = (constraintsMainMaxSize - usedSpace) / totalGrow
                    growList.forEach { flexItem ->
                        val mainSize = (flexItem.measurable.data.flexGrow * cell).toInt()
                        if (isRow) {
                            flexItem.placeable = flexItem.measurable.measure(constraints.copy(minWidth = mainSize, maxWidth = mainSize, minHeight = 0))
                        } else {
                            flexItem.placeable = flexItem.measurable.measure(constraints.copy(minWidth = 0, minHeight = mainSize, maxHeight = mainSize))
                        }
                        flexLine.mainTotalSize += if (isRow) flexItem.placeable.width else flexItem.placeable.height
                        flexLine.maxCrossSize = flexLine.maxCrossSize.coerceAtLeast(if (isRow) flexItem.placeable.height else flexItem.placeable.width)
                    }
                }else{
                    growList.forEach { flexItem ->
                        flexItem.placeable = flexItem.measurable.measure(normalChildConstraints)
                        flexLine.mainTotalSize += if (isRow) flexItem.placeable.width else flexItem.placeable.height
                        flexLine.maxCrossSize = flexLine.maxCrossSize.coerceAtLeast(if (isRow) flexItem.placeable.height else flexItem.placeable.width)
                    }
                }
            }

        }else{
            val normalChildConstraints = constraints.copy(minWidth = 0, minHeight = 0)
            for (i in orderedFlexItems.indices) {
                val flexItem = orderedFlexItems[i]
                val parentData = flexParentData[i]
                if (parentData.flexBasisPercent != FlexScope.FLEX_BASIS_PERCENT_DEFAULT && isMainAxisBounded) {
                    val mainSize = (parentData.flexBasisPercent * constraintsMainMaxSize).toInt()
                    if (isRow) {
                        flexItem.placeable = flexItem.measurable.measure(constraints.copy(minWidth = mainSize, maxWidth = mainSize, minHeight = 0))
                    } else {
                        flexItem.placeable = flexItem.measurable.measure(constraints.copy(minWidth = 0, minHeight = mainSize, maxHeight = mainSize))
                    }
                } else {
                    flexItem.placeable = flexItem.measurable.measure(normalChildConstraints)

                }

                if (flexLine.shouldWrap(parentData, if (isRow) flexItem.placeable.width else flexItem.placeable.height)) {
                    addFlexLine(flexLine, i - flexLine.startIndex)
                    flexLine = MiniFlexLine(i)
                    flexLine.sumCrossSizeBefore = measuredMaxCrossSize
                }
                flexLine.mainTotalSize += if (isRow) flexItem.placeable.width else flexItem.placeable.height
                flexLine.maxCrossSize = flexLine.maxCrossSize.coerceAtLeast(if (isRow) flexItem.placeable.height else flexItem.placeable.width)
            }
        }

        if (orderedFlexItems.size > flexLine.startIndex) {
            addFlexLine(flexLine, orderedFlexItems.size - flexLine.startIndex)
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
                            start += if (isRow) item.placeable.width else item.placeable.height
                        }
                    }
                    JustifyContent.FlexEnd -> {
                        var start = spaceRemain
                        for (j in 0 until it.itemCount) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.mainStart = start
                            start += if (isRow) item.placeable.width else item.placeable.height
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
                                start += if (isRow) item.placeable.width else item.placeable.height + spaceSize
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
                            start += if (isRow) item.placeable.width else item.placeable.height + spaceSize * 2
                        }
                    }
                    JustifyContent.SpaceEvenly -> {
                        val spaceCount = it.itemCount + 1
                        val spaceSize = spaceRemain / spaceCount
                        var start = spaceSize
                        for (j in 0 until it.itemCount) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.mainStart = start
                            start += if (isRow) item.placeable.width else item.placeable.height + spaceSize
                        }
                    }
                    else -> {
                        var start = 0
                        for (j in 0 until it.itemCount) {
                            val item = orderedFlexItems[it.startIndex + j]
                            item.mainStart = start
                            start += if (isRow) item.placeable.width else item.placeable.height
                        }
                    }
                }
            } else {
                var start = 0
                for (j in 0 until it.itemCount) {
                    val item = orderedFlexItems[it.startIndex + j]
                    item.mainStart = start
                    start += if (isRow) item.placeable.width else item.placeable.height
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
                it.handleAlignItems(item, alignItems, isRow)
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
                            item.placeable.place(item.mainStart, flexLine.sumCrossSizeBefore + item.crossStart)
                        }
                    }
                }
                FlexDirection.RowReverse -> {
                    flexLines.forEach { flexLine ->
                        for (i in 0 until flexLine.itemCount) {
                            val item = orderedFlexItems[flexLine.startIndex + i]
                            item.placeable.place(
                                layoutWidth - item.mainStart - item.placeable.width,
                                flexLine.sumCrossSizeBefore + item.crossStart
                            )
                        }
                    }
                }
                FlexDirection.Column -> {
                    flexLines.forEach { flexLine ->
                        for (i in 0 until flexLine.itemCount) {
                            val item = orderedFlexItems[flexLine.startIndex + i]
                            item.placeable.place(flexLine.sumCrossSizeBefore + item.crossStart, item.mainStart)
                        }
                    }
                }
                FlexDirection.ColumnReverse -> {
                    flexLines.forEach { flexLine ->
                        for (i in 0 until flexLine.itemCount) {
                            val item = orderedFlexItems[flexLine.startIndex + i]
                            item.placeable.place(
                                flexLine.sumCrossSizeBefore + item.crossStart,
                                layoutHeight - item.mainStart - item.placeable.height
                            )
                        }
                    }
                }
            }
        }
    }
}
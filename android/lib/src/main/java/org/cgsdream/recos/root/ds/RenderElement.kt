package org.cgsdream.recos.root.ds

import android.util.Log
import androidx.compose.animation.Crossfade
import androidx.compose.animation.core.tween
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.scrollable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.GridCells
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.LazyVerticalGrid
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.SolidColor
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.TextUnit
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.skydoves.landscapist.glide.GlideImage
import org.cgsdream.recos.root.js.JsArray
import org.cgsdream.recos.root.js.JsObject
import org.cgsdream.recos.root.util.getAsBool
import org.cgsdream.recos.root.util.getAsFloat
import org.cgsdream.recos.root.util.getAsInt
import org.cgsdream.recos.root.util.getAsString
import org.cgsdream.recos.root.widget.*
import java.lang.StringBuilder

interface RenderElement {
    
    @Composable
    fun Render(parentModifier: ((Modifier, props: Map<String, Any?>) -> Modifier)?)
}

class JsxRenderElement(
    val jsEvaluator: JsEvaluator,
    val name: String,
    val props: Map<String, Any?>,
    val children: List<RenderElement>?
): RenderElement {

    @ExperimentalFoundationApi
    @Composable
    override fun Render(parentModifier: ((Modifier, props: Map<String, Any?>) -> Modifier)?) {
        when(name){
            "RecyclerView" -> {
                val count = props.getAsInt("count", 0)
                val isColumn = props["direction"] != "row"
                var modifier = Modifier.recosProps(jsEvaluator, props)
                if(parentModifier != null){
                    modifier = parentModifier.invoke(modifier, props)
                }
                if(isColumn){
                    LazyColumn(modifier = modifier) {
                        items(count, key = {
                            // TODO key
                            it
                        }, itemContent = { index ->
                            (props["render"] as? JsFunctionDecl)?.let { child ->
                                jsEvaluator.Eval(child, listOf(index))
                            }
                        })
                    }
                }else{
                    LazyRow(modifier = modifier) {
                        items(count, key = {
                            // TODO key
                            it
                        }, itemContent = { index ->
                            (props["render"] as? JsFunctionDecl)?.let { child ->
                                jsEvaluator.Eval(child, listOf(index))
                            }
                        })
                    }
                }
            }
            "GridLayout" -> {
                val spanCount = props.getAsInt("spanCount", 1)
                val count = props.getAsInt("count", 0)
                var modifier = Modifier.recosProps(jsEvaluator, props)
                if(parentModifier != null){
                    modifier = parentModifier.invoke(modifier, props)
                }
                LazyVerticalGrid(
                    cells = GridCells.Fixed(spanCount),
                    modifier = modifier
                ) {
                    items(count, itemContent = { index ->
                        (props["render"] as? JsFunctionDecl)?.let { child ->
                            jsEvaluator.Eval(child, listOf(index))
                        }
                    })
                }
            }
            "StaggeredVerticalGrid" -> {
                val spanCount = props.getAsInt("spanCount", 2)
                val count = props.getAsInt("count", 0)
                val scrollState = rememberScrollState()
                var modifier = Modifier
                    .recosProps(jsEvaluator, props)
                if(parentModifier != null){
                    modifier = parentModifier.invoke(modifier, props)
                }
                Column(modifier = Modifier.verticalScroll(scrollState)) {
                    StaggeredVerticalGrid(
                        modifier = modifier,
                        columns = spanCount) {
                        for(i in 0 until count){
                            (props["render"] as? JsFunctionDecl)?.let { child ->
                                jsEvaluator.Eval(child, listOf(i))
                            }
                        }
                    }
                }
            }
            "Crossfade" -> {
                val targetState = props["targetState"]
                val content = props["content"] as? JsFunctionDecl ?: return
                Crossfade(targetState = targetState, animationSpec = tween(500)) {
                    jsEvaluator.Eval(content, listOf(it))
                }
            }
            "View" -> {
                var flexDirection = FlexDirection.Column
                var justifyContent = JustifyContent.FlexStart
                var alignItems = AlignItems.FlexStart
                var alignContent = AlignContent.FlexStart
                var wrap = FlexWrap.NoWrap
                (props["style"] as? JsObject)?.let { style ->
                    flexDirection = when (style.getAsString("flexDirection")) {
                        "row" -> FlexDirection.Row
                        "row-reverse" -> FlexDirection.RowReverse
                        "column-reverse" -> FlexDirection.ColumnReverse
                        else ->FlexDirection.Column
                    }

                    justifyContent = when (style.getAsString("justifyContent")) {
                        "flex-end" -> JustifyContent.FlexEnd
                        "center" -> JustifyContent.Center
                        "space-between" -> JustifyContent.SpaceBetween
                        "space-around" -> JustifyContent.SpaceAround
                        "space-evenly" -> JustifyContent.SpaceEvenly
                        else -> JustifyContent.FlexStart
                    }
                    alignItems = when (style.getAsString("alignItems")) {
                        "stretch" -> AlignItems.Stretch
                        "flex-end" -> AlignItems.FlexEnd
                        "center" -> AlignItems.Center
                        else -> AlignItems.FlexStart
                    }
                    alignContent = when (style.getAsString("alignContent")) {
                        "flex-end" -> AlignContent.FlexEnd
                        "stretch" -> AlignContent.Stretch
                        "center" -> AlignContent.Center
                        "space-between" -> AlignContent.SpaceBetween
                        "space-around" -> AlignContent.SpaceAround
                        "space-evenly" -> AlignContent.SpaceEvenly
                        else -> AlignContent.FlexStart
                    }
                    
                    wrap = when (style.getAsString("flexWrap")) {
                        "wrap" -> FlexWrap.Wrap
                        "wrap-reverse" -> FlexWrap.WrapReverse
                        else -> FlexWrap.NoWrap
                    }
                }
                var modifier = Modifier.recosProps(jsEvaluator, props)
                if(parentModifier != null){
                    modifier = parentModifier.invoke(modifier, props)
                }
                MiniFlexBox(flexDirection = flexDirection,
                    justifyContent = justifyContent,
                    alignItems = alignItems,
                    alignContent = alignContent,
                    flexWrap = wrap,
                    modifier = modifier) {
                    children?.forEach { child ->
                        val childModifier: ((Modifier, props: Map<String, Any?>) -> Modifier) = { modifier,childProps ->
                            val childStyle = childProps["style"] as? JsObject
                            if(childStyle != null){
                                val alignSelf = when (childProps.getAsString("alignSelf")) {
                                    "stretch" -> AlignSelf.Stretch
                                    "flex-end" -> AlignSelf.FlexEnd
                                    "center" -> AlignSelf.Center
                                    "baseline" -> AlignSelf.Baseline
                                    "flex-start" -> AlignSelf.FlexStart
                                    else -> AlignSelf.Auto
                                }
                                var flexGrow = 0f
                                var flexShrink = 0f
                                childStyle.getAsFloat("flex")?.let {
                                    flexGrow = it
                                    flexShrink = 1f
                                }
                                flexGrow = childStyle.getAsFloat("flexGrow", flexGrow)
                                flexShrink = childStyle.getAsFloat("flexShrink", flexShrink)
                                val flexBasisPercent = childStyle.getAsFloat("flexBasis", -1f)
                                modifier
                                    .alignSelf(alignSelf)
                                    .flex(flexGrow, flexShrink, flexBasisPercent)
                                    .order(childStyle.getAsInt("order", 0))
                                    .wrapBefore(childStyle.getAsBool("wrapBefore", false))
                            }else{
                                modifier
                            }
                        }
                        child.Render(childModifier)
                    }
                }
            }
            "Text" -> {
                val stringBuilder = StringBuilder()
                children?.forEach {
                    val value = (it as JsxValueRenderElement).value
                    if(value is JsxText){
                        stringBuilder.append(value.text)
                    }else{
                        stringBuilder.append(value)
                    }
                }

                var color = Color.Unspecified
                var fontSize = TextUnit.Unspecified

                (props["style"] as? JsObject)?.let { style ->
                    style.getAsString("color")?.let {
                        color = Color(android.graphics.Color.parseColor(it))
                    }

                    style.getAsInt("fontSize")?.let {
                        fontSize = it.sp
                    }
                }

                var modifier = Modifier.recosProps(jsEvaluator, props)
                if(parentModifier != null){
                    modifier = parentModifier.invoke(modifier, props)
                }

                Text(
                    stringBuilder.toString(),
                    color = color,
                    fontSize = fontSize,
                    modifier = modifier
                )
            }
            "Image" -> {
                var modifier = Modifier.recosProps(jsEvaluator, props)
                if(parentModifier != null){
                    modifier = parentModifier.invoke(modifier, props)
                }
                val url = props.getAsString("src")
                if(url != null){
                    GlideImage(
                        modifier = modifier,
                        imageModel = url,
                        // Crop, Fit, Inside, FillHeight, FillWidth, None
                        contentScale = ContentScale.Crop,
                        // shows an image with a circular revealed animation.
                        circularRevealedEnabled = true,
//                        // shows a placeholder ImageBitmap when loading.
//                        placeHolder = ImageBitmap.imageResource(R.drawable.placeholder),
//                        // shows an error ImageBitmap when the request failed.
//                        error = ImageBitmap.imageResource(R.drawable.error)
                    )
                }
            }
        }
    }
}

fun Modifier.recosProps(jsEvaluator: JsEvaluator, prop: Map<String, Any?>):  Modifier {
    var ret: Modifier = this
    (prop["style"] as? JsObject)?.let { style ->
        val margin = style.getAsInt("margin", 0)
        var marginLeft = margin
        var marginTop = margin
        var marginRight = margin
        var marginBottom = margin
        style.getAsInt("marginHorizontal")?.let {
            marginLeft = it
            marginRight = it
        }
        style.getAsInt("marginVertical")?.let {
            marginTop = it
            marginBottom = it
        }
        style.getAsInt("marginStart")?.let {
            marginLeft = it
        }
        style.getAsInt("marginLeft")?.let {
            marginLeft = it
        }
        style.getAsInt("marginRight")?.let {
            marginRight = it
        }
        style.getAsInt("marginEnd")?.let {
            marginRight = it
        }
        style.getAsInt("marginTop")?.let {
            marginTop = it
        }
        style.getAsInt("marginBottom")?.let {
            marginBottom = it
        }
        ret = ret.padding(marginLeft.dp, marginTop.dp, marginRight.dp, marginBottom.dp)

        style.getAsString("width")?.let {
            if (it.endsWith("%")) {
                try {
                    val percent = it.substring(0, it.length - 1).toInt()
                    ret = ret.fillMaxWidth(percent / 100f)
                } catch (e: Throwable) {
                    // TODO log
                }
            } else if (it != "auto") {
                try {
                    val w = it.toInt()
                    ret = ret.width(w.dp)
                } catch (e: Throwable) {
                    // TODO log
                }
            }
        }

        style.getAsInt("width")?.let {
            ret = ret.width(it.dp)
        }

        style.getAsString("height")?.let {
            if (it.endsWith("%")) {
                try {
                    val percent = it.substring(0, it.length - 1).toInt()
                    ret = ret.fillMaxHeight(percent / 100f)
                } catch (e: Throwable) {
                    // TODO log
                }
            } else if (it != "auto") {
                try {
                    val h = 0.coerceAtLeast(it.toInt())
                    ret = ret.height(h.dp)
                } catch (e: Throwable) {
                    // TODO log
                }
            }
        }

        style.getAsInt("height")?.let {
            ret = ret.height(0.coerceAtLeast(it).dp)
        }

        var borderLeftTopRadius = 0.0f
        var borderLeftBottomRadius = 0.0f
        var borderRightTopRadius = 0.0f
        var borderRightBottomRadius = 0.0f
        style.getAsFloat("borderRadius")?.let {
            borderLeftTopRadius = it
            borderLeftBottomRadius = it
            borderRightTopRadius = it
            borderRightBottomRadius = it
        }
        style.getAsFloat("borderTopStartRadius")?.let {
            borderLeftTopRadius = it
        }
        style.getAsFloat("borderTopLeftRadius")?.let {
            borderLeftTopRadius = it
        }
        style.getAsFloat("borderTopEndRadius")?.let {
            borderRightTopRadius = it
        }
        style.getAsFloat("borderTopRightRadius")?.let {
            borderRightTopRadius = it
        }

        style.getAsFloat("borderBottomLeftRadius")?.let {
            borderLeftBottomRadius = it
        }
        style.getAsFloat("borderBottomStartRadius")?.let {
            borderLeftBottomRadius = it
        }
        style.getAsFloat("borderBottomEndRadius")?.let {
            borderRightBottomRadius = it
        }
        style.getAsFloat("borderBottomRightRadius")?.let {
            borderRightBottomRadius = it
        }

        style.getAsString("backgroundColor")?.let {
            ret = ret.background(
                Color(android.graphics.Color.parseColor(it)),
                RoundedCornerShape(
                    borderLeftTopRadius.dp,
                    borderRightTopRadius.dp,
                    borderRightBottomRadius.dp,
                    borderLeftBottomRadius.dp
                )
            )
        }
        val borderWidth = style.getAsInt("borderWidth", 0)
        if (borderWidth > 0) {
            val borderStyle = style.getAsString("borderStyle", "solid") // TODO
            val borderColor = style.getAsString("borderColor")?.let { android.graphics.Color.parseColor(it) } ?: 0
            ret = ret.border(
                borderWidth.dp,
                SolidColor(Color(borderColor)),
                RoundedCornerShape(
                    borderLeftTopRadius.dp,
                    borderRightTopRadius.dp,
                    borderRightBottomRadius.dp,
                    borderLeftBottomRadius.dp
                )
            )
        }

        val padding = style.getAsInt("padding", 0)
        var paddingLeft = padding
        var paddingTop = padding
        var paddingRight = padding
        var paddingBottom = padding
        style.getAsInt("paddingHorizontal")?.let {
            paddingLeft = it
            paddingRight = it
        }
        style.getAsInt("paddingVertical")?.let {
            paddingTop = it
            paddingBottom = it
        }
        style.getAsInt("paddingLeft")?.let {
            paddingLeft = it
        }
        style.getAsInt("paddingStart")?.let {
            paddingLeft = it
        }
        style.getAsInt("paddingRight")?.let {
            paddingRight = it
        }
        style.getAsInt("paddingEnd")?.let {
            paddingRight = it
        }
        style.getAsInt("paddingBottom")?.let {
            paddingBottom = it
        }
        style.getAsInt("paddingTop")?.let {
            paddingTop = it
        }
        ret = ret.padding(paddingLeft.dp, paddingTop.dp, paddingRight.dp, paddingBottom.dp)
    }

    (prop["onClick"] as? JsFunctionDecl)?.let { func ->
        ret = ret.clickable {
            jsEvaluator.normalEval(func, null)
        }
    }
    return ret
}

class JsxValueRenderElement(val value: Any?): RenderElement {
    @ExperimentalFoundationApi
    @Composable
    override fun Render(parentModifier: ((Modifier, props: Map<String, Any?>) -> Modifier)?) {
        if(value is JsxRenderElement){
            value.Render(null)
        }else if(value is JsArray){
            for(i in 0 until value.itemCount()){
                (value.get(i) as? JsxRenderElement)?.Render(null)
            }
        }
    }
}

class FunctionDeclRenderElement(
    val jsEvaluator: JsEvaluator,
    val functionDecl: JsFunctionDecl,
    val args: List<Any?>? = null
): RenderElement {
    @Composable
    override fun Render(parentModifier: ((Modifier, props: Map<String, Any?>) -> Modifier)?) {
        jsEvaluator.Eval(functionDecl = functionDecl, args)
    }
}
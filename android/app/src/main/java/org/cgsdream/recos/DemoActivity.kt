package org.cgsdream.recos

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.GridCells
import androidx.compose.foundation.lazy.LazyVerticalGrid
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.ComposeView
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.cgsdream.recos.root.page.RecosPage
import org.cgsdream.recos.root.widget.*

class DemoActivity : AppCompatActivity() {

    private lateinit var pageRootLayout: ComposeView
    private lateinit var page: RecosPage

    @ExperimentalFoundationApi
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        pageRootLayout = ComposeView(this)
        page = RecosPage(recosDataSource, "waterfall.bundle", "Waterfall")
        page.attach(pageRootLayout)
        setContentView(pageRootLayout)
        lifecycle.addObserver(page)
    }
}

@Preview
@Composable
fun FLexBoxPreview() {
    FlexBox(
        flexDirection = FlexDirection.Column,
        justifyContent = JustifyContent.SpaceEvenly,
        alignItems = AlignItems.Center,
        alignContent = AlignContent.FlexStart,
        flexWrap = FlexWrap.Wrap,
        modifier = Modifier
            .background(Color.White)
            .fillMaxWidth()
            .fillMaxHeight()
    ) {
        Text(
            "A", fontSize = 30.sp, modifier = Modifier
                .padding(10.dp)
                .background(Color.Red)
                .padding(10.dp)
        )
        Text(
            "B", fontSize = 30.sp, modifier = Modifier
                .background(Color.Blue)
                .padding(10.dp)
                .padding(10.dp)
        )
        Text(
            "C", fontSize = 30.sp, modifier = Modifier
                .background(Color.Red)
                .padding(10.dp)
        )
        Text(
            "D", fontSize = 30.sp, modifier = Modifier
                .background(Color.Blue)
                .padding(10.dp)
        )
        Text(
            "E", fontSize = 30.sp, modifier = Modifier
                .background(Color.Red)
                .padding(10.dp)
        )
        Text(
            "F", fontSize = 30.sp, modifier = Modifier
                .background(Color.Blue)
                .padding(10.dp)
        )
        Text(
            "G", fontSize = 30.sp, modifier = Modifier
                .wrapBefore(true)
                .background(Color.Red)
                .padding(10.dp)
        )
        Text(
            "H", fontSize = 30.sp, modifier = Modifier
                .background(Color.Blue)
                .padding(10.dp)
        )
        Text(
            "I", fontSize = 30.sp, modifier = Modifier
                .alignSelf(AlignSelf.FlexEnd)
                .background(Color.Red)
                .padding(10.dp)
        )
        Text(
            "G", fontSize = 30.sp, modifier = Modifier
                .background(Color.Blue)
                .padding(10.dp)
        )
        Text(
            "K", fontSize = 30.sp, modifier = Modifier
                .background(Color.Red)
                .padding(10.dp)
        )
        Text(
            "L", fontSize = 30.sp, modifier = Modifier
                .background(Color.Blue)
                .padding(10.dp)
        )
    }
}


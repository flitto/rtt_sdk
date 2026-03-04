package com.flitto.livetranslation.sample.chatguest.ui

import android.content.res.Configuration
import androidx.compose.foundation.layout.size
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.flitto.livetranslation.sample.chatguest.theme.SampleTheme

@Composable
fun GoToBottomFloatingButton(
    modifier: Modifier = Modifier,
    isVisible: Boolean,
    onClick: () -> Unit = {},
) {
    if (isVisible) {
        FloatingActionButton(
            onClick = onClick,
            modifier = modifier.size(40.dp),
            containerColor = Color.White
        ) {
            Text("↓")
        }
    }
}

@Preview(uiMode = Configuration.UI_MODE_NIGHT_NO, name = "Light theme", showBackground = true)
@Composable
private fun GoToBottomFloatingButtonPreview() {
    SampleTheme {
        GoToBottomFloatingButton(isVisible = true)
    }
}

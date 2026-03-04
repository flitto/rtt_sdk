package com.flitto.livetranslation.sample.chatguest.ui

import android.content.res.Configuration
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.flitto.livetranslation.sample.chatguest.theme.Grey90
import com.flitto.livetranslation.sample.chatguest.theme.Red50
import com.flitto.livetranslation.sample.chatguest.theme.SampleTheme

@Composable
fun TopBanner(
    modifier: Modifier = Modifier,
    roomName: String,
    selectedLanguage: String,
    isDisconnected: Boolean,
    onClickLanguageSelectorChip: () -> Unit = {}
) {
    Column(
        modifier = modifier.background(Color.White)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(
                modifier = Modifier.padding(bottom = 12.dp),
                text = roomName,
                color = Grey90,
                style = SampleTheme.typography.bold16
            )
            if (isDisconnected) {
                Text(
                    modifier = Modifier.padding(start = 100.dp),
                    text = "Room Disconnected. Please try refresh",
                    color = Red50,
                    style = SampleTheme.typography.regular11
                )
            }
        }
        LanguageSelectorChip(
            label = selectedLanguage,
            onClick = onClickLanguageSelectorChip
        )
    }
}

@Preview(uiMode = Configuration.UI_MODE_NIGHT_NO, name = "Light theme", showBackground = true)
@Composable
private fun TopBannerPreview() {
    SampleTheme {
        TopBanner(
            modifier = Modifier.padding(16.dp),
            roomName = "title",
            selectedLanguage = "한국어",
            isDisconnected = true
        )
    }
}

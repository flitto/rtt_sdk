package com.flitto.livetranslation.sample.chatguest.ui

import android.content.res.Configuration
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.flitto.livetranslation.sample.chatguest.theme.Grey05
import com.flitto.livetranslation.sample.chatguest.theme.Grey90
import com.flitto.livetranslation.sample.chatguest.theme.SampleTheme
import com.flitto.livetranslation.sdk.chatguest.model.ChatHistoryItemEntity

@Composable
fun ChatMessageContents(
    messages: List<ChatHistoryItemEntity>,
    listState: LazyListState
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        state = listState,
        contentPadding = PaddingValues(start = 8.dp, end = 8.dp, top = 8.dp, bottom = 16.dp),
        verticalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        itemsIndexed(
            items = messages,
            key = { index, item ->
                if (item.chatId.isNotBlank()) item.chatId else "idx-$index"
            }
        ) { _, item ->
            if (item.text.isNotBlank()) {
                ChatMessageItem(message = item)
            }
        }
        item {
            Spacer(modifier = Modifier.height(80.dp))
        }
    }
}

@Composable
fun ChatMessageItem(
    message: ChatHistoryItemEntity
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(Grey05)
            .padding(vertical = 10.dp, horizontal = 12.dp)
    ) {
        if (message.isRealTime) {
            Row(
                verticalAlignment = Alignment.CenterVertically
            ) {
                LTLottieAnimation(
                    modifier = Modifier.size(24.dp),
                    assetName = "animation_typing.json",
                    lottieColor = Grey90
                )
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    text = message.text,
                    style = SampleTheme.typography.regular16,
                    color = Grey90
                )
            }
        } else {
            Text(
                text = if (message.srcLanguageCode != message.dstLanguageCode) {
                    message.textForTr
                } else {
                    message.text
                },
                style = SampleTheme.typography.regular16,
                color = Color.Black
            )
        }
    }
}

@Preview(uiMode = Configuration.UI_MODE_NIGHT_NO, name = "Light theme", showBackground = true)
@Composable
private fun ChatMessageContentsPreview() {
    SampleTheme {
        ChatMessageContents(
            messages = listOf(
                ChatHistoryItemEntity(
                    chatId = "1",
                    text = "hello"
                ),
                ChatHistoryItemEntity(
                    chatId = "2",
                    text = "This is test"
                ),
                ChatHistoryItemEntity(
                    chatId = "3",
                    text = "print 1"
                ),
                ChatHistoryItemEntity(
                    chatId = "4",
                    text = "print 2"
                ),
                ChatHistoryItemEntity(
                    chatId = "5",
                    text = "print 3",
                    isRealTime = true
                )
            ),
            listState = rememberLazyListState()
        )
    }
}

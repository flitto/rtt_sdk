package com.flitto.livetranslation.sample.chatguest

import android.content.res.Configuration
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.flitto.livetranslation.sample.chatguest.model.TYPE_REALTIME
import com.flitto.livetranslation.sample.chatguest.theme.SampleTheme
import com.flitto.livetranslation.sample.chatguest.ui.ChatMessageContents
import com.flitto.livetranslation.sample.chatguest.ui.GoToBottomFloatingButton
import com.flitto.livetranslation.sample.chatguest.ui.LanguageSelectBottomSheet
import com.flitto.livetranslation.sample.chatguest.ui.TopBanner
import com.flitto.livetranslation.sdk.chatguest.model.ChatHistoryItemEntity
import com.flitto.livetranslation.sdk.chatguest.model.LanguageInfoEntity
import kotlinx.coroutines.launch

@Composable
fun ChatHistoryScreen(
    uiState: UiState,
    onChangeLanguage: (LanguageInfoEntity) -> Unit = {}
) {
    var isLanguageSelectBottomSheetVisible by remember { mutableStateOf(false) }
    var isInitialScrollDone by rememberSaveable { mutableStateOf(false) }
    val listState = rememberLazyListState()
    val isLastItemVisible by remember(uiState.messages, listState) {
        derivedStateOf {
            val total = listState.layoutInfo.totalItemsCount
            if (total == 0) return@derivedStateOf true
            val lastIndex = total - 1
            listState.layoutInfo.visibleItemsInfo.lastOrNull()?.index == lastIndex
        }
    }

    val coroutineScope = rememberCoroutineScope()

    LaunchedEffect(uiState.isConnected) {
        if (uiState.isConnected.not()) isInitialScrollDone = false
    }

    LaunchedEffect(uiState.messages.size) {
        if (isInitialScrollDone.not() && uiState.messages.isNotEmpty()) {
            listState.scrollToItem(uiState.messages.lastIndex)
            isInitialScrollDone = true
        } else if (uiState.messages.isNotEmpty() && listState.isAtBottom()) {
            listState.scrollToItem(uiState.messages.lastIndex)
        }
    }

    LaunchedEffect(uiState.selectedLanguage) {
        if (uiState.messages.isNotEmpty()) {
            coroutineScope.launch {
                listState.animateScrollToItem(uiState.messages.lastIndex)
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.White)
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        TopBanner(
            roomName = uiState.roomName,
            selectedLanguage = uiState.selectedLanguage.languageLocal,
            isDisconnected = uiState.isConnected.not(),
            onClickLanguageSelectorChip = {
                isLanguageSelectBottomSheetVisible = true
            }
        )

        Box(
            modifier = Modifier.fillMaxSize()
        ) {
            ChatMessageContents(
                messages = uiState.messages,
                listState = listState
            )
            GoToBottomFloatingButton(
                isVisible = uiState.messages.isNotEmpty() && !isLastItemVisible,
                onClick = {
                    if (uiState.messages.isNotEmpty()) {
                        coroutineScope.launch {
                            listState.animateScrollToItem(uiState.messages.lastIndex)
                        }
                    }
                },
                modifier = Modifier
                    .align(Alignment.BottomEnd)
                    .padding(12.dp)
            )
        }
    }

    if (isLanguageSelectBottomSheetVisible) {
        LanguageSelectBottomSheet(
            languages = uiState.supportLanguages,
            selectedLanguageCode = uiState.selectedLanguage.languageCode,
            onSelected = { language ->
                onChangeLanguage(language)
                isLanguageSelectBottomSheetVisible = false
            },
            onDismiss = { isLanguageSelectBottomSheetVisible = false }
        )
    }
}

@Preview(uiMode = Configuration.UI_MODE_NIGHT_NO, name = "Light theme", showBackground = true)
@Composable
private fun ChatHistoryScreenPreview() {
    SampleTheme {
        ChatHistoryScreen(
            uiState = UiState(
                roomName = "title",
                selectedLanguage = LanguageInfoEntity(
                    languageCode = "ko",
                    languageLocal = "한국어"
                ),
                messagesType = "",
                messages = listOf(
                    ChatHistoryItemEntity(
                        text = "hello"
                    ),
                    ChatHistoryItemEntity(
                        text = "This is test"
                    ),
                    ChatHistoryItemEntity(
                        text = "print 1"
                    ),
                    ChatHistoryItemEntity(
                        text = "print 2"
                    ),
                    ChatHistoryItemEntity(
                        taskType = TYPE_REALTIME,
                        text = "print 3"
                    )
                )
            )
        )
    }
}

package com.flitto.livetranslation.sample.chatguest

import androidx.compose.foundation.lazy.LazyListState

fun LazyListState.isAtBottom(threshold: Int = 3): Boolean {
    val lastVisibleItem = layoutInfo.visibleItemsInfo.lastOrNull()?.index ?: return false
    val total = layoutInfo.totalItemsCount
    return total - lastVisibleItem <= threshold
}

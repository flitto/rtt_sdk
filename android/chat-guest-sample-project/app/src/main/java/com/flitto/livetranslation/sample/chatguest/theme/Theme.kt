package com.flitto.livetranslation.sample.chatguest.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider

@Composable
fun SampleTheme(
    content: @Composable () -> Unit
) {
    CompositionLocalProvider(
        LocalTypography provides Typography
    ) {
        MaterialTheme(content = content)
    }
}

object SampleTheme {
    val typography: SampleTypography
        @Composable
        get() = LocalTypography.current
}

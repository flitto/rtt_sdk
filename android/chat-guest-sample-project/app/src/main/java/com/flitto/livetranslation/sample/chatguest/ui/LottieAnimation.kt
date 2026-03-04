package com.flitto.livetranslation.sample.chatguest.ui

import android.content.res.Configuration
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.tooling.preview.Preview
import com.airbnb.lottie.LottieProperty
import com.airbnb.lottie.SimpleColorFilter
import com.airbnb.lottie.compose.LottieAnimation
import com.airbnb.lottie.compose.LottieCompositionSpec
import com.airbnb.lottie.compose.LottieConstants
import com.airbnb.lottie.compose.animateLottieCompositionAsState
import com.airbnb.lottie.compose.rememberLottieComposition
import com.airbnb.lottie.compose.rememberLottieDynamicProperties
import com.airbnb.lottie.compose.rememberLottieDynamicProperty
import com.flitto.livetranslation.sample.chatguest.theme.Grey90
import com.flitto.livetranslation.sample.chatguest.theme.SampleTheme

@Composable
fun LTLottieAnimation(
    modifier: Modifier = Modifier,
    assetName: String,
    iterations: Int = LottieConstants.IterateForever,
    lottieColor: Color? = null,
    animationSpeed: Float = 1f,
    animationEndProgress: Float = 1f,
    onAnimationEnd: () -> Unit = {}
) {
    val lottieComposition by rememberLottieComposition(LottieCompositionSpec.Asset(assetName))
    val progress by animateLottieCompositionAsState(lottieComposition)
    val dynamicProperties = if (lottieColor != null) {
        rememberLottieDynamicProperties(
            rememberLottieDynamicProperty(
                property = LottieProperty.COLOR_FILTER,
                value = SimpleColorFilter(lottieColor.toArgb()),
                "**"
            )
        )
    } else {
        null
    }

    Box(modifier = modifier.fillMaxSize()) {
        if (assetName.isNotEmpty()) {
            LottieAnimation(
                modifier = modifier.align(Alignment.Center),
                composition = lottieComposition,
                iterations = iterations,
                speed = animationSpeed,
                dynamicProperties = dynamicProperties
            )
        }
    }

    if (progress >= animationEndProgress && iterations != LottieConstants.IterateForever) {
        onAnimationEnd()
    }
}

@Preview(uiMode = Configuration.UI_MODE_NIGHT_NO, name = "Light theme", showBackground = true)
@Composable
private fun ChatMessageContentsPreview() {
    SampleTheme {
        LTLottieAnimation(
            assetName = "animation_typing.json",
            lottieColor = Grey90
        )
    }
}

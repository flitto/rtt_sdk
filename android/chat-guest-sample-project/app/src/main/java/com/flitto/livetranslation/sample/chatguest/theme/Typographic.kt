package com.flitto.livetranslation.sample.chatguest.theme

import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import com.flitto.livetranslation.sample.chatguest.R

private val PretendardFontFamily = FontFamily(
    Font(R.font.font_regular, FontWeight.Normal)
)

private val PretendardStyle = TextStyle(
    fontFamily = PretendardFontFamily,
    fontWeight = FontWeight.W600,
)

internal val Typography = SampleTypography(
    bold24 = PretendardStyle.copy(
        fontWeight = FontWeight.W600,
        fontSize = 24.sp,
        lineHeight = 34.sp,
        letterSpacing = (-0.2).sp
    ),
    bold18 = PretendardStyle.copy(
        fontWeight = FontWeight.W600,
        fontSize = 18.sp,
        lineHeight = 24.sp,
        letterSpacing = (-0.2).sp
    ),
    bold16 = PretendardStyle.copy(
        fontWeight = FontWeight.W600,
        fontSize = 16.sp,
        lineHeight = 22.sp,
        letterSpacing = (-0.2).sp
    ),
    regular18 = PretendardStyle.copy(
        fontWeight = FontWeight.W400,
        fontSize = 18.sp,
        lineHeight = 24.sp,
        letterSpacing = (-0.2).sp
    ),
    regular16 = PretendardStyle.copy(
        fontWeight = FontWeight.W400,
        fontSize = 16.sp,
        lineHeight = 22.sp,
        letterSpacing = (-0.2).sp
    ),
    regular14 = PretendardStyle.copy(
        fontWeight = FontWeight.W400,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = (-0.2).sp
    ),
    regular12 = PretendardStyle.copy(
        fontWeight = FontWeight.W400,
        fontSize = 12.sp,
        lineHeight = 18.sp,
        letterSpacing = (-0.2).sp
    ),
    regular11 = PretendardStyle.copy(
        fontWeight = FontWeight.W400,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = (-0.2).sp
    )
)

@Immutable
data class SampleTypography(
    val bold24: TextStyle,
    val bold18: TextStyle,
    val bold16: TextStyle,
    val regular18: TextStyle,
    val regular16: TextStyle,
    val regular14: TextStyle,
    val regular12: TextStyle,
    val regular11: TextStyle
)

val LocalTypography = staticCompositionLocalOf {
    SampleTypography(
        bold24 = PretendardStyle.copy(
            fontWeight = FontWeight.W600,
            fontSize = 24.sp,
            lineHeight = 34.sp,
            letterSpacing = (-0.2).sp
        ),
        bold18 = PretendardStyle.copy(
            fontWeight = FontWeight.W600,
            fontSize = 18.sp,
            lineHeight = 24.sp,
            letterSpacing = (-0.2).sp
        ),
        bold16 = PretendardStyle.copy(
            fontWeight = FontWeight.W600,
            fontSize = 16.sp,
            lineHeight = 22.sp,
            letterSpacing = (-0.2).sp
        ),
        regular18 = PretendardStyle.copy(
            fontWeight = FontWeight.W400,
            fontSize = 18.sp,
            lineHeight = 24.sp,
            letterSpacing = (-0.2).sp
        ),
        regular16 = PretendardStyle.copy(
            fontWeight = FontWeight.W400,
            fontSize = 16.sp,
            lineHeight = 22.sp,
            letterSpacing = (-0.2).sp
        ),
        regular14 = PretendardStyle.copy(
            fontWeight = FontWeight.W400,
            fontSize = 14.sp,
            lineHeight = 20.sp,
            letterSpacing = (-0.2).sp
        ),
        regular12 = PretendardStyle.copy(
            fontWeight = FontWeight.W400,
            fontSize = 12.sp,
            lineHeight = 18.sp,
            letterSpacing = (-0.2).sp
        ),
        regular11 = PretendardStyle.copy(
            fontWeight = FontWeight.W400,
            fontSize = 12.sp,
            lineHeight = 18.sp,
            letterSpacing = (-0.2).sp
        )
    )
}

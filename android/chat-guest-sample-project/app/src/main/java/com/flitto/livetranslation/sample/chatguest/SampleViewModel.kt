package com.flitto.livetranslation.sample.chatguest

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.flitto.livetranslation.sdk.chatguest.ChatGuestSdk
import com.flitto.livetranslation.sdk.chatguest.model.ChatDataEntity
import com.flitto.livetranslation.sdk.chatguest.model.ChatHistoryItemEntity
import com.flitto.livetranslation.sdk.chatguest.model.LanguageInfoEntity
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

class SampleViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(UiState())
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()
    private val _uiEffect: MutableSharedFlow<UiEffect> = MutableSharedFlow()
    val uiEffect: SharedFlow<UiEffect> = _uiEffect.asSharedFlow()

    private var job: Job? = null

    init {
        viewModelScope.launch {
            launch {
                ChatGuestSdk.isConnected.collect { isConnected ->
                    _uiState.update { it.copy(isConnected = isConnected) }
                }
            }
            launch {
                ChatGuestSdk.supportLanguages.collect { supportLanguages ->
                    _uiState.update { state ->
                        state.copy(
                            supportLanguages = supportLanguages,
                            selectedLanguage =
                                if (state.selectedLanguage.languageCode.isEmpty()) {
                                    supportLanguages.find { it.languageCode == "ko" }
                                        ?: LanguageInfoEntity()
                                } else {
                                    state.selectedLanguage
                                }
                        )
                    }
                }
            }
            enterRoom()
        }
    }

    private fun showError(exception: Exception) {
        val message = exception.message?.takeIf { it.isNotBlank() } ?: "Unknown error"
        viewModelScope.launch {
            _uiEffect.emit(UiEffect.ShowToast(message))
        }
    }

    suspend fun enterRoom() {
        try {
            job?.cancel()
            val selectedLanguageCode = uiState.value.selectedLanguage.languageCode.takeIf { it.isNotEmpty() } ?: "ko"
            val roomName = ChatGuestSdk.connectChat(roomCode = uiState.value.roomCode, selectedLanguageCode)
            _uiState.update { it.copy(isConnected = true) }
            job = viewModelScope.launch {
                ChatGuestSdk.observeMessages().collect { data ->
                    when (data) {
                        is ChatDataEntity.ErrorEntity -> {
                            when (data.errorCode) {
                                -1 -> {
                                    _uiEffect.emit(
                                        UiEffect.ShowToast("Unknown Error")
                                    )
                                }
                            }
                        }

                        is ChatDataEntity.ChatHistoryDataEntity -> {
                            _uiState.update { state ->
                                state.copy(
                                    roomName = roomName,
                                    messages = data.chatList,
                                    messagesType = data.listType
                                )
                            }
                        }
                    }
                }
            }
        } catch (e: Exception) {
            showError(e)
        }
    }

    fun onChangeLanguage(selectedLanguage: LanguageInfoEntity) {
        if (uiState.value.selectedLanguage.languageCode == selectedLanguage.languageCode) return
        _uiState.update {
            it.copy(selectedLanguage = selectedLanguage)
        }
        ChatGuestSdk.requestTranslate(selectedLanguage.languageCode)
    }

    suspend fun onRefresh() = enterRoom()

    override fun onCleared() {
        job?.cancel()
        ChatGuestSdk.disconnectChat()
        super.onCleared()
    }
}

data class UiState(
    val messages: List<ChatHistoryItemEntity> = emptyList(),
    val messagesType: String = "",
    val selectedLanguage: LanguageInfoEntity = LanguageInfoEntity(),
    val supportLanguages: List<LanguageInfoEntity> = emptyList(),
    val roomName: String = "",
    val roomCode: String = "910069",
    val isConnected: Boolean = false
)

sealed interface UiEffect {

    @JvmInline
    value class ShowToast(val message: String) : UiEffect
}

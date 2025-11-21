/**
 * Galmuri Diary Extension - Popup Script
 * Handles UI interactions and communication with background script
 */

// State
let captureData = {
    screenshot: '',
    url: '',
    title: ''
};

// DOM Elements
const captureView = document.getElementById('captureView');
const settingsView = document.getElementById('settingsView');
const navCapture = document.getElementById('navCapture');
const navSettings = document.getElementById('navSettings');
const previewImage = document.getElementById('previewImage');
const pageTitle = document.getElementById('pageTitle');
const pageUrl = document.getElementById('pageUrl');
const memoInput = document.getElementById('memoInput');
const saveBtn = document.getElementById('saveBtn');
const cancelBtn = document.getElementById('cancelBtn');
const status = document.getElementById('status');
const apiKeyInput = document.getElementById('apiKeyInput');
const userIdInput = document.getElementById('userIdInput');
const apiUrlInput = document.getElementById('apiUrlInput');
const saveSettingsBtn = document.getElementById('saveSettingsBtn');
const settingsStatus = document.getElementById('settingsStatus');

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
    // Load settings
    const settings = await loadSettings();
    apiKeyInput.value = settings.apiKey || '';
    userIdInput.value = settings.userId || '';
    apiUrlInput.value = settings.apiUrl || 'http://localhost:8000';

    // Check if settings are configured
    if (!settings.apiKey || !settings.userId) {
        showSettings();
        showStatus(settingsStatus, 'API Key와 User ID를 설정해주세요.', 'error');
        return;
    }

    // Capture current tab
    await captureCurrentTab();
});

// Navigation
navCapture.addEventListener('click', () => {
    showCapture();
});

navSettings.addEventListener('click', () => {
    showSettings();
});

function showCapture() {
    captureView.classList.remove('hidden');
    settingsView.classList.remove('active');
    navCapture.classList.add('active');
    navSettings.classList.remove('active');
}

function showSettings() {
    captureView.classList.add('hidden');
    settingsView.classList.add('active');
    navCapture.classList.remove('active');
    navSettings.classList.add('active');
}

// Capture functionality
async function captureCurrentTab() {
    try {
        // Get current tab
        const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
        
        if (!tab) {
            showStatus(status, '활성 탭을 찾을 수 없습니다.', 'error');
            return;
        }

        // Capture screenshot
        const screenshot = await chrome.tabs.captureVisibleTab(null, { format: 'png' });
        
        // Update state
        captureData = {
            screenshot: screenshot,
            url: tab.url,
            title: tab.title
        };

        // Update UI
        previewImage.src = screenshot;
        pageTitle.textContent = tab.title;
        pageUrl.textContent = tab.url;

    } catch (error) {
        console.error('Capture failed:', error);
        showStatus(status, '캡처에 실패했습니다: ' + error.message, 'error');
    }
}

// Save functionality
saveBtn.addEventListener('click', async () => {
    const settings = await loadSettings();

    if (!settings.apiKey || !settings.userId) {
        showStatus(status, 'API Key와 User ID를 먼저 설정해주세요.', 'error');
        showSettings();
        return;
    }

    // Disable button and show loading
    saveBtn.disabled = true;
    document.getElementById('saveBtnText').textContent = '저장 중...';
    showStatus(status, '저장 중입니다...', 'loading');

    try {
        // Prepare data
        const requestData = {
            user_id: settings.userId,
            image_data: captureData.screenshot.split(',')[1], // Remove data:image/png;base64, prefix
            source_url: captureData.url,
            page_title: captureData.title,
            memo_content: memoInput.value || '',
            platform: 'WEB_EXTENSION'
        };

        // Send to API
        const response = await fetch(`${settings.apiUrl}/api/capture`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-API-Key': settings.apiKey
            },
            body: JSON.stringify(requestData)
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.detail || 'API 요청 실패');
        }

        const result = await response.json();
        console.log('Saved successfully:', result);

        showStatus(status, '✅ 저장되었습니다! OCR 처리가 백그라운드에서 진행됩니다.', 'success');

        // Clear memo and close after delay
        setTimeout(() => {
            window.close();
        }, 1500);

    } catch (error) {
        console.error('Save failed:', error);
        showStatus(status, '저장 실패: ' + error.message, 'error');
    } finally {
        saveBtn.disabled = false;
        document.getElementById('saveBtnText').textContent = '저장';
    }
});

// Cancel functionality
cancelBtn.addEventListener('click', () => {
    window.close();
});

// Settings functionality
saveSettingsBtn.addEventListener('click', async () => {
    const apiKey = apiKeyInput.value.trim();
    const userId = userIdInput.value.trim();
    const apiUrl = apiUrlInput.value.trim();

    if (!apiKey || !userId) {
        showStatus(settingsStatus, 'API Key와 User ID는 필수입니다.', 'error');
        return;
    }

    // Validate User ID format (should be UUID)
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    if (!uuidRegex.test(userId)) {
        showStatus(settingsStatus, 'User ID는 UUID 형식이어야 합니다.', 'error');
        return;
    }

    try {
        await chrome.storage.sync.set({
            apiKey: apiKey,
            userId: userId,
            apiUrl: apiUrl || 'http://localhost:8000'
        });

        showStatus(settingsStatus, '✅ 설정이 저장되었습니다!', 'success');

        // Switch back to capture view
        setTimeout(() => {
            showCapture();
            captureCurrentTab();
        }, 1000);

    } catch (error) {
        console.error('Failed to save settings:', error);
        showStatus(settingsStatus, '설정 저장 실패: ' + error.message, 'error');
    }
});

// Utility functions
async function loadSettings() {
    try {
        const result = await chrome.storage.sync.get(['apiKey', 'userId', 'apiUrl']);
        return {
            apiKey: result.apiKey || '',
            userId: result.userId || '',
            apiUrl: result.apiUrl || 'http://localhost:8000'
        };
    } catch (error) {
        console.error('Failed to load settings:', error);
        return {
            apiKey: '',
            userId: '',
            apiUrl: 'http://localhost:8000'
        };
    }
}

function showStatus(element, message, type) {
    element.textContent = message;
    element.className = 'status ' + type;
    
    if (type !== 'loading') {
        setTimeout(() => {
            element.className = 'status';
        }, 5000);
    }
}



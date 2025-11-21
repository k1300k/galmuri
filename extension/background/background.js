/**
 * Galmuri Diary Extension - Background Service Worker
 * Handles background tasks and extension lifecycle
 */

// Extension installation
chrome.runtime.onInstalled.addListener((details) => {
    console.log('Galmuri Diary Extension installed:', details.reason);
    
    if (details.reason === 'install') {
        // First time installation
        console.log('First time installation - please configure API settings');
        
        // Open options page or show welcome message
        chrome.storage.sync.set({
            apiUrl: 'http://localhost:8000',
            apiKey: '',
            userId: ''
        });
    }
});

// Listen for messages from popup or content scripts
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
    console.log('Background received message:', request);
    
    if (request.action === 'capture') {
        handleCapture(request, sendResponse);
        return true; // Keep channel open for async response
    }
    
    if (request.action === 'getSettings') {
        handleGetSettings(sendResponse);
        return true;
    }
});

// Handle capture request
async function handleCapture(request, sendResponse) {
    try {
        // Get current active tab
        const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
        
        if (!tab) {
            sendResponse({ success: false, error: 'No active tab' });
            return;
        }

        // Capture visible tab
        const screenshot = await chrome.tabs.captureVisibleTab(null, { format: 'png' });
        
        sendResponse({
            success: true,
            data: {
                screenshot: screenshot,
                url: tab.url,
                title: tab.title
            }
        });
        
    } catch (error) {
        console.error('Capture error:', error);
        sendResponse({ success: false, error: error.message });
    }
}

// Handle get settings request
async function handleGetSettings(sendResponse) {
    try {
        const settings = await chrome.storage.sync.get(['apiKey', 'userId', 'apiUrl']);
        sendResponse({
            success: true,
            settings: settings
        });
    } catch (error) {
        console.error('Get settings error:', error);
        sendResponse({ success: false, error: error.message });
    }
}

// Optional: Sync unsynced items periodically
chrome.alarms.create('syncItems', { periodInMinutes: 30 });

chrome.alarms.onAlarm.addListener(async (alarm) => {
    if (alarm.name === 'syncItems') {
        console.log('Background sync triggered');
        // Future: Implement background sync logic
    }
});

console.log('Galmuri Diary Background Service Worker loaded');



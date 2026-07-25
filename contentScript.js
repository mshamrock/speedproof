chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
    if (request.action === "pasteText") {
        document.execCommand("insertText", false, request.text);
    }
});
document.addEventListener('DOMContentLoaded', function() {

const getSelectedTextButton = document.getElementById('getSelectedTextButton');

    // Automatically fetch selected text when the popup is loaded
    chrome.tabs.query({active: true, currentWindow: true}, (tabs) => {
        chrome.scripting.executeScript({
            target: {tabId: tabs[0].id},
            function: getSelectedText
        }, (injectionResults) => {
            // Check for results and set the textarea value
            if (injectionResults && injectionResults.length > 0) {
                const result = injectionResults[0].result;
                document.getElementById('textToCheck').value = result;

            }
        });
    });

    var checkButton = document.getElementById('checkGrammarButton');
    var translateButton = document.getElementById('translateButton');
    var rephraseButton = document.getElementById('rephraseButton');

    // Function to handle the response and copy to clipboard
    function handleResponse(data) {
        if (data.correctedText) {
            document.getElementById('textToCheck').value = data.correctedText;

            // Copy to clipboard automatically
            navigator.clipboard.writeText(data.correctedText).then(function() {
                var copyMessageElement = document.getElementById('copyMessage');
                copyMessageElement.textContent = 'Copied to clipboard!';
                copyMessageElement.style.color = 'green'; // Make the text green
                copyMessageElement.style.fontWeight = 'bold'; // Make the text bold
                setTimeout(() => {
                    copyMessageElement.textContent = '';
                    copyMessageElement.style.color = ''; // Reset the color
                    copyMessageElement.style.fontWeight = ''; // Reset the font weight
                }, 5000); // Clears the message after 5 seconds

                document.getElementById('pasteTextButton').style.visibility = 'visible';

            }).catch(function(err) {
                console.error('Error in copying text: ', err);
            });
        } else {
            console.error('Unexpected response format:', data);
        }
    }


    checkButton.addEventListener('click', function() {
        var textToCheck = document.getElementById('textToCheck').value;
        var userCommand = document.getElementById('userCommand').value;




        if (textToCheck.length === 0) {
            alert("Please enter some text to check.");
            return;
        }else{
            var copyMessageElement = document.getElementById('copyMessage');
            copyMessageElement.textContent = 'Processing...';
            copyMessageElement.style.color = 'blue'; // Make the text green
            copyMessageElement.style.fontWeight = 'bold'; // Make the text bold

        }

        fetch('https://sng.nfp.mybluehost.me/checkGrammar/checkGrammar.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: textToCheck, userCommand: userCommand})
        })
        .then(response => response.json())
        .then(handleResponse)
        .catch((error) => {
            console.error('Error:', error);
        });
    }, false);

    summarizeTextButton.addEventListener('click', function() {
        var textToCheck = document.getElementById('textToCheck').value;



        if (textToCheck.length === 0) {
            alert("Please enter some text to check.");
            return;
        }else{
            var copyMessageElement = document.getElementById('copyMessage');
            copyMessageElement.textContent = 'Processing...';
            copyMessageElement.style.color = 'blue'; // Make the text green
            copyMessageElement.style.fontWeight = 'bold'; // Make the text bold

        }

        fetch('https://sng.nfp.mybluehost.me/checkGrammar/checkGrammar.php?action=summarize', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: textToCheck })
        })
        .then(response => response.json())
        .then(handleResponse)
        .catch((error) => {
            console.error('Error:', error);
        });
    }, false);


explainTermButton.addEventListener('click', function() {
        var textToCheck = document.getElementById('textToCheck').value;



        if (textToCheck.length === 0) {
            alert("Please enter some text to check.");
            return;
        }else{
            var copyMessageElement = document.getElementById('copyMessage');
            copyMessageElement.textContent = 'Processing...';
            copyMessageElement.style.color = 'blue'; // Make the text green
            copyMessageElement.style.fontWeight = 'bold'; // Make the text bold

        }

        fetch('https://sng.nfp.mybluehost.me/checkGrammar/checkGrammar.php?action=explain', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: textToCheck })
        })
        .then(response => response.json())
        .then(handleResponse)
        .catch((error) => {
            console.error('Error:', error);
        });
    }, false);



    translateButton.addEventListener('click', function() {
        var textToCheck = document.getElementById('textToCheck').value;
        var languageSelect = document.getElementById('languageSelect').value;

        if (textToCheck.length === 0) {
            alert("Please enter some text to translate.");
            return;
        }else{
            var copyMessageElement = document.getElementById('copyMessage');
            copyMessageElement.textContent = 'Processing...';
            copyMessageElement.style.color = 'blue'; // Make the text green
            copyMessageElement.style.fontWeight = 'bold'; // Make the text bold

        }

        fetch('https://sng.nfp.mybluehost.me/checkGrammar/checkGrammar.php?action=translate&language=' + languageSelect, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: textToCheck })
        })
        .then(response => response.json())
        .then(handleResponse)
        .catch((error) => {
            console.error('Error:', error);
        });
    }, false);


    rephraseButton.addEventListener('click', function() {
        var textToCheck = document.getElementById('textToCheck').value;
        var rephraseSelect = document.getElementById('rephraseSelect').value;

        if (textToCheck.length === 0) {
            alert("Please enter some text to rephrase.");
            return;
        }else{
            var copyMessageElement = document.getElementById('copyMessage');
            copyMessageElement.textContent = 'Processing...';
            copyMessageElement.style.color = 'blue'; // Make the text green
            copyMessageElement.style.fontWeight = 'bold'; // Make the text bold

        }

        fetch('https://sng.nfp.mybluehost.me/checkGrammar/checkGrammar.php?action=rephrase&rephrase=' + rephraseSelect, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: textToCheck })
        })
        .then(response => response.json())
        .then(handleResponse)
        .catch((error) => {
            console.error('Error:', error);
        });
    }, false);



    giveAnswerButton.addEventListener('click', function() {
        var textToCheck = document.getElementById('textToCheck').value;

        if (textToCheck.length === 0) {
            alert("Please enter your question.");
            return;
        }else{
            var copyMessageElement = document.getElementById('copyMessage');
            copyMessageElement.textContent = 'Processing...';
            copyMessageElement.style.color = 'blue'; // Make the text green
            copyMessageElement.style.fontWeight = 'bold'; // Make the text bold

        }

        fetch('https://sng.nfp.mybluehost.me/checkGrammar/checkGrammar.php?action=giveAnswer', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ text: textToCheck })
        })
        .then(response => response.json())
        .then(handleResponse)
        .catch((error) => {
            console.error('Error:', error);
        });
    }, false);
});

function getSelectedText() {
    return window.getSelection().toString();
}

document.getElementById('pasteTextButton').addEventListener('click', function() {
    chrome.tabs.query({active: true, currentWindow: true}, function(tabs) {
        if (tabs.length) {
            chrome.tabs.sendMessage(tabs[0].id, {action: "pasteText", text: document.getElementById('textToCheck').value});
            setTimeout(function() { window.close(); }, 100); // Wait for 100ms before closing
        }
    });
});


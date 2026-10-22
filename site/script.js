const demo = document.querySelector('.app-window');
const demoButtons = document.querySelectorAll('[data-run-demo]');
let demoTimer;

function runDemo() {
  if (!demo) return;
  window.clearTimeout(demoTimer);
  demo.classList.remove('is-running');
  demo.querySelector('.window-status').lastChild.textContent = ' Ready';
  void demo.offsetWidth;
  demo.classList.add('is-running');
  demo.querySelector('.window-status').lastChild.textContent = ' Processing';
  demoTimer = window.setTimeout(() => {
    demo.querySelector('.window-status').lastChild.textContent = ' Pasted back';
  }, 1450);
}

demoButtons.forEach((button) => button.addEventListener('click', () => {
  runDemo();
  if (button.closest('.hero-copy')) {
    demo.scrollIntoView({ behavior: 'smooth', block: 'center' });
  }
}));

const proofreader = document.querySelector('[data-proofreader]');
const proofreadInput = proofreader?.querySelector('[data-proofread-input]');
const proofreadOutput = proofreader?.querySelector('[data-proofread-output]');
const proofreadStatus = proofreader?.querySelector('[data-proofread-status]');
const characterCount = proofreader?.querySelector('[data-character-count]');
const copyResult = proofreader?.querySelector('[data-copy-result]');
const submitButton = proofreader?.querySelector('.web-submit');
const submitLabel = submitButton?.querySelector('span');
const resultText = proofreadOutput?.querySelector('.web-output-result');
const errorText = proofreadOutput?.querySelector('.web-output-error');
let activeProofreadRequest;

function trackProofreaderEvent(name) {
  if (typeof window.gtag === 'function') {
    window.gtag('event', name, { event_category: 'online_proofreader' });
  }
}

function setProofreaderState(state, message) {
  if (!proofreader) return;
  proofreader.classList.remove('is-loading', 'has-result', 'has-error');
  if (state) proofreader.classList.add(state);
  proofreadStatus.textContent = message;
}

function updateCharacterCount() {
  if (!proofreadInput || !characterCount) return;
  characterCount.textContent = `${proofreadInput.value.length.toLocaleString('en-US')} / 4,000`;
}

async function proofreadText(text) {
  activeProofreadRequest?.abort();
  const requestController = new AbortController();
  activeProofreadRequest = requestController;
  const timeout = window.setTimeout(() => requestController.abort(), 30_000);

  try {
    const response = await fetch('/api/proofread', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text }),
      signal: requestController.signal,
    });
    const payload = await response.json().catch(() => ({}));
    if (!response.ok) {
      throw new Error(payload.error || 'SpeedProof could not process the text. Please try again.');
    }
    return payload.result;
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new Error('Proofreading took too long. Please try again.');
    }
    throw error;
  } finally {
    window.clearTimeout(timeout);
  }
}

proofreadInput?.addEventListener('input', () => {
  updateCharacterCount();
  if (proofreader.classList.contains('has-error')) setProofreaderState('', 'Ready');
});

proofreadInput?.addEventListener('keydown', (event) => {
  if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') {
    event.preventDefault();
    proofreader.requestSubmit();
  }
});

proofreader?.addEventListener('submit', async (event) => {
  event.preventDefault();
  const text = proofreadInput.value.trim();

  if (!text) {
    errorText.textContent = 'Paste or type some text first.';
    setProofreaderState('has-error', 'Text required');
    proofreadInput.focus();
    return;
  }

  submitButton.disabled = true;
  submitLabel.textContent = 'Improving…';
  copyResult.disabled = true;
  resultText.textContent = '';
  errorText.textContent = '';
  setProofreaderState('is-loading', 'Improving text…');
  trackProofreaderEvent('proofread_started');

  try {
    resultText.textContent = await proofreadText(text);
    copyResult.disabled = false;
    setProofreaderState('has-result', 'Ready to copy');
    trackProofreaderEvent('proofread_completed');
  } catch (error) {
    errorText.textContent = error.message;
    setProofreaderState('has-error', 'Could not improve text');
    trackProofreaderEvent('proofread_failed');
  } finally {
    submitButton.disabled = false;
    submitLabel.textContent = 'Improve text';
  }
});

copyResult?.addEventListener('click', async () => {
  if (!resultText.textContent) return;
  try {
    await navigator.clipboard.writeText(resultText.textContent);
    copyResult.querySelector('span').textContent = 'Copied';
    proofreadStatus.textContent = 'Copied to clipboard';
    trackProofreaderEvent('proofread_copied');
    window.setTimeout(() => {
      copyResult.querySelector('span').textContent = 'Copy';
      proofreadStatus.textContent = 'Ready to copy';
    }, 1800);
  } catch {
    proofreadStatus.textContent = 'Select the result to copy it';
  }
});

updateCharacterCount();

if (!window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
  window.setTimeout(runDemo, 500);
}

document.querySelectorAll('a[href^="#"]').forEach((link) => {
  link.addEventListener('click', (event) => {
    const target = document.querySelector(link.getAttribute('href'));
    if (!target) return;
    event.preventDefault();
    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
  });
});


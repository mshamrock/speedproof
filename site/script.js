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


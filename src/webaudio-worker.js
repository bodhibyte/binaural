const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
let leftOscillator;
let rightOscillator;

onmessage = function(e) {
  if (e.data === 'start') {
    leftOscillator = audioCtx.createOscillator();
    leftOscillator.type = 'sine';
    leftOscillator.frequency.value = 440;
    leftOscillator.start();

    rightOscillator = audioCtx.createOscillator();
    rightOscillator.type = 'sine';
    rightOscillator.frequency.value = 450;
    rightOscillator.start();

    // create panner nodes
    const leftPanner = audioCtx.createStereoPanner();
    leftPanner.pan.value = -1; // set to full left
    leftOscillator.connect(leftPanner).connect(audioCtx.destination);

    const rightPanner = audioCtx.createStereoPanner();
    rightPanner.pan.value = 1; // set to full right
    rightOscillator.connect(rightPanner).connect(audioCtx.destination);
  } else if (e.data === 'stop') {
    leftOscillator.stop();
    rightOscillator.stop();
  }
}

(function generateDiceWav() {
  const sampleRate = 44100;
  const duration = 0.15; // 150 ms para un impacto corto y seco
  const numSamples = sampleRate * duration;
  
  // Crear Contexto de Audio Offline
  const offlineCtx = new OfflineAudioContext(1, numSamples, sampleRate);
  
  // 1. Capa de Ruido Blanco (Fricción/Choque inicial)
  const bufferSize = numSamples;
  const noiseBuffer = offlineCtx.createBuffer(1, bufferSize, sampleRate);
  const output = noiseBuffer.getChannelData(0);
  for (let i = 0; i < bufferSize; i++) {
    output[i] = Math.random() * 2 - 1;
  }
  
  const noise = offlineCtx.createBufferSource();
  noise.buffer = noiseBuffer;

  // Filtro Paso Banda para simular la resonancia de la resina/madera (1200 Hz)
  const filter = offlineCtx.createBiquadFilter();
  filter.type = 'bandpass';
  filter.frequency.value = 1200;
  filter.Q.value = 3.0;

  // Envolvente de Volumen (Ataque explosivo instantáneo y decaimiento rápido)
  const gainNode = offlineCtx.createGain();
  gainNode.gain.setValueAtTime(1.0, 0);
  gainNode.gain.exponentialRampToValueAtTime(0.001, 0.08); // Cae a casi 0 en 80ms

  // 2. Capa de Tono Grave (Cuerpo del impacto)
  const osc = offlineCtx.createOscillator();
  const oscGain = offlineCtx.createGain();
  osc.type = 'triangle';
  osc.frequency.setValueAtTime(180, 0);
  osc.frequency.exponentialRampToValueAtTime(40, 0.05); // Caída de tono rápido
  
  oscGain.gain.setValueAtTime(0.7, 0);
  oscGain.gain.exponentialRampToValueAtTime(0.001, 0.06);

  // Conexiones
  noise.connect(filter);
  filter.connect(gainNode);
  gainNode.connect(offlineCtx.destination);
  
  osc.connect(oscGain);
  oscGain.connect(offlineCtx.destination);

  // Iniciar fuentes
  noise.start(0);
  osc.start(0);

  // Renderizar a Buffer
  offlineCtx.startRendering().then(renderedBuffer => {
    const pcmData = renderedBuffer.getChannelData(0);
    const wavBuffer = createWavBuffer(pcmData, sampleRate);
    
    // Disparar descarga del archivo .wav
    const blob = new Blob([wavBuffer], { type: 'audio/wav' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'dado_impacto.wav';
    a.click();
    URL.revokeObjectURL(url);
  });

  // Función interna para estructurar las cabeceras WAV en binario
  function createWavBuffer(samples, sampleRate) {
    const buffer = new ArrayBuffer(44 + samples.length * 2);
    const view = new DataView(buffer);

    const writeString = (offset, string) => {
      for (let i = 0; i < string.length; i++) {
        view.setUint8(offset + i, string.charCodeAt(i));
      }
    };

    writeString(0, 'RIFF');
    view.setUint32(4, 36 + samples.length * 2, true);
    writeString(8, 'WAVE');
    writeString(12, 'fmt ');
    view.setUint32(16, 16, true);
    view.setUint16(20, 1, true); // PCM
    view.setUint16(22, 1, true); // Mono
    view.setUint32(24, sampleRate, true);
    view.setUint32(28, sampleRate * 2, true);
    view.setUint16(32, 2, true);
    view.setUint16(34, 16, true); // 16 bits
    writeString(36, 'data');
    view.setUint32(40, samples.length * 2, true);

    let offset = 44;
    for (let i = 0; i < samples.length; i++, offset += 2) {
      const s = Math.max(-1, Math.min(1, samples[i]));
      view.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7FFF, true);
    }

    return buffer;
  }
})();
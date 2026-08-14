import math
import random
import struct
import wave


def generate_single_dice_pop_wav(filename="dado_impacto_primario.wav"):
    sample_rate = 44100
    duration = 0.04  # 40 milisegundos (transitorio muy corto)
    num_samples = int(sample_rate * duration)

    # Filtro paso banda centrado en resina/madera dura (1400 Hz)
    center_freq = 1400.0
    q_factor = 2.5
    w0 = 2.0 * math.pi * center_freq / sample_rate
    alpha = math.sin(w0) / (2.0 * q_factor)

    b0 = alpha / (1.0 + alpha)
    b1 = 0.0
    b2 = -alpha / (1.0 + alpha)
    a1 = (-2.0 * math.cos(w0)) / (1.0 + alpha)
    a2 = (1.0 - alpha) / (1.0 + alpha)

    x1 = x2 = y1 = y2 = 0.0
    samples = []

    for i in range(num_samples):
        t = i / sample_rate

        # Impulso de ruido inicial
        white_noise = random.uniform(-1.0, 1.0)

        # Filtrado
        x0 = white_noise
        filtered = b0 * x0 + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        x2, x1 = x1, x0
        y2, y1 = y1, filtered

        # Envolvente ultrarrápida (Ataque en 0ms, caída casi vertical en 8ms)
        env = math.exp(-t / 0.003)
        sample = filtered * env

        # Normalización a 16-bit PCM
        int_sample = int(max(-1.0, min(1.0, sample)) * 32767)
        samples.append(int_sample)

    with wave.open(filename, "w") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)

        binary_data = bytearray()
        for s in samples:
            binary_data.extend(struct.pack("<h", s))

        wav_file.writeframes(binary_data)

    print(f"Archivo micro-impacto '{filename}' generado.")


if __name__ == "__main__":
    generate_single_dice_pop_wav()
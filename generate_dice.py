import math
import random
import struct
import wave


def generate_dice_impact_wav(filename="dado_impacto.wav"):
    sample_rate = 44100
    duration = 0.15  # 150 milisegundos
    num_samples = int(sample_rate * duration)

    # Parámetros del filtro paso banda (Simulación de resina/madera)
    center_freq = 1200.0
    q_factor = 3.0
    w0 = 2.0 * math.pi * center_freq / sample_rate
    alpha = math.sin(w0) / (2.0 * q_factor)

    # Coeficientes del filtro Biquad Paso Banda
    b0 = alpha
    b1 = 0.0
    b2 = -alpha
    a0 = 1.0 + alpha
    a1 = -2.0 * math.cos(w0)
    a2 = 1.0 - alpha

    # Normalización de coeficientes
    b0 /= a0
    b1 /= a0
    b2 /= a0
    a1 /= a0
    a2 /= a0

    # Estados anteriores del filtro
    x1 = x2 = y1 = y2 = 0.0

    samples = []

    for i in range(num_samples):
        t = i / sample_rate

        # 1. Capa de Ruido Blanco (Fricción/Golpe inicial)
        white_noise = random.uniform(-1.0, 1.0)

        # Aplicar Filtro Paso Banda al ruido
        x0 = white_noise
        filtered_noise = (
            b0 * x0 + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
        )  # Biquad Direct Form I
        x2, x1 = x1, x0
        y2, y1 = y1, filtered_noise

        # Envolvente del ruido (Ataque instantáneo, caída exponencial rápida a 80ms)
        noise_env = math.exp(-t / 0.015) if t < 0.08 else 0.0
        noise_signal = filtered_noise * noise_env

        # 2. Capa de Tono Grave (Cuerpo del impacto)
        # Caída de frecuencia rápida de 180 Hz a 40 Hz
        freq = 180.0 * math.exp(-t / 0.015)
        if freq < 40.0:
            freq = 40.0

        # Onda triangular para el cuerpo grave
        phase = (t * freq) % 1.0
        triangular_wave = 4.0 * abs(phase - 0.5) - 1.0

        # Envolvente del cuerpo grave
        tone_env = math.exp(-t / 0.012) if t < 0.06 else 0.0
        tone_signal = triangular_wave * 0.7 * tone_env

        # Mezcla de ambas capas y limitación de amplitud
        mixed_sample = noise_signal + tone_signal
        mixed_sample = max(-1.0, min(1.0, mixed_sample))

        # Convertir a formato PCM entero de 16 bits
        int_sample = int(mixed_sample * 32767)
        samples.append(int_sample)

    # Generación y escritura del archivo WAV
    with wave.open(filename, "w") as wav_file:
        # Configuración: 1 Canal (Mono), 2 Bytes por muestra (16 bits), 44100 Hz
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)

        # Empaquetar las muestras en binario
        binary_data = bytearray()
        for sample in samples:
            binary_data.extend(struct.pack("<h", sample))

        wav_file.writeframes(binary_data)

    print(f"Archivo '{filename}' generado correctamente.")


if __name__ == "__main__":
    generate_dice_impact_wav()
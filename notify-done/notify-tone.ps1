# notify-tone.ps1 - 远方空谷巨兽 + 弥散混响晨唤铃 (Smeared Reverb Edition)
# 纯 PowerShell 动态合成 WAV

param(
    [ValidateRange(0, 100)]
    [int]$Volume = 80
)

function New-AlertTone {
    param([int]$Vol = 80)

    $sampleRate   = 44100
    $duration     = 10.0
    $totalSamples = [int]($sampleRate * $duration)
    $amplitude    = [math]::Min(($Vol / 100.0) * 0.82, 0.82)

    $bitsPerSample = 16
    $channels      = 1
    $byteRate      = $sampleRate * $channels * ($bitsPerSample / 8)
    $blockAlign    = $channels * ($bitsPerSample / 8)
    $dataSize      = $totalSamples * $blockAlign

    $samples = New-Object 'double[]' $totalSamples
    $twoPi   = 2.0 * [math]::PI

    $globalEnv = {
        param($t, $dur)
        if ($t -gt ($dur - 3.0)) {
            $fade = ($dur - $t) / 3.0
            return [math]::Max(0, $fade * $fade) # 平方淡出，更柔
        }
        return 1.0
    }

    for ($i = 0; $i -lt $totalSamples; $i++) {
        $t = $i / $sampleRate
        $sample = 0.0
        $gEnv = & $globalEnv $t $duration

        # ========================================
        # Layer 1: 远方空谷巨兽 (柔和低频底色)
        # ========================================
        $beacons = @(
            @{ T = 0.0; F = 174.6; Vol = 0.22 },  # F3
            @{ T = 2.8; F = 196.0; Vol = 0.22 },  # G3
            @{ T = 5.6; F = 130.8; Vol = 0.30 }   # C3
        )

        foreach ($b in $beacons) {
            $bT = [double]$b.T
            $bF = [double]$b.F
            $bV = [double]$b.Vol

            if ($t -ge $bT) {
                $td = $t - $bT

                # 极缓慢起音 + 极缓慢衰减
                $att = 0.5
                $env = 0.0
                if ($td -lt $att) {
                    $r = $td / $att
                    $env = $r * $r
                } else {
                    $env = [math]::Exp(-($td - $att) * 0.5)
                }

                $tone = [math]::Sin($twoPi * $bF * $td) * 0.8 +
                        [math]::Sin($twoPi * ($bF * 1.5) * $td) * 0.2

                $sample += $tone * $env * $bV

                # 多层弥散回声（低频）
                $lowDelays  = @(0.7, 1.3, 2.0, 2.8)
                $lowEchoVol = @(0.40, 0.28, 0.18, 0.10)
                for ($d = 0; $d -lt $lowDelays.Count; $d++) {
                    $eTd = $td - $lowDelays[$d]
                    if ($eTd -gt 0) {
                        # 涌动式包络：缓起缓落
                        $rise = 1.2 / ($d + 1)
                        $eEnv = ($eTd * $rise) * [math]::Exp(-$eTd * $rise)
                        $eTone = [math]::Sin($twoPi * $bF * $eTd)
                        $sample += $eTone * $eEnv * $bV * $lowEchoVol[$d]
                    }
                }
            }
        }

        # ========================================
        # Layer 2: 弥散混响铃音 (Smeared Chimes)
        # ========================================
        # 关键变化：
        #   - 去掉了高阶泛音（3x, 4x），只留基频和微失谐，让音色"圆"
        #   - 主音衰减极慢（exp * -2.0 而非 -6.0），拖着长长的尾巴
        #   - 回声 5 层密集叠加，间隔从 0.15s 到 1.8s，制造弥散"糊"感
        #   - 回声用柔和的涌动式包络（rise-fall）而非硬瞬态

        $chimes = @(
            @{ T = 0.9;  F = 1046.5; Vol = 0.30 },  # C6
            @{ T = 1.5;  F = 1318.5; Vol = 0.32 },  # E6

            @{ T = 3.6;  F = 1174.7; Vol = 0.30 },  # D6
            @{ T = 4.2;  F = 1567.9; Vol = 0.32 },  # G6

            @{ T = 6.4;  F = 1567.9; Vol = 0.35 },  # G6
            @{ T = 6.9;  F = 1318.5; Vol = 0.30 },  # E6
            @{ T = 7.4;  F = 1046.5; Vol = 0.38 }   # C6 (落点)
        )

        foreach ($c in $chimes) {
            $cT = [double]$c.T
            $cF = [double]$c.F
            $cV = [double]$c.Vol

            if ($t -ge $cT) {
                $td = $t - $cT

                # 主音：缓起音（0.06s）+ 极慢衰减（模拟远处传来 = 边缘模糊）
                $attC = 0.06
                $envC = 0.0
                if ($td -lt $attC) {
                    $envC = $td / $attC
                } else {
                    $envC = [math]::Exp(-($td - $attC) * 2.0)
                }

                # 音色：只用基频 + 轻微失谐（chorus），没有高次谐波
                # 这样声音是"圆润模糊"的，不是"清脆锐利"的
                $chime = [math]::Sin($twoPi * $cF * $td) * 0.65 +
                         [math]::Sin($twoPi * ($cF * 1.003) * $td) * 0.35  # 微失谐 chorus

                $sample += $chime * $envC * $cV

                # 5 层弥散回声（密集叠加，制造"糊上"的混响尾巴）
                $cDelays  = @(0.15, 0.35, 0.65, 1.1, 1.8)
                $cEchoVol = @(0.50, 0.38, 0.28, 0.18, 0.10)

                for ($d = 0; $d -lt $cDelays.Count; $d++) {
                    $eTd = $td - $cDelays[$d]
                    if ($eTd -gt 0) {
                        # 涌动包络：声音不是"砰"一下出现，而是缓缓涌起再散去
                        $riseRate = 3.5 / (1.0 + $d * 0.5)
                        $eEnv = ($eTd * $riseRate) * [math]::Exp(-$eTd * $riseRate)
                        # 每层回声加一点点额外失谐，让它越来越"糊"
                        $detune = 1.0 + ($d + 1) * 0.002
                        $eChime = [math]::Sin($twoPi * ($cF * $detune) * $eTd) * 0.6 +
                                  [math]::Sin($twoPi * $cF * $eTd) * 0.4
                        $sample += $eChime * $eEnv * $cV * $cEchoVol[$d]
                    }
                }
            }
        }

        # ========================================
        # Layer 3: 极微弱的空气底噪
        # ========================================
        $noiseEnv = $gEnv * 0.002
        $noise = (($i * 1103515245 + 12345) % 2147483648) / 2147483648.0 * 2 - 1
        $sample += $noise * $noiseEnv

        $sample = $sample * $gEnv * $amplitude
        $sample = [math]::Max(-0.98, [math]::Min(0.98, $sample))
        $samples[$i] = $sample
    }

    $stream = New-Object System.IO.MemoryStream
    $writer = New-Object System.IO.BinaryWriter($stream)

    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("RIFF"))
    $writer.Write([int](36 + $dataSize))
    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("WAVE"))

    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("fmt "))
    $writer.Write([int]16)
    $writer.Write([int16]1)
    $writer.Write([int16]$channels)
    $writer.Write([int]$sampleRate)
    $writer.Write([int]$byteRate)
    $writer.Write([int16]$blockAlign)
    $writer.Write([int16]$bitsPerSample)

    $writer.Write([System.Text.Encoding]::ASCII.GetBytes("data"))
    $writer.Write([int]$dataSize)

    for ($i = 0; $i -lt $totalSamples; $i++) {
        $val = [int]($samples[$i] * 32767)
        $val = [math]::Max(-32768, [math]::Min(32767, $val))
        $writer.Write([int16]$val)
    }

    $writer.Flush()
    $stream.Position = 0

    $player = New-Object System.Media.SoundPlayer($stream)
    $player.PlaySync()

    $player.Dispose()
    $writer.Dispose()
    $stream.Dispose()
}

New-AlertTone -Vol $Volume

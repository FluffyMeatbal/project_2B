    .global MAF					// Maak de functie zichtbaar voor de C-code
    .extern samples           	// Verwijs naar de globale samples array
    .extern n_overSample      	// Verwijs naar de globale n_overSample
    .extern movingAverage     	// Verwijs naar de globale movingAverage

MAF:
    // Initialisatie
    mov r0, #0               	// i = 0
    mov r1, #0               	// correctSamples = 0
    mov r2, #0               	// average = 0
    mov r3, #0               	// tijdelijke variabele voor movingAverage
    ldr r4, =n_overSample    	// r4 = n_overSample
    ldr r5, =samples         	// r5 = samples array base address

loop:
    cmp r0, r4               	// if i >= n_overSample, break loop
    bge end_loop

    ldr r6, [r5, r0, lsl #2] 	// r6 = samples[i] (assuming 4-byte integers)
    cmp r6, #0               	// if samples[i] == 0
    beq skip_sample          	// skip if zero

    add r1, r1, #1           	// correctSamples += 1
    add r2, r2, r6           	// average += samples[i]

skip_sample:
    add r0, r0, #1           	// i++
    b loop

end_loop:
    cmp r1, #0               	// if correctSamples == 0
    beq skip_calculation
    udiv r3, r2, r1          	// r3 = average / correctSamples

    // Laad het adres van movingAverage in een register (r7) en sla de waarde op
    ldr r7, =movingAverage   	// laad het adres van movingAverage in r7
    str r3, [r7]             	// sla de waarde van r3 (movingAverage) op in de globale variabele

    // Controleer op afronding
    mov r6, r2               	// r6 = average
    udiv r7, r6, r1          	// r7 = average / correctSamples
    mul r7, r7, r1           	// r7 = (average / correctSamples) * correctSamples
    sub r6, r6, r7           	// r6 = average % correctSamples
    cmp r6, r7               	// if (average % correctSamples) > (average / 2)
    bgt increment_moving_average
    b skip_increment

increment_moving_average:
    add r3, r3, #1           	// movingAverage += 1
    str r3, [r7]             	// sla de nieuwe movingAverage waarde op in de globale variabele

skip_increment:
skip_calculation:
    // Nu is movingAverage bijgewerkt
    bx lr                    	// Terug naar de aanroeper (C-code)

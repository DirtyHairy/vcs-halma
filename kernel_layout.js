let clock = 89;

for (let row = 0; row < 7; row++) {
    console.log(`sep    ${clock} / ${(clock / 3).toFixed(2)}`);
    clock += 4;

    console.log(`line   ${clock} / ${(clock / 3).toFixed(2)}`);
    clock += 12;

    console.log(`sep    ${clock} / ${(clock / 3).toFixed(2)}`);
    clock += 4;

    console.log();
}

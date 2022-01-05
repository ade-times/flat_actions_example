// Installs necessary packages
const r_install = Deno.run({
    cmd: ['sudo', 'Rscript', '-e', "install.packages(c('dplyr', 'readxl', 'readr', 'lubridate', 'tidyr', 'zoo'))"]
});

await r_install.status();

// Forwards the execution to the R script
const r_run = Deno.run({
    cmd: ['Rscript', './test_flat_data.R']
});

await r_run.status();

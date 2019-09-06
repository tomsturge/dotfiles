const fs = require('fs');
const readline = require('readline');
const { exec } = require('child_process');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const colors = {
    reset: "\x1b[0m",
    clear: "\x1b[2J",
    fgblack: "\x1b[30m",
    fgred: "\x1b[31m",
    fggreen: "\x1b[32m",
    fgyellow: "\x1b[33m",
    fgblue: "\x1b[34m",
    fgmagenta: "\x1b[35m",
    fgcyan: "\x1b[36m",
    fgwhite: "\x1b[37m",
    bgblack: "\x1b[40m",
    bgred: "\x1b[41m",
    bggreen: "\x1b[42m",
    bgyellow: "\x1b[43m",
    bgblue: "\x1b[44m",
    bgmagenta: "\x1b[45m",
    bgcyan: "\x1b[46m",
    bgwhite: "\x1b[47m",
};

console.clear();
console.log(`Welcome to${colors.fgcyan} 
__          __        _    _                     _ 
\\ \\        / /       | |  | |                   | |
 \\ \\  /\\  / /__  _ __| | __ |__   ___ _ __   ___| |__
  \\ \\/  \\/ / _ \\| '__| |/ / '_ \\ / _ \\ '_ \\ / __| '_ \\
   \\  /\\  / (_) | |  |   <| |_) |  __/ | | | (__| | | |
    \\/  \\/ \\___/|_|  |_|\\_\\_.__/ \\___|_| |_|\\___|_| |_|${colors.reset}

=======================================================

Welcome to ${colors.fgcyan}Workbench${colors.reset}, your friendly environment setup 
automation helper.
`);

let nodeVersion;

const question1 = () => new Promise(res => {
    rl.question('Are you setting up a new computer? (yes) ', ans => {
        if (ans === 'yes' || ans === '') {
            exec('node --version', (err, stdout) => {
                if (err) {
                // node couldn't execute the command
                return;
                }
                
                nodeVersion = stdout;
            })
            res();
        } if (ans === 'no') {
            console.log(`Oh! Why did you start this process then... Quitting.`);
            rl.close();
        }
    });
});

const question2 = () => new Promise(res => {
    rl.question('Where do you want to store your projects? (~/projects) ', ans => {
        let dir = ans || `${process.env.HOME}/projects`;

        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, err => console.log(err))
        }
        res();
    });
});

const main = async () => {
    await question1();
    await question2();
    rl.close();
};

main();

// fs.symlink(
//     '../package.json', 
//     './new-package.json',  
//     (err) => console.log(err || "Done."),
// )
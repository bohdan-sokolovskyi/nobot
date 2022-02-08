/* 
    Bot generated by NOBOT v.0.0.1 platform 23.03.21 
    Author: Bohdan Sokolovskyi
    Version: 0.0.1
*/

import {Bot, TelegramApplication, WebApplication} from '../src/wisteria.js';

const bot = new Bot({
    name: 'Tom',
    type: 'chat',
    startFrom: 'a'
});
// const application = new WebApplication({
//     host: 'localhost',
//     port: 3000
// });

const application = new TelegramApplication({
   token: '***********************************'
});

bot.use({
    userName: null
});

bot.on("a", (inputMsg, controller) => {
    if (inputMsg === "Hello") {
        controller.say("Hello, what is your name?");
        controller.next("b");
    } else {
        controller.next("def");
    }
});

bot.on("b", (inputMsg, controller) => {
    controller.save(inputMsg, "userName");
    controller.next("a");
});

bot.on("def", (inputMsg, controller) => {
    controller.say("Sorry, i don't understand you");
    controller.next("a");
});

application.configure(bot).run();

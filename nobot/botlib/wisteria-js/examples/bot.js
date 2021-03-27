/* 
    Bot generated by NOBOT v.0.0.1 platform 23.03.21 
    Author: Bohdan Sokolovskyi
    Version: 0.0.1
*/

import {Bot, BotOptions} from '../src/wisteria.js'

const options = new BotOptions()
    .setHost('localhost')
    .setName('Tom')
    .setPort(3000)
    .setType('chat')
    .setPlatform('web')
const bot = new Bot(options)

let userName = null;

bot.on("a", (inputMsg, controller) => {
    if (inputMsg === "Hello") {
        controller.say("Hello, what is your name?")
        controller.next("b")
    } else {
        controller.next("def")
    }
})

bot.on("b", (inputMsg, controller) => {
    userName = inputMsg
    controller.next("a")
})

bot.on("c", (inputMsg, controller) => {
    controller.say("Sorry, i don't understand you")
    controller.next("a")
})

bot.configure().runFrom("a")
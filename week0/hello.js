function sayHello(name) {
    console.log("Hello, " + name);
}

function sayHelloToConsole(name) {
    console.log("Hello, " + name);
}

function returnSayHello(name) {
    return "Hello, " + name;
}

sayHello("Caliban");
sayHello("Miranda");
sayHello("Ferdinand");

sayHelloToConsole('John');

var greeting = returnSayHello('John');
console.log(greeting);

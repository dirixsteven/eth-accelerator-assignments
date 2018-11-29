var myFn = function() {
    console.log("I am function.");
}

myFn.someAttribute = 42;
console.log(myFn.someAttribute);

function runner(f) {
    f();
}

runner(myFn);

function findWaldo(arr, found) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] === "Waldo") {
            console.log("Found him!");
            found(i);
        }
    }
}

function actionWhenFound() {
    console.log("Found him!");
}

findWaldo(["Alice", "Bob", "Waldo", "Winston"], function(result) {
    console.log("The result is:", result);
});

var outer = function() {
    var x = 10;

    var inner = function() {
        console.log("The value of x is: " + x);
    }

    return inner;
}

var foo = outer();
foo();
// Task 1: Repeating Numbers

var repeatNumbers = function(data) {
    var datastring = "";
    for (var i = 0; i < data.length; i++) {
        if (i>0) {datastring += ", ";}
        for (var j = 0; j < data[i][1]; j++) {
            datastring += data[i][0];
        }
    }
    return datastring;
};

console.log(repeatNumbers([[1,10]]));
console.log(repeatNumbers([[1, 2], [2, 3]]));
console.log(repeatNumbers([[10, 4], [34, 6], [92, 2]]));

// Task 2: Conditional Sums

var conditionalSum = function(values, condition) {
    
    function checkCondition(value) {
        if (condition == "even" && value%2 === 0) {
            return value;
        } else if (condition == "odd" && value%2 !== 0) {
            return value;
        } else {
            return 0;
        }
    }

    var total = 0;

    for (var i = 0; i < values.length; i++) {
        total += checkCondition(values[i]);
    }

    return total;
};
  
console.log(conditionalSum([1, 2, 3, 4, 5], "even"));
console.log(conditionalSum([1, 2, 3, 4, 5], "odd"));
console.log(conditionalSum([13, 88, 12, 44, 99], "even"));
console.log(conditionalSum([], "odd"));

// Task 3: Talking Calendar

var talkingCalendar = function(date) {
    
    var datestring;

    // check month
    var months = {1: "January", 2: "February", 3: "March", 4: "April", 5: "May", 6: "June", 7: "July", 8: "August", 9: "September", 10: "October", 11: "November", 12: "December"};
    datestring = months[Number(date.substring(5,7))] + " ";
    
    // check day
    var st = ["01","21","31"];
    var rd = ["03","23"];
    var nd = ["02","22"];

    if (st.indexOf(date.substring(8,10)) >= 0) {
        datestring += Number(date.substring(8,10)) + "st, ";
    } else if (nd.indexOf(date.substring(8,10)) >= 0) {
        datestring += Number(date.substring(8,10)) + "nd, ";
    } else if (rd.indexOf(date.substring(8,10)) >= 0) {
        datestring += Number(date.substring(8,10)) + "rd, ";
    } else {
        datestring += Number(date.substring(8,10)) + "th, ";
    }

    // check year
    datestring += date.substring(0,4);
    
    return datestring;
};
  
console.log(talkingCalendar("2017/12/02"));
console.log(talkingCalendar("2007/11/11"));
console.log(talkingCalendar("1987/08/24"));

// Task 4: Challenge Calculator

var calculateChange = function(total, cash) {
    var returnValue = cash - total;
    var change = {};
    var coinTypes = [2000, 1000, 500, 200, 100, 25, 10, 5, 1];
    var denominations = ["twentyDollar", "ten", "fiveDollar", "twoDollar", "dollar", "quarter", "dime", "nickel", "penny"];
    var amount;
    
    for (var i = 0; i < coinTypes.length; i++) {
        amount = Math.floor(returnValue/coinTypes[i]);
        if (amount > 0) {
            change[denominations[i]] = amount;
            returnValue = returnValue%coinTypes[i];
        }
    }

    return change;
};
  
console.log(calculateChange(1787, 2000));
console.log(calculateChange(2623, 4000));
console.log(calculateChange(501, 1000));
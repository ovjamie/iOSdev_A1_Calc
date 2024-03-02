//
//  main.swift
//  calc
//
//  Created by Jesse Clark on 12/3/18.
//  Copyright © 2018 UTS. All rights reserved.
//

// submitted by Jamie Ocumen Vallo
// student ID: 14344384
// 41889 Application Development in the iOS Environment

import Foundation

var args = ProcessInfo.processInfo.arguments; //an array of strings representing the command-line arguments; each element                                               of the array represents a single command-line argument.
args.removeFirst(); // remove the name of the program

//print(args); //testing

//separate args into numbers and operators
func processArgs(_ args:[String]) -> ([Int], [String]){
    var numbers = [Int]();
    var operators = [String]();
    
    for arg in args{
        if(arg.starts(with: "-") || arg.starts(with: "+")) && arg.count > 1{
            if let num = Int(arg.suffix(from: arg.index(after: arg.startIndex))){
                if arg.starts(with: "-"){
                    numbers.append(-num);
                }else{
                    numbers.append(num);
                }
            }
        }else if let num = Int(arg){
            numbers.append(num);
        }else{
            operators.append(arg);
        }
    }
    
    return (numbers, operators);
}

class HandleErrors{
    
    let validOperators:[String] = ["+", "-", "x", "/", "%"];
    
    //checks if command line arguments are valid
    func isArgsValid(_ args:[String]) -> Bool{
        guard args.count > 0 else{
            return false;
        }
//        guard let _ = Int(args[0]), let _ = Int(args[args.count - 1]) else{
//            return false;
//        }
        guard let _ = Int(args[0]) else{
            return false;
        }
//        guard args.allSatisfy({Int($0) != nil || validOperators.contains($0)}) else{
//            return false;
//        }

        //checks if input follows format: [number operator number ...]
        for i in stride(from: 1, to: (args.count) - 1, by: 2){
            if args[i].count != 1 || Int(args[i + 1]) == nil || !validOperators.contains(args[i]){
                return false;
            }
        }
        
        return true;
    }
    
    //checks division by zero errors
    func checkDivByZero(_ args:[String]) -> Bool{
        for i in stride(from: 1, to: (args.count) - 1, by: 2){
            if (args[i] == "%" || args[i] == "/") && Int(args[i + 1]) == 0{
                return true;
            }
        }
        return false; //no division by zero
    }
    
}

class Calculator{
    func evaluate(numbers:[Int], operators:[String]) -> Int{
        var result:Int = 0;
        var numbersCopy = numbers;
        var operatorsCopy = operators;
         
        guard operators.count > 1 else{
            let oneOperation = self.solve(operators[0], numbers[0], numbers[1]);
            return oneOperation;
        }
        guard !(operators.isEmpty) && numbers.count > 1 else{
            return numbers[0];
        }

        while operatorsCopy.count > 0{
            for i in 0...(operatorsCopy.count - 1){
                if "x%/".contains(operatorsCopy[i]){
                    result = self.solve(operatorsCopy[i], numbersCopy[i], numbersCopy[i + 1]);
                    operatorsCopy.remove(at: i);
                    numbersCopy.remove(at: i + 1);
                    numbersCopy.remove(at: i);
                    numbersCopy.insert(result, at: i);
                }
            }

            if !(operatorsCopy.contains("%/x")){
                while numbersCopy.count > 1{
                    result = self.solve(operatorsCopy[0], numbersCopy[0], numbersCopy[1]);
                    operatorsCopy.remove(at: 0);
                    numbersCopy.remove(at: 1);
                    numbersCopy.remove(at: 0);
                    numbersCopy.insert(result, at: 0);
                }
            }
            
        }

        return numbersCopy[0];
    }

    func solve(_ op: String, _ x:Int, _ y:Int) -> Int{
        switch op{
            case "+":
                return x + y;
            case "-":
                return x - y;
            case "x":
                return x * y;
            case "/":
                if x == 0{
                    return 0;
                }else{
                    return x / y;
                }
            case "%":
                if x == 0{
                    return 0;
                }else{
                    return x % y;
                }
            default:
                return 0;
        }
    }
}

func main(){
    let (numbers, operators) = calc.processArgs(args);
    let errorHandling = HandleErrors();
    let calculator = Calculator();
    
    //checks if command line arguments are valid and no division by zero occurs
    guard errorHandling.isArgsValid(args) else{
        print("Incomplete or invalid expression. Expected input: [number operator number ...]");
        exit(1);
    }
    guard !(errorHandling.checkDivByZero(args)) else{
        print("Division by zero");
        exit(1);
    }
    
    let result = calculator.evaluate(numbers: numbers, operators: operators);
    
    guard !(result > Int.max || result < Int.min) else{
        print("Out of bounds");
        exit(1);
    }
    
    print(result);

}

main();
    
//
//Specs:

//You are to prepare a macOS command-line tool that will act as a simple calculator. The calculator will be run from the command line and will only work with integer numbers and the following arithmetic operators: `+` `-` `x` `/` `%`. The `%` operator is the modulus operator, not percentage.
//
//For example, if the program is compiled to `calc`:
//
//    ./calc 3 + 5 - 7
//    1
//
//In the command line, the arguments are a repeated sequence in the form
//
//    number operator
//
//and ending in a
//
//    number
//
//Hitting the enter key will cause the program to evaluate the arguments and print the result. In this case `1`.
//
//The program must follow the usual rules of arithmetic which say:
//
//1. The `x` `/` and `%` operators must all be evaluated before the `+` and `–` operators.
//2. Operators must be evaluated from left to right.
//
//For example, using Rule 1
//
//> 2 + 4 x 3 – 6
//
//becomes
//
//> 2 + 12 – 6
//
//which results in
//
//> 8
//
//If we did not use Rule 1 then `2 + 4 x 3 – 6` would become `6 x 3 – 6` and then `18 – 6` and finally `12`. This is an incorrect result.
//
//If we do not use Rule 2 then the following illustrates how it can go wrong
//
//> 4 x 5 % 2
//
//Going from left to right we evaluate the `x` first, which reduces the expression to `20 % 2` which becomes `0`. If we evaluated the `%` first then the expression would reduce to `4 x 1` which becomes `4`. This is an incorrect result.
//
//Remember, we are using integer mathematics when doing our calculations, so we get integer results when doing division. For example
//
//    ./calc 20 / 3
//    6
//
//Also note that we can use the unary `+` and `–` operators. For example
//
//    ./calc -5 / +2
//    -2
//    
//    ./calc +2 - -2
//    4
//As part of your program design, it is expected you will create classes to model the problem domain.

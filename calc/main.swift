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

var args = ProcessInfo.processInfo.arguments; //an array of strings representing the command-line arguments; each element of the array represents a single command-line argument
args.removeFirst(); // remove the name of the program

// 'processArgs' function separates args into an array of numbers and an array of operators
func processArgs(_ args:[String]) -> ([Int], [String]){
    var numbers = [Int]();
    var operators = [String]();
    
    for arg in args{
        if(arg.starts(with: "-") || arg.starts(with: "+")) && arg.count > 1{ // handles both negative numbers and positive numbers with '+' on the front
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

// class HandleErrors contains functions that identify and handle errors
class HandleErrors{
    
    let validOperators:[String] = ["+", "-", "x", "/", "%"];
    
    // 'isArgsValid' function checks if command line arguments are valid
    func isArgsValid(_ args:[String], numbers:[Int], operators:[String]) -> Bool{
        guard args.count > 0 else{
            return false;
        }
        
        guard numbers.count > operators.count else{
            return false;
        }
        
        // checks if input follows format: [number operator number ...]
        guard !(validOperators.contains(args[0])) else{
            return false;
        }
        
        if operators.count > 0 {
            for i in stride(from: 1, to: (args.count) - 1, by: 2){
                if args[i].count != 1 || !validOperators.contains(args[i]){
                    return false;
                }
            }
            
            for j in stride(from: 0, to: (args.count) - 1, by: 2){
                if(args[j].starts(with: "-") || args[j].starts(with: "+")){
                    if Int(args[j].suffix(from: args[j].index(after: args[j].startIndex))) == nil || Int(args[j]) == nil{
                        return false;
                    }
                }
            }
        }

        return true;
    }
    
    // 'checkDivByZero' function checks for division by zero errors
    func checkDivByZero(numbers:[Int], operators:[String]) -> Bool{
        for i in 0...(operators.count - 1){
            if "%/".contains(operators[i]){
                if numbers[i + 1] == 0{
                    return true;
                }
            }
        }
        return false; // no division by zero
    }

}

// class Calculator contains functions that evaluate the given expression
class Calculator{
    // 'evaluate' function evaluates the given expression
    func evaluate(numbers:[Int], operators:[String]) -> Int{
        var numbersCopy = numbers;
        var operatorsCopy = operators;
        
        guard operators.count > 1 else{
            return self.solve(operators[0], numbers[0], numbers[1]);
        }
        
        // makes sure that '/' 'x' '%' operators get evaluated first
        var index:Int = 0;
        while index < operatorsCopy.count{
            if operatorsCopy[index] == "/" || operatorsCopy[index] == "x" || operatorsCopy[index] == "%"{
                let result = self.solve(operatorsCopy[index], numbersCopy[index], numbersCopy[index + 1]);
                numbersCopy[index] = result;
                numbersCopy.remove(at: index + 1);
                operatorsCopy.remove(at: index);
            }else{
                index += 1;
            }

        }

        return self.leftToRight(numbers: numbersCopy, operators: operatorsCopy);
    }

    // 'solve' function evaluates 1 operation and 2 integers; it also prevents repeating code
    func solve(_ op: String, _ x:Int, _ y:Int) -> Int{
        switch op{
            case "+":
                return x + y;
            case "-":
                return x - y;
            case "x":
                return x * y;
            case "/":
                return x / y;
            case "%":
                return x % y;
            default:
                return 0;
        }
    }
    
    // 'leftToRight' function prevents repeating code and makes sure the expression is evaluated from left to right
    func leftToRight(numbers:[Int], operators:[String]) -> Int{
        var numbersCopy = numbers;
        var operatorsCopy = operators;
        
        while(numbersCopy.count > 1){
            let result:Int;
            result = self.solve(operatorsCopy[0], numbersCopy[0], numbersCopy[1]);
            operatorsCopy.remove(at: 0);
            numbersCopy.remove(at: 1);
            numbersCopy.remove(at: 0);
            numbersCopy.insert(result, at: 0);
        }
        
        return numbersCopy[0];
    }
    
}

func main(){
    let (numbers, operators) = calc.processArgs(args);
    let errorHandling = HandleErrors();
    let calculator = Calculator();
    
    // checks if args is just a single integer
    guard numbers.count >= 1 && operators.count > 0 else{
        print(numbers[0]);
        exit(1);
    }
    // checks if command line arguments are valid and no division by zero occurs
    guard errorHandling.isArgsValid(args, numbers:numbers, operators:operators) else{
        print("Incomplete or invalid expression. Expected input: [number operator number ...]");
        exit(1);
    }
    guard !(errorHandling.checkDivByZero(numbers: numbers, operators: operators)) else{
        print("Error! Division by zero occurs.");
        exit(1);
    }
    
    // actually find and print the result of the given expression
    let result = calculator.evaluate(numbers: numbers, operators: operators);
    print(result);

}

main();

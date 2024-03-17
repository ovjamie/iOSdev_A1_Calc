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

var args = ProcessInfo.processInfo.arguments; //an array of strings representing the command-line arguments; each element of the array represents a single command-line argument.
args.removeFirst(); // remove the name of the program

//print(args); //testing

// function to separate args into numbers and operators
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

// class HandleErrors contains functions that identify and handle errors
class HandleErrors{
    
    let validOperators:[String] = ["+", "-", "x", "/", "%"];
    
    //checks if command line arguments are valid
    func isArgsValid(_ args:[String], numbers:[Int], operators:[String]) -> Bool{
        guard args.count > 0 else{
            return false;
        }
        
        guard !(validOperators.contains(args[0])) else{
            return false;
        }
        
        guard numbers.count > operators.count else{
            return false;
        }
        
        if operators.count > 0 {
            //checks if input follows format: [number operator number ...]
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
    
    //checks division by zero errors
    func checkDivByZero(numbers:[Int], operators:[String]) -> Bool{
        for i in 0...(operators.count - 1){
            if "%/".contains(operators[i]){
                if numbers[i + 1] == 0{
                    return true;
                }
            }
        }
        return false; //no division by zero
    }

}

// class Calculator contains functions that evaluate the given expression
class Calculator{
    func evaluate(numbers:[Int], operators:[String]) -> Int{
        var result:Int = 0;
        var numbersCopy = numbers;
        var operatorsCopy = operators;
        
        guard operators.count > 1 else{
            let oneOperation = self.solve(operators[0], numbers[0], numbers[1]);
            return oneOperation;
        }
        
        var index:Int = 0;
        
        while index < operatorsCopy.count{
            if operatorsCopy[index] == "/" || operatorsCopy[index] == "x" || operatorsCopy[index] == "%"{
                let solve = self.solve(operatorsCopy[index], numbersCopy[index], numbersCopy[index + 1]);
                numbersCopy.remove(at: index);
                numbersCopy.remove(at: index);
                numbersCopy.insert(solve, at: index);
                operatorsCopy.remove(at: index);
            }else{
                index += 1;
            }

        }
        
        result = self.leftToRight(numbers: numbersCopy, operators: operatorsCopy);

        return result;
    }

    // 'solve' function prevents repeating code
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
        print("Division by zero");
        exit(1);
    }
    
    // actually find the result of the given expression
    let result = calculator.evaluate(numbers: numbers, operators: operators);
    
    print(result);

}

main();

//**Max score**: 25 marks
//
//#### Functionality: 16 marks
//
//The Xcode project must unzip successfully and compile without errors.
//
//- Deduct 3 marks if there are **any** compiler warnings.
//
//- Deduct 1 mark for **each** failing test in the `CalcTest` suite.
//
//  ​
//
//#### Style: 3 marks
//
//- Deduct up to 1 mark for bad or inconsistent indentation, whitespace, or braces.
//- Deduct up to 1 mark for bad or misleading comments.
//- Deduct up to 1 mark for unclear symbol naming.
//
//#### Design: 6 marks
//
//- **Functional separation**
//    - Is the problem broken down into functions, classes and different files?
//    - Is each class addressing a meaningful problem domain?
//    - An example of **bad** functional separation: Everything in one big file with very large functions and many global variables.
//- **Loose coupling**
//    - Can parts of the code base be modified in isolation? Would changing one portion require significant changes throughout the code base?
//    - Is data passed between components in a structured way?
//    - An example of **good** loose coupling is when functionality can be re-used in multiple components and potentially different projects.
//
//- **Extensibility**
//    - Would it be easy to add more functionality? (more operations, more numerical accuracy, interactivity, variables, etc)
//    - Can extra functionality be added to the program with minimal changes. Such as supporting different levels of precedence?
//    - **Bad** extensibility would involve many hard-coded strings that are used in multiple places.
//
//- **Control flow**
//    - Are all actions of the same type handled at the same level?
//    - Can another developer understand the logic flow of your program by reading the main entry point?
//    - **Bad** control flow could be caused by exiting the program outside of the main routine.
//
//- **Error handling**
//    - Are errors detected at appropriate places? Can they be collected somewhere central?
//    - Are errors correctly thrown and caught? Are they appropriately handled in the main routine?
//    - Is the user presented with meaningful errors when they do something incorrectly such as providing invalid input?
//
//- **Marker's discretion**

/*:
 ## Exercise - Type Casting and Inspection
 
 Create a collection of type [Any], including a few doubles, integers, strings, and booleans within the collection. Print the contents of the collection.
 */
var stuff: [Any] = ["Jonny Boy", false, false, 5.2, 10]
print(stuff)
/*:
 Loop through the collection. For each integer, print "The integer has a value of ", followed by the integer value. Repeat the steps for doubles, strings and booleans.
 */
for thing in stuff {
    
    if let string = thing as? String {
        print("The String has a value of \(string)")
    }
    
    if let integer = thing as? Int {
        print("The Int has a value of \(integer)")
    }
    
    if let boolean = thing as? Bool {
        print("The Bool has a value of \(boolean)")
    }
    
    if let double = thing as? Double {
        print("The Double has a value of \(double)")
    }
}


/*:
 Create a [String : Any] dictionary, where the values are a mixture of doubles, integers, strings, and booleans. Print the key/value pairs within the collection
 */
var myStuff: [String: Any] = ["Jon": "athan", "Test": 6, "Bird": false, "Yes": 4.4]
print(myStuff)
/*:
 Create a variable `total` of type `Double` set to 0. Then loop through the dictionary, and add the value of each integer and double to your variable's value. For each string value, add 1 to the total. For each boolean, add 2 to the total if the boolean is `true`, or subtract 3 if it's `false`. Print the value of `total`.
 */
var total: Double = 0

for (_, item) in myStuff {
    if let number = item as? Int {
        total = total + Double(number)
    } else if let number = item as? Double {
        total = total + number
    }
    
    if item is String {
        total = total + Double(1)
    }
    
    if let bool = item as? Bool {
        if bool {
            total = total + 2
        } else {
            total = total - 3
        }
    }
}

print(total)

/*:
 Create a variable `total2` of type `Double` set to 0. Loop through the collection again, adding up all the integers and doubles. For each string that you come across during the loop, attempt to convert the string into a number, and add that value to the total. Ignore booleans. Print the total.
 */
var total2: Double = 0

for (_, item) in myStuff {
    
    if let number = item as? Int {
        total2 = total2 + Double(number)
    } else if let number = item as? Double {
        total2 = total2 + number
    } else if let string = item as? String, let number = Double(string) {
        total2 = total2 + number
    }
}

print(total2)

//: page 1 of 2  |  [Next: App Exercise - Workout Types](@next)

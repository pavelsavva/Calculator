Name: Pavel Savvy
SJSU ID: 012452999
SJSU email: pavel.savva@sjsu.edu

I am the student who crashed his motorcycle - I emailed Mr. Perry about that he said that I can submit the lab after the deadline. 
Also I was not able to create the .ipa file because did something wrong I was not able to sign up for the developers account. I emailed Mr. Perry about that too.

There are no special instruction to run the application other than that it needs xCode 9 and Swift 4 to be compiled. 

Initially I based my code on the code that we developed in during the first couple lectures, however eventually I had to make some substantial changes to make the calculator comply to all the requirements and also work as a real calculator. I tried to make something more useful than the default Apple calculator, so I made sure that users input evaluates as a real mathematical exception (so that 2+2*2 equals to 6 and not 8), the history displayed reflects users input better (displaying constants as constants and not their values) and I tried to ensure to the best of my ability that no user input can break the calculator. 

I used the same MVC approach, where all the calculator logic is stored in the CalculatorBrain class. However, I changed the CalculatorBrain class to be a state machine and moved some logic from ViewController to the model. Now, the controller pretty much routes users input to the model and the model decides if the input is valid for the current state (for example, a user cannot enter 2++2).

For the controller, I made one method that gets called when any of the buttons get pressed instead of having separate methods for numbers and functions.

I think this approach decouples Model from Controller and Controller from View slightly more, which makes it more extendable, and moves the logic that decides on how to react to input the model. Thus, I ended up with a very light controller that acts as a connector between the model and the view, sending the input from the View to the Model and output from the Model to the View. 

I think the final result is more extendibel, and it should be easy to add the lab 2 functionality or any additional functionality (such as parentheses, more operators, delete operation, etc) without any substantial
changes to the code, if I decide to make something that I could publish to the app store or use as a project for resumes. 
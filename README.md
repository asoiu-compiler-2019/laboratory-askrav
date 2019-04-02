# Swift Shakespeare Compiler
![Swift](http://img.shields.io/badge/swift-4.2-brightgreen.svg)

## Language Overview

> Shakespeare is a programming language created with the design goal to make the source code resemble Shakespeare plays.

> The characters in the play are variables. If you want to assign a character, let's say Hamlet, a negative value, you put him and another character on the stage and let that character insult Hamlet.

> Input and output is done be having someone tell a character to listen their heart and speak their mind. The language contains conditionals, where characters ask each other questions, and jumps, where they decide to go to a specific act or scene. Characters are also stacks that can be pushed and popped.

## Compiler Alrogithm
The algorithm can be written the next way: 

- Read the wordlists
- Read the Shakespeare source code
- Skip the title 
- Read name declarations
- Calculate the value of each name
- For every act and scene: <br>
 Parse the description 
- For every Act: <br>
Parse Act number
- For every Scene:
Parse Scene number
- While scene not finished: <br>
1 Detect the target and the speaker <br>
2 Calculate the value of the speaker’s speech <br>
3 Translate the assigning of value into C code <br>
4 Write the code into the file
- Compile the C code using GCC
- Run the executive

### Installation

Shakespeare Compiler requires [Swift 4.2](https://swift.org/download/) and [GCC](http://gcc.gnu.org) to run. <br>
Clone the project and put you `hello_world.txt` file into the **root** directory. <br>
Then simply run:

```sh
$ swift main.swift
```

For the comprehensive information about the language syntax and features refer to the [docs](https://metacpan.org/pod/distribution/Lingua-Shakespeare/lib/Lingua/Shakespeare.pod).

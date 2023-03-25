<html><head><title>For loops | The Mirin Template</title></head></html>

[Back to main page](..)
# For loops
At its core, a `for` loop is a "repeat" instruction, that means "do thing Y, X many times", with a few special rules about how it counts, defined by you.
The general structure is this:
```lua
for i = Start, End, StepSize do
  --do some stuff with i,
  --which starts at Start,
  --and goes until End,
  --with StepSize being the increment per "step"
end
```
The "`i`" part is the most important here. Everything within the `for` block is happening repeatedly for each value of `i`.
A quick example:
```lua
for i = 0, 10, 2 do
  print('HELLO, THIS IS STEP '..i)
end
```
(Note: `..` is concatenation, which combines two [strings](https://en.wikipedia.org/wiki/String_(computer_science)))
This is going to print 6 things to the console.<span style="color:red;" title="(since the start and end values are inclusive)"><sup>[?]</sup></span>
```
HELLO, THIS IS STEP 0
HELLO, THIS IS STEP 2
HELLO, THIS IS STEP 4
HELLO, THIS IS STEP 6
HELLO, THIS IS STEP 8
HELLO, THIS IS STEP 10
```
The ability to do things multiple times has many applications in programming, but it's particularly useful in mods.
If you're working in tables (as is the case with *every* modern template), you can add lots of things to a table at the same time.
Let's say for example, you want to move players back and forth every **4** beats, starting at beat **200**
```lua
for i = 200, 231, 4 do
  ease {i, 2, outCubic, 100, 'z'}
  ease {i + 2, 2, outCubic, 0, 'z'}
end
```
Starting at beat 200, this is going to move the playfields 100 pixels towards the camera, then at beat 202 move back to the starting position
Because of the `for` loop, this code will be run again, but with `i = 204`, making the playfields move forward again at 204 and back again at 206
This will carry on until `i` is greater than 231 (causing it to not run at beat 232, as the condition will have been satisfied by the time it reaches that point).

This is a very basic overview on how a `for` loop works and what it can be used for. There are many other things, like for `i,v in pairs`/`ipairs` or [`while` loops](https://en.wikipedia.org/wiki/While_loop), but this should give you a good start.
For more information on how `for` loops work, [click here](https://en.wikipedia.org/wiki/For_loop).

Original explanation written by [Taro](https://twitter.com/TaroNuke)
-- Jason Rangel-Martinez
-- CMPM 121 - 3CG
-- 6/8/25

1. Progrmming Patterns Used:
    - I used a pretty simple state pattern which determined a card's state, which then determines when they would have shadows and when they are or aren't able to be grabbed. I chose to use this pattern as it made it easy to keep each object's behavior in check, as only certain actions could be performed and only certain states could be transitioned into from any other given state.
    - I attempted to use the update method pattern, only placing parts of the code in update that needed to be updated every frame, like those dealing with the mouse's position. This was done to prevent overwhelming the code with concurrent processes each frame unneccessarily.
    - I used the prototype pattern to create clones of objects, like cards and piles, as it allowed each instance to have slight variations, like the differences between the locations or the states of individual cards.
    - I used some pretty dirty flags to determine the state of certain parts of the game, such as win conditions, due to their quick and, aptly, dirty nature in order to get the ball rolling on implementing certain features.

2.  Feedback:
    - Tyler Torrella - A big aspect of Tyler's feedback came from my use of simply the word "card" as a variable, and quick variations like card2 or even card3. I had formed a pretty bad habit of just getting these variable names out there, assuming I would need to change the code anyway, which lead to a lot of confusion when it eventually doesn't get changed. With his feedback, I sought to change all of these to be a bit more descriptive and relevant to their use, such as with my newer "heldCard" and "scoreCards".
    - Ronan Tsoi - Ronan's feedback was very helpful, in that he pointed out how I had been using a lot of redundant code where I could be using a variable instead, with one specific example being my use of gameTable[1].cardList in my enemyTurn function. Not only was this redundant, but it was also pretty much impossible to read, even with a line of comment code I had explaining that it was actually a representation of the enemy player's hand. With such a clear example, I was able to really see where I had made similar mistakes in other places, greatly improving the readability of my code.
    - Danica Dancel Carlos - While not a student of this class, I asked for her feedback since she also had coding experience, and one thing she pointed out was that I had chunks of code that seemed to never be called or otherwise used. These came from my previous project 2, and while I thought I had gotten rid of all of them, certain old functions that were similar to newer functions ended up slipping by. Even though this was a pretty simple mistake in hindsight, it made me more aware of what code was actually still being used as the code constantly iterates and evolves, allowing me to recognize when certain functions have been replaced or can easily be replaced as the overall structure of the code changes.

3.  Postmortem:
    - This project was very rough to say the least. When it was first announced, I actually got really excited about the idea of using the solitaire experience to make my own game from the ground up, even if the rules and framework were given in the assignment instructions. However, due to circumstances with a teammate in another class, I ended up falling really behind in said class, which really impacted the amount of work I was able to put into this project. Honesly, if I could do it all again, I do wish I would've made a bigger effort in making this assignment a higher priority, especially since I would've been able to make a lot more progress overall, given the more independent nature of the assignment, on something I was a lot more passionate about. Still, I did my best to get as much done as I could, and, even if it ended up being not as well put-together as I would've liked, I really want to try to make things even better for the final project's revision work.

4. Credits:
    - I based the code off of what was taught in lecture and during section, especially the vector.lua information.
    - All other code was made by me.
    - No external assets were used.

---
title: Making interview practice more effective
author: Allen Chang
date: '2018-11-09'
slug: making-interview-practice-more-effective
tags:
  - python
  - interviewing
---

I'm in the middle of a job hunt for a data science position and that means lots of studying for interviews. To help me study, I've enlisted the help of friends and family to quiz me by 'randomly' selecting questions from lists. Asking them to scroll through lists though, is somewhat cumbersome and annoying.

![lists, lists, lists](https://lh3.googleusercontent.com/Wfjrk1QsOKvXMFCD1VISVBoBiv2k69HV5XPUMt2-wOyB7OKAP29ib8ZPl3uW-y_QFhHnHCtIWaaf)

With that in mind, I wrote a small Python module that would randomly select interview questions across a number of different categories related to data science and print them one by one to the screen. The goal was to have something I could distribute to others that would be easy to run and fast. Additionally, forcing myself to randomly answer questions provides better practice than going sequentially through my lists.

The module reads in a list of text files where the questions are separated by semi-colons, randomly selects the number of questions that the user specifies, and concatenates all the questions into one large list that gets iterated over. An example of the script output is below.

```
python ask_questions.py --num_questions=3

What would be good metrics of success for 
an advertising-driven consumer product? 
(Buzzfeed, YouTube, Google Search, etc.) 
A service-driven consumer product? 
(Uber, Flickr, Venmo, etc.)

Press Enter to continue...

What kind of services would find churn 
(metric that tracks how many customers 
leave the service) helpful? How would you 
calculate churn?

Press Enter to continue...

You’re a restaurant and are approached by 
Groupon to run a deal. What data would you ask
from them in order to determine whether or not
to do the deal?

Press Enter to continue...
```

I'd like to make more improvements down the line to the script by randomizing the number of questions per category (as of now, the script takes in a single number and selects the same number of questions from each category). For now though, I have an improved method of testing my knowledge and preparation for data science interviews.

All the code for the module can be found on my [github](https://github.com/allenchng/quiz-yourself) .
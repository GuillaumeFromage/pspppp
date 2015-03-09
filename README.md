# pspppp
PSPP Pre-Processor

Some piece of shit shell script to accelerate the treatment of statistical data.
Altough shitty, this is a lot fucking faster than dicking around the poorly 
designed front ends of SPSS 22 or some other shit.

This start from what folks really do with SPSS: rub all of a set of variable X
against another set of variable Y, checking for significative p, and the 
direction of the correlation. We don't know of care about all the other 
undecipherable bullshit that SPSS is trying to feed us, or if we do, we need
those values for all the other entry in the table, not just for one single 
fucking entry at a time.

Basically, you would define a bunch of variables in SPSS and import your date
in there, and then, you would juste have to create a asdf file that would 
contain:
get file='thisfile.sav'
Recode 
Compute

And then, magic, this thing would rub your variables (that you need to edit
by hand in the script) against another list.

Anyways, its a start, and I'm sure I'll have to prove things or investigate
datasets in the future, so I'll fix this thing.

Oh, yeah, and it will pollute your current directory with a million garbage 
files, and its output stinks, and it work one time out of five, sorry, its
just some shit I've did instead of doing the things I had to do for school.

Also, its probably fair game if this get ported to perl or some language that
would support any form of fucking datastructures, because obviously this is
just not the right way of processing pspp's output.

# balanced-dice-numbering-messy
old, messy code for searching for perfectly balanced numbering of dice

Yes, I am aware this code is a total mess - I only wrote it for myself. I became interested in the recreational math problem of numerically balancing dice through the work of The Dice Lab (mainly Henry Segerman's videos) and https://www.youtube.com/watch?v=upr9vMpGn50

Essentially, the idea is that in addition to the standard of having opposite faces all add up to the same number, faces around a vertex should add up to the same number - or rather, a multiple of the same number, depending on the number of faces around that vertex.

The shapes explored here are the tetrakis hexahedron and disdyakis dodecahedron - d24 and d48 respectively - and I managed to bring the search space down for the d48 from what would have been with a trivial algorithm 24 factorial (6*10^23) down to a few billion that ran on my laptop in about 30 seconds.

As this is a hobby project, I'll only maintain and update it when I'm interested - I haven't run it in a while so I don't know if it even still works, but it did work in ~October 2022.

# Clubmaster

This repository is a fork of the original clubmaster by Aine Caoimhe, it does not contain the animations shipped, just the lsl and notecards.

Notecards have two extensions in this repository. 
.xml is for XMLS style notecards - but should still be copy/pasted as notecards inworld
.txt is for a text style notecard - just a notecard inworld 

Changes Summery
===============
While the Clubmaster is a very good product it did not allow for remote access points. Anyone wanting more than one dance ball on the same region had to rez two full dance balls. This modification allows to rez just once actual dance ball and use a much smaller script with lower simulator load for each place you want extra dance points. It is only useful if you want multiple dance points on the same region. 

Repository Branches:
====================
There are two branches, one contains the original clubmaster code by Aine Caoimhe, with the Covey Modifed version in the master branch. 

Assembly
========
1. Make a prim and place the "~Clubmaster poseball v2.lsl" script into the prim. 
2. Take this prim to your inventory and call it "~club poseball" with the quotation marks
3. Make a prim for the remote and add in the ClubMaster Remote script
4. Make a new prim which will be the main dance ball 
4. Add the "~club poseball" into the dance balls inventory along with all other scripts and notecards from this repository other than the remote script. 

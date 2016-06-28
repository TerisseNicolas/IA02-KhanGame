/*Board orientation*/
board(north,[
	[2, 3, 1, 2, 2, 3],
	[2, 1, 3, 1, 3, 1],
	[1, 3, 2, 3, 1, 2],
	[3, 1, 2, 1, 3, 2],
	[2, 3, 1, 3, 1, 3],
	[2, 1, 3, 2, 2, 1]
]).
board(east,[
	[2, 2, 3, 1, 2, 2],
	[1, 3, 1, 3, 1, 3],
	[3, 1, 2, 2, 3, 1],
	[2, 3, 1, 3, 1, 2],
	[2, 1, 3, 1, 3, 2],
	[1, 3, 2, 2, 1, 3]
]).
board(south,[
	[1, 2, 2, 3, 1, 2],
	[3, 1, 3, 1, 3, 2],
	[2, 3, 1, 2, 1, 3],
	[2, 1, 3, 2, 3, 1],
	[1, 3, 1, 3, 1, 2],
	[3, 2, 2, 1, 3, 2]
]).
board(west,[
	[3, 1, 2, 2, 3, 1],
	[2, 3, 1, 3, 1, 2],
	[2, 1, 3, 1, 3, 2],
	[1, 3, 2, 2, 1, 3],
	[3, 1, 3, 1, 3, 1],
	[2, 2, 1, 3, 2, 2]
]).

/*Recupere le board*/
getBoard(Board):-
   direction(Direction),
   board(Direction, Board).

/*The case is part of the board*/
caseInBoard(X,Y) :-
   Y >= 0,
   Y < 6,
   X >= 0,
   X < 6 .
   
/*Test similar cases*/
differentCases(X1,Y1,X2,Y2) :- X1 \== X2, Y1 \== Y2.

/*Valeur d'une case*/
getBoardCaseValue([BoardLine|_], 0, Y, Value):- getElement(BoardLine, Y, Value), !.
getBoardCaseValue([_|Q], X, Y, Value):-
   NextLine is X - 1, getBoardCaseValue(Q, NextLine, Y, Value).
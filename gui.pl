/*Compass*/
printCompass :- write('\nDirections:\n\tN\nW\t\tE\n\tS'), nl.

/*Print Board*/
printBoard :- getBoard(B), printBoard(B, 0).
printBoard([], _) :- printHLine.
printBoard([H|T], X) :-
	printHLine,
	printELine,
	write('|'),
	printLine(H, X, 0),
	NewX is X + 1,
	printELine,
	printBoard(T, NewX).

printLine([], _, _) :- nl, !.
printLine([H|Q], X, Y) :-
	write(' '),
	write(H),
	write(' '),
	printPawn(X, Y, PawnName),
	printKhan(PawnName),
	write(' |'),
	NewY is Y + 1,
	printLine(Q, X, NewY).

printPawn(X, Y, PawnName) :-
	getPositionFromPawnName(red, PawnName, X, Y),
	write(PawnName), !.
printPawn(X, Y, PawnName) :-
	getPositionFromPawnName(white, PawnName, X, Y),
	write(PawnName), !.
printPawn(_, _, _) :-
	write('  ').

printKhan(PawnName) :-
	khan(KhanName, _),
	PawnName == KhanName,
	write('*'), !.
printKhan(_) :-
	write(' ').


printELine :- write('|       |       |       |       |       |       |'), nl.

printHLine :- write('-------------------------------------------------'), nl.

/*Affichage des elements d'une liste*/
printList([]) :- nl.
printList([H|Q]) :- write(H), nl, printList(Q).

/*Print pawns positions*/
printPlayersPawns:-
   nl, write('Positions des pions : '), nl,
   printPlayerPawns(red),
   printPlayerPawns(white).

printPlayerPawns(Player):-
   player(Player, Pawns),
   printList(Pawns).

/*Affichage de la selection d'un move et retourne le move choisit*/
moveSelection(PossibleMoves, SelectedMove):-
   printMovesWithNumber(PossibleMoves, 0),
   write('Selectionner un numero de move : '), read(MoveNumber),
   getMovesWithNumber(PossibleMoves, MoveNumber, SelectedMove),
   nl, write('Move selectionne : '), write(SelectedMove), nl, !.

/*Affiche tous les moves avec un numero dans l'ordre croissant*/
printMovesWithNumber([], _) :- !.
printMovesWithNumber([[PawnName|Paths]|OtherPawns], Number):-
      write('=== '), write(PawnName), write(' :'), nl,
      printMoveWithNumberPath(Paths, Number, NewNumber),
      nl,
      printMovesWithNumber(OtherPawns, NewNumber).

printMoveWithNumberPath([], Number, Number):- !.
printMoveWithNumberPath([FirstPath|OtherPaths], Number, NewNumber):-
   write('('), write(Number), write(') -> '), write(FirstPath), nl,
   NextNumber is Number + 1,
   printMoveWithNumberPath(OtherPaths, NextNumber, NewNumber).

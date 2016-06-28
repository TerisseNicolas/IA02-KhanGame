/*Placement of pawns*/
placePawn(Player, PawnNb) :-
	player(Player,Pawns),
	retractall(player(Player, _)),
	getElement(Pawns, PawnNb, Pawn),
	repeat,
	write('Pion '), GuiPawnNb is PawnNb + 1, write(GuiPawnNb),
	write(', Indiquez sa position :'), nl,
	write('X: '),read_number(X),
	replace(Pawn, 1, X, TempPawn),
	write('Y: '), read_number(Y), nl,
	positionLimits(Player, X, Y),
	replace(TempPawn, 2, Y, NewPawn),
	replace(Pawns, PawnNb, NewPawn, NewPawns),
	asserta(player(Player, NewPawns)), !.

/*Position d'un pion a partir de son nom*/
getPositionFromPawnName(Player, PawnName, X, Y) :-
	player(Player, Pawns),
	getPositionFromPawnName_(PawnName, Pawns, X, Y).

getPositionFromPawnName_(PawnName, [[PawnName, X, Y]|_], X, Y):- !.
getPositionFromPawnName_(PawnName, [_|Q], X, Y):-
	getPositionFromPawnName_(PawnName, Q, X, Y).

/*Obtient le numero du pion a partir de son nom*/
getPawnNumber(Player, PawnName, Number):-
   player(Player, Pawns),
   getPawnNumber_(Pawns, PawnName, Number), !.

getPawnNumber_([[PawnName, _, _]|_], PawnName, 0):- !.
getPawnNumber_([_|Q], PawnName, Number):-
   getPawnNumber_(Q, PawnName, TempNumber),
   Number is TempNumber + 1,!.

changePawnPosition(Player, PawnName, X, Y):-
   player(Player,Pawns),
   getPawnNumber(Player, PawnName, PawnNb),
   retract(player(Player, _)),
   replace(Pawns, PawnNb, [PawnName, X, Y], NewPawns),
   asserta(player(Player, NewPawns)), !.

/*Compte le nombre de pieces mangees*/
countEatenPawn(Player, Count, EatenPawns):-
   player(Player, Pawns),
   countEatenPawn_(Pawns, Count, EatenPawns).

countEatenPawn_([], 0, []):- !.
countEatenPawn_([[PawnName, -1, -1]|Q], Res, EatenPawns):-
   countEatenPawn_(Q, Temp, TempEaten),
   Res is Temp + 1,
   concatenate([PawnName], TempEaten, EatenPawns), !.
countEatenPawn_([_|Q], Count, EatenPawns):-
   countEatenPawn_(Q, Count, EatenPawns).

/*Manger un pion*/
eatPawn(Player, PawnName):-
   nl, write('Eating '), write(PawnName), write('!'), nl,
   changePawnPosition(Player, PawnName, -1, -1).
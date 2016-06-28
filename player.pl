/*Players spec*/
/*
addPlayers :- write('Adding players'), nl,
   asserta(player(red,[
   [r1, -1, -1],
   [r2, -1, -1],
   [r3, -1, -1],
   [r4, -1, -1],
   [r5, -1, -1],
   [rK, -1, -1]
   ])),
   asserta(player(white,[
   [w1, -1, -1],
   [w2, -1, -1],
   [w3, -1, -1],
   [w4, -1, -1],
   [w5, -1, -1],
   [wK, -1, -1]
   ])),
   asserta(khan(noPawn, 0)),
   asserta(playerType(red, 0)),
   asserta(playerType(white, 0)),
   write('Players added'), nl.
*/
/*==================Test version for no initialization*/
addPlayers :- write('Adding players'), nl,
   asserta(player(red,[
   [r1, 5, 0],
   [r2, 5, 1],
   [r3, 4, 2],
   [r4, 5, 3],
   [r5, 5, 4],
   [rK, 4, 5]
   ])),
   asserta(player(white,[
   [w1, 1, 0],
   [w2, 1, 1],
   [w3, 0, 2],
   [w4, 1, 3],
   [w5, 0, 4],
   [wK, 0, 5]
   ])),
   asserta(khan(noPawn, 0)),
   asserta(playerType(red, 0)),
   asserta(playerType(white, 0)),
   write('Players added'), nl.

/*Liste des noms des pions*/
getPawnNamesList(red, [r1, r2, r3, r4, r5, rK]).
getPawnNamesList(white, [w1, w2, w3, w4, w5, wK]).

/*Nom de la kalista*/
getKalistaName(red, rK):- !.
getKalistaName(white, wK).

positionLimits(red, X, Y) :-
	between(4, 5, X),
	between(0, 5, Y).
positionLimits(white, X, Y) :-
	between(0, 1, X),
	between(0, 5, Y).

/*Initialisation*/
initPlayer(Player, 6) :-
   write('Fin du placement\nLes positions de vos pions sont : '), nl, printPlayers(Player).
initPlayer(Player, PawnNb) :-
   placePawn(Player,PawnNb),
   NewPawnNb is PawnNb + 1,
   initPlayer(Player, NewPawnNb).

/*Position occupee par un pion de player*/
caseOccupied(X, Y):-
   caseOccupiedByPlayer(red, X, Y), !.
caseOccupied(X, Y):-
   caseOccupiedByPlayer(white, X, Y).

caseOccupiedByPlayer(Player, X, Y):- player(Player, Pawns),
   caseOccupied_(X, Y, Pawns).

caseOccupied_(_, _, []) :- fail.
caseOccupied_(X, Y, [[_, X, Y]|_]):- !.
caseOccupied_(X, Y, [_|Q]):- caseOccupied_(X, Y, Q).

/*recuperer le nom de l'autre joueur*/
getOtherPlayerName(red, white):- !.
getOtherPlayerName(white, red).

/*Recupere la longueur du coup suivant le khan*/
getKhanLength(Length):-
   khan(_, Length), !.

/*Change khan*/
changeKhan(PawnName, Length):-
   retract(khan(_, _)),
   asserta(khan(PawnName, Length)).

/*Restreint la selection aux pions qui respectent le khan (gere le cas d'une piece mangee)*/
restrictPawnNamesListToKhan(_, _, [], []):- !.
restrictPawnNamesListToKhan(Board, Player, [PawnName|OtherPawns], KhanPawnNamesList):-
   getPositionFromPawnName(Player, PawnName, -1, -1),
   restrictPawnNamesListToKhan(Board, Player, OtherPawns, KhanPawnNamesList), !.
restrictPawnNamesListToKhan(Board, Player, [PawnName|OtherPawns], KhanPawnNamesList):-
   getKhanLength(Length),
   getPositionFromPawnName(Player, PawnName, X, Y),
   getBoardCaseValue(Board, X, Y, Value),
   addIfAsTheKhanLength(Length, Value, PawnName, Res1),
   restrictPawnNamesListToKhan(Board, Player, OtherPawns, Res2),
   clearConcatenate(Res1, Res2, KhanPawnNamesList).

addIfAsTheKhanLength(KhanLength, Value, PawnName, [PawnName]):-
   (KhanLength == Value) ; (KhanLength == 0), !.
addIfAsTheKhanLength(_, _, _, []).

/*Test si la kalista a ete mangee*/
eatenKalista(red):-
   getPositionFromPawnName(red, rK, -1, -1).
eatenKalista(white):-
   getPositionFromPawnName(white, wK, -1, -1).

/*set Type de joueur : 0-> man, 1-> IA*/
setPlayerType(Player, Type):-
   retract(playerType(Player, _)),
   asserta(playerType(Player, Type)).

/*get Type de joueur*/
getPlayerType(Player, Type):-
   playerType(Player, Type).

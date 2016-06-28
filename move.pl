/*Representation des moves possibles : [[PawnName, [[X11, Y11], [X12, Y12]], [[00, 00], [11, 11]]], [PawnName2, [[X11, Y11], [X12, Y12]], [[00, 00], [11, 11]]]]*/

/*Liste des moves possibles*/
possibleMoves(Board , Player, PossibleMoveList) :-
   getPawnNamesList(Player, PawnNamesList),
   %write('Pawn Name list'), write(PawnNamesList), nl,
   restrictPawnNamesListToKhan(Board, Player, PawnNamesList, KhanPawnNamesList),
   %write('Khan restriction : '), write(KhanPawnNamesList), nl,
   %printPlayersPawns,
   getKhanLength(Length),
   write('Khan Length : '), write(Length), nl, nl,
   possibleMoves_(Board, Player, PossibleMoveList, KhanPawnNamesList).


/*For each pawn*/
possibleMoves_(_, _, [], []):- !.
possibleMoves_(Board, Player, PossibleMoveList, [Pawn|Q]):-
   getMoveLengthFromPosition(Board, Player, Pawn, MoveLength),
   getPositionFromPawnName(Player, Pawn, X, Y),
   %write('Pawn : '), write(Pawn), write(', Position : ('), write(X), write(' '), write(Y), write('), Lenght : '), write(MoveLength), nl,
   startOtherPositionsExploration(Board, Player, PossibleMovePath, [[X, Y]], MoveLength, []),
   concatenate([Pawn], PossibleMovePath, CompletePath),
   %write('Complete path :'), write(CompletePath), nl,
   possibleMoves_(Board, Player, OtherPossibleMoves, Q),
   concatenate([CompletePath], OtherPossibleMoves, PossibleMoveList).

/*Explore a path*/
startOtherPositionsExploration(_, _, [], [], _, _):- !. %, write('exploration with no other position possible'), nl, !.
startOtherPositionsExploration(_, _, [[]],_ , -1, _):- !. %, write('End of exploration'), nl, !.
startOtherPositionsExploration(Board, Player, NewMovePath, [[X, Y]|OtherPossiblePositions], MoveLength, History):-
   concatenate([[X, Y]], History, NewHistory),
   NewMoveLength is MoveLength - 1,
   getListOfPossibleNextPosition(Player, X, Y, History, NewListOfPossibleNextPositions, MoveLength),
   startOtherPositionsExploration(Board, Player, PossibleMovePath1, NewListOfPossibleNextPositions, NewMoveLength, NewHistory),
   startOtherPositionsExploration(Board, Player, PossibleMovePath2, OtherPossiblePositions, MoveLength, History),
   addElementToAllSubLists([X, Y], PossibleMovePath1, SubPathWithActualPosition),
   clearConcatenate(SubPathWithActualPosition, PossibleMovePath2, NewMovePath).

/*Longueur du coup a partir d'un pion*/
getMoveLengthFromPosition(Board, Player, PawnName, MoveLength):-
   getPositionFromPawnName(Player, PawnName, X, Y),
   getBoardCaseValue(Board, X, Y, MoveLength).


/*Recupere les positions alentours a la position courante sur le plateau*/
/*Dans le cas ou c'est le dernier mouvement, on autotise le deplacement sur les pions adverses*/
getListOfPossibleNextPosition(Player, X, Y, History, Res, MoveLength):-
   XP is X + 1,
   XM is X - 1,
   YP is Y + 1,
   YM is Y - 1,
   addIfCaseFree(Player, XP, Y, History, Res1, MoveLength),
   addIfCaseFree(Player, XM, Y, History, Res2, MoveLength),
   addIfCaseFree(Player, X, YP, History, Res3, MoveLength),
   addIfCaseFree(Player, X, YM, History, Res4, MoveLength),
   clearConcatenate([Res1], [Res2], Clear1),
   clearConcatenate([Res3], Clear1, Clear2),
   clearConcatenate([Res4], Clear2, Res).

/*Renvoie une case si elle est disponible, sinon une liste vide*/
addIfCaseFree(Player, X, Y, History, [X,Y], 1) :-
   caseInBoard(X, Y),
   \+ caseOccupiedByPlayer(Player, X, Y),
   \+ member([X, Y], History).
addIfCaseFree(_, X, Y, History, [X,Y], _) :-
   caseInBoard(X, Y),
   \+ caseOccupied(X, Y),
   \+ member([X, Y], History), !.
addIfCaseFree(_, _, _, _,[], _).

/*Move d'un joueur*/
makeAMove(Board, Player, 0):-
   printBoard,
   possibleMoves(Board , Player, PossibleMoveList),
   moveOptionsMenu(Player, PossibleMoveList), !.

/*Move de l'IA*/
makeAMove(Board, Player, 1):-
   printBoard,
   generateMove(Board, Player, MoveToPlay),
   write('IA ('), write(Player), write(') Making move '), write(MoveToPlay), nl,
   moveAction(Player, MoveToPlay), !.

moveOptionsMenu(Player, []):- alternativeActionMenu(Player), !.
moveOptionsMenu(Player, PossibleMoveList):-
   \+ checkAllEmptyMoveForEachPawn(PossibleMoveList),
   moveSelection(PossibleMoveList, SelectedMove),
   moveAction(Player, SelectedMove), !.
moveOptionsMenu(Player, _):- alternativeActionMenu(Player).

/*Test si pour chaque pion candidat, il n'y a pas de move possible*/
checkAllEmptyMoveForEachPawn([]):- !.
checkAllEmptyMoveForEachPawn([H|Q]):-
   length(H, Length),
   Length == 1,
   checkAllEmptyMoveForEachPawn(Q).

/*Dans le cas de desobeisance au khan*/
alternativeActionMenu(Player) :-
   countEatenPawn(Player, Count, EatenPawns),
   repeat,
   write('Desobeissance au khan : '), nl,
   write('1 ) Bouger une autre piece'), nl,
   alternativeActionMenu_(Count),
   read(Answer),
   Answer > 0,
   Answer < 3, !,
   alternativeActionMenu2_(Player, Answer, EatenPawns).

alternativeActionMenu_(0):- !.
alternativeActionMenu_(Count):-
   Count > 0,
   write('2 ) Remettre en jeu un autre pion'), nl.

/*Option du menu choisie*/
alternativeActionMenu2_(Player, 1, _):-
   changeKhan(_, 0),
   getBoard(Board),
   makeAMove(Board, Player, 0), !.
alternativeActionMenu2_(Player, 2, EatenPawns):-
   write('Pions replacables'), nl,
   write(EatenPawns), nl,
   write('Saisir le nom d\'un pion a replacer '),
   read(PawnNameToReplace), nl,
   getPawnNumber(Player, PawnNameToReplace, PawnNb),
   placePawn(Player, PawnNb), !.

moveAction(Player, SelectedMove):-
   getElement(SelectedMove, 0, [FromX, FromY]),
   getPositionFromPawnName(Player, PawnName, FromX, FromY),
   last(SelectedMove, [ToX, ToY]),
   moveAndEatIfEnemy(Player, PawnName, ToX, ToY),
   getBoard(Board),
   getBoardCaseValue(Board, ToX, ToY, NewPositionValue),
   changeKhan(PawnName, NewPositionValue), !.

/*Deplace un pion et mane le pion adverse si present*/
moveAndEatIfEnemy(Player, PawnName, ToX, ToY):-
   getOtherPlayerName(Player, Enemy),
   caseOccupiedByPlayer(Enemy, ToX, ToY),
   getPositionFromPawnName(Enemy, EnemyPawnName, ToX, ToY),
   eatPawn(Enemy, EnemyPawnName),
   changePawnPosition(Player, PawnName, ToX, ToY), !.
moveAndEatIfEnemy(Player, PawnName, ToX, ToY):-
   changePawnPosition(Player, PawnName, ToX, ToY).

/*Recupere le move numero Number de la liste*/
getMovesWithNumber([], _, []) :- !.
getMovesWithNumber([[_|Paths]|_], Number, Move):-
      getMoveWithNumberPath(Paths, Number, _, Move),
      Move \== [], !.
getMovesWithNumber([[_|Paths]|OtherPawns], Number, Move):-
      getMoveWithNumberPath(Paths, Number, NumberToContinue, MustBeEmpty),
      MustBeEmpty == [],
      getMovesWithNumber(OtherPawns, NumberToContinue, Move).

getMoveWithNumberPath([], Number, Number, []):- !.
getMoveWithNumberPath([Path|_], 0, _, Path):- !.
getMoveWithNumberPath([_|OtherPaths], Number, NewNumber, Move):-
   NextNumber is Number - 1,
   getMoveWithNumberPath(OtherPaths, NextNumber, NewNumber, Move).

/* Intelligence artificielle ======================================================*/

/*Meilleur coup possible*/
generateMove(Board, Player, MoveToPlay):-
   possibleMoves(Board , Player, PossibleMoveList),
   generateMovesMenu(Player, PossibleMoveList, MoveToPlay).

generateMovesMenu(Player, [], MoveToPlay):- alternativeActionMenuIA(Player, MoveToPlay), !.
generateMovesMenu(Player, PossibleMoveList, MoveToPlay):-
   \+ checkAllEmptyMoveForEachPawn(PossibleMoveList),
   getBestIAMove(Player, PossibleMoveList, MoveToPlay), !.
generateMovesMenu(Player, _, MoveToPlay):- alternativeActionMenuIA(Player, MoveToPlay).

alternativeActionMenuIA(Player, MoveToPlay):-
   write('IA : desobeissance au khan.'), nl,
	changeKhan(_, 0),
	getBoard(Board),
	possibleMoves(Board , Player, PossibleMoveList),
	getBestIAMove(Player, PossibleMoveList, MoveToPlay).

/*Recupere le meilleur move possible dans une liste de moves possibles*/
getBestIAMove(Player, PossibleMoveList, PathToWin):-
   getOtherPlayerName(Player, Enemy),
   getKalistaName(Enemy, EnemyKalistaName),
   getPositionFromPawnName(Enemy, EnemyKalistaName, TargetX, TargetY),
   getMoveClosestToKalista(PossibleMoveList, TargetX, TargetY, _, PathToWin).

/*Test si un path possible meme a manger la kalista*/
findPathToTarget([], _, _, []):- !.
findPathToTarget([[_|FirstPawnPaths]|_], TargetX, TargetY, PathToWin):-
   findPathToTargetOnePawnPaths(FirstPawnPaths, TargetX, TargetY, PathToWin),
   PathToWin \== [], !.
findPathToTarget([_|OtherPawns], TargetX, TargetY, PathToWin):-
   findPathToTarget(OtherPawns, TargetX, TargetY, PathToWin).

/*Pour un pion*/
findPathToTargetOnePawnPaths([], _, _, []) :- !.
findPathToTargetOnePawnPaths([FirstPath|_], TargetX, TargetY, FirstPath):-
   last(FirstPath, [TargetX, TargetY]), !.
findPathToTargetOnePawnPaths([_|OtherPaths], TargetX, TargetY, FirstPath):-
   findPathToTargetOnePawnPaths(OtherPaths, TargetX, TargetY, FirstPath).

getMoveClosestToKalista([], _, _, 99.0, []) :- !.
getMoveClosestToKalista([[_ | NewPaths] | MoveList], KX, KY, Distance, Path) :-
   getMoveClosestToKalistaOnePawn(NewPaths, KX, KY, D1, Path1), 
   getMoveClosestToKalista(MoveList, KX, KY, D2,Path2),
   addClosestPath(D1, Path1, D2, Path2, Distance, Path).
   
addClosestPath(D1, Path1, D2, _, D1, Path1) :- D1 < D2, !.
addClosestPath(D1, _, D2, Path2, D2, Path2) :- D1 >= D2.  
     
getMoveClosestToKalistaOnePawn([], _, _, 99.0, []) :- !.
getMoveClosestToKalistaOnePawn([FirstPath|OtherPaths], KX, KY, D2, Path2):- 
   last(FirstPath, [X1, Y1]),
	distance(X1, Y1, KX, KY, D1),
   getMoveClosestToKalistaOnePawn(OtherPaths, KX, KY, D2, Path2),
   D1 > D2, !.
getMoveClosestToKalistaOnePawn([FirstPath|_], KX, KY, D1, FirstPath):-
   last(FirstPath, [X1, Y1]),
	distance(X1, Y1, KX, KY, D1), !.

distance(X1, Y1, X2, Y2, D) :-
	D is sqrt((X2 - X1)^2 + (Y2 - Y1)^2), !.
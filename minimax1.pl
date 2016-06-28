

%max(PawnsP, PawnsE, Khan, 1, MinOrMax, Score, Move) :-
%	possibleMovesIA(PawnsP, PawnsE, Khan, MoveList),
%	asserta(moveListIA(MoveList)).
/*

minimax() :-
	moveScore(Player, Score), !.
minimax(Player, Depth, MinOrMax, BestScore) :-
	getBoard(Board),
	% sauvegarder l'état du tableau (Khan/Positions pions) OU Simuler mouvement
	bagof(P, moveIA(Player, NextMoves), NextMoves),
	getOtherPlayerName(Player, NextPlayer),
	NewDepth is Depth - 1,
	getIAEnemy(MinOrMax, NewMinOrMax),
	bestNode(NextPlayer, NewDepth, NewMinOrMax, Score),
	% undo move&eat to previous state % (pas besoin si mouvement simulé)
	!.


bestNode([Node], Depth, MinOrMax, Node, Score) :-
	minimax(Node, Depth, NewMinOrMax, Score).
bestNode([Node | NodeList], Depth, MinOrMax, BestNode, BestScore) :-
	minimax(Node, Depth, NewMinOrMax, _, Score1),
	bestNode(NodeList, Pos2, Score2),
	betterOf(Node1, Score1, Node2, Score2, MinOrMax, BestNode, BestScore).


betterOf(Node0, Score0, _, Score1, min, Node0, Val0) :-
	Score0 < Score1, !.
betterOf(Node0, Score0, _, Score1, max, Node0, Val0) :-
	Score0 > Score1, !.
betterOf(_, _, Node1, Score1, _, Node1, Score1).

moveIA(Player, SelectedMove, NewPawnP, NewPawnE):-
   getElement(SelectedMove, 0, [FromX, FromY]),
   getPawnPos(PawnList, PawnName, FromX, FromY),
   last(SelectedMove, [ToX, ToY]),
   length(SelectedMove, MoveLengthPlusOne),
   MoveLength is MoveLengthPlusOne - 1,
   changeKhan(PawnName, MoveLength),
   moveAndEatIfEnemyIA(Player, PawnName, ToX, ToY, EatenEnemy),
   concatenate(EatenEnemyList, EatenEnemy) !.

/*Deplace un pion et mange le pion adverse si present*
moveAndEatIfEnemyIA(Player, PawnName, ToX, ToY):-
   getOtherPlayerName(Player, Enemy),
   caseOccupiedByPlayer(Enemy, ToX, ToY),
   getPositionFromPawnName(Enemy, EnemyPawnName, ToX, ToY),
   eatPawn(Enemy, EnemyPawnName),
   changePawnPosition(Player, PawnName, ToX, ToY), !.
moveAndEatIfEnemy(Player, PawnName, ToX, ToY):-
   changePawnPosition(Player, PawnName, ToX, ToY).


% Fonctions modifiées pour ne pas se baser sur l'état courant

/*Liste des moves possibles*
possibleMovesIA(Pawns1, Pawns2, KhanLength, PossibleMoveList) :-
	restrictPawnNamesListToKhanIA(KhanLength, Pawns1, KhanPawnNamesList),
	possibleMovesIA_(Pawns1, PossibleMoveList, KhanPawnNamesList).

restrictPawnNamesListToKhanIA(_, [], []):- !.
restrictPawnNamesListToKhanIA(Length, [Pawn|PawnList], RestrictedList):-
	getPositionFromPawnNameIA(Pawn, PawnList, -1, -1), % pion hors de la board - on ne l'ajoute pas
	restrictPawnNamesListToKhanIA(Length, OtherPawns, RestrictedList), !.
restrictPawnNamesListToKhanIA(Length, [Pawn|PawnList], RestrictedList):-
	getPositionFromPawnNameIA(Pawn, PawnList, X, Y),
	getBoard(B)
	getBoardCaseValue(B, X, Y, Value),
	addIfAsTheKhanLength(Length, V, Pawn, Res1),
	restrictPawnNamesListToKhanIA(OtherPawns, Res2),
	clearConcatenate(Res1, Res2, KhanPawnNamesList).

/*For each pawn*
possibleMovesIA_(_, _, [], []):- !.
possibleMovesIA_(PawnList, PossibleMoveList, [Pawn|Q]):-
	getBoard(Board),
	getPositionFromPawnNameIA(Pawn, PawnList, X, Y),
	getBoardCaseValue(Board, X, Y, MoveLength),
	startOtherPositionsExplorationIA(Board, Player, PossibleMovePath, [[X, Y]], MoveLength, []),%%%%%%%%%%%%%%%%%%%%%
	concatenate([Pawn], PossibleMovePath, CompletePath),
	possibleMoves_(Board, Player, OtherPossibleMoves, Q),
	concatenate([CompletePath], OtherPossibleMoves, PossibleMoveList).

getMoveLengthFromPosition(Board, Player, PawnName, MoveLength):-
	getPositionFromPawnName(PawnName, X, Y),
	getBoardCaseValue(Board, X, Y, MoveLength).

/*Explore a path*
startOtherPositionsExplorationIA(_, [], [], _, _):- !. %, write('exploration with no other position possible'), nl, !.
startOtherPositionsExplorationIA(_, [[]],_ , -1, _):- !. %, write('End of exploration'), nl, !.
startOtherPositionsExplorationIA(PawnList, NewMovePath, [[X, Y]|OtherPossiblePositions], MoveLength, History):-
	getBoard(Board),
	concatenate([[X, Y]], History, NewHistory),
	NewMoveLength is MoveLength - 1,
	getListOfPossibleNextPositionIA(PawnList, X, Y, History, NewListOfPossibleNextPositions, MoveLength),
	startOtherPositionsExplorationIA(PawnList, PossibleMovePath1, NewListOfPossibleNextPositions, NewMoveLength, NewHistory),
	startOtherPositionsExplorationIA(PawnList, PossibleMovePath2, OtherPossiblePositions, MoveLength, History),
	addElementToAllSubLists([X, Y], PossibleMovePath1, SubPathWithActualPosition),
	clearConcatenate(SubPathWithActualPosition, PossibleMovePath2, NewMovePath).


getListOfPossibleNextPositionIA(PawnList, X, Y, History, Res, MoveLength):-
	XP is X + 1,
	XM is X - 1,
	YP is Y + 1,
	YM is Y - 1,
	addIfCaseFreeIA(PawnList, XP, Y, History, Res1, MoveLength),
	addIfCaseFreeIA(PawnList, XM, Y, History, Res2, MoveLength),
	addIfCaseFreeIA(PawnList, X, YP, History, Res3, MoveLength),
	addIfCaseFreeIA(PawnList, X, YM, History, Res4, MoveLength),
	clearConcatenate([Res1], [Res2], Clear1),
	clearConcatenate([Res3], Clear1, Clear2),
	clearConcatenate([Res4], Clear2, Res).


   /*Renvoie une case si elle est disponible, sinon une liste vide*
addIfCaseFreeIA(Pawns1, Pawns2, X, Y, History, [X,Y], 1) :-
	caseInBoard(X, Y),
	\+ caseOccupied_(X, Y, PawnList),
	\+ member([X, Y], History).
addIfCaseFreeIA(_, X, Y, History, [X,Y], _) :-
	caseInBoard(X, Y),
	\+ caseOccupied(X, Y),
	\+ member([X, Y], History), !.
addIfCaseFreeIA(_, _, _, _,[], _).

*/


/*For each pawn*/
possibleMoves_(_, _, [], []):- !.
possibleMoves_(Board, Player, PossibleMoveList, [Pawn|Q]):-
   getMoveLengthFromPosition(Board, Player, Pawn, MoveLength),
   getPositionFromPawnName(Player, Pawn, X, Y),
   %nl, write('--------------------------------------'),
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
   %nl, write('History'), write(History), nl,
   concatenate([[X, Y]], History, NewHistory),
   NewMoveLength is MoveLength - 1,
   %write('-----------------------------Actual position : ('), write(X), write(' '), write(Y), write('), Exploration move length: '), write(MoveLength), nl,
   getListOfPossibleNextPosition(Player, X, Y, History, NewListOfPossibleNextPositions, MoveLength),
   %write('List of possible next positions '), write(NewListOfPossibleNextPositions), nl,
   %write('List of other possible next positions '), write(OtherPossiblePositions), nl,
   startOtherPositionsExploration(Board, Player, PossibleMovePath1, NewListOfPossibleNextPositions, NewMoveLength, NewHistory),
   startOtherPositionsExploration(Board, Player, PossibleMovePath2, OtherPossiblePositions, MoveLength, History),
   %write('Path1' ), write(PossibleMovePath1), nl,
   %write('Path2' ), write(PossibleMovePath2), nl,
   addElementToAllSubLists([X, Y], PossibleMovePath1, SubPathWithActualPosition),
   clearConcatenate(SubPathWithActualPosition, PossibleMovePath2, NewMovePath).
   %write('('), write(X), write(' '), write(Y), write('), move path: '), write(NewMovePath), nl.


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
   %write('Possibles positions ('), write(X), write(' '), write(Y), write(') : '), write(Res), nl.
   %write('3-'), write(Tmp3), nl, write(Res), !.

/*Renvoie une case si elle est disponible, sinon une liste vide*/
addIfCaseFree(Player, X, Y, History, [X,Y], 1) :-
   %write('Try 1 : '), write(Player), write(' '), write(X), write(' '), write(Y), nl,
   caseInBoard(X, Y),
   \+ caseOccupiedByPlayer(Player, X, Y),
   \+ member([X, Y], History).
   %write('Try 1 : end'), nl, !.
addIfCaseFree(_, X, Y, History, [X,Y], _) :-
   %write('Try 2: '), write(X), write(' '), write(Y), write(' Length ----------------'), write(Length), write('History '), write(History), nl,
   caseInBoard(X, Y),
   \+ caseOccupied(X, Y),
   %write('Tru 2 : end'), nl,
   \+ member([X, Y], History), !.
addIfCaseFree(_, _, _, _,[], _).

/*Move d'un joueur*/
makeAMove(Board, Player, 0):-
   %write('Make a move human'), nl,
   printBoard,
   possibleMoves(Board , Player, PossibleMoveList),
   %write('Making move '), write(PossibleMoveList), nl,
   moveOptionsMenu(Player, PossibleMoveList), !.

/*Move de l'IA*/
makeAMove(Board, Player, 1):-
   %write('Make a move IA'), nl,
   printBoard,
   generateMove(Board, Player, MoveToPlay),
   write('Making move '), write(MoveToPlay), nl,
   moveAction(Player, MoveToPlay).

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
   %write('In move action'), nl,
   getElement(SelectedMove, 0, [FromX, FromY]),
   getPositionFromPawnName(Player, PawnName, FromX, FromY),
   last(SelectedMove, [ToX, ToY]),
   length(SelectedMove, MoveLengthPlusOne),
   MoveLength is MoveLengthPlusOne - 1,
   %write('New khan '), write(MoveLength), nl,
   changeKhan(PawnName, MoveLength),
   moveAndEatIfEnemy(Player, PawnName, ToX, ToY), !.

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
   %write('Possibles move IA'), write(PossibleMoveList), nl,
   generateMovesMenu(Player, PossibleMoveList, MoveToPlay).

generateMovesMenu(Player, [], MoveToPlay):- alternativeActionMenuIA(Player, MoveToPlay), !.
generateMovesMenu(Player, PossibleMoveList, MoveToPlay):-
   \+ checkAllEmptyMoveForEachPawn(PossibleMoveList),
   getBestIAMove(Player, PossibleMoveList, MoveToPlay), !.
generateMovesMenu(Player, _, MoveToPlay):- alternativeActionMenuIA(Player, MoveToPlay).

alternativeActionMenuIA(Player, MoveToPlay):-
	changeKhan(_, 0),
	getBoard(Board),
	possibleMoves(Board , Player, PossibleMoveList),
	getBestIAMove(Player, PossibleMoveList, MoveToPlay).

/*Recupere le meilleur move possible dans une liste de moves possibles*/
getBestIAMove(Player, PossibleMoveList, PathToWin):-
   getOtherPlayerName(Player, Enemy),
   getKalistaName(Enemy, EnemyKalistaName),
   getPositionFromPawnName(Enemy, EnemyKalistaName, TargetX, TargetY),
   getMoveClosestToKalista(PossibleMoveList, TargetX, TargetY, PathToWin),
   PathToWin \== [], !.
getBestIAMove(_, PossibleMoveList, PathToWin):-
   getMoveClosestToKalista(PossibleMoveList, _, _, PathToWin).

/*Test si un path possible meme a manger la kalista*/
findPathToTarget([], _, _, []):- !.
findPathToTarget([[_|FirstPawnPaths]|_], TargetX, TargetY, PathToWin):-
   %write('In'), write(FirstPawnPaths), nl,
   findPathToTargetOnePawnPaths(FirstPawnPaths, TargetX, TargetY, PathToWin),
   %write('Path '), write(PathToWin), nl,
   PathToWin \== [], !.
findPathToTarget([_|OtherPawns], TargetX, TargetY, PathToWin):-
   %write('Next'), nl,
   findPathToTarget(OtherPawns, TargetX, TargetY, PathToWin).

/*Pour un pion*/
findPathToTargetOnePawnPaths([], _, _, []) :- !.
findPathToTargetOnePawnPaths([FirstPath|_], TargetX, TargetY, FirstPath):-
   last(FirstPath, [TargetX, TargetY]), !.
findPathToTargetOnePawnPaths([_|OtherPaths], TargetX, TargetY, FirstPath):-
   findPathToTargetOnePawnPaths(OtherPaths, TargetX, TargetY, FirstPath).


getMoveClosestToKalista([Move], _, _, Move) :- !.
getMoveClosestToKalista([NewBestMove | MoveList], KX, KY, Distance, BestMove) :-
	getMoveClosestToKalista(MoveList, KX, KY, NewBestMove),
	last(NewBestMove, M1), last(M1, [X1, Y1]),
	distance(X1, Y1, XT, YT, D1),
	last(BestMove, M2), last(M2, [X2, Y2]),
	distance(X2, Y2, XT, YT, D2),
	D1 < D2,
	write('Move ('), write(NewBestMove), write('): '), write(NewBestMove),
	write('VS ('), write(BestMove), write('): '), write(BestMove), !.
getMoveClosestToKalista([Move | MoveList], KX, KY, BestMove),
	getMoveClosestToKalista(MoveList, KX, KY, BestMove).

distance(X1, Y1, X2, Y2, D) :-
	D is sqrt((X2 - X1)^2 + (Y2 - Y1)^2), !.

% Minimax

/*
function minimax(node, depth, maximizingPlayer)
	if depth = 0 or node is a terminal node
		return the heuristic value of node

	if maximizingPlayer MIN
		bestValue := −∞
		for each child of node
			v := minimax(child, depth − 1, FALSE)
			bestValue := max(bestValue, v)
		return bestValue

	else    (* minimizing player *) MAX
		bestValue := +∞
		for each child of node
			v := minimax(child, depth − 1, TRUE)
			bestValue := min(bestValue, v)
		return bestValue

premier appel : minimax(origin, depth, TRUE)
-> minimax(Player, 2, max, _).
*/

getIAEnemy(min, max), !.
getIAEnemy(max, min).

%max(PawnsP, PawnsE, Khan, 1, MinOrMax, Score, Move) :-
%	possibleMovesIA(PawnsP, PawnsE, Khan, MoveList),
%	asserta(moveListIA(MoveList)).
/*

minimax() :-
	moveScore(Player, Score), !.
minimax(Player, Depth, MinOrMax, BestScore) :-
	getBoard(Board),
	% sauvegarder l'état du tableau (Khan/Positions pions) OU Simuler mouvement
	bagof(P, moveIA(Player, NextMoves), NextMoves),
	getOtherPlayerName(Player, NextPlayer),
	NewDepth is Depth - 1,
	getIAEnemy(MinOrMax, NewMinOrMax),
	bestNode(NextPlayer, NewDepth, NewMinOrMax, Score),
	% undo move&eat to previous state % (pas besoin si mouvement simulé)
	!.


bestNode([Node], Depth, MinOrMax, Node, Score) :-
	minimax(Node, Depth, NewMinOrMax, Score).
bestNode([Node | NodeList], Depth, MinOrMax, BestNode, BestScore) :-
	minimax(Node, Depth, NewMinOrMax, _, Score1),
	bestNode(NodeList, Pos2, Score2),
	betterOf(Node1, Score1, Node2, Score2, MinOrMax, BestNode, BestScore).


betterOf(Node0, Score0, _, Score1, min, Node0, Val0) :-
	Score0 < Score1, !.
betterOf(Node0, Score0, _, Score1, max, Node0, Val0) :-
	Score0 > Score1, !.
betterOf(_, _, Node1, Score1, _, Node1, Score1).

moveIA(Player, SelectedMove, NewPawnP, NewPawnE):-
   getElement(SelectedMove, 0, [FromX, FromY]),
   getPawnPos(PawnList, PawnName, FromX, FromY),
   last(SelectedMove, [ToX, ToY]),
   length(SelectedMove, MoveLengthPlusOne),
   MoveLength is MoveLengthPlusOne - 1,
   changeKhan(PawnName, MoveLength),
   moveAndEatIfEnemyIA(Player, PawnName, ToX, ToY, EatenEnemy),
   concatenate(EatenEnemyList, EatenEnemy) !.

/*Deplace un pion et mange le pion adverse si present*
moveAndEatIfEnemyIA(Player, PawnName, ToX, ToY):-
   getOtherPlayerName(Player, Enemy),
   caseOccupiedByPlayer(Enemy, ToX, ToY),
   getPositionFromPawnName(Enemy, EnemyPawnName, ToX, ToY),
   eatPawn(Enemy, EnemyPawnName),
   changePawnPosition(Player, PawnName, ToX, ToY), !.
moveAndEatIfEnemy(Player, PawnName, ToX, ToY):-
   changePawnPosition(Player, PawnName, ToX, ToY).


% Fonctions modifiées pour ne pas se baser sur l'état courant

/*Liste des moves possibles*
possibleMovesIA(Pawns1, Pawns2, KhanLength, PossibleMoveList) :-
	restrictPawnNamesListToKhanIA(KhanLength, Pawns1, KhanPawnNamesList),
	possibleMovesIA_(Pawns1, PossibleMoveList, KhanPawnNamesList).

restrictPawnNamesListToKhanIA(_, [], []):- !.
restrictPawnNamesListToKhanIA(Length, [Pawn|PawnList], RestrictedList):-
	getPositionFromPawnNameIA(Pawn, PawnList, -1, -1), % pion hors de la board - on ne l'ajoute pas
	restrictPawnNamesListToKhanIA(Length, OtherPawns, RestrictedList), !.
restrictPawnNamesListToKhanIA(Length, [Pawn|PawnList], RestrictedList):-
	getPositionFromPawnNameIA(Pawn, PawnList, X, Y),
	getBoard(B)
	getBoardCaseValue(B, X, Y, Value),
	addIfAsTheKhanLength(Length, V, Pawn, Res1),
	restrictPawnNamesListToKhanIA(OtherPawns, Res2),
	clearConcatenate(Res1, Res2, KhanPawnNamesList).

/*For each pawn*
possibleMovesIA_(_, _, [], []):- !.
possibleMovesIA_(PawnList, PossibleMoveList, [Pawn|Q]):-
	getBoard(Board),
	getPositionFromPawnNameIA(Pawn, PawnList, X, Y),
	getBoardCaseValue(Board, X, Y, MoveLength),
	startOtherPositionsExplorationIA(Board, Player, PossibleMovePath, [[X, Y]], MoveLength, []),%%%%%%%%%%%%%%%%%%%%%
	concatenate([Pawn], PossibleMovePath, CompletePath),
	possibleMoves_(Board, Player, OtherPossibleMoves, Q),
	concatenate([CompletePath], OtherPossibleMoves, PossibleMoveList).

getMoveLengthFromPosition(Board, Player, PawnName, MoveLength):-
	getPositionFromPawnName(PawnName, X, Y),
	getBoardCaseValue(Board, X, Y, MoveLength).

/*Explore a path*
startOtherPositionsExplorationIA(_, [], [], _, _):- !. %, write('exploration with no other position possible'), nl, !.
startOtherPositionsExplorationIA(_, [[]],_ , -1, _):- !. %, write('End of exploration'), nl, !.
startOtherPositionsExplorationIA(PawnList, NewMovePath, [[X, Y]|OtherPossiblePositions], MoveLength, History):-
	getBoard(Board),
	concatenate([[X, Y]], History, NewHistory),
	NewMoveLength is MoveLength - 1,
	getListOfPossibleNextPositionIA(PawnList, X, Y, History, NewListOfPossibleNextPositions, MoveLength),
	startOtherPositionsExplorationIA(PawnList, PossibleMovePath1, NewListOfPossibleNextPositions, NewMoveLength, NewHistory),
	startOtherPositionsExplorationIA(PawnList, PossibleMovePath2, OtherPossiblePositions, MoveLength, History),
	addElementToAllSubLists([X, Y], PossibleMovePath1, SubPathWithActualPosition),
	clearConcatenate(SubPathWithActualPosition, PossibleMovePath2, NewMovePath).


getListOfPossibleNextPositionIA(PawnList, X, Y, History, Res, MoveLength):-
	XP is X + 1,
	XM is X - 1,
	YP is Y + 1,
	YM is Y - 1,
	addIfCaseFreeIA(PawnList, XP, Y, History, Res1, MoveLength),
	addIfCaseFreeIA(PawnList, XM, Y, History, Res2, MoveLength),
	addIfCaseFreeIA(PawnList, X, YP, History, Res3, MoveLength),
	addIfCaseFreeIA(PawnList, X, YM, History, Res4, MoveLength),
	clearConcatenate([Res1], [Res2], Clear1),
	clearConcatenate([Res3], Clear1, Clear2),
	clearConcatenate([Res4], Clear2, Res).


   /*Renvoie une case si elle est disponible, sinon une liste vide*
addIfCaseFreeIA(Pawns1, Pawns2, X, Y, History, [X,Y], 1) :-
	caseInBoard(X, Y),
	\+ caseOccupied_(X, Y, PawnList),
	\+ member([X, Y], History).
addIfCaseFreeIA(_, X, Y, History, [X,Y], _) :-
	caseInBoard(X, Y),
	\+ caseOccupied(X, Y),
	\+ member([X, Y], History), !.
addIfCaseFreeIA(_, _, _, _,[], _).

*/

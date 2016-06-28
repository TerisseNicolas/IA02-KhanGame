%%%%%%%%%%%%%%%
%             %
%   MINIMAX   %
%			  %
%%%%%%%%%%%%%%%

/*
Node = [Player, Pawns1, Pawns2, KhanLength, NextMoves]
function minimax(node, depth, maximizingPlayer)
 if depth = 0 or node is a terminal node
		 return the heuristic value of node

	 if maximizingPlayer
		 bestValue := −∞
		 for each child of node
			 v := minimax(child, depth − 1, FALSE)
			 bestValue := max(bestValue, v)
		 return bestValue

	 else    (* minimizing player *)
		 bestValue := +∞
		 for each child of node
			 v := minimax(child, depth − 1, TRUE)
			 bestValue := min(bestValue, v)
		 return bestValue

premier appel : minimax(origin, depth, TRUE)
*/


/*
getIAEnemy(min,max), !.
getIAEnemy(max, min).

minimax(Player, 1, MinOrMax, Score) :-
 moveScore(Player, Score).

minimax(Player, Depth, max, BestScore) :-
 getBoard(Board),
 bagof(P, moveIA(Player, NextMoves), NextMoves),
 getOtherPlayerName(Player, NextPlayer),
 NewDepth is Depth - 1,
 bestNode(NextPlayer, NewDepth, max, Score),
 % undo move&eat to previous state
 !.

% minimax(Node, MoveList, 2, max, _, NextMove).
minimax(Nodes, 1,_, Node, Score) :-
 moveScore(Node, Score).




bestNode([Node], Depth, MinOrMax, Node, Score) :-
 getIAEnemy(MinOrMax, NewMinOrMax)
 minimax(Node, Depth, NewMinOrMax, Score).

bestNode([Node], Depth, MinOrMax, Node, Score) :-
 getIAEnemy(MinOrMax, NewMinOrMax)
 minimax(Node, Depth, NewMinOrMax, Score).

 bestNode([Node | NodeList], Depth, MinOrMax, BestNode, BestScore) :-
	 getIAEnemy(MinOrMax, NewMinOrMax)
	 minimax(Node, Depth, NewMinOrMax, _, Score1),
	 bestNode(NodeList, Pos2, Score2),
	 betterOf(Node1, Score1, Node2, Score2, MinOrMax, BestNode, BestScore).


 betterOf(Node0, Score0, _, Score1, min, Node0, Val0) :-
	 Score0 < Score1, !.
 betterOf(Node0, Score0, _, Score1, max, Node0, Val0) :-
	 Score0 > Score1, !.
 betterOf(_, _, Node1, Score1, _, Node1, Score1).


 /*
 moveScore(Node, Move, Score),
	 betterOf(Move, Score, Move2, Score2, BestNextMove, BestScore).
	 NewDepth is Depth - 1,
	 minimax(Pawns1, Pawns2, Board, MoveList, NewDepth, min, BestNextMove)
 .

 minimax(,[Pawns1, Pawns2, B, Move], Depth, min, Score) :-
 .


 best()


 %%%%%%%%%%%%%%%%%%%%%%%%%%%

 minimax(, _, 1, Score) :-
	 moveScore(Node, Score).
	 minimax([Node | NodeList], BestNextMove, Depth, Score) :-
		 NewDepth is Depth - 1,
		 best(MoveList, BestNextMove, NewDepth, Score), !.




	 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 */
/*
Modified board function for minmax
 */

getBestNextMove(Player, BestNextMove) :-
	getOtherPlayerName(Player, Enemy),
	player(Player, Pawns1),
	player(Enemy, Pawns2),
	getBoard(Board),
	possibleMoves(Board, Player, NextMoves)
	minimax([Player, Pawns1, Pawns2, KhanLength, NextMoves], 2, max, BestNextMove, _).

getPositionFromPawnNameIA(Pawn, [[Pawn, X, Y]|_], X, Y):- !.
getPositionFromPawnNameIA(Pawn, [_|Q], X, Y):-
	getPositionFromPawnNameIA(Pawn, Q, X, Y).

getKhanLengthIA(L)

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

/*Liste des moves possibles*/
possibleMovesIA(Pawns1, Pawns2, KhanLength, PossibleMoveList) :-
	restrictPawnNamesListToKhanIA(KhanLength, Pawns1, KhanPawnNamesList),
	possibleMovesIA_(Pawns1, PossibleMoveList, KhanPawnNamesList).

/*For each pawn*/
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

/*Explore a path*/
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




   /*Renvoie une case si elle est disponible, sinon une liste vide*/
   addIfCaseFreeIA(Pawns1, Pawns2, X, Y, History, [X,Y], 1) :-
   	caseInBoard(X, Y),
   	\+ caseOccupied_(X, Y, PawnList),
   	\+ member([X, Y], History).
   addIfCaseFreeIA(_, X, Y, History, [X,Y], _) :-
   	caseInBoard(X, Y),
   	\+ caseOccupied(X, Y),
   	\+ member([X, Y], History), !.
   addIfCaseFreeIA(_, _, _, _,[], _).

/*Manipulation des listes*/

/*remplace un element à un index I donné dans une liste*/
replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]):- I > 0, I1 is I-1, replace(T, I1, X, R).

/*nth*/
getElement([H|_], 0, H).
getElement([_|Q], Index, Res) :-
   NewIndex is Index - 1,
   getElement(Q, NewIndex, Res).

/*Concatenation de listes*/
concatenate([], L, L).
concatenate([H|Q], L, [H|Res]) :- concatenate(Q, L, Res).

/*Retire les sous listes vides d'une liste*/
clearingList([], []).
clearingList([[]], []).
clearingList([[[]]], []).
clearingList([[]|Q], Res):- clearingList(Q, Res).
clearingList([H|Q], [H|Res]):- clearingList(Q, Res).

/*Concatenation avec suppression des sous listes vides*/
clearConcatenate(L1, L2, Res):-
   concatenate(L1, L2, Tmp),
   clearingList(Tmp, Res), !.
   
/*Premier element d'une liste*/
getFirstItem([], _):- !.
getFirstItem([H|_], H).

/*Ajoute l'element au debut de toutes les sous listes*/
addElementToAllSubLists(_, [], []):- !.
addElementToAllSubLists(X, [H|Q], Res):-
   clearConcatenate([X], H, Temp1),
   addElementToAllSubLists(X, Q, Temp2),
   clearConcatenate([Temp1], Temp2, Res).
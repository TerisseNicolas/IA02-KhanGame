/*Load files*/
loadFiles :-
   [player],
   [pawn],
   [board],
   [list],
   [gui],
   [move].

/*Initialisation du board*/
initBoard :-
  	nl, write('Board Initialisation'), nl, nl,
	board(north, InitB),
	printBoard(InitB, 0),
	printCompass,
	write('Rouge : Indiquez la direction (north/east/south/west)  - Attention aux minuscule : '),
	read(Direction),
	asserta(direction(Direction)),
	nl,
	getBoard(B),
	printBoard(B, 0),
	menuSelectIAPlayer.

/*Selection d'un joueur ou d'une IA*/
menuSelectIAPlayer:-
   write('Selectionner le type de jeu :'), nl,
   write('0 -> 2 joueurs'), nl,
   write('1 -> 1 joueur (red) une IA (white)'), nl,
   write('2 -> 2 IA'), nl,
   read(Mode),
   menuSelectIAPlayer_(Mode).

menuSelectIAPlayer_(0):-
	setPlayerType(red, 0),
	write('Positionnement des pions du joueur Rouge (bas du plateau)'), nl,
   initPlayer(red, 0),
	setPlayerType(white, 0),
	write('Positionnement des pions du joueur Blanc (haut du plateau)'), nl, nl,
	initPlayer(white, 0).

menuSelectIAPlayer_(1):-
   setPlayerType(red, 0),
   write('Positionnement des pions du joueur Rouge (bas du plateau)'), nl,
   %Decommenter pour placer manuellement les pions (decommenter le addPlayer de player.pl et commenter l'existant)
   %initPlayer(red, 0),
   setPlayerType(white, 1).

menuSelectIAPlayer_(2):-
   setPlayerType(red, 1),
   setPlayerType(white, 1).

/*Gere les tours de jeu*/
startGame:-
	nl, write('Start the game'), nl,
	infinitePlayingLoop(red, Winner), nl,
	write('Le joueur gagant est : '), write(Winner), write(' !!'),
	retractall(player(red, _)),
	retractall(player(white, _)),
	retractall(khan(_, _)), !.

infinitePlayingLoop(Player, WinningPlayer):-
   nl, write('Tour du joueur : '), write(Player), write(' ----------------------'), nl,
   getBoard(Board),
   getPlayerType(Player, Type),
   makeAMove(Board, Player, Type),
   getOtherPlayerName(Player, Enemy),
   \+ eatenKalista(Enemy),
   infinitePlayingLoop(Enemy, WinningPlayer), !.
infinitePlayingLoop(Player, Player).


/*Start game*/
start :-
   loadFiles,
   addPlayers,
   initBoard,
   startGame.

%% @author iamawdf
%% @doc @todo Add description to game_bin.

%% cd("/home/awdf/workspace/testing/src").
%% c(game_bin).

-module(game_bin).
-export([prototype/1, preprocessing/1, calculate_jumps/2, test/1]).
-export([test/3]).
%% ====================================================================
%% Module difinitions
%% ====================================================================

-define(MAX_SIZE, 1000000).
-define(BYTES, 4).
-define(BITS, 32).
-define(MUL(N), N bsl 2).
-define(MSEC(T), T div 1000).
-define(COMPRES(V), V bsl 20 bor V). %V + 1 it is first jump decreasment
-define(COMPRES(A, B, C), A bsl 20 bor B bsl 20 bor C). %V + 1 it is first jump decreasment
-define(INDEX, (Jumps bsr 40)).
-define(SIZE, ((Jumps bsr 20) band 1048575)).
-define(JUMPS, (Jumps band 1048575)).

%% ====================================================================
%% API functions
%% ====================================================================

test(N) ->
	loop((N * 3) + N , prototype(?MAX_SIZE)).

test(Pid, Type, Model) ->
	Pid ! {Type, timer:tc(?MODULE, calculate_jumps, [Type, Model])}.

%preprocessing(A) should be excluded. It is here only by task reason.
calculate_jumps(_, []) -> {ok, 0};
calculate_jumps(binary, A) -> 
	calculate_binary(<< <<X:?BITS>> || X <- preprocessing(A) >>, ?COMPRES(length(A)));
calculate_jumps(arrays, A) -> 
	calculate_arrays(array:from_list(preprocessing(A)), ?COMPRES(length(A)));
calculate_jumps(fastest, A) -> 
	calculate_fastest(<< <<X:?BITS>> || X <- preprocessing(A) >>, 0, length(A), length(A)).

%% ====================================================================
%% Internal functions
%% ====================================================================

loop(0, _) -> bye;
loop(N, Model) ->
	receive
		{_, {_ ,never}} -> 
			io:format("Model endless~n");
		{arrays, {Time,{ok, Iteration}}} ->  
			io:format("Processed ~w itrations in ~w ms for arrays~n", [Iteration, ?MSEC(Time)]);
		{binary, {Time,{ok, Iteration}}} ->
			io:format("Processed ~w itrations in ~w ms for binary~n", [Iteration, ?MSEC(Time)]);
		{fastest, {Time,{ok, Iteration}}} ->
			io:format("Processed ~w itrations in ~w ms for fastest~n", [Iteration, ?MSEC(Time)]);		
		Other -> 
			io:format("Unknown message ~s~n", [Other])
	after
		2000 -> 
			io:format("It is ~w~n", [N div 4]),
			spawn(?MODULE, test, [self(), arrays, Model]),
			spawn(?MODULE, test, [self(), binary, Model]),
			spawn(?MODULE, test, [self(), fastest, Model])
	end,
	loop(N -1, Model).

prototype(1) -> [1];
prototype(N) when N band 1 == 0 ->
	lists:reverse(odd([], N)) ++ [N bsr 1] ++ negative(even([], N - 2));
prototype(N) when N band 1 == 1 ->
	lists:reverse(even([], N)) ++ [1 +N bsr 1] ++ negative(odd([], N - 2)).

odd(L, 0) -> L;
odd(L, N) when N band 1 == 1 -> odd([N|L], N -1);
odd(L, N) -> odd(L, N -1).

even(L, 0) -> L;
even(L, N) when N band 1 == 0 -> even([N|L], N -1);
even(L, N) -> even(L, N -1).

negative(L) -> 
	[0 - N || N <- L].

preprocessing(L) -> preprocessing(lists:reverse(L), length(L) - 1, []).
preprocessing([], _, Acc) -> Acc;
preprocessing([H|T], N, Acc) -> preprocessing(T, N - 1, [H + N|Acc]). 

%% ====================================================================
%% Fastest solution
%% ====================================================================
nth(Bin, Index) -> 
	<<Nth:?BITS/integer-signed>> = binary:part(Bin, {?MUL(Index), ?BYTES}), 
	Nth.


calculate_fastest(_, Index, Jumps, Size)
  when Index < 0; Index >= Size -> {ok, Size - Jumps};
calculate_fastest(_, _, 0, _) -> never;
calculate_fastest(Data, Index, Jumps, Size) ->
		calculate_fastest(Data, nth(Data, Index), Jumps-1, Size).

%% ====================================================================
%% Binary solution
%% ====================================================================

calculate_binary(_, Jumps)
  when ?INDEX < 0; ?INDEX >= ?SIZE -> {ok, ?SIZE - ?JUMPS};
calculate_binary(_, Jumps) when ?JUMPS == 0 -> never;
calculate_binary(Data, Jumps) ->
		calculate_binary(Data, ?COMPRES(nth(Data, ?INDEX), ?SIZE , ?JUMPS) - 1).

%% ====================================================================
%% Arrays solution
%% ====================================================================

calculate_arrays(Data, Jumps) ->
	<<Index:20/integer, Size:20/integer, Now:20/integer>> = <<Jumps:60>>,
	if 
		
		Index < 0; Index >= Size -> {ok, Size - Now};
		Now == 0 -> never;
		true -> 
			Idx = array:get(Index, Data),
			<<NextJumps:60>> = <<Idx:20/integer, Size:20/integer, Now:20/integer>>,
			calculate_arrays(Data, NextJumps -1)
	end.






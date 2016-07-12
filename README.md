# game_bin

This is simple task need to understand 
how we can use binary calculations in Erlang

Let us think of a game consisting of a series of boxes
arranged in a single line, in which a player starts by jumping
onto the first box, and each box contains a relative pointer
to another box so that if we think of the boxes as a zero-
indexed array, then if A[K] = M then element A[K] points to
element A[K+M].
The array defines a sequence of jumps of a player as follows:

	• initially, the player is located at the first
	element.
	• on each jump the player moves from its current
	element to the destination element pointed to by
	the current element; i.e. if the player stands on
	element A[K] then it jumps to the element pointed
	to by A[K];
	• the player may jump forever or may jump out of
	the array.

For example, consider the following array A.
A[0] = 2	A[1] = 3	A[2] = -1	A[3] = 1	A[4] = 3

	• initially, the player is located at element A[0];
	• on the first jump, the player moves from A[0] to 
	A[2] because 0 + A[0] = 2;
	• on the second jump, the player moves from A[2] to
	A[1] because 2 + A[2] = 1;
	• on the third jump, the player moves from A[1] to
	A[4] because 1 + A[1] = 4;
	• on the fourth jump, the player jumps out of the
	array.
	
	
  
Write a function:

calculate_jumps(A) -> {ok, Jumps} | never

that, given a non-empty List A consisting of N integers,
returns the number of jumps after which the player will jump
out of the array. The function should return never if the
player will never jump out of the array.
For example, for the array A given above, the function should
return 4, as explained above. 

Given array A such that:
A[0] = 1	A[1] = 1	A[2] = -1	A[3] = 1
The function should return never.

Assume that:
	
	• N is an integer within the range [1..100,000];
	• each element of array A is an integer within the
	range [−1,000,000..1,000,000].

Complexity:

	• expected worst-case time complexity is O(N);
	• expected worst-case space complexity is O(N),
	beyond input storage (not counting the storage
	required for input arguments).
	
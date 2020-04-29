% Project: FLP - Spanning Trees
% Author: Ondřej Pavela - xpavel34
% Year: 2020


/************** Code copied from input2.pl **************/
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).

read_line(L,C) :- get_char(C), (isEOFEOL(C), L = [], !; read_line(LL,_), [C|LL] = L).

read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).
      
write_lines2([]).
write_lines2([H|T]) :- writeln(H), write_lines2(T).
/********************************************************/

% Convenience function for output to standard error stream
printError(Format) :- !, printError(Format, []).
printError(Format, Args) :- !, set_output(user_error), format(Format, Args), set_output(user_output).

% Parses input lines and returns all edges and vertices.
% Output might contain duplicate elements and should be sorted
isWhiteSpace([Char]) :- char_type(Char, space).
isWhiteSpace([Char|T]) :- char_type(Char, space), isWhiteSpace(T).

parseLine([], [], []) :- printError('Ignoring empty line\n').
parseLine([V, ' ', V], [], []) :- char_type(V, upper), printError('Ignoring invalid self loop edge\n').
parseLine([V1, ' ', V2], [(Src, Dst)], [Src, Dst]) :-
    char_type(V1, upper), char_type(V2, upper),
    sort([V1, V2], [Src, Dst]). % Sort to obtain canonical edge form
parseLine([X, ' ', Y|Tail], OutEdge, OutVertices) :- isWhiteSpace(Tail), parseLine([X, ' ', Y], OutEdge, OutVertices).

parseInput([], [], []).
parseInput([Line|Tail], OutEdges, OutVertices) :- parseLine(Line, Edge, Verts), parseInput(Tail, Edges, Vertices),
    append(Edge, Edges, OutEdges), append(Verts, Vertices, OutVertices).
parseInput([_|Tail], Edges, Vertices) :- printError('Ignoring invalid edge\n'), parseInput(Tail, Edges, Vertices).

% Prints single spanning tree in the specified format
printTree([]).
printTree([(A,B), (C,D)|Tail]) :- format('~w-~w ', [A, B]), printTree([(C,D)|Tail]).
printTree([(A,B)|Tail]) :- format('~w-~w\n', [A, B]), printTree(Tail).


% Find single combination of N elements from a total of K elements
% Works as follows: there are basically two options for each element of a list, pick or ignore
% We traverse the list and make a choice for each element. By using the setof predicate,
% we can search the whole state space and find all posibilities, i.e., all combinations of N
combination(_, 0, []).
combination([H|Tail], N, [H|Combinations]) :- N1 is N - 1, combination(Tail, N1, Combinations).
combination([_|Tail], N, Combinations) :- combination(Tail, N, Combinations).

% Utility function for DFS
% Searches the input edge set for all graph neighbours of specified vertex, excluding the parent vertex
getNeighbours(_, _, [], []).
getNeighbours(Parent, Src, [(Src, Dst)|Tail], [Dst|Output]) :- Dst \= Parent, getNeighbours(Parent, Src, Tail, Output).
getNeighbours(Parent, Src, [(Dst, Src)|Tail], [Dst|Output]) :- Dst \= Parent, getNeighbours(Parent, Src, Tail, Output).
getNeighbours(Parent, Src, [_|Tail], Destinations) :- getNeighbours(Parent, Src, Tail, Destinations).

% Visits all graph neighbours of current vertex in the DFS order
visitVertices(_, [], _, Visited, Visited).
visitVertices(CurrentVertex, [Dst|Tail], Edges, Visited, VisitedOut) :-
    dfs(CurrentVertex, Dst, Edges, Visited, VisitedNew), visitVertices(CurrentVertex, Tail, Edges, VisitedNew, VisitedOut).

% Performs DFS on a graph specified by the input edge set, returns all visited vertices
dfs(_, Current, _, Visited, Visited) :- member(Current, Visited).
dfs(Parent, Current, Edges, Visited, Out) :-getNeighbours(Parent, Current, Edges, Neighbours), !,
    visitVertices(Current, Neighbours, Edges, [Current|Visited], Out).

% Filters input list of valid edge combinations and returns list with valid spanning trees
% Each edge combination is searched with the DFS algorithm and the resulting
% number of visited vertices is compared with the number of all vertices as
% each spanning tree must contain all graph vertices.
getSpanningTrees(_, [], []).
getSpanningTrees(N, [EdgeSet|Tail], Out) :- getSpanningTrees(N, Tail, Trees), [(Initial, _)|_] = EdgeSet,
    dfs(Initial, Initial, EdgeSet, [], Visited), length(Visited, VertexCount), 
    (N == VertexCount -> Out = [EdgeSet|Trees]; Out = Trees).
    

% Extract all vertices from edge set with duplicates
extractVertices([], []).
extractVertices([(Src, Dst)|Tail], [Src, Dst|Out]) :- extractVertices(Tail, Out).

% Counts unique vertices in the input edge set
vertexCount(Edges, Count) :- extractVertices(Edges, Vertices), sort(Vertices, Sorted), length(Sorted, Count).

% Simple early check for valid candidate combinations. Each candidate edge set
% must contain all graph vertices otherwise it cannot possibly be a spanning tree
filterValidCombinations(_, [], []).
filterValidCombinations(N, [EdgeSet|Tail], Out) :- filterValidCombinations(N, Tail, Result),
    vertexCount(EdgeSet, VertexCount), (N == VertexCount -> Out = [EdgeSet|Result]; Out = Result).

start :-
    prompt(_, ''), % Set prompt to nothing
    read_lines(InputLines), !,
    parseInput(InputLines, Edges, Vertices), !,
    sort(Edges, UniqueEdges), % Sort and remove duplicates
    sort(Vertices, UniqueVertices), % Sort and remove duplicates
    length(UniqueVertices, VertexCount),
    (VertexCount > 1 ->
        SubsetSize is VertexCount - 1, !, % Find all combinations of size (|V| - 1)
        setof(Subset, combination(UniqueEdges, SubsetSize, Subset), Combinations), !,

        % Filter all combinations that do not contain all graph vertices
        filterValidCombinations(VertexCount, Combinations, ValidCombinations),
        getSpanningTrees(VertexCount, ValidCombinations, Trees),
        maplist(printTree, Trees) ; true
    ).
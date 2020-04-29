# [BUT FIT 2020] FLP (Functional and Logic programming) project no. 2

Assignment: Finding all spanning trees of undirected graphs in Prolog

## Dependencies
* **swipl (SWI-Prolog)**

## Usage
Simply compile with make and run the program as follows:
```
./flp20-log < input
    input       input file containing a graph in valid format.
                Invalid edges, duplicates and self loop edges are ignored
```

## Input graph fomat
Program expects an input where each line 
contains a single edge with the following notation:
```
<V1> <V2>\n
<V3> <V4>\n
<V5> <V6>\n
...
```
where each V marks a single vertex and is a single character from [A-Z].
Trailing whitespace characters preceding newline character are ignored.

## Output spanning tree fomat
Each output line describes a single spanning tree with the following notation:
```
<V1>-<V2> <V3>-<V4> ... <Vn-1>-<Vn>\n
...
```

where each pair `<Vi>-<Vj>` denotes an edge in the spanning tree.

The program will terminate without any output if the
input is invalid or the input graph contains no spanning trees
(due to various reasons such as with disconnected graphs).

## Example
```
<<
A B
A C
A D
>>
A-B A-C A-D
```

## Implementation
The solution is based on mathematical properties of graphs
and spanning trees. A spanning tree must contain all graph
verticies and no cycles (it is a tree after all). As such,
a spanning tree will contain exactly `|V| - 1` edges because with
less than `|V| - 1` edges we cannot possibly connect all |V| graph
vertices in a tree and with more than `|V| - 1` edges a cycle will
naturally occur. 

The program thus works as follows:
1. Input is parsed into a list of edges `[(A,B), (C,D), ...]` of size K.
2. All possible combinations of edges with size |V|-1 are generated
    from the list (no duplicate edges).
3. Candidate solutions are filtered out with a simple check as
    candiate solution (edge combination) must contain all graph vertices.
4. Each candidate is traversed with depth first search and is selected
    as a valid spanning tree if all graph verticies were visited.
    DFS checks for connectivity as a candidate of size `|V| - 1` with V
    verticies does not have to be a spanning tree. Such subgraph will
    be disconnected and contain a cycle.

## Tests
No automated tests were created, however './tests' directory
contains few valid example inputs with expected reference outputs.

Apart from that, previously existing
[test script](https://github.com/Bihanojko/SpanningTreeTests)
was used to test the core functionality and various edge cases

## Authors
* **Ondřej Pavela**

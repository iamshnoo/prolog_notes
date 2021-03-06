% ===
% Predicate to look for an extremal value in a dict. It yields that value
% and the corresponding key.
%
% As given on https://eu.swi-prolog.org/pldoc/doc_for?object=f(min/2)
% ===

% ---
% Shortcuts
% ---

min_entry_of_dict(Dict,FoundKey,FoundVal) :-
   extremal_entry_of_dict(Dict,FoundKey,FoundVal,min,earliest).

max_entry_of_dict(Dict,FoundKey,FoundVal) :-
   extremal_entry_of_dict(Dict,FoundKey,FoundVal,max,earliest).
   
% ---
% General predicate. Can look for 'min', 'max' and in both cases
% for either the 'earliest' or 'latest' entry.
% ---

extremal_entry_of_dict(Dict,FoundKey,FoundVal,MaxOrMin,How) :-
   must_be(dict,Dict),
   must_be(oneof([max,min]),MaxOrMin),
   must_be(oneof([latest,earliest]),How),
   dict_pairs(Dict,_Tag,[FirstKey-FirstVal|MorePairs]),    % simply fails on empty dict
   foldl(for_each_element(MaxOrMin,How),                   % make a "Prolog closure" with first two args already filled-in
         MorePairs,
         [FirstKey,FirstVal],
         [FoundKey,FoundVal]).

% ---
% Called for each Key-Value pair of the list of pairs contained in the Dict
% except the first one.
% K-V        : A single pair of the list of pairs.
% [Ksf,Vsf]  : The Key and Value pair (as a 2-element list) with the extremal value found so far
% [Kn,Vn]    : The new or next Key and Value pair (as a 2-element list) with the extremal value found after the call
% ---

for_each_element(MaxOrMin, How,K-V,[Ksf,Vsf],[Kn,Vn]) :-
   for_each_element_2(MaxOrMin, How, [K,V], [Ksf,Vsf], [Kn,Vn]).

for_each_element_2(max, _        , [K,V]  , [_  ,Vsf] , [K,V])     :- (V > Vsf),!. % max sought, current value is larger
for_each_element_2(max, _        , [_,V]  , [Ksf,Vsf] , [Ksf,Vsf]) :- (V < Vsf),!. % max sought, current value is smaller
for_each_element_2(min, _        , [K,V]  , [_  ,Vsf] , [K,V])     :- (V < Vsf),!. % min sought, current value is smaller
for_each_element_2(min, _        , [_,V]  , [Ksf,Vsf] , [Ksf,Vsf]) :- (V > Vsf),!. % min sought, current value is larger
for_each_element_2(_  , earliest , [_,Vx] , [Ksf,Vx]  , [Ksf,Vx])  :- !.           % value equality, and want the earliest key
for_each_element_2(_  , latest   , [K,Vx] , [_  ,Vx]  , [K,Vx]).                   % value equality, and want the latest key

% ---
% And some tests
% ---

:- begin_tests(extremal_value_of_dict).

test("empty dict", fail) :- 
   min_entry_of_dict(_{},_,_).
   
test("(earliest) min over dict #1", true([K,V] == [a,1])) :-
   min_entry_of_dict(_{a:1,b:2,c:3},K,V).

test("(earliest) min over dict #2", true([K,V] == [b,2])) :-
   min_entry_of_dict(_{a:4,b:2,c:3},K,V).
   
test("(earliest) min over dict #3", true([K,V] == [c,3])) :-
   min_entry_of_dict(_{a:5,b:4,c:3},K,V).

test("(earliest) max over dict #1", true([K,V] == [a,3])) :-
   max_entry_of_dict(_{a:3,b:2,c:1},K,V).

test("(earliest) max over dict #2", true([K,V] == [b,5])) :-
   max_entry_of_dict(_{a:3,b:5,c:4},K,V).
   
test("(earliest) max over dict #3", true([K,V] == [c,3])) :-
   max_entry_of_dict(_{a:1,b:2,c:3},K,V).
   
test("(earliest) min over dict, multiple candidates", true([K,V] == [a,1])) :-
   min_entry_of_dict(_{a:1,b:2,c:3,d:1,e:1,f:5},K,V).

test("(earliest) max over dict, multiple candidates", true([K,V] == [f,5])) :-
   max_entry_of_dict(_{a:1,b:2,c:3,d:1,e:3,f:5},K,V).
   
test("latest min over dict, multiple candidates", true([K,V] == [e,1])) :-
   extremal_entry_of_dict(_{a:1,b:2,c:3,d:1,e:1,f:5},K,V,min,latest).

test("latest max over dict, multiple candidates", true([K,V] == [f,3])) :-
   extremal_entry_of_dict(_{a:1,b:2,c:3,d:1,e:1,f:3},K,V,max,latest).
     
:- end_tests(extremal_value_of_dict).

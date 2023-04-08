:- include("/Users/stevenslater/Desktop/cpsc312proj2/Course-schedule-recommendation-tool/database.pl").

noun_phrase(L0,L5,Ind,C0,C5) :-
    det(L0,L1,_,C0,C1),
    noun(L1,L2,Ind,C1,C2),
    verb(L2,L3,Ind,C2,C3),
    prep(L3,L4,Ind,C3,C4),
    noun(L4,L5,_,C4,C5).

det(["the" | L],L,_,C,C).
det(["a" | L],L,_,C,C).
det(L,L,_,C,C).

noun(["class" | L],L,class,C,C).
noun(L,L,class,C,C).
noun(["Monday" | L],L,monday,C,C).
noun(L,L,monday,C,C).

verb(["start" | L],L,start,C,C).
verb(L,L,start,C,C).

prep(["on" | L],L,on,C,C).
prep(L,L,on,C,C).

/*
% DICTIONARY
% adj(L0,L1,Ind,C0,C1) is true if L0-L1
% is an adjective that imposes constraints C0-C1 Ind
adj(["large" | L],L,Ind, [large(Ind)|C],C).
adj([LangName,"speaking" | L],L,Ind, [language(Ind, Lang), name(Lang, LangName)|C],C).
*/

noun(["class" | L],L,Ind, _ ,C).
noun([N | L], L, Ind, C,C) :- name(Ind, N). % Parse fails if there is no entity for name

% reln(L0,L1,Sub,Obj,C0,C1) is true if L0-L1 is a relation on individuals Sub and Obj
reln(["start", "on" | L], L, Obj, Sub, [starts_on(Obj, Sub)|C], C).

% question(Question,QR,Ind) is true if Query provides an answer about Ind to Question
question(["What", "classes", "start", "on", "Monday" | L], L1, Ind, C0, C1) :-
    noun_phrase(["classes"], L2, Ind, C0, C1),
    course(Course, _, day, "mwf").

% ask(Q,A) gives answer A to question Q
ask(Q,A) :-
    get_constraints_from_question(Q,A,C),
    prove_all(C).

% get_constraints_from_question(Q,A,C) is true if C is the constraints on A to infer question Q
get_constraints_from_question(Q,A,C) :-
    question(Q,End,A,C,[]),
    member(End,[[],["?"],["."]]).

% prove_all(L) is true if all elements of L can be proved from the knowledge base
prove_all([]).
prove_all([H|T]) :-
    call(H),      % built-in Prolog predicate calls an atom
    prove_all(T).

% To get the input from a line:

q(Ans) :-
    write("Ask me: "), flush_output(current_output), 
    read_line_to_string(user_input, St), 
    split_string(St, " -", " ,?.!-", Ln), % ignore punctuation
    ask(Ln, Ans).
q(Ans) :-
    write("No more answers\n"),
    q(Ans).
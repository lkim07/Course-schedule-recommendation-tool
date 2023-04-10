:- include("database.pl").


filter :-
    read_search_term(SearchTerm),
    filter(SearchTerm).

filter(end) :- !.

filter(SearchTerm) :-
    findall(course(Course, Section, Title),
            (course(Course, Section, title, Title),
             % Check if search term is NOT a subatom of the course title OR course name
             (\+ sub_atom(Title, _, _, _, SearchTerm),
              \+ sub_atom(Course, _, _, _, SearchTerm)),
             write(Course), write(" "), write(Section), write(" "), write(Title), nl),
            _),
    filter.

read_search_term(SearchTerm) :-
    write("Enter a search term (or 'end' to quit): "),
    read_line_to_string(user_input, SearchTerm).

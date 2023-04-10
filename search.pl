:- include("database.pl").


search :-
    read_search_term(SearchTerm),
    search(SearchTerm).

search(end) :- !.

search(SearchTerm) :-
    findall(course(Course, Section, Title),
            (course(Course, Section, title, Title),
             (sub_atom(Title, _, _, _, SearchTerm);
              sub_atom(Course, _, _, _, SearchTerm))),
            Courses),
    print_courses(Courses),
    search.

print_courses([]) :- !.

print_courses([course(Course, Section, Title)|T]) :-
    write(Course), write(" "), write(Section), write(" "), write(Title), nl,
    print_courses(T).

read_search_term(SearchTerm) :-
    write("Enter a search term (or 'end' to quit): "),
    read_line_to_string(user_input, SearchTerm).

:- include("/Users/stevenslater/Desktop/cpsc312proj2/Course-schedule-recommendation-tool/database.pl").
:- use_module(library(readutil)).

search :-
    repeat,
    read_search_term(SearchTerm),
    (SearchTerm = end ->
        ! ; % Exit the repeat loop if "end" is entered
        search_courses(SearchTerm)),
    !.

search_courses(SearchTerm) :-
    findall(course(Course, Section, Title),
            (course(Course, Section, title, Title),
             (sub_atom(Title, _, _, _, SearchTerm);
              sub_atom(Course, _, _, _, SearchTerm))),
            Courses),
    print_courses(Courses).

print_courses([]) :- !.

print_courses([course(Course, Section, Title)|T]) :-
    write(Course), write(" "), write(Section), write(" "), write(Title), nl,
    print_courses(T).

read_search_term(SearchTerm) :-
    write("Enter a search term (or 'end' to quit): "),
    flush_output(current_output),
    read_line_to_codes(user_input, Input),
    string_codes(SearchTerm, Input).

:- include("/Users/stevenslater/Desktop/cpsc312proj2/Course-schedule-recommendation-tool/database.pl").
:- use_module(library(readutil)).

% SUGGEST courses functions
suggest_course(Day, Start, End, Term) :-
    course(Course, Section, title, Title),
    course(Course, Section, start, Start),
    course(Course, Section, finish, End),
    course(Course, Section, day, Day),
    course(Course, Section, term, Term),
    write(Course), write(" "), write(Section), write(" "), write(Title), nl,
    fail.  % so only one course is suggested


% sequentially asks user for input (day, start time, end time, term) and calls suggest_course to suggest courses
suggest_courses :-
    write("What days are you looking for? Type \"mwf\" for M/W/F classes, and \"tt\" for T/T classes. "), nl,
    read(Day),
    write("What is the earliest start time? Give time in 24 hour format. "), nl,
    read(Start),
    write("What time do you want to end that class? Give time in 24 hour format. "), nl,
    read(End),
    write("What term are you looking for? "), nl,
    read(Term),
    suggest_course(Day, Start, End, Term).


% FILTER functions - type in word and shows courses not relevant
filter :-
    read_search_term(SearchTerm),
    (SearchTerm = "end" -> true ; filter_courses(SearchTerm)).

filter_courses(SearchTerm) :-
    findall(course(Course, Section, Title),
            (course(Course, Section, title, Title),
             % Check if search term is NOT a subatom of the course title OR course name
             (\+ sub_atom(Title, _, _, _, SearchTerm),
              \+ sub_atom(Course, _, _, _, SearchTerm)),
             write(Course), write(" "), write(Section), write(" "), write(Title), nl),
            _),
    filter.

read_search_term(SearchTerm) :-
    write("Enter a filter term (or 'end' to quit): "),
    read_line_to_string(user_input, SearchTerm).


% SEARCH functions
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

% TIMETABLE
% Define the conflict predicate
conflict(Course1-Section1, Course2-Section2, Term, Day) :-
    % Check that the two courses being compared are different
    Course1 \= Course2,
    % Get the start and finish times of both courses
    course(Course1, Section1, start, Start1),
    course(Course1, Section1, finish, Finish1),
    course(Course1, Section1, term, Term),
    course(Course1, Section1, day, Day),
    course(Course2, Section2, start, Start2),
    course(Course2, Section2, finish, Finish2),
    course(Course2, Section2, term, Term),
    course(Course2, Section2, day, Day),
    % Check if the courses have overlapping schedules
    (Start1 =< Finish2, Finish1 >= Start2).

% Define the timetable predicate
timetable([]) :-
    write("No courses specified."), nl.

timetable(Courses) :-
    % Sort the courses alphabetically by title
    sort(Courses, SortedCourses),
    % Output the timetable for each course
    format("Timetable for the selected courses:~n"),
    output_timetable(SortedCourses),
    % Add a dashed line between course timetable and conflicts
    format("--------------------~n"),
    % Check for conflicts between the courses
    check_conflicts(SortedCourses),
    !.

% Output the timetable for each course
output_timetable([]).

output_timetable([Course-Section | Rest]) :-
    % Get the details for the course and section
    course(Course, Section, title, CourseTitle),
    course(Course, Section, term, Term),
    course(Course, Section, start, Start),
    course(Course, Section, finish, Finish),
    course(Course, Section, day, Day),
    format("~w (Section ~w): ~w ~w - ~w~n", [CourseTitle, Section, Day, Start, Finish]),
    % Continue with the rest of the courses
    output_timetable(Rest).

% Check for conflicts between the courses
check_conflicts([]).

check_conflicts([Course-Section | Rest]) :-
    % Check for conflicts with the rest of the courses
    check_course_for_conflicts(Course-Section, Rest),
    % Continue with the rest of the courses
    check_conflicts(Rest).

% Check for conflicts with a specific course and the rest of the courses
check_course_for_conflicts(_, []).

check_course_for_conflicts(Course-Section, [Other-OtherSection | Rest]) :-
    % Check for conflicts only if the courses are different
    Course \= Other,
    conflict(Course-Section, Other-OtherSection, Term, Day),
    course(Course, Section, title, CourseTitle),
    course(Other, OtherSection, title, OtherTitle),
    format("*** CONFLICT: ~w (Section ~w) and ~w (Section ~w) overlap on ~w in term ~w~n", [CourseTitle, Section, OtherTitle, OtherSection, Day, Term]),
    check_course_for_conflicts(Course-Section, Rest).

check_course_for_conflicts(Course-Section, [_ | Rest]) :-
    % Skip checking for conflicts if the courses are the same
    check_course_for_conflicts(Course-Section, Rest).

% Base case when all courses have been processed
timetable(_).

% SOMETHING EXTRA - WRITING TO FILE

% Define the file name to write the course details to
file_name('course_details.txt').

% Write the details of each course in the given list to a text file
write_course_details(Courses) :-
    % Open the file for writing
    file_name(File),
    open(File, write, Stream),
    % Write the details of each course to the file
    write_course_details(Courses, Stream),
    % Close the file
    close(Stream).

% Write the details of each course in the given list to the given stream
write_course_details([], _).

write_course_details([Course-Section | Rest], Stream) :-
    % Get the details for the course and section
    course(Course, Section, title, CourseTitle),
    course(Course, Section, term, Term),
    course(Course, Section, start, Start),
    course(Course, Section, finish, Finish),
    course(Course, Section, day, Day),
    % Write the details to the stream
    format(Stream, "~w (Section ~w): ~w ~w - ~w~n", [CourseTitle, Section, Day, Start, Finish]),
    % Continue with the rest of the courses
    write_course_details(Rest, Stream).

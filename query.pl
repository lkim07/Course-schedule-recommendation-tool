:- include('database.pl').

% suggests a course to take given a day, start time, and end time
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


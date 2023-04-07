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


% NATURAL LANGUAGE PROCESSING FOR QUERYING THE DATABASE
% TODO:

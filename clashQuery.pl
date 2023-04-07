:- include("/Users/stevenslater/Desktop/cpsc312proj2/Course-schedule-recommendation-tool/database.pl").

% build a function that takes in a course and outputs courses and sections that dont clash with it on those days and time.

no_clash(Course, Section, Day, Time) :-
    course(Course, Section, start, Start),
    course(Course, Section, finish, Finish),
    Time < Start;
    Time > Finish,
    fail.



:- include("/Users/stevenslater/Desktop/cpsc312proj2/Course-schedule-recommendation-tool/database.pl").


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

:- include('database.pl').

packed_time_table :-
    write('Enter number of courses you want to search in term 1: '), 
    read(X),
    integer(X),
    X > 0,
    length(A, X),
    maplist(read_n, A),
    write_list(A),
    create_array(MTWTF),
    check_schedule(A, MTWTF).

%%%
% Sum, CourseSectionList should be global variables.
check_schedule(CourseList, Timetable):-
    Sum = 0,
    CourseSectionList=[],
    check_schedule_helper(CourseList, Timetable, CourseSectionList, Sum),
    format('The most packed course schedule is taking ~w\n', [CourseSectionList]).

% Recursive case: check schedule for current course and update course section list and sum
check_schedule_helper([Course|Rest], Timetable, CourseSectionList, Sum) :-
    NewSum =0,
    split_string(Course, "-" , L), %
    L= [CourseName, Section],

    course(CourseName, Section, term, 1),
    course(CourseName, Section, start, Start),
    course(CourseName, Section, finish, Finish),
    course(CourseName, Section, day, Day),

    StartIndex is (Start - 800) div 30,
    FinishIndex is (Finish - 800) div 30,

    % fill the timetable based on the day and time
    (Day == "mwf"-> mwf(CourseName, Section, StartIndex, FinishIndex, Timetable, CourseSectionList), NewSum is Sum + (FinishIndex - StartIndex); tt(CourseName, Section, StartIndex, FinishIndex, Timetable, CourseSectionList), NewSum is Sum + (FinishIndex - StartIndex)),


    % Check if new sum is greater than previous sum
    (NewSum > Sum ->
        CourseSectionList = [CourseSectionList | [Course section]],
        check_schedule_helper(Rest, Timetable, NewCourseSectionList, NewSum)
    ;
        check_schedule_helper(Rest, Timetable, CourseSectionList, Sum)
    ).

% How to get into access[][]
mwf(Course, Section, StartIndex, FinishIndex, Timetable, CourseSectionList):-
    % Check if there are conflicts with existing courses in the timetable
    \+ has_conflict(Timetable[0], StartIndex, FinishIndex),
    \+ has_conflict(Timetable[2], StartIndex, FinishIndex),
    \+ has_conflict(Timetable[4], StartIndex, FinishIndex),
    % Fill in the timetable with the new course
    fill_timetable(Timetable[0], StartIndex, FinishIndex),
    fill_timetable(Timetable[2], StartIndex, FinishIndex),
    fill_timetable(Timetable[4], StartIndex, FinishIndex),
    append(CourseSectionList, [Course-Section], NewCourseSectionList).

tt(Course, Section, StartIndex, FinishIndex, Timetable, CourseSectionList):-
    \+ has_conflict(Timetable[1], StartIndex, FinishIndex),
    \+ has_conflict(Timetable[3], StartIndex, FinishIndex),
    % Fill in the timetable with the new course
    fill_timetable(Timetable[1], StartIndex, FinishIndex),
    fill_timetable(Timetable[3], StartIndex, FinishIndex),
    append(CourseSectionList, [Course-Section], NewCourseSectionList).

% Predicate to check if there are conflicts with existing courses in the timetable
has_conflict(Timetable, StartIndex, FinishIndex) :-
    between(StartIndex, FinishIndex, Index),
    nth0(Index, Timetable, Row),
    member(true, Row).

% Predicate to fill timetable with new course
fill_timetable(Timetable, StartIndex, FinishIndex) :-
    % Fill in cells between start and finish indices with true
    foreach(between(StartIndex, FinishIndex, Index), nth0(Index, Timetable, Row, [true|Row])).

% Predicate to undo filling of timetable with new course
undo_fill_timetable(Timetable, StartIndex, FinishIndex) :-
    % Fill in cells between start and finish indices with false
    foreach(between(StartIndex, FinishIndex, Index), nth0(Index, Timetable, Row, [false|Row])).

%%%%

read_n(X) :-
    write('Enter courses and their section (ex: cpsc100-101): '),
    read(X).

write_list(A) :-
    write_list(A, 1).
write_list([], _) :- nl.
write_list([H|T], X) :-
    format('~nYou have entered course ~w: ~w', [X, H]),
    X1 is X + 1,
    write_list(T, X1).


create_array(MondayToFriday) :-
    length(MondayToFriday, 5),
    create_rows(MondayToFriday).

create_rows([]).
create_rows([Row|Rows]) :-
    length(Row, 21),
    maplist(=(false), Row),
    create_rows(Rows).


update_array(MondayToFriday, RowIndex, ColumnIndex, Value, NewMondayToFriday) :-
    nth0(RowIndex, MondayToFriday, Row),
    replace(Row, ColumnIndex, Value, NewRow),
    replace(MondayToFriday, RowIndex, NewRow, NewMondayToFriday), !.

replace([_|T], 0, X, [X|T]).
replace([H|T], I, X, [H|R]) :-
    I > 0,
    NI is I-1,
    replace(T, NI, X, R).
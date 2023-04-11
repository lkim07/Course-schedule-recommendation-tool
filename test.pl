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
    check_schedule(A, MTWTF),
    write("2"),
    CourseSectionList = [],
    format('The most packed course schedule is taking ~w\n', [CourseSectionList]),
    !.

check_schedule(A, MTWTF):-
    CourseSectionList = [],
    Sum = 0,
    check_schedule_helper(A, MTWTF, CourseSectionList, Sum), !.

% Recursive case: check schedule for current course and update course section list and sum
check_schedule_helper([Course|Rest], Timetable, CourseSectionList, Sum) :-
    write("4"),
    split_string(Course, "-" , L), 
    write("split string"),
    L= [CourseName, Section],
    write(L),

    course(CourseName, Section, term, 1),
    course(CourseName, Section, start, Start),
    course(CourseName, Section, finish, Finish),
    course(CourseName, Section, day, Day),

    StartIndex is (Start - 800) div 30,
    FinishIndex is (Finish - 800) div 30,

    (Day == "mwf"-> mwf(CourseName, Section, StartIndex, FinishIndex, Timetable, CourseSectionList), NewSum is Sum + (FinishIndex - StartIndex); tt(CourseName, Section, StartIndex, FinishIndex, Timetable, CourseSectionList), NewSum is Sum + (FinishIndex - StartIndex)),

    (NewSum > Sum ->
        CourseSectionList = [CourseSectionList | [Course Section]],
        check_schedule_helper(Rest, Timetable, NewCourseSectionList, NewSum)
    ;
        check_schedule_helper(Rest, Timetable, CourseSectionList, Sum)
    ), !.

mwf(Course, Section, StartIndex, FinishIndex, Timetable, CourseSectionList):-
    % Check if there are conflicts with existing courses in the timetable
    \+ has_conflict(Timetable, StartIndex, FinishIndex, 0),
    \+ has_conflict(Timetable, StartIndex, FinishIndex, 2),
    \+ has_conflict(Timetable, StartIndex, FinishIndex, 4),

    % Fill in the timetable with the new course
    fill_timetable(Timetable[0], StartIndex, FinishIndex),
    fill_timetable(Timetable[2], StartIndex, FinishIndex),
    fill_timetable(Timetable[4], StartIndex, FinishIndex),
    append(CourseSectionList, [Course-Section], NewCourseSectionList).

tt(Course, Section, StartIndex, FinishIndex, Timetable, CourseSectionList):-
    \+ has_conflict(Timetable, StartIndex, FinishIndex, 1),
    \+ has_conflict(Timetable, StartIndex, FinishIndex, 3),

    % Fill in the timetable with the new course
    % col index from start to finish.
    update_array(Timetable, 1, ColumnIndex, Value, NewMondayToFriday),  
    update_array(Timetable, 3, ColumnIndex, Value, NewMondayToFriday),
    % fill timetable
    foreach(between(StartIndex, FinishIndex, Index), nth0(Index, Timetable[0], Row, [true|Row])),
    nth0 (index, timetable[0], )

    fill_timetable(Timetable[1], StartIndex, FinishIndex),
    fill_timetable(Timetable[3], StartIndex, FinishIndex),
    append(CourseSectionList, [Course-Section], NewCourseSectionList).

% Predicate to check if there are conflicts with existing courses in the timetable
has_conflict(Timetable, StartIndex, FinishIndex, RowIndex) :-
    nth0(RowIndex, Timetable, Row)
    between(StartIndex, FinishIndex, Index),
    nth0(Index, Row, Rows),
    member(true, Rows).

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
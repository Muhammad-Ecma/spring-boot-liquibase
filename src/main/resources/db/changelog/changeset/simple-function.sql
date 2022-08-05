CREATE OR REPLACE procedure create_attendance_by_students(studentIdListString varchar, timeTableId UUID)
    language plpgsql
AS
$$
DECLARE
    studentIdListUUID json := (select cast(studentIdListString as json));
    learned_lesson    record;
    new_student_id    varchar;
BEGIN
    FOR learned_lesson IN SELECT * FROM lesson l WHERE time_table_id = timeTableId AND NOT l.deleted
        LOOP
            FOR new_student_id IN SELECT * FROM json_array_elements_text(studentIdListUUID)
                LOOP
                    IF (SELECT COUNT(*) = 0 FROM student_attendance sa where sa.lesson_id = learned_lesson.id AND sa.student_id = new_student_id::uuid and not sa.deleted) THEN
                        INSERT INTO student_attendance (id, deleted, status, lesson_id, student_id, time_table_id)
                        VALUES (gen_random_uuid(), false, 'LEFT', learned_lesson.id, new_student_id::uuid, timeTableId);
                    END IF;
                END LOOP;
        END LOOP;
END
$$;
-- FUNCTIONAL AREA Logcheck
INSERT INTO functional_areas (functional_area_name, rmd_menu)
VALUES ('Logcheck', false);


-- PROGRAM: Sql
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Sql', 1,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'Logcheck'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs
                   WHERE program_name = 'Sql'
                     AND functional_area_id = (SELECT id
                                               FROM functional_areas
                                               WHERE functional_area_name = 'Logcheck')),
                                               'LogCheck');


-- PROGRAM FUNCTION Search Sql_logs
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Sql'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'Logcheck')),
        'Search Sql_logs',
        '/search/sql_logs',
        2,
        NULL,
        false,
        false);


-- PROGRAM FUNCTION Sql_logs
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Sql'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'Logcheck')),
        'Sql_logs',
        '/list/sql_logs',
        2,
        NULL,
        false,
        false);


-- PROGRAM: Rails1
INSERT INTO programs (program_name, program_sequence, functional_area_id)
VALUES ('Rails1', 1,
        (SELECT id FROM functional_areas WHERE functional_area_name = 'Logcheck'));

-- LINK program to webapp
INSERT INTO programs_webapps (program_id, webapp)
VALUES ((SELECT id FROM programs
                   WHERE program_name = 'Rails1'
                     AND functional_area_id = (SELECT id
                                               FROM functional_areas
                                               WHERE functional_area_name = 'Logcheck')),
                                               'LogCheck');


-- PROGRAM FUNCTION Search Rails1_logs
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Rails1'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'Logcheck')),
        'Search Rails1_logs',
        '/search/rails1_logs',
        2,
        NULL,
        false,
        false);


-- PROGRAM FUNCTION Rails1_logs
INSERT INTO program_functions (program_id, program_function_name, url, program_function_sequence,
                               group_name, restricted_user_access, show_in_iframe)
VALUES ((SELECT id FROM programs WHERE program_name = 'Rails1'
          AND functional_area_id = (SELECT id FROM functional_areas
                                    WHERE functional_area_name = 'Logcheck')),
        'Rails1_logs',
        '/list/rails1_logs',
        2,
        NULL,
        false,
        false);


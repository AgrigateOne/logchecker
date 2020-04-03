Crossbeams::MenuMigrations::Migrator.migration('LogCheck') do
  up do
    add_functional_area 'Logcheck'
    add_program 'Sql', functional_area: 'Logcheck'
    add_program 'Rails1', functional_area: 'Logcheck'
    add_program 'Nginx', functional_area: 'Logcheck'
    add_program_function 'SQL logs', functional_area: 'Logcheck', program: 'Sql', url: '/list/sql_logs'
    add_program_function 'Search SQL logs', functional_area: 'Logcheck', program: 'Sql', url: '/search/sql_logs', seq: 2
    add_program_function 'Rails logs', functional_area: 'Logcheck', program: 'Rails1', url: '/list/rails1_logs'
    add_program_function 'Search Rails logs', functional_area: 'Logcheck', program: 'Rails1', url: '/search/rails1_logs', seq: 2
    add_program_function 'Nginx logs', functional_area: 'Logcheck', program: 'Nginx', url: '/list/nginx_logs'
    add_program_function 'Search Nginx logs', functional_area: 'Logcheck', program: 'Nginx', url: '/search/nginx_logs', seq: 2
  end

  down do
    drop_functional_area 'Logcheck'
  end
end

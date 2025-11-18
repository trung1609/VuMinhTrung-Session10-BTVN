create table gioi1.employees
(
    id       int primary key,
    name     varchar(100),
    position varchar(50),
    salary   numeric(10, 2)
);
create table gioi1.employees_log
(
    employee_id int,
    operation   varchar(20),
    old_data    varchar(255),
    new_data    varchar(255),
    change_time timestamp default now()
);
--after insert
create or replace function gioi1.after_insert_employees()
    returns trigger as
$$
begin
    insert into gioi1.employees_log (employee_id, operation, old_data, new_data)
    values (new.id, 'After_insert', null, to_json(new));
    return new;
end;
$$ language plpgsql;

create trigger trg_after_insert_employees
    after insert
    on gioi1.employees
    for each row
execute function gioi1.after_insert_employees();

insert into gioi1.employees (id, name, position, salary)
values (1, 'Trung', 'Dev', 50000);

--after update
create or replace function gioi1.after_update_employees()
    returns trigger as
$$
begin
    insert into gioi1.employees_log(employee_id, operation, old_data, new_data)
    values (old.id, 'After update', to_json(old), to_json(new));
    return new;
end;
$$ language plpgsql;

create trigger trg_after_update_employees
    after update
    on gioi1.employees
    for each row
execute function gioi1.after_update_employees();


update gioi1.employees
set salary = 100000
where employees.id = 1;

--After delete
create or replace function gioi1.after_delete_employees()
    returns trigger as
$$
begin
    insert into gioi1.employees_log (employee_id, operation, old_data, new_data)
    values (old.id, 'After delete', to_json(old), null);
    return old;
end;
$$ language plpgsql;

create trigger trg_after_delete_employees
    after delete
    on gioi1.employees
    for each row
execute function gioi1.after_delete_employees();

delete
from gioi1.employees
where employees.id = 1;






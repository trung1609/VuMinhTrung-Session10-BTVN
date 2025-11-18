create table xuatsac1.customers
(
    id      int primary key,
    name    varchar(100),
    email   varchar(100),
    phone   int,
    address varchar(100)
);

create table xuatsac1.customers_log
(
    customer_id int,
    operation   varchar,
    old_data    varchar(255),
    new_data    varchar(255),
    changed_by  varchar(100),
    change_time timestamp default now()
);



--After insert
--function
create or replace function xuatsac1.after_insert_customers()
    returns trigger as
$$
begin
    insert into xuatsac1.customers_log(customer_id, operation, old_data, new_data, changed_by)
    values (new.id, 'After insert', null, to_json(new), current_user);
    return new;
end;
$$ language plpgsql;
--trigger
create trigger trg_after_insert_customers
    after insert
    on xuatsac1.customers
    for each row
execute function xuatsac1.after_insert_customers();

insert into xuatsac1.customers (id, name, email, phone, address)
values (2, 'Hung', 'hung@gmail.com', 0123423789, 'Thanh Oai, Ha Noi');

--After update
--function
create or replace function xuatsac1.after_update_customers()
    returns trigger as
$$
begin
    insert into xuatsac1.customers_log (customer_id, operation, old_data, new_data, changed_by)
    values (new.id, 'After update', to_json(old), to_json(new), current_user);
    return new;
end;
$$ language plpgsql;
--trigger
create trigger trg_after_update_customers
    after update
    on xuatsac1.customers
    for each row
execute function xuatsac1.after_update_customers();

update xuatsac1.customers
set email = 'trung2005@gmail.com'
where customers.id = 1;

--After delete
--function
create or replace function xuatsac1.after_delete_customers()
    returns trigger as
$$
begin
    insert into xuatsac1.customers_log (customer_id, operation, old_data, new_data, changed_by)
    values (old.id, 'After delete', to_json(old), null, current_user);
    return old;
end;
$$ language plpgsql;
--trigger
create trigger trg_after_delete_customers
    after delete
    on xuatsac1.customers
    for each row
execute function xuatsac1.after_delete_customers();

delete
from xuatsac1.customers
where customers.id = 2;



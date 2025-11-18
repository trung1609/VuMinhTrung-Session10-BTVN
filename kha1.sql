create table kha1.products
(
    id            serial primary key,
    name          varchar(100),
    price         numeric(10, 2),
    last_modified timestamp default now()
);

insert into kha1.products (name, price)
values ('SP1', 1000),
       ('SP2', 2000),
       ('SP3', 3000);

create or replace function kha1.update_last_modified()
    returns trigger as
$$
begin
    new.last_modified = now();
    return new;
end;
$$ language plpgsql;

create trigger trg_update_last_modified
    before update
    on kha1.products
    for each row
execute function kha1.update_last_modified();

update kha1.products
set price = 10000
where products.id = 1;




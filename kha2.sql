create table kha2.customers
(
    id           int primary key,
    name         varchar(100),
    credit_limit numeric(10, 2)
);
insert into kha2.customers (id, name, credit_limit)
values (1, 'Trung', 5000),
       (2, 'Tung', 10000),
       (3, 'Hung', 4000);

create table kha2.orders
(
    id           int primary key,
    customer_id  int references kha2.customers (id),
    order_amount numeric(10, 2)
);

create or replace function check_credit_limit()
    returns trigger as
$$
    declare c_credit_limit numeric(10,2);
begin
        select credit_limit into c_credit_limit from kha2.customers where id = new.customer_id;
    if new.order_amount > c_credit_limit then
        raise exception 'Tong so tien cua don hang vuot qua han muc toi da';
    else
        return new;
    end if;
end;
$$ language plpgsql;
create trigger trg_check_credit
    before insert
    on kha2.orders
    for each row
execute function check_credit_limit();

insert into kha2.orders (id, customer_id, order_amount)
values (1,1,4000);

insert into kha2.orders (id, customer_id, order_amount)
values (1,1,7000);



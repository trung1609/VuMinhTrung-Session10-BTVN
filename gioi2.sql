create table gioi2.products
(
    id    int primary key,
    name  varchar(100),
    stock int
);

create table gioi2.orders
(
    id         int primary key,
    product_id int references gioi2.products (id),
    quantity   int
);

insert into gioi2.products (id, name, stock)
values (1, 'SP1', 20),
       (2, 'SP2', 15),
       (3, 'SP3', 10);

--check so luong don hang moi va so luong ton kho
create or replace function gioi2.check_orders()
    returns trigger as
$$
declare
    p_stock int;
begin
    select stock into p_stock from gioi2.products p where p.id = new.product_id;
    if new.quantity > p_stock then
        raise exception 'So luong trong kho khong du';
    else
        return new;
    end if;
end;
$$ language plpgsql;
create trigger trg_check_orders_insert
    before insert
    on gioi2.orders
    for each row
execute function gioi2.check_orders();

--giam so luong ton kho khi tao don hang
--function
create or replace function gioi2.after_insert_orders()
    returns trigger as
$$
begin
    update gioi2.products
    set stock = products.stock - new.quantity
    where products.id = new.product_id;
    return new;
end;
$$ language plpgsql;
--trigger
create trigger trg_after_insert_orders
    after insert
    on gioi2.orders
    for each row
execute function gioi2.after_insert_orders();

insert into gioi2.orders (id, product_id, quantity)
values (1, 1, 10);

--cap nhat ton kho tuong ung voi su thay doi so luong

create trigger trg_check_orders_update
    before insert
    on gioi2.orders
    for each row
execute function gioi2.check_orders();
--function
create or replace function gioi2.after_update_orders()
    returns trigger as
$$
begin
    update gioi2.products
    set stock = products.stock + old.quantity - new.quantity
    where products.id = new.product_id;
    return new;
end;
$$ language plpgsql;
create trigger trg_after_update_orders
    after update
    on gioi2.orders
    for each row
execute function gioi2.after_update_orders();

update gioi2.orders
set quantity = 14
where orders.id = 1;

--tra lai so luong vao stock khi don hang bi xoa
--function
create or replace function gioi2.after_delete_orders()
    returns trigger as
$$
begin
    update gioi2.products
    set stock = products.stock + old.quantity
    where products.id = old.product_id;
    return old;
end;
$$ language plpgsql;

create trigger trg_after_delete_orders
    after delete
    on gioi2.orders
    for each row
execute function gioi2.after_delete_orders();

delete
from gioi2.orders
where orders.id = 1;






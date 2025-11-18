create table xuatsac2.products
(
    id    int primary key,
    name  varchar(100),
    stock int
);
create table xuatsac2.orders
(
    id           int primary key,
    product_id   int references xuatsac2.products (id),
    quantity     int,
    order_status boolean default true
);

--Check don hang mua co nho hon hoac bang so luong ton kho hay khong
--function
create or replace function xuatsac2.check_stock()
    returns trigger as
$$
declare
    p_stock int;
begin
    if tg_op = 'INSERT' then
        select stock into p_stock from xuatsac2.products p where p.id = new.product_id;
        if new.quantity > p_stock then
            raise exception 'So luong ton kho khong du de insert';
        end if;
        return new;
    elsif tg_op = 'UPDATE' then
        select stock into p_stock from xuatsac2.products p where p.id = new.product_id;
        if new.quantity > (p_stock + old.quantity) then
            raise exception 'So luong ton kho khong du de cap nhat';
        end if;
        return new;
    end if;
end;
$$ language plpgsql;
--trigger check khi insert
create trigger trg_check_stock_insert
    before insert
    on xuatsac2.orders
    for each row
execute function xuatsac2.check_stock();
--trigger check khi update
create trigger trg_check_stock_update
    before update
    on xuatsac2.orders
    for each row
execute function xuatsac2.check_stock();

--Giam ton kho theo so luong khi tao don hang moi
--function
create or replace function xuatsac2.after_insert_orders()
    returns trigger as
$$
begin
    update xuatsac2.products set stock = products.stock - new.quantity where products.id = new.product_id;
    return new;
end;
$$ language plpgsql;
--trigeger
create trigger trg_after_insert_orders
    after insert
    on xuatsac2.orders
    for each row
execute function xuatsac2.after_insert_orders();

insert into xuatsac2.orders (id, product_id, quantity, order_status)
values (1, 1, 15, true);


--Dieu chinh ton kho theo su thay doi so luong
--function
create or replace function xuatsac2.after_update_orders()
    returns trigger as
$$
begin
    update xuatsac2.products p set stock = stock + old.quantity - new.quantity where id = new.product_id;
    return new;
end;
$$ language plpgsql;
--trigger
create trigger trg_after_update_orders
    after update
    on xuatsac2.orders
    for each row
execute function xuatsac2.after_update_orders();

update xuatsac2.orders
set quantity = 10
where orders.id = 1;

--Tra lai ton kho tuong ung khi xoa don hang
--function
create or replace function xuatsac2.after_delete_orders() returns trigger as
$$
begin
    update xuatsac2.products p
    set stock = stock + old.quantity
    where id = old.product_id;
    return old;
end;
$$ language plpgsql;
--trigger
create trigger trg_after_delete_orders
    after delete
    on xuatsac2.orders
    for each row
execute function xuatsac2.after_delete_orders();

delete
from xuatsac2.orders
where orders.id = 1;

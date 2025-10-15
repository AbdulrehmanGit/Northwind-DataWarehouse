--dim_product
create table dim_product 
(
	product_sk int identity(1,1) primary key,
	product_id int not null,
	product_name nvarchar(40) not null,
	category_id int not null,
	category_name nvarchar(15) not null,
	description text,
	quantity_per_unit nvarchar(20),
	discontinued BIT
)
insert into dim_product (product_id,product_name,category_id,category_name,description,quantity_per_unit,discontinued )
select 
productid, 
productname,
c.CategoryID,
CategoryName,
c.description,
QuantityPerUnit ,
Discontinued
from dbo.Products  p join dbo.Categories c 
on p.CategoryID = c.CategoryID



--dim_customer
create table dim_customer 
(
customer_sk int identity(1,1) primary key,
customer_id nchar(5) not null,
company_name nvarchar(40) not null,
contact_name nvarchar(30),
contact_title nvarchar(30),
address nvarchar(60),
city nvarchar(15),
region nvarchar(15),
postal_code nvarchar(10),
country nvarchar(15),
phone nvarchar(24),
fax nvarchar(24)
)

insert into dim_customer (customer_id,company_name,contact_name,contact_title,address,city,region,postal_code,country,phone,fax)
select 
customerid,
CompanyName,
contactname,
ContactTitle,
address,
city,
region,
PostalCode,
country,
phone,
fax 
from dbo.customers

--dim_supplier
create table dim_supplier(
supplier_sk int identity(1,1) primary key,
supplier_id	int not null,
company_name	nvarchar(40),
contact_name	nvarchar(30),
contact_title	nvarchar(30),
address	nvarchar(60),
city	nvarchar(15),
region	nvarchar(15),
postalcode	nvarchar(10),
country	nvarchar(15),
phone	nvarchar(24),
fax	nvarchar(24),
homepage	ntext
)


insert into dim_supplier 
(
supplier_id,
company_name,
contact_name,
contact_title,
address,
city,
Region,
postalcode,
country,
phone,
fax,
homepage
)
select supplierid,CompanyName,ContactName,ContactTitle,Address,city,Region,PostalCode,country,phone,fax,HomePage from dbo.Suppliers

--dim_employee

create table dim_employee(
employee_sk int identity(1,1) primary key,
employee_id	int not null,
first_name	nvarchar(10) not null,
last_Name	nvarchar(20) not null ,
title	nvarchar(30),
title_of_courtesy	nvarchar(25),
birth_date	datetime		,
hire_date	datetime		,
address	nvarchar(60)		,
city	nvarchar(15)		,
region	nvarchar(15)		,
postal_code	nvarchar(10)	,
country	nvarchar(15)		,
homephone	nvarchar(24)	,
extension	nvarchar(4)		,
photo	image				,
notes	ntext				,
reports_to	int				,
photo_path	nvarchar(255)	,
territory_id	nvarchar(20)  not null,
territory_description	nchar(50) not null ,
region_id	int				not null	 ,
region_description	nchar(50) not null	 
)
insert into dim_employee (
employee_id,
first_name ,
last_name  ,
title	   ,
title_of_courtesy,
birth_date		 ,
hire_date		 ,
address			 ,
city			 ,
region			 ,
postal_code		 ,
country			 ,
homephone		 ,
extension		 ,
photo			 ,
notes			 ,
reports_to		 ,
photo_path		 ,
territory_id	 ,
territory_description,
region_id			 ,
region_description	 
)
select e.employeeid,firstname,LastName,
title,TitleOfCourtesy,
birthdate,HireDate,Address,
city,region,PostalCode,
country,homephone,extension,
photo,notes,ReportsTo,PhotoPath,
t.TerritoryID, t.TerritoryDescription,
r.RegionID,r.RegionDescription
from dbo.Employees e
join EmployeeTerritories et
on e.EmployeeID =et.EmployeeID 
join Territories t 
on et.TerritoryID = t.TerritoryID
join region r 
on t.RegionID = r.RegionID


--dim_shippers

create table dim_shipper (
shipper_sk int identity(1,1) primary key,
shipper_id	int not null,
company_name	nvarchar(40),
phone	nvarchar(24),
)


insert into dim_shipper (shipper_id,company_name,phone)
select ShipperID,CompanyName,Phone from dbo.Shippers

--dim_date
create table dim_date (
orderdate_sk	int Primary Key,
order_date	nvarchar(4000),
Year	int,
Month	int,
Day	int
)
insert into dim_date (orderdate_sk,order_date,year,month,day)
select cast(order_date_sk as Int) as order_date_sk,order_date,year,month,day  from 
(select distinct(format(OrderDate,'yyyyMMdd')) as order_date_sk  ,format(OrderDate,'dd/MM/yyyy') as order_date,Year(orderdate) as Year,Month(orderdate) as Month ,Day(orderdate)  as Day from dbo.orders o) as e


--fact_inventory

create table fact_inventory (

fact_inventory_sk int identity(1,1) primary key ,
order_date_sk	int not null,
product_sk	int not null,
units_in_stock	smallint,
units_on_order	smallint,
reorder_level	smallint

constraint fk_fact_inventory_dim_date foreign key(order_date_sk) references dim_date(orderdate_sk),
constraint fk_fact_inventory_dim_product foreign key (product_sk) references dim_product(product_sk)
);

with fact_invetory_snapshot as 
(
select format(o.orderdate,'yyyyMMdd') as order_date_sk,dp.product_sk,p.UnitsInStock,p.UnitsOnOrder,p.ReorderLevel from Products p 
join dim_product dp on p.ProductID = dp.product_id
join [Order Details] od on p.ProductID = od.ProductID 
join orders o  on od.OrderID = o.OrderID
)
insert into fact_inventory (order_date_sk,product_sk,units_in_stock,units_on_order,reorder_level)


select order_date_sk,product_sk,UnitsInStock as units_in_stock,UnitsOnOrder as units_on_order, ReorderLevel  as reorder_level from fact_invetory_snapshot
order by order_date_sk


--fact_orders

create table fact_orders (

order_sk int identity(1,1) primary key,
order_id	int not null,
product_sk	int not null,
customer_sk	int not null,
employee_sk	int not null,
orderdate_sk	int not null,
shipper_sk	int not null,
supplier_sk int not null,
unitprice	decimal(6,2),
quantity	smallint ,
discount	decimal(3,2),
actualprice	decimal(6,2) , 
orderdate	nvarchar(4000), 
requireddate	nvarchar(4000),
shippeddate	nvarchar(4000),
ShipVia	int,
freight	decimal(6,2),
ShipName	nvarchar(40),
ShipAddress	nvarchar(60),
ShipCity	nvarchar(15),
ShipRegion	nvarchar(15),
ShipPostalCode	nvarchar(10),
ShipCountry	nvarchar(15)


constraint fact_orders_product_sk foreign key(product_sk) references dim_product(product_sk),
constraint customer_sk foreign key(customer_sk)  references dim_customer(customer_sk),
constraint employee_sk foreign key(employee_sk) references dim_employee(employee_sk),
constraint orderdate_sk foreign key(orderdate_sk) references dim_date(orderdate_sk),
constraint shipper_sk foreign key(shipper_sk) references dim_shipper(shipper_sk),
constraint supplier_sk foreign key(supplier_sk) references dim_supplier(supplier_sk)
)



insert into fact_orders(order_id,product_sk,customer_sk,employee_sk,orderdate_sk,shipper_sk,supplier_sk,unitprice,Quantity,discount,actualprice,orderdate,requireddate,shippeddate,ShipVia,freight,ShipName,ShipAddress,ShipCity,ShipRegion,ShipPostalCode,ShipCountry)
select 
o.orderid as OrderId,
product_sk,
customer_sk ,
de.employee_sk,
orderdate_sk,
shipper_sk,
dsp.supplier_sk,
cast(od.UnitPrice as decimal(6,2)) as unitprice,
od.Quantity,
cast(od.Discount as decimal(3,2)) as discount,
cast((od.UnitPrice-od.Discount) as decimal(6,2)) as actualprice,
format(OrderDate,'dd/MM/yyyy') as orderdate,
format(o.RequiredDate,'dd/MM/yyyy') as requireddate,
format(ShippedDate,'dd/MM/yyyy') as shippeddate,
ShipVia,
cast(Freight as decimal(6,2)) as freight,
ShipName,
ShipAddress,
ShipCity,
ShipRegion,
ShipPostalCode,
ShipCountry 
from orders o 
join dbo.[Order Details] od
on o.OrderID =od.OrderID
join dbo.Products p
on p.ProductID = od.ProductID
join dbo.Shippers s 
on o.ShipVia =s.ShipperID
join dbo.Suppliers sp
on p.SupplierID =sp.SupplierID
join dim_product dp 
on dp.product_id = p.ProductID
join dim_customer dc 
on dc.customer_id = o.CustomerID
join dim_shipper ds 
on s.ShipperID = ds.shipper_id
join dim_date dd
on format(o.OrderDate,'dd/MM/yyyy') = dd.order_date
join dim_supplier dsp
on dsp.supplier_id = sp.SupplierID
join dim_employee de 
on de.employee_id = o.EmployeeID


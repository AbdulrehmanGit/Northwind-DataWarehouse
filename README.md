# Northwind-DataWarehouse
Built a Kimball style data warehouse from the Northwind DB for analytics. Includes dims, transactional and snapshot facts.

## Quick overview

Dimensions with surrogate keys: dim_date, dim_product, dim_customer, dim_employee, dim_supplier, dim_shipper.

### Facts:

- fact_orders — transactional (one row per order line).

- fact_inventory — snapshot (one row per product × date).

- Optional summary/aggregate facts can be derived from fact_orders for reporting performance.

## Norhtwind DB
<img width="1287" height="787" alt="image" src="https://github.com/user-attachments/assets/7f77b5d3-d8cb-4f99-a181-57043fde6eff" />

## Northwind DWH
<img width="1170" height="772" alt="image" src="https://github.com/user-attachments/assets/ba60dc3f-7b37-4315-a33a-64790c7f78e6" />

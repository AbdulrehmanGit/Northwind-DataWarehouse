# Northwind-DataWarehouse
Built a Kimball style data warehouse from the Northwind DB for analytics. Includes dims, transactional and snapshot facts.

## Quick overview

Conformed dimensions with surrogate keys: dim_date, dim_product, dim_customer, dim_employee, dim_supplier, dim_shipper.

### Facts:

-- fact_orders — transactional (one row per order line).

-- fact_inventory — snapshot (one row per product × date).

-- Optional summary/aggregate facts can be derived from fact_orders for reporting performance.

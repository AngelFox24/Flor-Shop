import Foundation
import PowerSync
// MARK: - Companies
let CompaniesTable = Table(
    name: "companies",
    columns: [
        .text("company_cic"),
        .text("company_name"),
        .text("ruc"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_companies_company_cic",
            columns: [IndexedColumn.ascending("company_cic")]
        )
    ]
)
// MARK: - Customers
let CustomersTable = Table(
    name: "customers",
    columns: [
        .text("customer_cic"),
        .text("name"),
        .text("last_name"),
        .integer("total_debt"),
        .integer("credit_score"),
        .integer("credit_days"),
        .text("date_limit"),
        .text("last_date_purchase"),
        .text("first_date_purchase_with_credit"),
        .text("phone_number"),
        .integer("credit_limit"),
        .integer("is_credit_limit_active"),
        .integer("is_credit_limit"),
        .integer("is_date_limit_active"),
        .integer("is_date_limit"),
        .text("image_url"),
        .text("company_id"),
        .text("company_cic"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_customers_company_id",
            columns: [IndexedColumn.ascending("company_id")]
        ),
        Index(
            name: "idx_customers_customer_cic",
            columns: [IndexedColumn.ascending("customer_cic")]
        )
    ]
)
// MARK: - Employees
let EmployeesTable = Table(
    name: "employees",
    columns: [
        .text("employee_cic"),
        .text("name"),
        .text("last_name"),
        .text("email"),
        .text("phone_number"),
        .text("image_url"),
        .text("company_id"),
        .text("company_cic"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_employees_company_id",
            columns: [IndexedColumn.ascending("company_id")]
        ),
        Index(
            name: "idx_employees_employee_cic",
            columns: [IndexedColumn.ascending("employee_cic")]
        )
    ]
)
// MARK: - EmployeesSubsidiaries
let EmployeesSubsidiariesTable = Table(
    name: "employees_subsidiaries",
    columns: [
        .text("role"),
        .integer("active"),
        .text("subsidiary_id"),
        .text("subsidiary_cic"),
        .text("employee_id"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_employees_subsidiaries_subsidiary_id",
            columns: [IndexedColumn.ascending("subsidiary_id")]
        ),
        Index(
            name: "idx_employees_subsidiaries_employee_id",
            columns: [IndexedColumn.ascending("employee_id")]
        )
    ]
)
// MARK: - Products
let ProductsTable = Table(
    name: "products",
    columns: [
        .text("product_cic"),
        .text("bar_code"),
        .text("product_name"),
        .text("unit_type"),
        .text("image_url"),
        .text("company_id"),
        .text("company_cic"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_products_company_id",
            columns: [IndexedColumn.ascending("company_id")]
        ),
        Index(
            name: "idx_products_product_cic",
            columns: [IndexedColumn.ascending("product_cic")]
        ),
        Index(
            name: "idx_products_bar_code",
            columns: [IndexedColumn.ascending("bar_code")]
        )
    ]
)
// MARK: - ProductSubsidiary
let ProductSubsidiaryTable = Table(
    name: "product_subsidiary",
    columns: [
        .integer("active"),
        .text("expiration_date"),
        .integer("quantity_stock"),
        .integer("unit_cost"),
        .integer("unit_price"),
        .text("product_id"),
        .text("subsidiary_id"),
        .text("subsidiary_cic"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_product_subsidiary_product_id",
            columns: [IndexedColumn.ascending("product_id")]
        ),
        Index(
            name: "idx_product_subsidiary_subsidiary_id",
            columns: [IndexedColumn.ascending("subsidiary_id")]
        )
    ]
)
// MARK: - Subsidiaries
let SubsidiariesTable = Table(
    name: "subsidiaries",
    columns: [
        .text("subsidiary_cic"),
        .text("name"),
        .text("image_url"),
        .text("company_id"),
        .text("company_cic"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_subsidiaries_company_id",
            columns: [IndexedColumn.ascending("company_id")]
        ),
        Index(
            name: "idx_subsidiaries_subsidiary_cic",
            columns: [IndexedColumn.ascending("subsidiary_cic")]
        )
    ]
)
// MARK: - Sales
let SalesTable = Table(
    name: "sales",
    columns: [
        .text("payment_type"),
        .text("sale_date"),
        .integer("total"),
        .integer("total_charged"),
        .integer("rounding_difference"),
        .text("subsidiary_id"),
        .text("subsidiary_cic"),
        .text("employee_subsidiary_id"),
        .text("customer_id"),
        .text("customer_cic"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_sales_subsidiary_id",
            columns: [IndexedColumn.ascending("subsidiary_id")]
        ),
        Index(
            name: "idx_sales_customer_id",
            columns: [IndexedColumn.ascending("customer_id")]
        )
    ]
)
// MARK: - SaleDetails
let SaleDetailsTable = Table(
    name: "sale_details",
    columns: [
        .text("product_name"),
        .text("bar_code"),
        .integer("quantity_sold"),
        .integer("subtotal"),
        .text("unit_type"),
        .integer("unit_cost"),
        .integer("unit_price"),
        .text("image_url"),
        .text("sale_id"),
        .text("subsidiary_cic"),
        .text("created_at"),
        .text("updated_at")
    ],
    indexes: [
        Index(
            name: "idx_saleDetails_sale_id",
            columns: [IndexedColumn.ascending("sale_id")]
        ),
        Index(
            name: "idx_saleDetails_bar_code",
            columns: [IndexedColumn.ascending("bar_code")]
        )
    ]
)
// MARK: - FlorShopCoreSchema
let FlorShopCoreSchema = Schema(
    tables: [
        CompaniesTable,
        CustomersTable,
        EmployeesTable,
        EmployeesSubsidiariesTable,
        ProductsTable,
        ProductSubsidiaryTable,
        SubsidiariesTable,
        SalesTable,
        SaleDetailsTable
    ]
)

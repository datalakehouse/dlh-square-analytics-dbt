# Square package

This dbt package:

*   Contains a DBT dimensional model based on square data from [Datalakehouse’s](https://www.datalakehouse.io/) connector.
*   The main use of this package is to provide a stable snowflake dimensional model that will provide useful insights.
    

### Models

The primary ouputs of this package are fact and dimension tables as listed below. There are several intermediate models used to create these models.

|        Type       |        Model       |        Raw tables involved       |
|:----------------:|:----------------:|----------------|
|Dimension| W_CATALOG_ITEM_D       | CATALOG_CATEGORY<br>CATALOG_MODIFIER<br>CATALOG_ITEM_VARIATION<br>CATALOG_ITEM<br>ORDER_LINE_ITEM<br>|
|Dimension| W_CURRENCY_D         | Manually built |
|Dimension| W_MERCHANT_LOCATION_D       | LOCATION |
|Dimension| W_CUSTOMERS_D      | CUSTOMER|
|Fact| W_ORDERS_F | ORDER<br>ORDER_LINE_ITEM<br>ORDER_LINE_ITEM_MODIFIER|
|Fact| W_PAYMENTS_F          | PAYMENT|

*Data Lineage*
| ![159382981-6347e14d-84e3-46f8-ac6b-5e0c658d0ef2.png](https://user-images.githubusercontent.com/29486566/159382981-6347e14d-84e3-46f8-ac6b-5e0c658d0ef2.png) | 
|:--:| 
| *Data Lineage* |

Installation Instructions
-------------------------

Check [dbt Hub](https://hub.getdbt.com/dbt-labs/snowplow/latest/) for the latest installation instructions, or [read the docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

Include in your packages.yml

```yaml
packages:
  - package: datalakehouse/dlh-square-analytics-dbt
    version: [">=0.1.0"]
```

Configuration
-------------

By default, this package uses `DEVELOPER_SANDBOX` as the source database name and `DEMO_SQUARE` as schema name. If this is not the where your salesforce data is, change ther below [variables](https://docs.getdbt.com/docs/using-variables) configuration on your `dbt_project.yml`:

```yaml
# dbt_project.yml

...

vars:    
    source_database: DEVELOPER_SANDBOX
    source_schema: DEMO_SQUARE
    target_schema: SQUARE
```

### Database support

Core:

*   Snowflake
    

### Contributions

Additional contributions to this package are very welcome! Please create issues or open PRs against `main`. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.


*   Fork and :star: this repository :)
*   Check it out and :star: [the datalakehouse core repository](https://github.com/datalakehouse/datalakehouse-core);

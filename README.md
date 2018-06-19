# QSAR database converted to SQL

The custom database format designed for Biobyte's QSAR database is not useful
for anyone not running Biobyte software. These scripts show how the data can
be exported to SQL.

## QSAR data

The portions of the raw QSAR data which are exported include:

* informational headers
* compound structure (SMILES)
* biological activity measurement
* regression model
* regression statistics

What is not exported is the underlying table of data (steric, electronic, etc)
upon which the regression model is built, so the exported data is not suitable
for developing new regression models.

## Main data tables:

1. qsar_sets -- descriptive text, regression model
   * qsar_id          -- integer, primary key
   * system_id        -- integer, xref 'systems' table
   * class_id         -- integer, xref 'classes' table
   * compound_id      -- integer, xref 'compounds' table
   * action_id        -- integer, xref 'actions' table
   * citation_id      -- integer, xref 'citations' table
   * model            -- text, full regression model
   * n                -- integer, number of data points in model
   * r                -- float, correlation coefficient
   * s                -- float, standard deviation

2. structures -- relates compounds to set given by 'qsar_id'
   * structure_id     -- integer, primary key
   * qsar_id          -- integer, xref 'qsar_sets' table
   * smiles_id        -- integer, xref 'smiles' table
   * observed         -- float, biological activity

3. qsar_parameters -- relates parameters in model to set given by 'qsar_id'
   * qsar_param_id    -- integer, primary key
   * qsar_id          -- integer, xref 'qsar_sets' table
   * parameter_label  -- text
   * coefficient      -- float, regression coefficient
   * confidence       -- float, 95% confidence limit

## Indirect data tables:

4. smiles
   * smiles_id   -- integer, primary key
   * smiles      -- text, 'unique' SMILES (via Biobyte method)
   * mf          -- text, molecular formula
   * mw          -- float, molecular weight

5. systems
   * system_id   -- integer, primary key
   * system      -- text

6. classes
   * class_id    -- integer, primary key
   * class       -- text

7. compounds
   * compound_id -- integer, primary key
   * compound    -- text

8. actions
   * action_id   -- integer, primary key
   * action      -- text

9. citations
   * citation_id -- integer, primary key
   * citation    -- text

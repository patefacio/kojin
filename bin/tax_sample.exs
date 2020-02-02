import Kojin.Pod.{PodPackage, PodObject, PodArray, PodEnum}

tax_package = pod_package(
  :taxes,
  """
  Objects and enumerations associated with taxes
  """,
  pod_objects: [
    pod_object(
      :tax_lot,
      """
      A single entry in a position, representing a purchase at specific price
      """,
      [
        [:quantity, "Amount purchased/sold in lot", :double],
        [:price, "Price of one unit for lot", :double],
        [:year, "When lot was created (year of purchase/sale)", :year]
      ]
    ),
    pod_object(
      :taxable_position,
      """
      Tracks lotting associated with a `Holding` position
      """,
      [
        [:total_position, "Position sum of all lots", :double],
        [:total_cost_basis, "Total cost for all lots in position", :double],
        [
          :tax_lots,
          """
          List of tax lots.

          This is the history of the position and will be tracked iff
          `TaxablePosition` is created with `from_first_lot_with_history`

          """,
          array_of(:tax_lot),
          [{:optional?, true}]
        ],
        [:mark_price, "Record of most recent mark price", :double]
      ]
    ),
    pod_object(
      :tax_basis_entry,
      """
      A single tax rate associated with basis for building tax schedules
      """,
      [
        [:basis, "Basis value beginning the tax class", :double],
        [:tax_rate, "The tax rate for this entry", :double]
      ]
    ),
    pod_object(
      :tax_schedule,
      """
      Supports tax rate with basis lookup
      """,
      [
        [:bases, "Entries in the tax schedule", array_of(:tax_basis_entry)]
      ]
    ),
    pod_object(
      :tax_category_schedule,
      """
      Schedule of tax rates for (regime, category)
      """,
      [
        [:user, "User responsible for defining tax schedule", :string],
        [:tax_regime, "Indicates authority that levies the tax", :tax_regime],
        [:year, "Year which the schedule applies", :year],
        [:tax_category, "Tax category associated with a tax", :tax_category],
        [:filing_status, "Tax filing status", :filing_status, [{:optional?, true}]],
        [:tax_schedule, "Rate associated with tax category", :tax_schedule]
      ]
    ),
    pod_object(
      :tax_schedules,
      """
      List of schedules for all categories, pulled from the database
      """,
      [
        [:fed_schedules, "Association of federal tax rates", array_of(:tax_category_schedule)],
        [
          :state_schedules,
          "Association of state tax rates",
          array_of(:tax_category_schedule),
          [{:optional?, true}]
        ]
      ]
    ),
    pod_object(
      :fed_tax_schedules,
      """
      Tax schedules for a specific forecast
      """,
      [
        [:year, "Year of the schedule", :year],
        [:filing_status, "Filing status of schedules based on `Dossier` owner", :filing_status],
        [:ordinary_income, "Tax schedule for ordinary income", :tax_schedule],
        [
          :social_security,
          "Tax schedule for social security based on `earned_income`",
          :tax_schedule
        ],
        [:medicare, "Tax schedule for medicare based on `earned_income`", :tax_schedule],
        [:qualified_dividend, "Tax schedule for qualified dividends", :tax_schedule],
        [:long_term_capital_gain, "Tax schedule for long term capital gains", :tax_schedule]
      ]
    ),
    pod_object(
      :tax_inputs,
      """
      Break down of income for tax purposes
      """,
      [
        [
          :earned_income,
          "Income from salary, wages, earnings from self-employment, etc",
          :double
        ],
        [
          :portfolio_income,
          "Income from interest, non-qualified dividends and capital gain distributions, taxed at ordinary income",
          :double
        ],
        [
          :qualified_dividends,
          "Income from qualified dividends, taxed at scaled rate (0, 15, 20) based on taxable income",
          :double
        ],
        [
          :long_term_capital_gains,
          "Gains/losses from sales of securities held one year or more",
          :double
        ],
        [
          :passive_income,
          "Rental income, income from business that does not require involvement, royalties on IP, etc",
          :double
        ],
        [
          :ordinary_income,
          "Income bucketed with the rest, not subject to SS and Medicare and not covered by any others",
          :double
        ]
      ]
    ),
    pod_object(
      :tax_determinants,
      """
      Fixed static data used to calculate taxes covering all filing statuses
      """,
      [
        [
          :tax_schedules,
          "Tax schedules, optional because taxes may be modeled with simple effective rate",
          :tax_schedules
        ],
        [:standard_deductions, "Standard deduction for tax calculations", :standard_deductions]
      ]
    ),
    pod_object(
      :fed_tax_determinants,
      """
      Fixed static data used to calculate taxes given specific filing status
      """,
      [
        [
          :fed_tax_schedules,
          "Tax schedules, optional because taxes may be modeled with simple effective rate",
          :fed_tax_schedules
        ],
        [:standard_deduction, "Standard deduction for tax calculations", :double]
      ]
    ),
    pod_object(
      :state_tax_determinants,
      """
      Details on state tax determinants
      """,
      [
        [:state_of_residence, "State of taxation", :state_of_residence]
      ]
    ),
    pod_object(
      :forecast_tax_determinants,
      """
      Combines federal and state tax determinants
      """,
      [
        [:fed_tax_determinants, "Details on federal tax calculations", :fed_tax_determinants],
        [
          :state_tax_determinants,
          "Details of state taxes, if applicable",
          :state_tax_determinants,
          [{:optional?, true}]
        ]
      ]
    ),
    pod_object(
      :standard_deductions,
      """
      The standard deductions
      """,
      [
        [:single, "Single standard deduction", :double],
        [:married_joint, "Married joint standard deduction", :double],
        [:head_of_household, "Head of household standard deduction", :double]
      ]
    ),
    pod_object(
      :fed_tax_statement,
      """
      Details of tax calculations including final bill
      """,
      [
        [:tax_inputs, "The primary inputs", :tax_inputs],
        [:total_income, "Sum of taxable income", :double],
        [:above_line_exemptions, "Exemptions above the line", :double],
        [:adjusted_gross_income, "Total income less exemptions", :double],
        [:below_line_exemptions, "Exemptions below the line", :double],
        [
          :standard_deduction,
          "Standard deduction - moved to current year from reference year",
          :double
        ],
        [:tax_basis, "Tax Basis - AGI less deductions", :double],
        [:marginal_tax_rate, "Tax rate based on scheduled lookup", :double],
        [:tax_bill_pre_credit, "Tax bill before credits", :double],
        [:credits, "Sum of credits", :double],
        [:tax_bill, "Tax bill", :double],
        [:qualified_dividend_tax, "Taxes on qualified dividends", :double],
        [
          :losses_offsetting_ordinary_income,
          "Loss from cap gains offsetting ordinary income, capped at rate (eg $3K)",
          :double
        ],
        [
          :long_term_capital_gains,
          "Remaining long term capital gains - possibly reduced by prior losses",
          :double
        ],
        [:long_term_capital_gains_tax, "Taxes on long term capital gains", :double],
        [
          :long_term_capital_gains_hurdle,
          "First entry in ltcg tax schedule, adjust for inflation",
          :double
        ],
        [:social_security_tax, "Social security taxes", :double],
        [:medicare_tax, "Medicare taxes", :double],
        [:prior_losses_available, "Losses from prior years, available this year", :double],
        [
          :losses_offsetting_gains,
          "Losses from capital gains that were applied against gains in this return",
          :double
        ],
        [
          :remaining_losses_available,
          "Losses from capital gains carried forward for future",
          :double
        ],
        [
          :total_tax_bill,
          """
          Sum of `tax_bill`, `qualified_dividend_tax`, `social_security_tax`, `medicare_tax`

          """,
          :double
        ]
      ]
    )
  ],
  pod_enums: [
    pod_enum(
      :tax_treatment,
      """
      Various types of accounts
      """,
      [
        [:taxable, "Income from the account is taxable"],
        [
          :tax_deferred,
          "Income from the account is not taxable however gains are taxed on withdrawal"
        ],
        [:tax_exempt, "Income from the account is not taxable"]
      ]
    ),
    pod_enum(
      :forecast_tax_treatment,
      """
      Dictates how the forecaster will treat accounts in terms of taxes.

      The default is `as_modeled` so all taxation is based on account types.
      If `as_tax_deferred` the forecaster ignores all account type designations
      and treats all accounts as deferred. Similarly `as_taxable` treats all
      accounts as taxable and `as_tax_exempt` treats all accounts as tax exempt.
      The purpose of these is to get a quick view of how taxes are impacting
      the forecast.
      """,
      [
        [:as_modeled, "Treat taxes as modeled by accounts"],
        [:as_taxable, "Treat all accounts as if `Taxable`"],
        [:as_tax_deferred, "Treat all accounts as if `TaxDeferred`"],
        [:as_tax_exempt, "Treat all accounts as if `TaxExempt`"]
      ]
    ),
    pod_enum(
      :state_of_residence,
      """
      The state of residence
      """,
      [
        [:ak, "AK"],
        [:al, "AL"],
        [:ar, "AR"],
        [:az, "AZ"],
        [:ca, "CA"],
        [:co, "CO"],
        [:ct, "CT"],
        [:de, "DE"],
        [:fl, "FL"],
        [:ga, "GA"],
        [:hi, "HI"],
        [:ia, "IA"],
        [:id, "ID"],
        [:il, "IL"],
        [:in, "IN"],
        [:ks, "KS"],
        [:ky, "KY"],
        [:la, "LA"],
        [:ma, "MA"],
        [:md, "MD"],
        [:me, "ME"],
        [:mi, "MI"],
        [:mn, "MN"],
        [:mo, "MO"],
        [:ms, "MS"],
        [:mt, "MT"],
        [:nc, "NC"],
        [:nd, "ND"],
        [:ne, "NE"],
        [:nh, "NH"],
        [:nj, "NJ"],
        [:nm, "NM"],
        [:nv, "NV"],
        [:ny, "NY"],
        [:oh, "OH"],
        [:ok, "OK"],
        [:or, "OR"],
        [:pa, "PA"],
        [:ri, "RI"],
        [:sc, "SC"],
        [:sd, "SD"],
        [:tn, "TN"],
        [:tx, "TX"],
        [:ut, "UT"],
        [:va, "VA"],
        [:vt, "VT"],
        [:wa, "WA"],
        [:wi, "WI"],
        [:wv, "WV"],
        [:wy, "WY"]
      ]
    ),
    pod_enum(
      :tax_regime,
      """
      Entities with authority to tax
      """,
      [
        [:fed, "Federal tax authority"],
        [:al, "AL"],
        [:ak, "AK"],
        [:az, "AZ"],
        [:ar, "AR"],
        [:ca, "CA"],
        [:co, "CO"],
        [:ct, "CT"],
        [:de, "DE"],
        [:fl, "FL"],
        [:ga, "GA"],
        [:hi, "HI"],
        [:id, "ID"],
        [:il, "IL"],
        [:in, "IN"],
        [:ia, "IA"],
        [:ks, "KS"],
        [:ky, "KY"],
        [:la, "LA"],
        [:me, "ME"],
        [:md, "MD"],
        [:ma, "MA"],
        [:mi, "MI"],
        [:mn, "MN"],
        [:ms, "MS"],
        [:mo, "MO"],
        [:mt, "MT"],
        [:ne, "NE"],
        [:nv, "NV"],
        [:nh, "NH"],
        [:nj, "NJ"],
        [:nm, "NM"],
        [:ny, "NY"],
        [:nc, "NC"],
        [:nd, "ND"],
        [:oh, "OH"],
        [:ok, "OK"],
        [:or, "OR"],
        [:pa, "PA"],
        [:ri, "RI"],
        [:sc, "SC"],
        [:sd, "SD"],
        [:tn, "TN"],
        [:tx, "TX"],
        [:ut, "UT"],
        [:vt, "VT"],
        [:va, "VA"],
        [:wa, "WA"],
        [:wv, "WV"],
        [:wi, "WI"],
        [:wy, "WY"]
      ]
    ),
    pod_enum(
      :tax_category,
      """
      Categorizes taxes according to the schedules that might be used.
      """,
      [
        [:social_security, "Social security taxes"],
        [:medicare, "Medicare taxes"],
        [:qualified_dividend, "Qualified dividends"],
        [:long_term_capital_gain, "Long term capital gains"],
        [
          :passive_income,
          "Rental income and income from business in which you do not participate"
        ],
        [:ordinary_income, "Ordinary income, effectively *other* bucket"]
      ]
    ),
    pod_enum(
      :filing_status,
      """
      The filing status for taxes
      """,
      [
        [:married_joint, "Married filing jointly"],
        [:single, "Filing single person"],
        [:head_of_household, "Filing as head of household"]
      ]
    ),
    pod_enum(
      :flow_tax_type,
      """
      Categorizes flow by tax type.

      Note: Focus is only on types for flows modeled by user.
      Flows generated by the system, like qualified dividends do have
      special treatment, but do not need to be classified here because
      they are created by the system itself. Users don't enter dividend
      flows, they model dividends and the system turns them into flows.

      """,
      [
        [:earned_income, "Flow is earned income"],
        [:passive_income, "Flow is passive income"],
        [:long_term_capital_gain, "Flow is long term capital gain"],
        [:ordinary_income, "Flow is ordinary income"],
        [:not_taxed, "Flow is not taxed"]
      ]
    )
  ]
)

package_set = Kojin.Pod.PodPackageSet.pod_package_set(:tax_sample, "Sample tax package", [tax_package])
package_to_module = Kojin.PodRust.PodPackageToModule.pod_package_to_module(package_set, tax_package)
module = Kojin.PodRust.PodPackageToModule.to_module(package_to_module)
IO.puts Kojin.Rust.Module.content(module)

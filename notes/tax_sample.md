```rust
//! Objects and enumerations associated with taxes

////////////////////////////////////////////////////////////////////////////////////
// --- type aliases ---
////////////////////////////////////////////////////////////////////////////////////

pub type Year = i32;


////////////////////////////////////////////////////////////////////////////////////
// --- enums ---
////////////////////////////////////////////////////////////////////////////////////

///  Various types of accounts
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum TaxTreatment {
  ///  Income from the account is taxable
  Taxable,
  ///  Income from the account is not taxable however gains are taxed on withdrawal
  TaxDeferred,
  ///  Income from the account is not taxable
  TaxExempt
}
////////////////////////////////////////////////////////////////////////////////////
// --- TaxTreatment trait impls ---
////////////////////////////////////////////////////////////////////////////////////

impl Default for TaxTreatment {
  ///  Function to provide default value of type
  ///
  ///  * _return_ - Returns the default, which is the first value in the enum
  fn default() -> Self {
    TaxTreatment::Taxable
  }
}


///  Dictates how the forecaster will treat accounts in terms of taxes.
///
///  The default is `as_modeled` so all taxation is based on account types.
///  If `as_tax_deferred` the forecaster ignores all account type designations
///  and treats all accounts as deferred. Similarly `as_taxable` treats all
///  accounts as taxable and `as_tax_exempt` treats all accounts as tax exempt.
///  The purpose of these is to get a quick view of how taxes are impacting
///  the forecast.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum ForecastTaxTreatment {
  ///  Treat taxes as modeled by accounts
  AsModeled,
  ///  Treat all accounts as if `Taxable`
  AsTaxable,
  ///  Treat all accounts as if `TaxDeferred`
  AsTaxDeferred,
  ///  Treat all accounts as if `TaxExempt`
  AsTaxExempt
}
////////////////////////////////////////////////////////////////////////////////////
// --- ForecastTaxTreatment trait impls ---
////////////////////////////////////////////////////////////////////////////////////

impl Default for ForecastTaxTreatment {
  ///  Function to provide default value of type
  ///
  ///  * _return_ - Returns the default, which is the first value in the enum
  fn default() -> Self {
    ForecastTaxTreatment::AsModeled
  }
}


///  The state of residence
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum StateOfResidence {
  ///  AK
  Ak,
  ///  AL
  Al,
  ///  AR
  Ar,
  ///  AZ
  Az,
  ///  CA
  Ca,
  ///  CO
  Co,
  ///  CT
  Ct,
  ///  DE
  De,
  ///  FL
  Fl,
  ///  GA
  Ga,
  ///  HI
  Hi,
  ///  IA
  Ia,
  ///  ID
  Id,
  ///  IL
  Il,
  ///  IN
  In,
  ///  KS
  Ks,
  ///  KY
  Ky,
  ///  LA
  La,
  ///  MA
  Ma,
  ///  MD
  Md,
  ///  ME
  Me,
  ///  MI
  Mi,
  ///  MN
  Mn,
  ///  MO
  Mo,
  ///  MS
  Ms,
  ///  MT
  Mt,
  ///  NC
  Nc,
  ///  ND
  Nd,
  ///  NE
  Ne,
  ///  NH
  Nh,
  ///  NJ
  Nj,
  ///  NM
  Nm,
  ///  NV
  Nv,
  ///  NY
  Ny,
  ///  OH
  Oh,
  ///  OK
  Ok,
  ///  OR
  Or,
  ///  PA
  Pa,
  ///  RI
  Ri,
  ///  SC
  Sc,
  ///  SD
  Sd,
  ///  TN
  Tn,
  ///  TX
  Tx,
  ///  UT
  Ut,
  ///  VA
  Va,
  ///  VT
  Vt,
  ///  WA
  Wa,
  ///  WI
  Wi,
  ///  WV
  Wv,
  ///  WY
  Wy
}
////////////////////////////////////////////////////////////////////////////////////
// --- StateOfResidence trait impls ---
////////////////////////////////////////////////////////////////////////////////////

impl Default for StateOfResidence {
  ///  Function to provide default value of type
  ///
  ///  * _return_ - Returns the default, which is the first value in the enum
  fn default() -> Self {
    StateOfResidence::Ak
  }
}


///  Entities with authority to tax
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum TaxRegime {
  ///  Federal tax authority
  Fed,
  ///  AL
  Al,
  ///  AK
  Ak,
  ///  AZ
  Az,
  ///  AR
  Ar,
  ///  CA
  Ca,
  ///  CO
  Co,
  ///  CT
  Ct,
  ///  DE
  De,
  ///  FL
  Fl,
  ///  GA
  Ga,
  ///  HI
  Hi,
  ///  ID
  Id,
  ///  IL
  Il,
  ///  IN
  In,
  ///  IA
  Ia,
  ///  KS
  Ks,
  ///  KY
  Ky,
  ///  LA
  La,
  ///  ME
  Me,
  ///  MD
  Md,
  ///  MA
  Ma,
  ///  MI
  Mi,
  ///  MN
  Mn,
  ///  MS
  Ms,
  ///  MO
  Mo,
  ///  MT
  Mt,
  ///  NE
  Ne,
  ///  NV
  Nv,
  ///  NH
  Nh,
  ///  NJ
  Nj,
  ///  NM
  Nm,
  ///  NY
  Ny,
  ///  NC
  Nc,
  ///  ND
  Nd,
  ///  OH
  Oh,
  ///  OK
  Ok,
  ///  OR
  Or,
  ///  PA
  Pa,
  ///  RI
  Ri,
  ///  SC
  Sc,
  ///  SD
  Sd,
  ///  TN
  Tn,
  ///  TX
  Tx,
  ///  UT
  Ut,
  ///  VT
  Vt,
  ///  VA
  Va,
  ///  WA
  Wa,
  ///  WV
  Wv,
  ///  WI
  Wi,
  ///  WY
  Wy
}
////////////////////////////////////////////////////////////////////////////////////
// --- TaxRegime trait impls ---
////////////////////////////////////////////////////////////////////////////////////

impl Default for TaxRegime {
  ///  Function to provide default value of type
  ///
  ///  * _return_ - Returns the default, which is the first value in the enum
  fn default() -> Self {
    TaxRegime::Fed
  }
}


///  Categorizes taxes according to the schedules that might be used.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum TaxCategory {
  ///  Social security taxes
  SocialSecurity,
  ///  Medicare taxes
  Medicare,
  ///  Qualified dividends
  QualifiedDividend,
  ///  Long term capital gains
  LongTermCapitalGain,
  ///  Rental income and income from business in which you do not participate
  PassiveIncome,
  ///  Ordinary income, effectively *other* bucket
  OrdinaryIncome
}
////////////////////////////////////////////////////////////////////////////////////
// --- TaxCategory trait impls ---
////////////////////////////////////////////////////////////////////////////////////

impl Default for TaxCategory {
  ///  Function to provide default value of type
  ///
  ///  * _return_ - Returns the default, which is the first value in the enum
  fn default() -> Self {
    TaxCategory::SocialSecurity
  }
}


///  The filing status for taxes
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum FilingStatus {
  ///  Married filing jointly
  MarriedJoint,
  ///  Filing single person
  Single,
  ///  Filing as head of household
  HeadOfHousehold
}
////////////////////////////////////////////////////////////////////////////////////
// --- FilingStatus trait impls ---
////////////////////////////////////////////////////////////////////////////////////

impl Default for FilingStatus {
  ///  Function to provide default value of type
  ///
  ///  * _return_ - Returns the default, which is the first value in the enum
  fn default() -> Self {
    FilingStatus::MarriedJoint
  }
}


///  Categorizes flow by tax type.
///
///  Note: Focus is only on types for flows modeled by user.
///  Flows generated by the system, like qualified dividends do have
///  special treatment, but do not need to be classified here because
///  they are created by the system itself. Users don't enter dividend
///  flows, they model dividends and the system turns them into flows.
#[derive(Clone, Debug, Deserialize, PartialEq, Serialize)]
pub enum FlowTaxType {
  ///  Flow is earned income
  EarnedIncome,
  ///  Flow is passive income
  PassiveIncome,
  ///  Flow is long term capital gain
  LongTermCapitalGain,
  ///  Flow is ordinary income
  OrdinaryIncome,
  ///  Flow is not taxed
  NotTaxed
}
////////////////////////////////////////////////////////////////////////////////////
// --- FlowTaxType trait impls ---
////////////////////////////////////////////////////////////////////////////////////

impl Default for FlowTaxType {
  ///  Function to provide default value of type
  ///
  ///  * _return_ - Returns the default, which is the first value in the enum
  fn default() -> Self {
    FlowTaxType::EarnedIncome
  }
}



////////////////////////////////////////////////////////////////////////////////////
// --- structs ---
////////////////////////////////////////////////////////////////////////////////////

///  A single entry in a position, representing a purchase at specific price
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct TaxLot {
  ///  Amount purchased/sold in lot
  pub quantity: f64,
  ///  Price of one unit for lot
  pub price: f64,
  ///  When lot was created (year of purchase/sale)
  pub year: Year
}

///  Tracks lotting associated with a `Holding` position
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct TaxablePosition {
  ///  Position sum of all lots
  pub total_position: f64,
  ///  Total cost for all lots in position
  pub total_cost_basis: f64,
  ///  List of tax lots.
  ///
  ///  This is the history of the position and will be tracked iff
  ///  `TaxablePosition` is created with `from_first_lot_with_history`
  pub tax_lots: Option<Vec<TaxLot>>,
  ///  Record of most recent mark price
  pub mark_price: f64
}

///  A single tax rate associated with basis for building tax schedules
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct TaxBasisEntry {
  ///  Basis value beginning the tax class
  pub basis: f64,
  ///  The tax rate for this entry
  pub tax_rate: f64
}

///  Supports tax rate with basis lookup
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct TaxSchedule {
  ///  Entries in the tax schedule
  pub bases: Vec<TaxBasisEntry>
}

///  Schedule of tax rates for (regime, category)
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct TaxCategorySchedule {
  ///  User responsible for defining tax schedule
  pub user: String,
  ///  Indicates authority that levies the tax
  pub tax_regime: TaxRegime,
  ///  Year which the schedule applies
  pub year: Year,
  ///  Tax category associated with a tax
  pub tax_category: TaxCategory,
  ///  Tax filing status
  pub filing_status: Option<FilingStatus>,
  ///  Rate associated with tax category
  pub tax_schedule: TaxSchedule
}

///  List of schedules for all categories, pulled from the database
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct TaxSchedules {
  ///  Association of federal tax rates
  pub fed_schedules: Vec<TaxCategorySchedule>,
  ///  Association of state tax rates
  pub state_schedules: Option<Vec<TaxCategorySchedule>>
}

///  Tax schedules for a specific forecast
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct FedTaxSchedules {
  ///  Year of the schedule
  pub year: Year,
  ///  Filing status of schedules based on `Dossier` owner
  pub filing_status: FilingStatus,
  ///  Tax schedule for ordinary income
  pub ordinary_income: TaxSchedule,
  ///  Tax schedule for social security based on `earned_income`
  pub social_security: TaxSchedule,
  ///  Tax schedule for medicare based on `earned_income`
  pub medicare: TaxSchedule,
  ///  Tax schedule for qualified dividends
  pub qualified_dividend: TaxSchedule,
  ///  Tax schedule for long term capital gains
  pub long_term_capital_gain: TaxSchedule
}

///  Break down of income for tax purposes
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct TaxInputs {
  ///  Income from salary, wages, earnings from self-employment, etc
  pub earned_income: f64,
  ///  Income from interest, non-qualified dividends and capital gain distributions, taxed at ordinary income
  pub portfolio_income: f64,
  ///  Income from qualified dividends, taxed at scaled rate (0, 15, 20) based on taxable income
  pub qualified_dividends: f64,
  ///  Gains/losses from sales of securities held one year or more
  pub long_term_capital_gains: f64,
  ///  Rental income, income from business that does not require involvement, royalties on IP, etc
  pub passive_income: f64,
  ///  Income bucketed with the rest, not subject to SS and Medicare and not covered by any others
  pub ordinary_income: f64
}

///  Fixed static data used to calculate taxes covering all filing statuses
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct TaxDeterminants {
  ///  Tax schedules, optional because taxes may be modeled with simple effective rate
  pub tax_schedules: TaxSchedules,
  ///  Standard deduction for tax calculations
  pub standard_deductions: StandardDeductions
}

///  Fixed static data used to calculate taxes given specific filing status
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct FedTaxDeterminants {
  ///  Tax schedules, optional because taxes may be modeled with simple effective rate
  pub fed_tax_schedules: FedTaxSchedules,
  ///  Standard deduction for tax calculations
  pub standard_deduction: f64
}

///  Details on state tax determinants
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct StateTaxDeterminants {
  ///  State of taxation
  pub state_of_residence: StateOfResidence
}

///  Combines federal and state tax determinants
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct ForecastTaxDeterminants {
  ///  Details on federal tax calculations
  pub fed_tax_determinants: FedTaxDeterminants,
  ///  Details of state taxes, if applicable
  pub state_tax_determinants: Option<StateTaxDeterminants>
}

///  The standard deductions
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct StandardDeductions {
  ///  Single standard deduction
  pub single: f64,
  ///  Married joint standard deduction
  pub married_joint: f64,
  ///  Head of household standard deduction
  pub head_of_household: f64
}

///  Details of tax calculations including final bill
#[derive(Clone, Debug, Default, Deserialize, PartialEq, Serialize)]
pub struct FedTaxStatement {
  ///  The primary inputs
  pub tax_inputs: TaxInputs,
  ///  Sum of taxable income
  pub total_income: f64,
  ///  Exemptions above the line
  pub above_line_exemptions: f64,
  ///  Total income less exemptions
  pub adjusted_gross_income: f64,
  ///  Exemptions below the line
  pub below_line_exemptions: f64,
  ///  Standard deduction - moved to current year from reference year
  pub standard_deduction: f64,
  ///  Tax Basis - AGI less deductions
  pub tax_basis: f64,
  ///  Tax rate based on scheduled lookup
  pub marginal_tax_rate: f64,
  ///  Tax bill before credits
  pub tax_bill_pre_credit: f64,
  ///  Sum of credits
  pub credits: f64,
  ///  Tax bill
  pub tax_bill: f64,
  ///  Taxes on qualified dividends
  pub qualified_dividend_tax: f64,
  ///  Loss from cap gains offsetting ordinary income, capped at rate (eg $3K)
  pub losses_offsetting_ordinary_income: f64,
  ///  Remaining long term capital gains - possibly reduced by prior losses
  pub long_term_capital_gains: f64,
  ///  Taxes on long term capital gains
  pub long_term_capital_gains_tax: f64,
  ///  First entry in ltcg tax schedule, adjust for inflation
  pub long_term_capital_gains_hurdle: f64,
  ///  Social security taxes
  pub social_security_tax: f64,
  ///  Medicare taxes
  pub medicare_tax: f64,
  ///  Losses from prior years, available this year
  pub prior_losses_available: f64,
  ///  Losses from capital gains that were applied against gains in this return
  pub losses_offsetting_gains: f64,
  ///  Losses from capital gains carried forward for future
  pub remaining_losses_available: f64,
  ///  Sum of `tax_bill`, `qualified_dividend_tax`, `social_security_tax`, `medicare_tax`
  pub total_tax_bill: f64
}


// α <mod-def taxes>
// ω <mod-def taxes>
```
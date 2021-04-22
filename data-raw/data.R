# notes ----

# I recommend checking out the census reporter (https://censusreporter.org/) to
# learn more about census data, it is much more accessible than USCB resources

# in this analysis, I determine the value of "median" variables by taking the
# mean of all census tracts in a given area so that tracts with exceptionally
# high median values (e.g., median income in some UES tracts) don't skew the
# overall data for that region. so, for example, median income is instead the
# average median income of all census tracts in a given area.

# setup ----

# # use ctrl+shift+C to uncomment and run this block of code if needed
#
# # install packages used in this analysis
# install.packages(c("tidyverse","tidycensus", "sf"))
#
# # census api key (only need to install once)
# # request an api key here: https://api.census.gov/data/key_signup.html
# my_key <- 'YOUR_KEY_HERE'
# tidycensus::census_api_key(my_key, install = TRUE)
# # restart R and check installation
# Sys.getenv("CENSUS_API_KEY")
#
# # if you're having issues, you can manually edit your .Renviron file
# usethis::edit_r_environ()

# prep ----

library(tidyverse)
library(tidycensus)
library(sf)

# geographic data ----

geos <- c("assembly", "borough", "commBoard", "congressional", "council", "modzcta",
          "nCode", "school", "stateSenate", "tract_2020", "tract_2010")

data <- list()
for (i in geos) {
  df <- st_read(paste0("data-raw/geo_", i, ".geojson")) %>%
    mutate(GEO_ID = as.character(GEO_ID))

  data[[paste0("geo_", i)]] <- df
}
list2env(data, envir=.GlobalEnv)
rm(data, df, i, geos)

crosswalk_tract_2020 <- read_csv("data-raw/crosswalk_tract_2020.csv") %>%
  mutate(across(where(is.numeric), as.character))

usethis::use_data(crosswalk_tract_2020, geo_assembly, geo_borough, geo_commBoard, geo_congressional, geo_council, geo_modzcta,
                  geo_nCode, geo_school, geo_stateSenate, geo_tract_2020, geo_tract_2010, overwrite = TRUE)

# response rate data ----

geos <- c("assembly", "borough", "commBoard", "congressional", "council", "modzcta",
          "nCode", "nyc", "school", "stateSenate", "tract_2020", "us")

data <- list()
for (i in geos) {
  df <- read_csv(paste0("data-raw/rr_", i, ".csv")) %>%
    mutate(GEO_ID = as.character(GEO_ID))

  if (i != "us") {
    df <- mutate(df, RESP_DATE = as.Date(RESP_DATE, format = "%m/%d/%Y"))
  }

  if (i %in% c("nyc", "us")) {
    df <- select(df, -GEO_ID)
  }

  if (i == "tract_2020") {
    df <- mutate(df, TRACT = as.character(TRACT))
  }

  data[[paste0("rr_", i)]] <- df
}
list2env(data, envir=.GlobalEnv)
rm(data, df, i, geos)

usethis::use_data(rr_assembly, rr_borough, rr_commBoard, rr_congressional, rr_council, rr_modzcta,
                  rr_nCode, rr_nyc, rr_school, rr_stateSenate, rr_tract_2020, rr_us, overwrite = TRUE)

# acs data ----

# load crosswalk file
crosswalk <- read_csv("data-raw/crosswalk_tract_2010.csv") %>%
  mutate(across(everything(), as.character))

# save nyc county names
nyc_counties <- c("Bronx","Kings","New York","Queens","Richmond")

# save list of acs variables
acs5_2019 <- load_variables(2019, "acs5", cache = TRUE) %>%
  filter(!str_detect(name, "B16001"))
acs5_2015 <- load_variables(2015, "acs5", cache = TRUE) %>%
  filter(str_detect(name, "B16001"))
acs5_vars <- bind_rows(acs5_2015, acs5_2019)

# create vectors of tables names based on how they will be aggregated
sums <- c(
  "B03002", # race
  "B19058", # snap benefits
  "B25014", # occupancy
  "B15003", # education
  "B01001", # sex by age
  "B12001", # sex by marital status
  "C24010", # sex by occupation
  "C24030", # sex by industry
  "B11001", # household type
  "B16001", # language
  "B17023", # poverty status by number of own children in household
  "B27011", # health insurance
  "B01003", # total population
  "B25008" # total housing units
)

means <- c(
  "B19013", # median income
  "B01002" # median age by sex
)

all_tables <- c(sums, means)

# data download

# run get_acs() on every table name and create a wide data frame
acs_tract_raw <- map_df(all_tables,
                        ~ get_acs(geography = "tract", table = ., state = "NY",
                                  # detailed language data only available at tract level up until 2015
                                  county = nyc_counties, year = ifelse(. == "B16001", 2015, 2019))) %>%
  select(-c(NAME, moe)) %>%
  pivot_wider(names_from = variable, values_from = estimate)

# data wrangling

# clean up census tables
acs5_tables <- acs5_vars %>%
  # save table name by removing suffix from variable name
  mutate(table = str_remove_all(name, "_[[:digit:]]*")) %>%
  # filter to only include downloaded tables
  filter(table %in% all_tables) %>%
  # add demo column
  mutate(demo = case_when(
    table == "B03002" ~ "Race", # race
    table == "B19058" ~ "SNAP", # snap benefits
    table == "B25014" ~ "Occupancy", # occupancy
    table == "B15003" ~ "Education", # education
    table == "B01001" ~ "Age", # sex by age
    table == "B12001" ~ "Marital Status", # sex by marital status
    table == "C24010" ~ "Occupation", # sex by occupation
    table == "C24030" ~ "Industry", # sex by industry
    table == "B11001" ~ "Household Type", # household type
    table == "B16001" ~ "Language", # language
    table == "B17023" ~ "Poverty", # poverty status by number of own children in household
    table == "B27011" ~ "Health Insurance", # health insurance
    table == "B01003" ~ "Total Population", # total population
    table == "B25008" ~ "Total HousingUnits", # total housing units
    table == "B19013" ~ "Median Income", # median income
    table == "B01002" ~ "Median Age" # median age by sex
  )) %>%
  # refactor label name
  mutate(label = str_remove_all(label, c('Estimate!!|"|,|:|--|\\(|\\)')),
         label = str_remove_all(label, "'"),
         label = str_to_title(label),
         label = str_replace_all(label, c("!!" = "_", " " = "_", "-" = "_")),
         label = str_replace_all(label, "__", "_"),
         label = str_remove_all(label, "_Total"),
         label = str_replace_all(label, "Total", str_remove(demo, " ")),
         label = str_replace_all(label, "Median", str_remove(demo, " ")),
         label = str_remove_all(label, "_Household_Income_In_The_Past_12_Months_In_2019_Inflation_Adjusted_Dollars"),
         label = str_remove_all(label, "_Or_Food_Stamps/Snap")) %>%
  select(demo, table, everything())

# function to calculate totals for every geography
acs_totals <- function(geography) {
  crosswalk %>%
    # select tract and desired geography columns
    select(GEOID10, {{geography}}) %>%
    # join these columns with acs tract data
    right_join(acs_tract_raw, by = c("GEOID10" = "GEOID")) %>%
    # group by desired geography
    group_by({{geography}}) %>%
    # take the mean of median variables and sum all others
    summarize(across(contains(sums), ~sum(.x, na.rm = TRUE)),
              across(contains(means), ~mean(.x, na.rm = TRUE))) %>%
    # removing grouping
    ungroup() %>%
    # pivot table
    pivot_longer(where(is.numeric)) %>%
    # replace any NaN values with NA
    mutate(value = ifelse(is.nan(value), NA, value)) %>%
    # add variable definitions from data dictionary
    left_join(acs5_tables, by = "name") %>%
    # group by geography and table
    group_by({{geography}}, table) %>%
    # calculate percentage if variable is NOT a median value or 0 (generates NaN values)
    mutate(percentage = ifelse(table %in% means | is.na(value), NA,
                               round(value / max(value), digits = 4))) %>%
    # arrange columns in desired order
    select({{geography}}, table, everything()) %>%
    # remove grouping
    ungroup() %>%
    # drop any tracts not assigned to desired geography
    drop_na({{geography}}) %>%
    # arrange by table column
    arrange({{geography}}, table) %>%
    # arrange columns in order
    select({{geography}}, demo, table, name, label, value, percentage, concept)
}

# calculate totals for desired geographies
acs_modzcta <- acs_totals(modzcta)
acs_congressional <- acs_totals(congressional)
acs_school <- acs_totals(school)
acs_council <- acs_totals(council)
acs_assembly <- acs_totals(assembly)
acs_stateSenate <- acs_totals(stateSenate)
acs_commBoard <- acs_totals(commBoard)
acs_nCode <- acs_totals(nCode)
acs_borough <- acs_totals(borough)
acs_tract_2010 <- acs_totals(GEOID10) %>%
  rename(tract_2010 = GEOID10) %>%
  mutate(tract_2010 = paste0("1400000US", tract_2010))

# export raw data

# write csvs
write_csv(acs_modzcta, "data-raw/acs_modzcta.csv")
write_csv(acs_congressional, "data-raw/acs_congressional.csv")
write_csv(acs_school, "data-raw/acs_school.csv")
write_csv(acs_council, "data-raw/acs_council.csv")
write_csv(acs_assembly, "data-raw/acs_assembly.csv")
write_csv(acs_stateSenate, "data-raw/acs_stateSenate.csv")
write_csv(acs_commBoard, "data-raw/acs_commBoard.csv")
write_csv(acs_nCode, "data-raw/acs_nCode.csv")
write_csv(acs_borough, "data-raw/acs_borough.csv")
# write_csv(acs_tract_2010, "data-raw/acs_tract_2010.csv") # too large to store on GitHub

# calculate demos

# save vectors of variables to pull counts for
counts <- c(
  "B01003", # total population
  "B25008", # total housing units
  "B19013", # median income
  "B01002" # median age by sex
)

# function to calculate demos for every geography
acs_demos <- function(geography){
  get(paste0("acs_", geography)) %>%
    # pull percentages for variables not in counts vector
    mutate(value = ifelse(table %in% counts, value, percentage)) %>%
    select({{geography}}, label, value) %>%
    pivot_wider(names_from = label,
                values_from = value) %>%
    rowwise() %>%
    transmute("{geography}" := !!as.name(geography),
              TotalPopulation = TotalPopulation,
              TotalHousingUnits = TotalHousingUnits,
              TotalHousingUnits_PercentOwned = ifelse(TotalHousingUnits == 0, NA,
                                                      TotalHousingUnits_Owner_Occupied/TotalHousingUnits),
              TotalHousingUnits_PercentRented = ifelse(TotalHousingUnits == 0, NA,
                                                       TotalHousingUnits_Renter_Occupied/TotalHousingUnits),
              Sex_Male = Age_Male,
              Sex_Female = Age_Female,
              MedianAge = MedianAge_Age,
              MedianIncome = MedianIncome,
              Poverty_BelowPovertyLevel = Poverty_Income_In_The_Past_12_Months_Below_Poverty_Level,
              Poverty_AtOrAboveovertyLevel = Poverty_Income_In_The_Past_12_Months_At_Or_Above_Poverty_Level,
              SNAP_Recipient = SNAP_With_Cash_Public_Assistance,
              SNAP_NotRecipient = SNAP_No_Cash_Public_Assistance,
              Age_Under18 = sum(Age_Male_Under_5_Years, Age_Male_5_To_9_Years, Age_Male_10_To_14_Years,
                                Age_Male_15_To_17_Years, Age_Female_Under_5_Years, Age_Female_5_To_9_Years,
                                Age_Female_10_To_14_Years, Age_Female_15_To_17_Years, na.rm = TRUE),
              Age_18To34 = sum(Age_Male_18_And_19_Years, Age_Male_20_Years, Age_Male_21_Years, Age_Male_22_To_24_Years,
                               Age_Male_25_To_29_Years, Age_Male_30_To_34_Years, Age_Female_18_And_19_Years,
                               Age_Female_20_Years, Age_Female_21_Years, Age_Female_22_To_24_Years, Age_Female_25_To_29_Years,
                               Age_Female_30_To_34_Years, na.rm = TRUE),
              Age_35To44 = sum(Age_Male_35_To_39_Years, Age_Male_40_To_44_Years, Age_Female_35_To_39_Years,
                               Age_Female_40_To_44_Years, na.rm = TRUE),
              Age_45To54 = sum(Age_Male_45_To_49_Years, Age_Male_50_To_54_Years, Age_Female_45_To_49_Years,
                               Age_Female_50_To_54_Years, na.rm = TRUE),
              Age_55To64 = sum(Age_Male_55_To_59_Years, Age_Male_60_And_61_Years, Age_Male_62_To_64_Years,
                               Age_Female_55_To_59_Years, Age_Female_60_And_61_Years, Age_Female_62_To_64_Years,
                               na.rm = TRUE),
              Age_Over65 = sum(Age_Male_65_And_66_Years, Age_Male_67_To_69_Years, Age_Male_70_To_74_Years,
                               Age_Male_75_To_79_Years, Age_Male_80_To_84_Years, Age_Male_85_Years_And_Over,
                               Age_Female_65_And_66_Years, Age_Female_67_To_69_Years, Age_Female_70_To_74_Years,
                               Age_Female_75_To_79_Years, Age_Female_80_To_84_Years, Age_Female_85_Years_And_Over,
                               na.rm = TRUE),
              Race_White_NotHispanic = Race_Not_Hispanic_Or_Latino_White_Alone,
              Race_White_Hispanic = Race_Hispanic_Or_Latino_White_Alone,
              Race_Black_NotHispanic = Race_Not_Hispanic_Or_Latino_Black_Or_African_American_Alone,
              Race_Black_Hispanic = Race_Hispanic_Or_Latino_Black_Or_African_American_Alone,
              Race_Amerind_NotHispanic = Race_Not_Hispanic_Or_Latino_American_Indian_And_Alaska_Native_Alone,
              Race_Amerind_Hispanic = Race_Hispanic_Or_Latino_American_Indian_And_Alaska_Native_Alone,
              Race_Asian_NotHispanic = Race_Not_Hispanic_Or_Latino_Asian_Alone,
              Race_Asian_Hispanic = Race_Hispanic_Or_Latino_Asian_Alone,
              Race_Pacific_NotHispanic = Race_Not_Hispanic_Or_Latino_Native_Hawaiian_And_Other_Pacific_Islander_Alone,
              Race_Pacific_Hispanic = Race_Hispanic_Or_Latino_Native_Hawaiian_And_Other_Pacific_Islander_Alone,
              Race_Other_NotHispanic = Race_Not_Hispanic_Or_Latino_Some_Other_Race_Alone,
              Race_Other_Hispanic = Race_Hispanic_Or_Latino_Some_Other_Race_Alone,
              Race_MoreThanOne_NotHispanic = Race_Not_Hispanic_Or_Latino_Two_Or_More_Races,
              Race_MoreThanOne_Hispanic = Race_Hispanic_Or_Latino_Two_Or_More_Races,
              Occupancy_DoubledUp = sum(Occupancy_Owner_Occupied_1.01_To_1.50_Occupants_Per_Room,
                                        Occupancy_Owner_Occupied_1.51_To_2.00_Occupants_Per_Room,
                                        Occupancy_Owner_Occupied_2.01_Or_More_Occupants_Per_Room,
                                        Occupancy_Renter_Occupied_1.01_To_1.50_Occupants_Per_Room,
                                        Occupancy_Renter_Occupied_1.51_To_2.00_Occupants_Per_Room,
                                        Occupancy_Renter_Occupied_2.01_Or_More_Occupants_Per_Room,
                                        na.rm = TRUE),
              HouseholdType_Family = HouseholdType_Family_Households,
              HouseholdType_Family_Married = HouseholdType_Family_Households_Married_Couple_Family,
              HouseholdType_Family_Other = HouseholdType_Family_Households_Other_Family,
              HouseholdType_NonFamily = HouseholdType_Nonfamily_Households,
              HouseholdType_NonFamily_LivingAlone = HouseholdType_Nonfamily_Households_Householder_Living_Alone,
              HouseholdType_NonFamily_NotLivingAlone = HouseholdType_Nonfamily_Households_Householder_Not_Living_Alone,
              MaritalStatus_NeverMarried = sum(MaritalStatus_Male_Never_Married, MaritalStatus_Female_Never_Married, na.rm = TRUE),
              MaritalStatus_NowMarried = sum(MaritalStatus_Male_Now_Married, MaritalStatus_Female_Now_Married, na.rm = TRUE),
              MaritalStatus_Widowed = sum(MaritalStatus_Male_Widowed, MaritalStatus_Female_Widowed, na.rm = TRUE),
              MaritalStatus_Divorced = sum(MaritalStatus_Male_Divorced, MaritalStatus_Female_Divorced, na.rm = TRUE),
              Education_NoHighSchoolDiploma = sum(Education_No_Schooling_Completed,Education_Nursery_School,Education_Kindergarten,
                                                  Education_1st_Grade, Education_2nd_Grade, Education_3rd_Grade, Education_4th_Grade,
                                                  Education_5th_Grade, Education_6th_Grade, Education_7th_Grade, Education_8th_Grade,
                                                  Education_9th_Grade, Education_10th_Grade, Education_11th_Grade,
                                                  Education_12th_Grade_No_Diploma, na.rm = TRUE),
              Education_HighSchoolDiplomaOrGED = sum(Education_Regular_High_School_Diploma, Education_Ged_Or_Alternative_Credential, na.rm = TRUE),
              Education_SomeCollege = sum(Education_Some_College_Less_Than_1_Year,Education_Some_College_1_Or_More_Years_No_Degree, na.rm = TRUE),
              Education_Associates = Education_Associates_Degree,
              Education_Bachelors = Education_Bachelors_Degree,
              Education_AdvancedDegree = sum(Education_Masters_Degree, Education_Professional_School_Degree, Education_Doctorate_Degree, na.rm = TRUE),
              Employment_Employed = HealthInsurance_In_Labor_Force_Employed,
              Employment_Unemployed = HealthInsurance_In_Labor_Force_Unemployed,
              Employment_NotInLaborForce = HealthInsurance_Not_In_Labor_Force,
              HealthInsurance_Covered = sum(HealthInsurance_In_Labor_Force_Employed_With_Health_Insurance_Coverage,
                                            HealthInsurance_In_Labor_Force_Unemployed_With_Health_Insurance_Coverage,
                                            HealthInsurance_Not_In_Labor_Force_With_Health_Insurance_Coverage,
                                            na.rm = TRUE),
              HealthInsurance_Covered_Private = sum(HealthInsurance_In_Labor_Force_Employed_With_Health_Insurance_Coverage_With_Private_Health_Insurance,
                                                    HealthInsurance_In_Labor_Force_Unemployed_With_Health_Insurance_Coverage_With_Private_Health_Insurance,
                                                    HealthInsurance_Not_In_Labor_Force_With_Health_Insurance_Coverage_With_Private_Health_Insurance,
                                                    na.rm = TRUE),
              HealthInsurance_Covered_Public = sum(HealthInsurance_In_Labor_Force_Employed_With_Health_Insurance_Coverage_With_Public_Coverage,
                                                   HealthInsurance_In_Labor_Force_Unemployed_With_Health_Insurance_Coverage_With_Public_Coverage,
                                                   HealthInsurance_Not_In_Labor_Force_With_Health_Insurance_Coverage_With_Public_Coverage,
                                                   na.rm = TRUE),
              HealthInsurance_NotCovered = sum(HealthInsurance_In_Labor_Force_Employed_No_Health_Insurance_Coverage,
                                               HealthInsurance_In_Labor_Force_Unemployed_No_Health_Insurance_Coverage,
                                               HealthInsurance_Not_In_Labor_Force_No_Health_Insurance_Coverage,
                                               na.rm = TRUE),
              Language_OnlyEnglish_Total = Language_Speak_Only_English,
              Language_LimitedEnglish_Total = sum(across(contains("Speak_English_Less_Than_Very_Well"), ~sum(., na.rm = TRUE))),
              Language_Spanish_Total = Language_Spanish_Or_Spanish_Creole,
              Language_French_Total = Language_French_Incl._Patois_Cajun,
              Language_FrenchCreole_Total = Language_French_Creole,
              Language_Italian_Total = Language_Italian,
              Language_Portuguese_Total = Language_Portuguese_Or_Portuguese_Creole,
              Language_German_Total = Language_German,
              Language_Yiddish_Total = Language_Yiddish,
              Language_OtherWestGermanic_Total = Language_Other_West_Germanic_Languages,
              Language_Scandinavian_Total = Language_Scandinavian_Languages,
              Language_Greek_Total = Language_Greek,
              Language_Russian_Total = Language_Russian,
              Language_Polish_Total = Language_Polish,
              Language_SerboCroatian_Total = Language_Serbo_Croatian,
              Language_OtherSlavic_Total = Language_Other_Slavic_Languages,
              Language_Armenian_Total = Language_Armenian,
              Language_Persian_Total = Language_Persian,
              Language_Gujarati_Total = Language_Gujarati,
              Language_Hindi_Total = Language_Hindi,
              Language_Urdu_Total = Language_Urdu,
              Language_OtherIndic_Total = Language_Other_Indic_Languages,
              Language_OtherIndoEuropean_Total = Language_Other_Indo_European_Languages,
              Language_Chinese_Total = Language_Chinese,
              Language_Japanese_Total = Language_Japanese,
              Language_Korean_Total = Language_Korean,
              Language_Cambodian_Total = Language_Mon_Khmer_Cambodian,
              Language_Hmong_Total = Language_Hmong,
              Language_Thai_Total = Language_Thai,
              Language_Laotian_Total = Language_Laotian,
              Language_Vietnamese_Total = Language_Vietnamese,
              Language_OtherAsian_Total = Language_Other_Asian_Languages,
              Language_Tagalog_Total = Language_Tagalog,
              Language_OtherPacificIsland_Total = Language_Other_Pacific_Island_Languages,
              Language_Navajo_Total = Language_Navajo,
              Language_OtherNativeNorthAmerican_Total = Language_Other_Native_North_American_Languages,
              Language_Hungarian_Total = Language_Hungarian,
              Language_Arabic_Total = Language_Arabic,
              Language_Hebrew_Total = Language_Hebrew,
              Language_AfricanLanguages_Total = Language_African_Languages,
              Language_OtherAndUnspecifiedLanguages_Total = Language_Other_And_Unspecified_Languages,
              Language_Spanish_LimitedEnglish = Language_Spanish_Or_Spanish_Creole_Speak_English_Less_Than_Very_Well,
              Language_French_LimitedEnglish = Language_French_Incl._Patois_Cajun_Speak_English_Less_Than_Very_Well,
              Language_FrenchCreole_LimitedEnglish = Language_French_Creole_Speak_English_Less_Than_Very_Well,
              Language_Italian_LimitedEnglish = Language_Italian_Speak_English_Less_Than_Very_Well,
              Language_Portuguese_LimitedEnglish = Language_Portuguese_Or_Portuguese_Creole_Speak_English_Less_Than_Very_Well,
              Language_German_LimitedEnglish = Language_German_Speak_English_Less_Than_Very_Well,
              Language_Yiddish_LimitedEnglish = Language_Yiddish_Speak_English_Less_Than_Very_Well,
              Language_OtherWestGermanic_LimitedEnglish = Language_Other_West_Germanic_Languages_Speak_English_Less_Than_Very_Well,
              Language_Scandinavian_LimitedEnglish = Language_Scandinavian_Languages_Speak_English_Less_Than_Very_Well,
              Language_Greek_LimitedEnglish = Language_Greek_Speak_English_Less_Than_Very_Well,
              Language_Russian_LimitedEnglish = Language_Russian_Speak_English_Less_Than_Very_Well,
              Language_Polish_LimitedEnglish = Language_Polish_Speak_English_Less_Than_Very_Well,
              Language_SerboCroatian_LimitedEnglish = Language_Serbo_Croatian_Speak_English_Less_Than_Very_Well,
              Language_OtherSlavic_LimitedEnglish = Language_Other_Slavic_Languages_Speak_English_Less_Than_Very_Well,
              Language_Armenian_LimitedEnglish = Language_Armenian_Speak_English_Less_Than_Very_Well,
              Language_Persian_LimitedEnglish = Language_Persian_Speak_English_Less_Than_Very_Well,
              Language_Gujarati_LimitedEnglish = Language_Gujarati_Speak_English_Less_Than_Very_Well,
              Language_Hindi_LimitedEnglish = Language_Hindi_Speak_English_Less_Than_Very_Well,
              Language_Urdu_LimitedEnglish = Language_Urdu_Speak_English_Less_Than_Very_Well,
              Language_OtherIndic_LimitedEnglish = Language_Other_Indic_Languages_Speak_English_Less_Than_Very_Well,
              Language_OtherIndoEuropean_LimitedEnglish = Language_Other_Indo_European_Languages_Speak_English_Less_Than_Very_Well,
              Language_Chinese_LimitedEnglish = Language_Chinese_Speak_English_Less_Than_Very_Well,
              Language_Japanese_LimitedEnglish = Language_Japanese_Speak_English_Less_Than_Very_Well,
              Language_Korean_LimitedEnglish = Language_Korean_Speak_English_Less_Than_Very_Well,
              Language_Cambodian_LimitedEnglish = Language_Mon_Khmer_Cambodian_Speak_English_Less_Than_Very_Well,
              Language_Hmong_LimitedEnglish = Language_Hmong_Speak_English_Less_Than_Very_Well,
              Language_Thai_LimitedEnglish = Language_Thai_Speak_English_Less_Than_Very_Well,
              Language_Laotian_LimitedEnglish = Language_Laotian_Speak_English_Less_Than_Very_Well,
              Language_Vietnamese_LimitedEnglish = Language_Vietnamese_Speak_English_Less_Than_Very_Well,
              Language_OtherAsian_LimitedEnglish = Language_Other_Asian_Languages_Speak_English_Less_Than_Very_Well,
              Language_Tagalog_LimitedEnglish = Language_Tagalog_Speak_English_Less_Than_Very_Well,
              Language_OtherPacificIsland_LimitedEnglish = Language_Other_Pacific_Island_Languages_Speak_English_Less_Than_Very_Well,
              Language_Navajo_LimitedEnglish = Language_Navajo_Speak_English_Less_Than_Very_Well,
              Language_OtherNativeNorthAmerican_LimitedEnglish = Language_Other_Native_North_American_Languages_Speak_English_Less_Than_Very_Well,
              Language_Hungarian_LimitedEnglish = Language_Hungarian_Speak_English_Less_Than_Very_Well,
              Language_Arabic_LimitedEnglish = Language_Arabic_Speak_English_Less_Than_Very_Well,
              Language_Hebrew_LimitedEnglish = Language_Hebrew_Speak_English_Less_Than_Very_Well,
              Language_AfricanLanguages_LimitedEnglish = Language_African_Languages_Speak_English_Less_Than_Very_Well,
              Language_OtherAndUnspecifiedLanguages_LimitedEnglish = Language_Other_And_Unspecified_Languages_Speak_English_Less_Than_Very_Well,
              Industry_AgricultureForestryFishingAndHuntingAndMining = sum(Industry_Male_Agriculture_Forestry_Fishing_And_Hunting_And_Mining,
                                                                           Industry_Female_Agriculture_Forestry_Fishing_And_Hunting_And_Mining, na.rm = TRUE),
              Industry_Construction = sum(Industry_Male_Construction, Industry_Female_Construction, na.rm = TRUE),
              Industry_Manufacturing = sum(Industry_Male_Manufacturing, Industry_Female_Manufacturing, na.rm = TRUE),
              Industry_WholesaleTrade = sum(Industry_Male_Wholesale_Trade, Industry_Female_Wholesale_Trade, na.rm = TRUE),
              Industry_RetailTrade = sum(Industry_Male_Retail_Trade, Industry_Female_Retail_Trade, na.rm = TRUE),
              Industry_TransportationAndWarehousingAndUtilities = sum(Industry_Male_Transportation_And_Warehousing_And_Utilities,
                                                                      Industry_Female_Transportation_And_Warehousing_And_Utilities, na.rm = TRUE),
              Industry_Information = sum(Industry_Male_Information, Industry_Female_Information, na.rm = TRUE),
              Industry_FinanceAndInsuranceAndRealEstateAndRentalAndLeasing = sum(Industry_Male_Finance_And_Insurance_And_Real_Estate_And_Rental_And_Leasing,
                                                                                 Industry_Female_Finance_And_Insurance_And_Real_Estate_And_Rental_And_Leasing, na.rm = TRUE),
              Industry_ProfessionalScientificAndManagementAndAdministrativeAndWasteManagementServices = sum(Industry_Male_Professional_Scientific_And_Management_And_Administrative_And_Waste_Management_Services,
                                                                                                            Industry_Female_Professional_Scientific_And_Management_And_Administrative_And_Waste_Management_Services, na.rm = TRUE),
              Industry_EducationalServicesAndHealthCareAndSocialAssistance = sum(Industry_Male_Educational_Services_And_Health_Care_And_Social_Assistance,
                                                                                 Industry_Female_Educational_Services_And_Health_Care_And_Social_Assistance, na.rm = TRUE),
              Industry_ArtsEntertainmentAndRecreationAndAccommodationAndFoodServices = sum(Industry_Male_Arts_Entertainment_And_Recreation_And_Accommodation_And_Food_Services,
                                                                                           Industry_Female_Arts_Entertainment_And_Recreation_And_Accommodation_And_Food_Services, na.rm = TRUE),
              Industry_OtherServicesExceptPublicAdministration = sum(Industry_Male_Other_Services_Except_Public_Administration, Industry_Female_Other_Services_Except_Public_Administration, na.rm = TRUE),
              Industry_PublicAdministration = sum(Industry_Male_Public_Administration, Industry_Female_Public_Administration, na.rm = TRUE),
              Occupation_ManagementBusinessAndFinancial = sum(Occupation_Male_Management_Business_Science_And_Arts_Occupations_Management_Business_And_Financial_Occupations,
                                                              Occupation_Female_Management_Business_Science_And_Arts_Occupations_Management_Business_And_Financial_Occupations, na.rm = TRUE),
              Occupation_ComputerEngineeringAndScience = sum(Occupation_Male_Management_Business_Science_And_Arts_Occupations_Computer_Engineering_And_Science_Occupations,
                                                             Occupation_Female_Management_Business_Science_And_Arts_Occupations_Computer_Engineering_And_Science_Occupations, na.rm = TRUE),
              Occupation_EducationLegalCommunityServiceArtsAndMedia = sum(Occupation_Male_Management_Business_Science_And_Arts_Occupations_Education_Legal_Community_Service_Arts_And_Media_Occupations,
                                                                          Occupation_Female_Management_Business_Science_And_Arts_Occupations_Education_Legal_Community_Service_Arts_And_Media_Occupations, na.rm = TRUE),
              Occupation_HealthcarePractitionersAndTechnical = sum(Occupation_Male_Management_Business_Science_And_Arts_Occupations_Healthcare_Practitioners_And_Technical_Occupations,
                                                                   Occupation_Female_Management_Business_Science_And_Arts_Occupations_Healthcare_Practitioners_And_Technical_Occupations, na.rm = TRUE),
              Occupation_HealthcareSupport = sum(Occupation_Male_Service_Occupations_Healthcare_Support_Occupations,
                                                 Occupation_Female_Service_Occupations_Healthcare_Support_Occupations, na.rm = TRUE),
              Occupation_ProtectiveService = sum(Occupation_Male_Service_Occupations_Protective_Service_Occupations,
                                                 Occupation_Female_Service_Occupations_Protective_Service_Occupations, na.rm = TRUE),
              Occupation_FoodPreparationAndServingRelated = sum(Occupation_Male_Service_Occupations_Food_Preparation_And_Serving_Related_Occupations,
                                                                Occupation_Female_Service_Occupations_Food_Preparation_And_Serving_Related_Occupations, na.rm = TRUE),
              Occupation_BuildingAndGroundsCleaningAndMaintenance = sum(Occupation_Male_Service_Occupations_Building_And_Grounds_Cleaning_And_Maintenance_Occupations,
                                                                        Occupation_Female_Service_Occupations_Building_And_Grounds_Cleaning_And_Maintenance_Occupations, na.rm = TRUE),
              Occupation_PersonalCareAndService = sum(Occupation_Male_Service_Occupations_Personal_Care_And_Service_Occupations,
                                                      Occupation_Female_Service_Occupations_Personal_Care_And_Service_Occupations, na.rm = TRUE),
              Occupation_SalesAndOffice = sum(Occupation_Male_Sales_And_Office_Occupations, Occupation_Female_Sales_And_Office_Occupations, na.rm = TRUE),
              Occupation_NaturalResourcesConstructionAndMaintenance = sum(Occupation_Male_Natural_Resources_Construction_And_Maintenance_Occupations,
                                                                          Occupation_Female_Natural_Resources_Construction_And_Maintenance_Occupations, na.rm = TRUE),
              Occupation_ProductionTransportationAndMaterialMoving = sum(Occupation_Male_Production_Transportation_And_Material_Moving_Occupations,
                                                                         Occupation_Female_Production_Transportation_And_Material_Moving_Occupations, na.rm = TRUE)) %>%
    ungroup() %>%
    rename(GEO_ID = !!as.name(geography))
}

# calculate totals for desired geographies
demos_modzcta <- acs_demos("modzcta")
demos_congressional <- acs_demos("congressional")
demos_school <- acs_demos("school")
demos_council <- acs_demos("council")
demos_assembly <- acs_demos("assembly")
demos_stateSenate <- acs_demos("stateSenate")
demos_commBoard <- acs_demos("commBoard")
demos_nCode <- acs_demos("nCode")
demos_borough <- acs_demos("borough")
demos_tract_2010 <- acs_demos("tract_2010")

# add neighborhood name and boro to nCode dataframe
demos_nCode <- crosswalk %>%
  select(borough, neighborhood, nCode) %>%
  right_join(demos_nCode, by = c("nCode" = "GEO_ID")) %>%
  unique() %>%
  rename(GEO_ID = nCode)

# write csvs
write_csv(demos_modzcta, "data-raw/demos_modzcta.csv")
write_csv(demos_congressional, "data-raw/demos_congressional.csv")
write_csv(demos_school, "data-raw/demos_school.csv")
write_csv(demos_council, "data-raw/demos_council.csv")
write_csv(demos_assembly, "data-raw/demos_assembly.csv")
write_csv(demos_stateSenate, "data-raw/demos_stateSenate.csv")
write_csv(demos_commBoard, "data-raw/demos_commBoard.csv")
write_csv(demos_borough, "data-raw/demos_borough.csv")
write_csv(demos_tract_2010, "data-raw/demos_tract_2010.csv")
write_csv(demos_nCode, "data-raw/demos_nCode.csv")

usethis::use_data(demos_assembly, demos_borough, demos_commBoard, demos_congressional, demos_council, demos_modzcta,
                  demos_nCode, demos_school, demos_stateSenate, demos_tract_2010, overwrite = TRUE)

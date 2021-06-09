# Setup -------------------------------------------------------------------

# Standard way of loading libraries
library('readxl')
library('dplyr')
library(ggplot2) # Using quotes is optional. This is called 'non standard evaluation' if you're interested.

# My preferred way of loading libraries
# Why? If you don't have a library installed librarian will install it for you.
# Also, it lets you load multiple packages at once.
# Note:: we didn't load the librarian package. Instead we used the :: operator to  use the function shelf from librarian.
librarian::shelf('readxl', 'dplyr', 'ggplot2', 'janitor', 'tidyr')


# Load xlsx file
# Note: Since we are in an R project, all file paths are relative
goliaths <- read_xlsx(path = "data/data.xlsx", sheet = 'figure 3')


# Cleaning data ----------------------------------------------------------------

# The variable names from the raw data are in sentence case.
# I prefer using snakcase. So Variable one becomes variable_one.
# Camel case would be variableOne.

# There are various ways in which you can rename variables.
# The easiest way for individual variables is dplyr::rename()
# However, if you just want to put things in snakcase for all your variables you can use janitor::clean_names

(goliaths <-
   goliaths %>%
   janitor::clean_names())



# Data wrangling (data manipulation) --------------------------------------

# Now, we want to know the share for each variable.
# We could do this by typing out the computation for each variable
goliaths %>%
  mutate(europe_share = europe / total,
         latin_am_share = latin_am / total,
         asia_share = asia / total,
         canada_share = canada / total
  )

# But what if we had 65 variables? Surely you'd make a mistake somewhere or fall asleep. One of the most helpful things computers can do well is iteration. In our case, we can use the dplyr::across() function inside of dplyr::mutate() to iterate  calculating the share/ratio over all the relevant variables (everything except date and total) and create new variables ending with "_ratio"
#
# Note: I'm using the %<>% assignment pipe from magrittr to avoid this pattern:
# df  <- df %>% some_calculation.
library('magrittr')
goliaths  %<>%
  select(-other) %>%
  mutate(across(.cols = -c(date, total),
                .fns = ~ .x / total,
                .names = "{.col}_ratio"))


goliaths %>%
  # Select variables we wish to plot
  select(date, ends_with('ratio')) %>%
  # Pivot so that the variable name is in a column and the variable value  in another
  tidyr::pivot_longer(-date) %>%
  # First layer maps data to aesthetics. In our case we want the x axis to represent the date, the y axis to represent the values, and the color to distinguish variables by their name.
  ggplot(mapping = aes(x = date, y = value, color = name)) +
  # Now we can tell R to visualize these with a line.
  geom_line()

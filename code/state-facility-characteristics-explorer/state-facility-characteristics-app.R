# -------------------------------
# Load libraries
# -------------------------------
library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(tigris)
library(tidycensus)

options(tigris_use_cache = TRUE)

# -------------------------------
# Load facility data
# -------------------------------
facility_data <- read.csv("NSUMHSS_2023_PUF_CSV.csv")

# -------------------------------
# State crosswalk
# -------------------------------
stfips_crosswalk <- tibble::tribble(
  ~State, ~Abbreviation,
  "Alabama","AL","Alaska","AK","Arizona","AZ","Arkansas","AR","California","CA",
  "Colorado","CO","Connecticut","CT","Delaware","DE","District of Columbia","DC",
  "Florida","FL","Georgia","GA","Hawaii","HI","Idaho","ID","Illinois","IL",
  "Indiana","IN","Iowa","IA","Kansas","KS","Kentucky","KY","Louisiana","LA",
  "Maine","ME","Maryland","MD","Massachusetts","MA","Michigan","MI","Minnesota","MN",
  "Mississippi","MS","Missouri","MO","Montana","MT","Nebraska","NE","Nevada","NV",
  "New Hampshire","NH","New Jersey","NJ","New Mexico","NM","New York","NY",
  "North Carolina","NC","North Dakota","ND","Ohio","OH","Oklahoma","OK","Oregon","OR",
  "Pennsylvania","PA","Rhode Island","RI","South Carolina","SC","South Dakota","SD",
  "Tennessee","TN","Texas","TX","Utah","UT","Vermont","VT","Virginia","VA",
  "Washington","WA","West Virginia","WV","Wisconsin","WI","Wyoming","WY"
)

# -------------------------------
# ACS population (2023)
# -------------------------------
state_pop <- get_acs(
  geography = "state",
  variables = "B01003_001",
  year = 2023,
  survey = "acs1"
) %>%
  select(State = NAME, population = estimate)

# -------------------------------
# Variable map
# -------------------------------
vars_map <- list(
  "Counseling / Education Services" = "SRVC99",
  "Federal / State Funding" = "EARMARK",
  "Hospital-affiliated" = "HOSPITAL",
  "Solo Practice" = "LOC15_SU",
  "Transitional Housing" = "LOC5",
  "Skilled Nursing Facility" = "SNF",
  "Treatment in Spanish" = "LANG16_SU",
  "Only OUD Clients" = "ONLYOUD",
  "OTP Certified" = "OTP",
  "Housing Assistance" = "SRVC39",
  "Social Services Assistance" = "SRVC36",
  "Self-Help Groups" = "SRVC102",
  "Aftercare / Continuing Care" = "SRVC27",
  "Outcome Follow-up" = "SRVCOUTCM",
  "Inpatient Services" = "CTYPE4",
  "Outpatient Services" = "CTYPE1",
  "Detoxification" = "DETOX",
  "Substance Use Treatment" = "TREATMT_SU",
  "Mental Health Treatment" = "MHTXSA"
)

# -------------------------------
# Base map geometry (ONCE)
# -------------------------------
states_sf <- states(cb = TRUE) %>%
  st_transform(crs = 5070) %>% 
  shift_geometry() %>% 
  filter(STATEFP <= 56)

# -------------------------------
# UI
# -------------------------------
ui <- fluidPage(
  titlePanel("N-SUMHSS Facility Characteristics by State"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "variable",
        "Select Facility Characteristic:",
        choices = names(vars_map)
      ),
      checkboxInput(
        "per_capita",
        "Standardize per 100,000 residents",
        value = TRUE
      ),
      hr(),
      p("Each facility is counted once per state."),
      p("Population source: ACS 2023 (1-year).")
    ),
    
    mainPanel(
      plotlyOutput("facility_map", height = "800px", width = "100%")
    )
  )
)

# -------------------------------
# Server
# -------------------------------
server <- function(input, output, session) {
  
  map_data <- reactive({
    var_selected <- vars_map[[input$variable]]
    
    facility_data %>%
      filter(.data[[var_selected]] == 1) %>%
      count(LOCATIONSTATE, name = "n") %>%
      left_join(stfips_crosswalk,
                by = c("LOCATIONSTATE" = "Abbreviation")) %>%
      left_join(state_pop, by = "State") %>%
      mutate(
        population = as.numeric(population),
        value = if (input$per_capita) (n / population) * 100000 else n
      )
  })
  
  output$facility_map <- renderPlotly({
    df <- map_data()
    
    map_sf <- states_sf %>%
      left_join(df, by = c("NAME" = "State")) %>%
      mutate(
        n = replace_na(n, 0),
        value = replace_na(value, 0)
      )
    
    p <- ggplot(map_sf) +
      geom_sf(
        aes(
          fill = value,
          text = paste0(
            NAME,
            "<br>Facilities: ", n,
            if (input$per_capita)
              paste0("<br>Per 100k residents: ", round(value, 2))
          )
        ),
        color = "white",
        linewidth = 0.2
      ) +
      scale_fill_gradient(
        low = "#b0d5cd",
        high = "#183c40",
        name = ifelse(input$per_capita,
                      "Facilities per 100k",
                      "Number of Facilities")
      ) +
      coord_sf(expand = FALSE) +        # 🔹 key line
      theme_void() +
      theme(
        plot.margin = margin(5, 5, 5, 5),  # 🔹 minimal margins
        legend.title = element_text(size = 10),
        legend.text  = element_text(size = 9),
        legend.key.height = unit(0.4, "cm"),
        legend.key.width  = unit(0.3, "cm")
      ) + 
      labs(
        title = input$variable,
        subtitle = ifelse(
          input$per_capita,
          "Standardized by state population",
          "Raw facility counts"
        )) + 
      theme_void() +
      theme(
        plot.title = element_text(
          size = 18,        # 🔹 increase size
          face = "bold",
        )
      )
    
    ggplotly(p, tooltip = "text")
  })
}

# -------------------------------
# Run app
# -------------------------------
shinyApp(ui, server)

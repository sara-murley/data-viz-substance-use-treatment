# -------------------------------
# Load libraries
# -------------------------------
library(shiny)
library(tidyverse)
library(scales)
library(RColorBrewer)
library(plotly)

# -------------------------------
# Load pre-aggregated data
# -------------------------------
drug_counts <- readRDS("tedsa_drug_counts.rds")
demo_counts <- readRDS("tedsa_demo_counts.rds")

# -------------------------------
# Map labels
# -------------------------------
age_labels <- c(
  "12–14","15–17","18–20","21–24","25–29",
  "30–34","35–39","40–44","45–49","50–54",
  "55–64","65+"
)

demo_counts <- demo_counts %>%
  filter(!is.na(AGE), !is.na(SEX), !is.na(RACE), !is.na(EMPLOY)) %>%
  mutate(
    AGE_label = factor(AGE, levels = 1:12, labels = age_labels),
    RACE_group = case_when(
      RACE %in% c(1,2) ~ "Native American",
      RACE %in% c(3,6) ~ "Asian",
      RACE == 4 ~ "Black",
      RACE == 5 ~ "White",
      TRUE ~ "Other"
    ),
    EMPLOY_group = case_when(
      EMPLOY == 1 ~ "Full-time",
      EMPLOY == 2 ~ "Part-time",
      EMPLOY == 3 ~ "Unemployed",
      EMPLOY == 4 ~ "Not in labor force",
      TRUE ~ NA_character_
    )
  )

# -------------------------------
# Color palette (consistent)
# -------------------------------
ppt_colors <- c(
  "#183c40",  # deep teal
  "#20494d",  # dark teal
  "#426345",  # muted green
  "#799da7",  # blue-gray
  "#b0d5cd",  # soft mint
  "#a6daea",  # light blue
  "#9aa864",  # olive
  "#b78d43"   # muted gold
)
palette_main <- ppt_colors

# ============================================================
# UI
# ============================================================
ui <- fluidPage(
  
  titlePanel("Substance Use Treatment Admissions Explorer"),
  
  tabsetPanel(
    
    # TAB 1: Drug Counts
    tabPanel(
      "Drug Counts by State & Year",
      sidebarLayout(
        sidebarPanel(
          selectInput(
            "state_drug",
            "Select a State:",
            choices = sort(unique(drug_counts$State))
          ),
          sliderInput(
            "year_drug",
            "Select Year:",
            min = min(drug_counts$ADMYR),
            max = max(drug_counts$ADMYR),
            value = max(drug_counts$ADMYR),
            step = 1,
            sep = ""
          )
        ),
        mainPanel(
          h3(textOutput("drug_title"), style = "font-weight: bold;"),
          plotlyOutput("drug_plot", height = "600px")
        )
      )
    ),
    
    # TAB 2: Demographics
    tabPanel(
      "Demographics Explorer",
      sidebarLayout(
        sidebarPanel(
          selectInput(
            "dem_state",
            "Select a State:",
            choices = sort(unique(demo_counts$State))
          ),
          sliderInput(
            "dem_year",
            "Select Year:",
            min = min(demo_counts$ADMYR),
            max = max(demo_counts$ADMYR),
            value = max(demo_counts$ADMYR),
            step = 1,
            sep = ""
          ),
          selectInput(
            "dem_drug",
            "Select Primary Drug:",
            choices = sort(unique(demo_counts$SUB1_group))
          )
        ),
        mainPanel(
          h3(textOutput("demo_title"), style = "font-weight: bold;"),
          h5("All figures show total counts of treatment admissions",
             style = "color: #555555; margin-bottom: 20px;"),
          plotlyOutput("age_plot", height = "300px"),
          plotlyOutput("sex_plot", height = "300px"),
          plotlyOutput("race_plot", height = "300px"),
          plotlyOutput("emp_plot", height = "300px")
        )
      )
    ),
    
    # TAB 3: Data Source & Notes
    tabPanel(
      "Data Source & Notes",
      fluidRow(
        column(
          12,
          h4("Data Source"),
          p("The data used in this application are derived from the Treatment Episode Data Set (TEDS), maintained by SAMHSA."),
          h4("Notes"),
          tags$ul(
            tags$li("All figures represent counts of treatment admissions."),
            tags$li("Demographic distributions are based on available reported data; missing or invalid values are excluded."),
            tags$li("Drug counts include only primary substances reported at admission."),
            tags$li("This application is intended for research and policy exploration purposes.")
          )
        )
      )
    )
  )
)

# ============================================================
# SERVER
# ============================================================
server <- function(input, output, session) {
  
  # Reactive filtered demographics
  filtered_demo <- reactive({
    demo_counts %>%
      filter(
        State == input$dem_state,
        ADMYR == input$dem_year,
        SUB1_group == input$dem_drug
      )
  })
  
  # Dynamic titles
  output$drug_title <- renderText({
    paste("Primary Substance Distribution —", input$state_drug, "(", input$year_drug, ")")
  })
  
  output$demo_title <- renderText({
    paste("Demographic Profile of Admissions —", input$dem_state, "(", input$dem_year, ") |", input$dem_drug)
  })
  
  # Drug Counts Plot
  output$drug_plot <- renderPlotly({
    df <- drug_counts %>%
      filter(State == input$state_drug, ADMYR == input$year_drug, !is.na(SUB1_group))
    
    p <- ggplot(df, aes(
      x = reorder(SUB1_group, n),
      y = n,
      fill = SUB1_group,
      text = paste("Drug:", SUB1_group, "<br>Admissions:", comma(n))
    )) +
      geom_col() +
      coord_flip() +
      scale_y_continuous(labels = comma) +
      scale_fill_manual(values = palette_main) +
      labs(x = NULL, y = NULL) +
      theme_minimal(base_size = 16) +
      theme(legend.position = "none", axis.text = element_text(size = 14))
    
    ggplotly(p, tooltip = "text")
  })
  
  # Demographic plots with counts in tooltip
  output$age_plot <- renderPlotly({
    df <- filtered_demo() %>%
      count(AGE_label)
    
    p <- ggplot(df, aes(
      x = AGE_label,
      y = n,
      text = paste("Age Group:", AGE_label, "<br>Count:", n)
    )) +
      geom_bar(stat = "identity", fill = palette_main[1]) +
      labs(title = "Age Distribution", x = NULL, y = NULL) +
      theme_minimal(base_size = 16)
    
    ggplotly(p, tooltip = "text")
  })
  
  output$sex_plot <- renderPlotly({
    df <- filtered_demo() %>%
      count(SEX)
    
    p <- ggplot(df, aes(
      x = factor(SEX),
      y = n,
      text = paste("Sex:", ifelse(SEX == 1, "Male", "Female"), "<br>Count:", n)
    )) +
      geom_bar(stat = "identity", fill = palette_main[2]) +
      scale_x_discrete(labels = c("1" = "Male", "2" = "Female")) +
      labs(title = "Sex Distribution", x = NULL, y = NULL) +
      theme_minimal(base_size = 16)
    
    ggplotly(p, tooltip = "text")
  })
  
  output$race_plot <- renderPlotly({
    df <- filtered_demo() %>%
      count(RACE_group)
    
    p <- ggplot(df, aes(
      x = RACE_group,
      y = n,
      text = paste("Race:", RACE_group, "<br>Count:", n)
    )) +
      geom_bar(stat = "identity", fill = palette_main[3]) +
      labs(title = "Race Distribution", x = NULL, y = NULL) +
      theme_minimal(base_size = 16)
    
    ggplotly(p, tooltip = "text")
  })
  
  output$emp_plot <- renderPlotly({
    df <- filtered_demo() %>%
      count(EMPLOY_group)
    
    p <- ggplot(df, aes(
      x = EMPLOY_group,
      y = n,
      text = paste("Employment:", EMPLOY_group, "<br>Count:", n)
    )) +
      geom_bar(stat = "identity", fill = palette_main[4]) +
      labs(title = "Employment Status", x = NULL, y = NULL) +
      theme_minimal(base_size = 16)
    
    ggplotly(p, tooltip = "text")
  })
}

# ============================================================
# RUN APP
# ============================================================
shinyApp(ui, server)

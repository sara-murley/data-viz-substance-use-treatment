# Substance Use Treatment Access — Data Visualization Project

**Author:** Sara Murley  
**Program:** M.S. in Data Science for Public Policy, Georgetown University  

This repository contains a data visualization project developed as part of a graduate-level data visualization course in Georgetown University’s *Data Science for Public Policy* program. The primary purpose of this project is to document and showcase my applied skills in data wrangling, visualization design, and interactive dashboard development for public policy contexts.

The project focuses on visualizing substance use treatment access across U.S. states using publicly available data from SAMHSA.

---

## Project Overview

This repository includes:

- Static visualizations created in R (saved as `.png` and `.gif`)
- Two interactive Shiny dashboards
- Supporting R Markdown code
- A PowerPoint presentation and project proposal summarizing methods and findings

Per course requirements, each visualization was implemented as a **separate R Markdown file**, which results in some repetition across scripts (e.g., loading data, state crosswalks, themes). This structure reflects the assignment format rather than an optimized production workflow.

The visualizations and dashboards are intended as portfolio artifacts demonstrating:

- Data cleaning and aggregation
- Log-scale modeling and residual analysis
- Geographic and scatter-based visualizations
- Thoughtful annotation and labeling
- Interactive dashboard development with Shiny
- Policy-oriented interpretation of results

---

## Repository Structure

```
├── code/
│ ├── admission-rates-by-state.Rmd
│ ├── criminal-justice-patterns.Rmd
│ ├── relapse-patterns.Rmd
│ ├── treatment-over-time.Rmd
│ ├── treatment-supply-demand.Rmd
│ │
│ ├── state-admissions-explorer/
│ │ ├── prep-state-data.R
│ │ └── state-admissions-app.R
│ │
│ └── state-facility-characteristics-explorer/
│ │ ├── state-facility-characteristics-app.R
│
├── data/
│ └── (raw CSV files not tracked in GitHub)
│
├── figures/
│ ├── admission-rates-by-state.png
│ ├── criminal-justice-patterns.png
│ ├── relapse-patterns.png
│ ├── treatment-over-time.gif
│ ├── treatment-supply-demand.png
│
├── presentation.pdf
├── project-proposal.pdf
└── README.md
```

---

## Code

### Static Visualizations

The `code/` folder contains **five R Markdown files**, each producing a standalone visualization. Output figures are saved to the `figures/` directory as `.png` or `.gif`.
These files are designed to be knit to `.html` files that include descriptions of each figure. 

These visualizations explore:

- State-level treatment admission rates
- Relationships between facility supply and treatment demand
- Deviations from expected admissions using log-log regression
- Geographic disparities in access
- Facility characteristics

Because each visualization was required to be self-contained, you will see duplicated setup code across RMarkdown files.

---

### Interactive Dashboards

Two Shiny applications are included:

#### 1. State Admissions Explorer  
`code/state-admissions-explorer/`

- `prep-state-data.R`: prepares and aggregates data for the app  
- `state-admissions-app.R`: Shiny application

**[Live dashboard](https://smurley3.shinyapps.io/shinyapp/)**  

---

#### 2. State Facility Characteristics Explorer  
`code/state-facility-characteristics-explorer/`

- `state-facility-characteristics-app.R`: Shiny application

**[Live dashboard](https://smurley3.shinyapps.io/facility_characteristics/)**  

---

## Data

Raw CSV files are stored locally and are **not uploaded to GitHub**.

Primary data sources:

- **Treatment Episode Data Set Admissions (TEDS-A), 2023**  
  SAMHSA  
  https://www.samhsa.gov/data/data-we-collect/teds-treatment-episode-data-set

- **National Substance Use and Mental Health Services Survey (N-SUMHSS), 2023**  
  SAMHSA  
  https://www.samhsa.gov/data/data-we-collect/nsumhss-national-survey-substance-abuse-treatment-services

- U.S. Census Bureau ACS (for population normalization)

---

## Figures

All rendered visualizations are saved in the `figures/` folder. These include static maps and scatterplots (`.png`) as well as animated graphics (`.gif`) used in the accompanying presentation.

---

## Presentation Materials

At the root of the repository:

- **Project proposal** — outlines motivation, research questions, and design plan  
- **PowerPoint presentation** — summarizes methods, visualizations, and policy implications  

---

## Intended Use

This project was created for academic and portfolio purposes. It demonstrates applied data visualization techniques for public policy analysis, with a focus on substance use treatment access and capacity across U.S. states.

Interpretations should be viewed as exploratory; facility counts do not directly measure capacity, and admissions reflect both access and reporting practices.

---

## Contact

Sara Murley  
M.S. Data Science for Public Policy  
Georgetown University  

Feel free to reach out with questions or feedback.


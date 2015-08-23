
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(navbarPage("Predict family heights!",

   # Application title
   ### tilePanel("Who will be the tallest family member?"),
   ### h4('.t..predict child height based upon gender and birth order'),
                   
  
  tabPanel("App",
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      
     
      sliderInput("MotherHeight",
                  "Choose height of mother (inches)",
                  min = 24,
                  max = 96,
                  value = 60),
      
      sliderInput("FatherHeight",
                  "Choose height of father (inches)",
                  min = 24,
                  max = 96,
                  value = 60),
      
      sliderInput("ChildQty",
                  "How many children in family?",
                  min = 1,
                  max = 15,
                  value = 2),
      
      sliderInput("BirthOrder",
                  "Which child's height to add to plot? (1 = first born)",
                  min = 1,
                  max = 15,
                  value = 1),
      
      radioButtons("ChildGender",
                   "Choose child gender",
                   c("male","female"),
                   selected = NULL,
                   inline = TRUE
      ),
      
      
      textInput("ChildName", "Enter child's name:", value=""),
      
      actionButton("goButton","Update Family Heights")
      
      
    ),

    # Show a plot of the generated distribution
    mainPanel(
      h3('Your Family Heights'),
      plotOutput("FamilyHeights"),
      
      h3('Need to start over?'),
      actionButton("resetButton","Restart")
    )
  )
),
  tabPanel("Help",
           fluidRow(
              column(6, 
                     includeMarkdown("AppHelp.Rmd"))
           )
)
)
)

library(shiny)

# load the posterior probability from the fitted model 

post <- readRDS('output/post.rds')

# functions

# link function that compute lambda
link <- function( A , B ) {
 
 
  
  # construct a vector of the log(lambda)
  mu_j <- with( post ,{ 
    alpha_j + beta_j * B + gamma_j * A 
    })
  
  # convert it in to positve value 
  lambda_j <- exp( mu_j )
  lambda_j
  
 }


# function to compute the highest density see details of ?coda::HPDinterval for further info
hpdi <- function(samples, prob = 0.97) {
  samples <- coda::as.mcmc(samples)
  x <- sapply(prob, function(p) coda::HPDinterval(samples, prob = p))
  n <- length(prob)
  result <- rep(0, n * 2)
  for (i in 1:n) {
    low_idx <- n + 1 - i
    up_idx <- n + i
    result[low_idx] <- x[1, i]
    result[up_idx] <- x[2, i]
    }
  return(result)
  }



# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("PROMETheus"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(# site
          radioButtons(inputId = "L",
                       label = "Location:",
                       choiceNames = c('Stomach', 'Duodenum', 'Small intestine', 'Colonrectum'),
                       choiceValues = c(4L, 2L, 3L, 1L)),
          
          # Input: Selector for choosing Size
          numericInput(inputId = "Si",
                       label = "Tumor size in mm:",
                       value = 45,
                       step = 1, 
                       min = 1) ,

          # Input: Selector for choosing m_bio
          numericInput(inputId = "m_bio",
                       label = "Mitotic count on biopsy:",
                       value = 2,
                       step = 1,
                       min = 0) ,

          # Input: Selector for choosing Su
          sliderInput(inputId = "Su",
                       label = "Available surface on biopsy (in HPF):",
                       value = 23.5,
                       min = 0.1,
                       max = 23.5),

        
        
        h4("Miettinen and Lasota Risk class"),
        uiOutput("r_class_bio")
       
         ),

        # Show a plot of the generated distribution
        mainPanel(
          plotOutput(outputId = "densPlot"),
          plotOutput(outputId = "riskPlot") 
          
        )
        )
    )
 

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  # return the risk class computed on the biopsy
  rbio <- reactive( risk_str( size = input$Si,  mic = input$m_bio, site = as.numeric(input$L)))
  
  # insert the risk class computed in the text
  output$r_class_bio <-  renderText({
   HTML(
     paste0("Based on mitotic count on biopsy, the risk class is: <b>", rbio(),"</b>."))
    })
  
  
  # Model prediction
  ## compute lambda for the data provided
  
  lambda <- reactive(link( Si =  input$Si , m_bio = input$m_bio, Su = input$Su,  L = as.numeric(input$L)))
  
  ## generate the mitosis on the surgical specimen starting from the lambda
  m_surg <- reactive({ 
    m_surg <- numeric(length = length(lambda()))
    m_surg <- rpois(n = length(lambda()), lambda = lambda())
    m_surg  
  })
  
  ## create a data frame with the mitosis counted (row 1) and the proportion of them over the total (row 2)
  ## i.e. the probability that that mitotic count will be in the surgical specimen
  
  t_m_surg <- reactive({ 
    t_m_surg <- data.frame(proportions(table(m_surg())))  
    # str(t_m_surg) 
    # $Var1: Factor {levels are the mitotic counts} 
    # $Freq: num {the probability}
    t_m_surg[,1] <- as.numeric(t_m_surg[,1]) - 1  # convert the $Var1 to 'numeric' of the actual mitosis counted       
    t_m_surg  
  })
  
  ## calculate the HPDi (50%) on the predicted mitosis parameter lambda
  
  hpdi_su <- reactive({
    hpdi_su <- hpdi(samples = lambda())
    hpdi_su
  })
  
  ## however probability encompassed will be >than 50% because mitosis is a count variable
  ## so we have to recalculate the total probability of the interval
  
  pr_m <-  reactive({
    l <- which(t_m_surg()[,1] <= hpdi_su()[1]) 
    l <- max(l)
    h <- which(t_m_surg()[,1] >= hpdi_su()[2])
    h <- min(h)
    i <- seq( from = l, to = h, by = 1)
    pr_m <- sum(t_m_surg()[ i , 2 ] )
    pr_m <- c(pr_m, l - 1, h - 1 ) # - 1 convert indexes to mitotic count
  })
  
  # calculate the ylim
  ylim_h <- reactive( max( t_m_surg()[,2] ) )
  
  # write the probability encompassed in the shaded area
  legend_text <- reactive({
    HPDI <-  paste0( round( pr_m()[1] * 100 ), '% HPDI')
    legend_text <- c("on the biopsy", "prediction", HPDI)
    legend_text
    })
  
  # plot the predicted mitotic count
  output$densPlot <- renderPlot({
    title <-  bquote(bold("Mitotic count in 5 mm"^2))
    plot(NULL, xlim = c( 0 , max( lambda() ) + 3 ), 
         ylim = c( 0 , ylim_h()  ) ,
         xlab = "Mitosis", bty = 'n',
         ylab = 'Probability',
         main = title,
         font.main = 2)
    polygon(x = c(pr_m()[2] - 0.15 , pr_m()[3] + 0.15 , pr_m()[3] + 0.15 , pr_m()[2] - 0.15 ),
            y = c( 0 , 0, ylim_h() , ylim_h() ),
            col = scales::alpha(1, 0.05), border = NA)
    abline( v = input$m_bio, lty = 2)
    lines(t_m_surg()[,1], t_m_surg()[,2], type = 'h', col = "seagreen3", lwd = 6)
    legend('topright', lty = c(2,1,0), pch = c(NA,NA,15),
           col = c(1,"seagreen3",scales::alpha(1, 0.1)), pt.cex = c(1,1,3),
           lwd = c(1,6,0), legend = legend_text())
   
    })
    
  # compute the risk stratification for all the m_surg and table the computed risk classes 
    fr_rsurg <- reactive({ 
      
      rsurg <- vector( "character" , length = length(lambda()))
      
      for(i in 1:length(lambda())){
        rsurg[i] <- risk_str(size = input$Si,
                             mic = m_surg()[i],
                             site = as.numeric(input$L))
      }
      
      fr_rsurg <- data.frame(proportions(table(rsurg)))
      })
    
    #Plot the risk classes
    output$riskPlot <- renderPlot({
      barplot(fr_rsurg()$Freq, names = fr_rsurg()$rsurg, 
              main = 'Predicted Risk Class')

    })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

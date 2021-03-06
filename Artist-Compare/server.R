library(shiny)
library(plotly)

source("data_from_artist.R")
source("equation.R")

shinyServer(function(input, output, session) {
  
      #Gets data from data_from_artist for each artist then finds the better artist and returns a list
      lists <- eventReactive(input$goButton ,{
        ret <- list()
        ret$artist1 <- each_artist(input$first_artist)
        ret$artist2 <- each_artist(input$second_artist)
        ret$best <- better_artist_algorithm(ret$artist1, ret$artist2)
        return(ret)
      })
      
      observeEvent(input$goButton, {
        updateTabsetPanel(session, inputId = "tab_panel", selected = "Winner")
      })
      
      output$logo <- renderImage({
        list(src = 'imgs/spartify-logo2.png', 
             alt = "Spartify Logo",
             width = "30%")
      }, deleteFile = FALSE)
      
      output$both_names <- renderText({
        temp <- lists()
        paste0(temp$artist1$name_artist, " Vs. ", temp$artist2$name_artist)
      })
      
      #Text for who is the better artist  
      output$sentence <- renderText({ 
        temp <- lists()
        paste0(temp$best$name_artist, " Wins!")
      })
      
      #Plays music
      output$url <- renderUI({
        temp <- lists()
        url <- paste0("<audio src='",temp$best$track_id ,"' type='audio/mp3' autoplay controls></audio>")
        HTML(url)
      })
      
      output$previewSentence <- renderText({
        temp <- lists()
        paste0("Listen to a sample here...")
      })
      
      #Gives image of the artist
      output$image <- renderImage({
        temp <- lists()
        z = tempfile()
        download.file(temp$best$img_artist, z, mode = "wb")
        list(src = z,
             alt = "Artist Image")
      })
      
      #Creates table for the data
      output$table <- renderTable({
        temp <- lists()
        table <- data.frame(row.names = c("Popularity", "Followers", "Total Albums", "Current Hit Songs"))
        table$artist1 <- c(temp$artist1$pop_artist, temp$artist1$followers_artist, 
                           temp$artist1$num_albums, temp$artist1$num_hit_trax)
        table$artist2 <- c(temp$artist2$pop_artist, temp$artist2$followers_artist, 
                           temp$artist2$num_albums, temp$artist2$num_hit_trax)
        colnames(table) <- c(temp$artist1$name_artist, temp$artist2$name_artist)
        return(table)
      })
      
      #Creates plots for each form of data pulled out
      output$visualization <- renderPlotly({
        temp <- lists()
        loc_one <- paste0("temp$artist1$", input$radioButtons)
        loc_two <- paste0("temp$artist2$", input$radioButtons)
        plot_ly(
          x = c(temp$artist1$name_artist, temp$artist2$name_artist),
          y = c(eval(parse(text=loc_one)), eval(parse(text=loc_two))),
          type = "bar",
          marker = list(color = toRGB("forestgreen")),
          opacity = 0.75) %>% 
        layout(xaxis = list(title = ""),
               yaxis = list(title = ""),
               paper_bgcolor = toRGB("gray60"),
               plot_bgcolor = toRGB("gray60"))
      })
})

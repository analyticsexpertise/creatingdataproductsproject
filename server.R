
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#


### Creating Data Products
### Prediction Algorithm for Project
### Mark Stephens
### August 2015

require(HistData)
require(shiny)
require(ggplot2)
require(plyr)

data("GaltonFamilies")

### Child height predictor
### based on GaltonFamilies data set from HistData package
### Package information: http://www.inside-r.org/packages/cran/HistData/docs/GaltonFamilies
### Research Paper: http://www.medicine.mcgill.ca/epidemiology/hanley/galton/
### fit a general linear model to predict child height 
### a model is fitted for males and a separate model fitted for females

data_male <<- GaltonFamilies[GaltonFamilies$gender=="male",c(-1,-4,-7)]

data_female <<- GaltonFamilies[GaltonFamilies$gender=="female",c(-1,-4,-7)]

fit_male <<- lm(childHeight ~ father + mother + children + childNum, 
                data = data_male, na.action = "na.exclude" )


fit_female <<- lm(childHeight ~ father + mother + children + childNum, 
                  data = data_female, na.action = "na.exclude" )

heightformula <<- as.data.frame(rbind(male=fit_male$coefficients,female=fit_female$coefficients))

childindex <<- 0
lastgo <<- 0
childname <<- ""

predictheight <- function(gender="male",fheight=60, mheight=60, numchildren=1,birthorder=1){
  
  rownum = 1
  
  if(gender=="female"){
    rownum = 2
  }
  predformula <- heightformula[rownum, ]    
  return(round(predformula$`(Intercept)`
               +predformula$father*fheight
               +predformula$mother*mheight
               +predformula$children*numchildren
               +predformula$childNum*birthorder,0))
  
}


familyheights <- function(gender="male",fheight=60, mheight=60, numchildren=1,birthorder=1){
  
  members = c("father","mother")
  heights = c(fheight,mheight)
  gender = c("male","female")
  
  familydata <<- as.data.frame(x=cbind(members,heights,gender),stringsAsFactors=FALSE)
  
  childindex <<- 0
  
}

addchild <- function(gender="male",fheight=60, mheight=60, numchildren=1,birthorder=1){
  
  childindex <<- childindex + 1
  
  if(childindex <= numchildren){
    
   
     if(childname=="" | childname %in% familydata$members == TRUE){
    childname <<- as.character(paste0("child",birthorder))
    }
    
    childheight <- as.integer(predictheight(gender,fheight, mheight, numchildren,birthorder))
    
    newchild <- c(childname,childheight,gender)
    
    familydata <<- rbind(familydata,newchild)
    
   
  }
  
}

createfamilyplot <- function(gender="male",fheight=60, mheight=60, numchildren=1,birthorder=1){
  
  if(childindex==0){
    familyheights(gender,fheight,mheight,numchildren,birthorder)
    birthorders <<- c()
  }
  
  if (birthorder %in% birthorders == FALSE ){
    addchild(gender,fheight,mheight,numchildren,birthorder)
    birthorders <<- c(birthorders,birthorder)
  }
  
  
}

updatefamilyplot<-function(){
  
  ##barplot(height=as.integer(familydata$heights),
  ##        horiz=FALSE,names.arg=familydata$members,col=familydata$barcolor)
  
  arrange(familydata,desc(heights))
  
  familydata$members <- factor(familydata$members,
                               levels=familydata$members[order(familydata$heights,decreasing = TRUE)])
  
  
  g <- ggplot(data=familydata,aes(x=members,y=heights,fill=gender)) + geom_bar(stat="identity")
  
  g
  
}

resetAll <- function(){
  
  childindex <<- 0
}

### Shiny Server Code

shinyServer(function(input, output) {

    observeEvent(input$resetButton, {
      
      resetAll()
      output$FamilyHeights <- renderPlot(barplot(height=0,horiz=FALSE,names.arg=c(),plot=FALSE))
      lastgo = lastgo-1
      childname = ""
    })  
    
   
     
      
   
    
    observeEvent(input$goButton, {
    
      output$FamilyHeights <- renderPlot({
    
      if(input$goButton==0) return()
    
      if(lastgo<input$goButton){
        
        childname <<- input$ChildName
        
        createfamilyplot(gender=input$ChildGender,
                         fheight=input$FatherHeight,
                         mheight=input$MotherHeight,
                         numchildren = input$ChildQty,
                         birthorder = input$BirthOrder)
        
        lastgo<<-input$goButton
        
       
      }
      
      updatefamilyplot()
      
 
      })
    })
    
    
    
   
})



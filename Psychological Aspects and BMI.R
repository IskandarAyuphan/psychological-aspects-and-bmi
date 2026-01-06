library(lavaan)
library(semPlot)
library(semTools)
library(corrplot)
library(psych)
library(parameters)
library(mvnormalTest)
library(dplyr)

#####demography######
full_demography <- read.csv("data/Demography.csv", header = TRUE)
head(full_demography)
str(full_demography)
demography <- full_demography[-c(1:3)]

demography$Gender <- as.factor(demography$Gender)
demography$Age <- as.factor(demography$Age)
demography$Race <- as.factor(demography$Race)
demography$Year_of_Study <- as.factor(demography$Year_of_Study)
demography$Department <- as.factor(demography$Department)
summary(demography)

anthropometry <- full_demography[,c(1:3)]
summary(anthropometry)
sqrt(diag(var(anthropometry))) #standard deviation
head(anthropometry)

BMI <- full_demography[,c(3), drop = FALSE]
summary(BMI)
boxplot(BMI)

# categorize BMI into four categories
library(dplyr)
category <- BMI %>%
  mutate(
    BMI_category = case_when(
      BMI < 18.5 ~ "Underweight",
      BMI >= 18.5 & BMI < 25 ~ "Normal",
      BMI >= 25 & BMI < 30 ~ "Overweight",
      BMI >= 30 ~ "Obesity"
    )
  )

category_summary <- category %>%
  group_by(BMI_category) %>%
  summarise(Count = n(), 
            Average = mean(BMI), 
            Standard_deviation = sd(BMI))

category_summary

#####psychological_aspects#####
psychological_aspects <- read.csv("data/Psychological_aspects.csv", header = TRUE)
head(psychological_aspects)
str(psychological_aspects)

# descriptive analysis of psychological aspects
depression <- psychological_aspects[,c(1:9)]
head(depression)
summary(depression)
sqrt(diag(var(depression))) #standard deviation
boxplot(depression,
        ylab = "Score",
        xlab = "Item")

anxiety <- psychological_aspects[,c(10:16)]
head(anxiety)
summary(anxiety)
sqrt(diag(var(anxiety))) #standard deviation
boxplot(anxiety,
        ylab = "Score",
        xlab = "Item")

stress <- psychological_aspects[,c(17:26)]
head(stress)
summary(stress)
sqrt(diag(var(stress))) #standard deviation
boxplot(stress,
        ylab = "Score",
        xlab = "Item")

# normality test

mardia(fyp)

# preliminary tests for factor analysis

cortest.bartlett(cor(psychological_aspects), n=nrow(fyp))
KMO(r=cor(psychological_aspects))
corrplot(cor(psychological_aspects), method="number")

#####CFA#####

# CFA model 1

cfamodel_1 <- '
  Depression =~ M1 + M2 + M3 + M4 + M5 + M6 + M7 + M8 + M9
  Anxiety =~ R1 + R2 + R3 + R4 + R5 + R6 + R7
  Stress =~ T1 + T2 + T3 + T4 + T5 + T6 + T7 + T8 + T9 + T10
  Overall_BMI =~ BMI
'

# fit CFA model  1
fit.cfamodel_1 <- cfa(cfamodel_1, data = psychological_aspects, estimator = "MLR")

summary(fit.cfamodel_1, standardized = TRUE)
compRelSEM(fit.cfamodel_1)
AVE(fit.cfamodel_1)
fitMeasures(fit.cfamodel_1, output="text")

# CFA model 2

cfamodel_2 <- '
  Depression =~ M1 + M2 + M3 + M4 + M5 + M6 + M7 + M8 + M9
  Anxiety =~ R1 + R2 + R3 + R4 + R5 + R6 + R7
  Stress =~ T1 + T2 + T3 + T6 + T9 + T10
  Overall_BMI =~ BMI
'

# fit CFA model 2
fit.cfamodel_2 <- cfa(cfamodel_2, data = psychological_aspects, estimator = "MLR")

summary(fit.cfamodel_2, standardized = TRUE)
compRelSEM(fit.cfamodel_2)
AVE(fit.cfamodel_2)
fitMeasures(fit.cfamodel_2, output="text")

#####SEM analysis#####

# SEM model 2.1

semmodel_2.1 <- '
  # measurement model
  Depression =~ M1 + M2 + M3 + M4 + M5 + M6 + M7 + M8 + M9
  Anxiety =~ R1 + R2 + R3 + R4 + R5 + R6 + R7
  Stress =~ T1 + T2 + T3 + T6 + T9 + T10
  Overall_BMI =~ BMI

  # structural model
  Overall_BMI ~ Depression + Anxiety + Stress
'

# fit SEM model 2.1
fit.semmodel_2.1 <- sem(semmodel_2.1, data = psychological_aspects, estimator = "MLR")

summary(fit.semmodel_2.1, standardized = TRUE)
fitMeasures(fit.semmodel_2.1, output="text")

semPaths(fit.semmodel_2.1, 
         what="std", 
         rotation = 2, 
         sizeMan=3.2,
         nCharNodes=7,
         color="lightgray",
         optimizeLatRes=TRUE,
         esize=2)

# SEM model 2.2

semmodel_2.2 <- '
  # measurement model
  Depression =~ M1 + M2 + M3 + M4 + M5 + M6 + M7 + M8 + M9
  Anxiety =~ R1 + R2 + R3 + R4 + R5 + R6 + R7
  Stress =~ T1 + T2 + T3 + T6 + T9 + T10
  Overall_BMI =~ BMI

  # structural model
  Depression ~ Overall_BMI
  Anxiety ~ Overall_BMI
  Stress ~ Overall_BMI
'

# fit SEM model 2.2
fit.semmodel_2.2 <- sem(semmodel_2.2, data = psychological_aspects, estimator = "MLR")

summary(fit.semmodel_2.2, standardized=TRUE)
fitMeasures(fit.semmodel_2.2, output="text")

semPaths(fit.semmodel_2.2, 
         what="std", 
         rotation = 2, 
         sizeMan=3.2,
         nCharNodes=7,
         color="lightgray",
         optimizeLatRes=TRUE,
         esize=2,
)



# @knitr setup
load("C:/github/HtmlWidgetExamples/data/fai_temps.RData")
library(data.table)
library(reshape2)
library(dplyr)
library(DT)
library(sparkline)

fai <- mutate(fai, Decade=paste0(Year - Year %% 10, "s"))
r <- range(filter(fai, Var=="Temperature")$Val)

# @knitr table_full
fai

# @knitr defs_callbacks
colDefs1 <- list(list(targets=c(1:12), render=JS("function(data, type, full){ return '<span class=spark>' + data + '</span>' }")))
colDefs2 <- list(list(targets=c(1:6), render=JS("function(data, type, full){ return '<span class=spark>' + data + '</span>' }")))

# @knitr callbacks
cb_bar = JS(paste0("function (oSettings, json) {
  $('.spark:not(:has(canvas))').sparkline('html', { type: 'bar', highlightColor: 'black' });
}"), collapse="")

cb_line = JS(paste0("function (oSettings, json) {
  $('.spark:not(:has(canvas))').sparkline('html', {
    type: 'line', highlightColor: 'black', chartRangeMin: ", r[1], ", chartRangeMax: ", r[2], "
  });
}"), collapse="")

cb_box1 = JS(paste0("function (oSettings, json) {
  $('.spark:not(:has(canvas))').sparkline('html', { type: 'box', highlightColor: 'black' });
}"), collapse="")

cb_box2 = JS(paste0("function (oSettings, json) {
  $('.spark:not(:has(canvas))').sparkline('html', {
    type: 'box', highlightColor: 'black', chartRangeMin: ", r[1], ", chartRangeMax: ", r[2], "
  });
}"), collapse="")

# @knitr sparklines
fai.p <- filter(fai, Var=="Precipitation" & Decade=="2000s" & Month=="Aug")$Val
fai.p

# @knitr sparkline_dt_prep
fai.t <- fai %>% filter(Var=="Temperature" & Year >= 1950 & Year < 2010) %>% group_by(Decade, Month) %>% summarise(Temperature=paste(Val, collapse = ","))
fai.t
fai.ta <- dcast(fai.t, Decade ~ Month)
fai.tb <- dcast(fai.t, Month ~ Decade)

# @knitr table_DxM_line
d1 <- datatable(data.table(fai.ta), rownames=FALSE, options=list(columnDefs=colDefs1, fnDrawCallback=cb_line))
d1$dependencies <- append(d1$dependencies, htmlwidgets:::getDependency('sparkline'))
d1

# @knitr table_MxD_bar
d2 <- datatable(data.table(fai.tb), rownames=FALSE, options=list(columnDefs=colDefs2, fnDrawCallback=cb_bar))
d2$dependencies <- append(d2$dependencies, htmlwidgets:::getDependency('sparkline'))
d2

# @knitr table_MxD_box1
d3 <- datatable(data.table(fai.tb), rownames=FALSE, options=list(columnDefs=colDefs2, fnDrawCallback=cb_box1))
d3$dependencies <- append(d3$dependencies, htmlwidgets:::getDependency('sparkline'))
d3

# @knitr table_MxD_box2
d4 <- datatable(data.table(fai.tb), rownames=FALSE, options=list(columnDefs=colDefs2, fnDrawCallback=cb_box2))
d4$dependencies <- append(d4$dependencies, htmlwidgets:::getDependency('sparkline'))
d4

# @knitr final_prep
fai.t2 <- fai %>% filter(Var=="Temperature" & Month=="Aug" & Year >= 1950 & Year < 2010) %>%
    group_by(Location, Var, Decade) %>%
    summarise(Mean=round(mean(Val), 1), SD=round(sd(Val), 2), Min=min(Val), Max=max(Val), Samples=paste(Val, collapse = ",")) %>%
    mutate(Series=Samples) %>% data.table
    
fai.t2

cd <- list(list(targets=5, render=JS("function(data, type, full){ return '<span class=sparkSamples>' + data + '</span>' }")),
      list(targets=6, render=JS("function(data, type, full){ return '<span class=sparkSeries>' + data + '</span>' }")))

cb = JS("function (oSettings, json) {
  $('.sparkSeries:not(:has(canvas))').sparkline('html', { type: 'line', highlightColor: 'black' });
  $('.sparkSamples:not(:has(canvas))').sparkline('html', { type: 'box', highlightColor: 'black' });
}")

# @knitr table_final
d5 <- datatable(data.table(fai.t2), rownames=FALSE, options=list(columnDefs=cd, fnDrawCallback=cb))
d5$dependencies <- append(d5$dependencies, htmlwidgets:::getDependency('sparkline'))
d5

# @knitr setup
load("C:/github/HtmlWidgetExamples/data/climate.RData")
library(data.table)
library(reshape2)
library(dplyr)
library(DT)
library(sparkline)

dat <- mutate(dat, Decade=paste0(Year - Year %% 10, "s"))
r <- range(filter(dat, Var=="Temperature" & Location=="Edmonton, Alberta")$Val)

# @knitr table_full
datatable(dat, rownames=FALSE, filter="bottom")

# @knitr defs
colDefs1 <- list(list(targets=c(1:12), render=JS("function(data, type, full){ return '<span class=spark>' + data + '</span>' }")))
colDefs2 <- list(list(targets=c(1:6), render=JS("function(data, type, full){ return '<span class=spark>' + data + '</span>' }")))

# @knitr callbacks
bar_string <- "type: 'bar', barColor: 'orange', negBarColor: 'purple', highlightColor: 'black'"
cb_bar = JS(paste0("function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { ", bar_string, " }); }"), collapse="")

line_string <- "type: 'line', lineColor: 'black', fillColor: '#ccc', highlightLineColor: 'orange', highlightSpotColor: 'orange'"
cb_line = JS(paste0("function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { ", line_string, ", chartRangeMin: ", r[1], ", chartRangeMax: ", r[2], " }); }"), collapse="")

box_string <- "type: 'box', lineColor: 'black', whiskerColor: 'black', outlierFillColor: 'black', outlierLineColor: 'black', medianColor: 'black', boxFillColor: 'orange', boxLineColor: 'black'"
cb_box1 = JS(paste0("function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { ", box_string," }); }"), collapse="")
cb_box2 = JS(paste0("function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { ", box_string, ", chartRangeMin: ", r[1], ", chartRangeMax: ", r[2], " }); }"), collapse="")

# @knitr sparklines
dat.p <- filter(dat, Var=="Precipitation" & Decade=="2000s" & Month=="Aug")$Val
dat.p

# @knitr sparkline_dt_prep
dat.t <- filter(dat, Var=="Temperature" & Location=="Edmonton, Alberta") %>%
    group_by(Decade, Month) %>% summarise(Temperature=paste(Val, collapse = ","))
dat.ta <- dcast(dat.t, Decade ~ Month)
dat.tb <- dcast(dat.t, Month ~ Decade)

# @knitr table_DxM_line
d1 <- datatable(data.table(dat.ta), rownames=FALSE, filter="bottom", options=list(columnDefs=colDefs1, fnDrawCallback=cb_line))
d1$dependencies <- append(d1$dependencies, htmlwidgets:::getDependency('sparkline'))
d1

# @knitr table_MxD_bar
d2 <- datatable(data.table(dat.tb), rownames=FALSE, filter="bottom", options=list(columnDefs=colDefs2, fnDrawCallback=cb_bar))
d2$dependencies <- append(d2$dependencies, htmlwidgets:::getDependency('sparkline'))
d2

# @knitr table_MxD_box1
d3 <- datatable(data.table(dat.tb), rownames=FALSE, filter="bottom", options=list(columnDefs=colDefs2, fnDrawCallback=cb_box1))
d3$dependencies <- append(d3$dependencies, htmlwidgets:::getDependency('sparkline'))
d3

# @knitr table_MxD_box2
d4 <- datatable(data.table(dat.tb), rownames=FALSE, filter="bottom", options=list(columnDefs=colDefs2, fnDrawCallback=cb_box2))
d4$dependencies <- append(d4$dependencies, htmlwidgets:::getDependency('sparkline'))
d4

# @knitr final_prep
dat.t2 <- filter(dat, Var=="Temperature" & Location=="Edmonton, Alberta" & Month=="Aug") %>%
    group_by(Location, Month, Var, Decade) %>%
    summarise(Mean=round(mean(Val), 1), SD=round(sd(Val), 2), Min=min(Val), Max=max(Val), Samples=paste(Val, collapse = ",")) %>%
    mutate(Series=Samples) %>% data.table
    
cd <- list(list(targets=8, render=JS("function(data, type, full){ return '<span class=sparkSamples>' + data + '</span>' }")),
      list(targets=9, render=JS("function(data, type, full){ return '<span class=sparkSeries>' + data + '</span>' }")))

cb = JS(paste0("function (oSettings, json) {
  $('.sparkSeries:not(:has(canvas))').sparkline('html', { ", line_string, " });
  $('.sparkSamples:not(:has(canvas))').sparkline('html', { ", box_string, " });
}"), collapse="")

# @knitr table_final
d5 <- datatable(data.table(dat.t2), rownames=FALSE, filter="bottom", options=list(columnDefs=cd, fnDrawCallback=cb))
d5$dependencies <- append(d5$dependencies, htmlwidgets:::getDependency('sparkline'))
d5

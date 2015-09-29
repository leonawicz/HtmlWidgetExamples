# Combining datatables and sparkline



##
##
## Examples using Fairbanks, Alaska climate

In the examples below, I use SNAP's 2-km resolution downscaled CRU 3.2 temperature and precipitation data for Fairbanks, Alaska
to demonstrate the use of the `DT` package for data tables and the `sparkline` package for in-line graphs as well as integration of sparkline in-line graphs into data tables.
These packages make use of the `htmlwidgets` package and are interfaces to the jQuery plugins DataTables and Sparklines.

First, load data and required packages. I store the temperature range over all months and years for later use.


```r
load("C:/github/HtmlWidgetExamples/data/fai_temps.RData")
library(data.table)
library(reshape2)
library(dplyr)
library(DT)
library(sparkline)

fai <- mutate(fai, Decade = paste0(Year - Year%%10, "s"))
r <- range(filter(fai, Var == "Temperature")$Val)
```

##
##
### DT data tables

Here is the full data table.


```r
fai
```

```
##                 Var          Location   Val Month Year Decade
##    1:   Temperature Fairbanks, Alaska -24.5   Jan 1901  1900s
##    2:   Temperature Fairbanks, Alaska -21.9   Feb 1901  1900s
##    3:   Temperature Fairbanks, Alaska -10.4   Mar 1901  1900s
##    4:   Temperature Fairbanks, Alaska  -2.7   Apr 1901  1900s
##    5:   Temperature Fairbanks, Alaska   7.6   May 1901  1900s
##   ---                                                        
## 2708: Precipitation Fairbanks, Alaska  57.0   Aug 2013  2010s
## 2709: Precipitation Fairbanks, Alaska  52.0   Sep 2013  2010s
## 2710: Precipitation Fairbanks, Alaska  11.0   Oct 2013  2010s
## 2711: Precipitation Fairbanks, Alaska  33.0   Nov 2013  2010s
## 2712: Precipitation Fairbanks, Alaska  18.0   Dec 2013  2010s
```

##

There are many options for displaying data table html wdigets in the browser using `DT`. See this tutorial for details.

##
##
### Sparkline in-line graphs


```r
fai.p <- filter(fai, Var == "Precipitation" & Decade == "2000s" & Month == "Aug")$Val
fai.p
```

```
##  [1] 86 56 85 55 10  8 61 42 74 76
```

##

Next, display some in-line graphs. Here I use August precipitation totals from Fairbanks each year from 2000 - 2009, stored in `fai.p`.
In-line graphs can be shown with calls in your `R` Markdown document in the form ``` `r sparkline(fai.p)` ```.
Different plots can be made by passing a `type` argument, e.g., ``` `r sparkline(fai.p, type='bar')` ```.
Options include but are not limited to line graphs <!--html_preserve--><span id="htmlwidget-7913" class="sparkline"></span>
<script type="application/json" data-for="htmlwidget-7913">{"x":{"values":[86,56,85,55,10,8,61,42,74,76],"options":{"height":20,"width":60},"width":60,"height":20},"evals":[]}</script><!--/html_preserve-->, bar graphs <!--html_preserve--><span id="htmlwidget-9705" class="sparkline"></span>
<script type="application/json" data-for="htmlwidget-9705">{"x":{"values":[86,56,85,55,10,8,61,42,74,76],"options":{"type":"bar","height":20,"width":60},"width":60,"height":20},"evals":[]}</script><!--/html_preserve-->, and box plots <!--html_preserve--><span id="htmlwidget-9651" class="sparkline"></span>
<script type="application/json" data-for="htmlwidget-9651">{"x":{"values":[86,56,85,55,10,8,61,42,74,76],"options":{"type":"box","height":20,"width":60},"width":60,"height":20},"evals":[]}</script><!--/html_preserve-->.

##
##
### Sparklines inside data tables

To make things more interesting, I integrate sparklines into data tables. This requires providing column definitions and callback functions when making the tables.
Here I provide two similar column definitions, the only difference being which columns to target (counting from zero because this refers to javascript, not `R`).
These definitions add the `spark` class to the targeted columns.


```r
colDefs1 <- list(list(targets = c(1:12), render = JS("function(data, type, full){ return '<span class=spark>' + data + '</span>' }")))
colDefs2 <- list(list(targets = c(1:6), render = JS("function(data, type, full){ return '<span class=spark>' + data + '</span>' }")))
```

##

I also define several callback functions, again all very similar. The only differences are minor tweaks to what I want the sparklines to look like.
I make four data tables with sparklines, using lines, bars, and two with box plots.
For some tables I use the range values from earlier to set a single y-axis common to each graph and for the others I allow each plot to have unique axis limits.


```r
bar_string <- "type: 'bar', barColor: 'orange', negBarColor: 'purple', highlightColor: 'black'"
cb_bar = JS(paste0("function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { ", 
    bar_string, " }); }"), collapse = "")

line_string <- "type: 'line', lineColor: 'black', fillColor: '#ccc', highlightLineColor: 'orange', highlightSpotColor: 'orange'"
cb_line = JS(paste0("function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { ", 
    line_string, ", chartRangeMin: ", r[1], ", chartRangeMax: ", r[2], " }); }"), 
    collapse = "")

box_string <- "type: 'box', lineColor: 'black', whiskerColor: 'black', outlierFillColor: 'black', outlierLineColor: 'black', medianColor: 'black', boxFillColor: 'orange', boxLineColor: 'black'"
cb_box1 = JS(paste0("function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { ", 
    box_string, " }); }"), collapse = "")
cb_box2 = JS(paste0("function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { ", 
    box_string, ", chartRangeMin: ", r[1], ", chartRangeMax: ", r[2], " }); }"), 
    collapse = "")
```

##

Notice that the call to `summarise` below does collapse the data over years (grouped by decades and months), but nothing is lost because the values are concatenated into single character strings.
`dcast` is used to return the table to wide format for a more convenient display.


```r
fai.t <- fai %>% filter(Var == "Temperature" & Year >= 1950 & Year < 2010) %>% 
    group_by(Decade, Month) %>% summarise(Temperature = paste(Val, collapse = ","))
fai.ta <- dcast(fai.t, Decade ~ Month)
fai.tb <- dcast(fai.t, Month ~ Decade)
```

##
##
#### Example tables

In the tables below, I have not excluded the option to sort rows by specific columns, because this is a nice feature of data tables I wish to show.
However, as far as I can tell, the DataTables library does not do anything intelligent when required to sort table rows by a column containing sparklines.
Also, the twelve months in the first column are levels of a factor in `R` but the javascript DataTables library sees this as a simple character string.
Ideally sorting should be disallowed unless it can be restricted to reverse of what is listed initially.

Plot temperature line graphs with a decades by months layout.
This table shows sparklines which all share a common y-axis. It is not easy to read given the data.
Sparklines are most often used in-line among text, though in-line in a table is really no different and can in fact only make them easier to juxtapose and compare.
Nevertheless, they work best when the interest is in obtaining a sense for variability in a signal at a glance.
By their nature they will not work as well for making comparisons between sparklines.


```r
d1 <- datatable(data.table(fai.ta), rownames = FALSE, options = list(columnDefs = colDefs1, 
    fnDrawCallback = cb_line))
d1$dependencies <- append(d1$dependencies, htmlwidgets:::getDependency("sparkline"))
d1
```

<!--html_preserve--><div id="htmlwidget-2813" style="width:100%;height:auto;" class="datatables"></div>
<script type="application/json" data-for="htmlwidget-2813">{"x":{"data":[["1950s","1960s","1970s","1980s","1990s","2000s"],["-17.8,-29.2,-27.8,-27.6,-25,-18.7,-28.1,-16.2,-18.6,-28.1","-19.3,-18.2,-21.3,-16.3,-25.6,-26.9,-31.9,-25.5,-23.2,-31.7","-26.1,-31.2,-26.2,-27.2,-26.3,-25.7,-23.3,-13.4,-17,-21.1","-22.4,-10,-27,-23.3,-20.4,-12.3,-18.1,-16.7,-19.9,-28.9","-24.1,-19.5,-19.6,-19.2,-17.9,-22.2,-26.5,-26,-24.4,-26.3","-22.3,-12.8,-14.9,-18.8,-25.7,-21.9,-29,-20.8,-22,-23.2"],["-25.5,-21.3,-18.5,-15.5,-26.3,-23.7,-22.9,-18.5,-16.4,-13.7","-15.2,-19.5,-13.2,-17.1,-16.7,-26.5,-21.2,-20.8,-19.6,-21","-13.9,-19.6,-22.7,-18,-26.5,-19,-24.6,-12.3,-14.9,-30.4","-12.2,-14.2,-19.3,-15.3,-24.5,-22.4,-14.6,-16.2,-15,-15.1","-28.3,-17.7,-21.8,-15.6,-20.6,-17.1,-19.1,-12.6,-15.8,-24.7","-12.9,-13.1,-17.4,-12.1,-16.4,-18.3,-13.8,-20.6,-19.7,-17.8"],["-7.9,-17.8,-12.6,-13.3,-11,-12,-14.2,-7.7,-8.8,-18.7","-15.2,-17.2,-13.2,-13.2,-18.7,-5,-18.7,-12.1,-10.3,-11.8","-7.5,-16.8,-18.1,-11.1,-13.4,-10.7,-11.1,-15.2,-9.8,-11","-8.1,-3.5,-10.4,-10.2,-6.8,-9.6,-14.3,-10.3,-7.8,-13.9","-7.4,-11.1,-9.8,-8,-11.7,-15.2,-8.7,-15,-7.3,-13.1","-7.9,-11.8,-11.9,-12.6,-13.8,-6.3,-15.2,-17.5,-9,-14"],["-1.9,1.2,-2.4,2.7,-3.3,-5.2,-0.6,0.1,1.3,-3.5","-3,-4,-1.2,-4.2,-3.6,-0.7,-2.9,-0.4,-1.7,2.2","-0.2,-3.1,-5.7,1.5,1.3,-1.1,1.9,-2.4,1.4,-0.8","1.9,-0.6,-2.7,2.6,-1.2,-6.4,-4.7,1.3,0.7,2.1","3.2,1.7,-3.5,3.9,1.3,4.3,0.4,1.6,3.5,0.1","-0.1,0.8,-4.9,0.6,1.5,0.2,-1.3,3,-1,-0.7"],["8.6,9.6,5.4,10.7,10.2,7.7,9.1,9.1,9,8.4","11.6,9.5,7,9.5,4.9,6,7.3,7.5,8.6,9.6","10.9,8.4,8.4,10.2,10.6,11.7,8.7,9.2,10,9.9","10.4,10.7,8.1,10,8.3,8.1,8.6,10.3,11.4,8.7","12.6,10.7,5.5,12,10.8,11.9,9.4,9.6,10.1,8.4","7,6.9,10.2,8.5,11.3,13.2,10.1,10.6,9.9,11"],["14.8,13.8,14.5,16.4,14.7,13,14.1,17.6,16.9,16.2","13.2,14.7,14.6,12.1,15.4,12.8,17.2,16.3,15.1,17.9","14.2,17.2,15,15.5,14.6,17.1,15.1,15.1,12.5,13.9","13.5,14.7,14.5,16.5,16.2,14,16.7,16.3,16.9,15.4","16.2,17.5,15.4,16.5,14.5,15.8,15.2,17,14.8,16.3","16.1,16.2,14.5,15.8,19,16.2,14.5,16.4,15.5,15.8"],["16.2,15.4,15.2,16.3,14.3,15.9,15.8,15.5,16.6,13.5","16.2,14.8,17,15.2,15,15.3,16.4,15,18.3,14.7","16.4,15.7,17.6,16.2,17,18.9,16.1,16.6,17,15.9","15.7,14.1,16.8,17.3,15.6,16.8,17,17.3,18.2,17.6","18.1,15.4,17.3,18.2,17.8,16.8,16.9,17.7,16.8,16","15.3,15.2,16.2,15.8,17.7,16.4,16.1,17.7,15.7,18.8"],["14.2,14.3,12.1,13.2,13.6,11.6,13.1,15.1,13.6,12.4","12.7,12.8,14.3,12.6,13.5,11.5,13.7,14.4,14.6,10","13.7,13.2,14.8,12.7,14.9,13.3,15,16.8,15.1,15.7","12,12,13.5,11.8,12,13.3,12.5,14.2,14.5,15.9","15.3,12.3,13.5,13.2,15.2,13.8,11.8,14.8,11.9,14.5","11.5,14.1,12.5,13.4,16.8,14.2,12.6,16,12.7,12.8"],["8,8.1,5.6,7.1,5.7,6.2,5.3,6.2,5.9,6.1","5,6.4,5,8.5,6.9,8.7,9.7,7.8,5.7,9.2","4.6,6.7,4.2,8.2,10.1,7.4,7.1,7.3,7.9,7.9","5.8,6.4,9.2,4.7,7.9,5.8,7.6,6.4,6.6,8.9","6.9,8.6,3.8,6.4,6.4,10.7,5.3,9.7,7.7,7.2","5.2,8.5,8.4,5.6,5.1,7.9,9.6,8.2,8.1,8.9"],["-3.1,-5.1,-0.4,-4.1,0,-4.3,-7.8,-1.2,-7.4,-4.1","-2.8,-5.7,-0.4,-2.8,-1.7,-7.8,-4,-3.7,-5.1,1.2","-7,-2.1,-2.5,-3.6,-5.5,-4.2,-4.2,-3.1,-4.5,0.2","0.7,-1.2,-7.3,-4.5,-3.2,-6.6,-2.4,0.9,-7.2,-2.9","-4.1,-3.6,-7.7,-1.1,-5.7,-1.9,-8.5,-6.8,-2.9,-5.9","-4.8,-4.9,0.2,0.7,-0.9,-2,0.3,-5.5,-6.5,-0.4"],["-19.7,-10.2,-7.9,-15.3,-9.5,-21.9,-19.1,-9.5,-15.7,-12.9","-17,-17.9,-14,-20.3,-15.1,-14.4,-16.2,-11.3,-15.2,-15.9","-11.9,-16.4,-12.7,-17,-16.3,-20.2,-8.1,-19.1,-11.8,-6.6","-10.3,-10,-14.3,-11.8,-16.7,-19.1,-16.5,-13.3,-18.4,-20.5","-19.5,-16.2,-10.9,-12,-16.5,-18.1,-17.6,-10.6,-13.7,-18.9","-11.8,-16.2,-7.1,-11.5,-12.7,-18.1,-20,-10,-17.1,-16.9"],["-21.1,-22.3,-19.8,-20.4,-29.9,-23.2,-29.1,-26.7,-22.1,-23.4","-15.1,-29.4,-21.7,-16.3,-30,-25.9,-28.9,-19.1,-27.8,-15.8","-23.6,-21.4,-19.7,-19.9,-24.5,-27,-20.2,-26.3,-16.5,-23.8","-29.8,-20.5,-17,-20.2,-20,-13.8,-14.5,-19.8,-15.8,-15.6","-21.7,-19.7,-22.3,-17.7,-22.7,-23.1,-25.5,-21.4,-21,-24.7","-17.9,-23.8,-15.2,-23.1,-20,-17.6,-19.2,-19.8,-22.3,-20.1"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>Decade</th>\n      <th>Jan</th>\n      <th>Feb</th>\n      <th>Mar</th>\n      <th>Apr</th>\n      <th>May</th>\n      <th>Jun</th>\n      <th>Jul</th>\n      <th>Aug</th>\n      <th>Sep</th>\n      <th>Oct</th>\n      <th>Nov</th>\n      <th>Dec</th>\n    </tr>\n  </thead>\n</table>","options":{"columnDefs":[{"targets":[1,2,3,4,5,6,7,8,9,10,11,12],"render":"function(data, type, full){ return '<span class=spark>' + data + '</span>' }"}],"fnDrawCallback":"function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { type: 'line', lineColor: 'black', fillColor: '#ccc', highlightLineColor: 'orange', highlightSpotColor: 'orange', chartRangeMin: -32.6, chartRangeMax: 19 }); }\n","order":[],"autoWidth":false,"orderClasses":false},"callback":null,"filter":"none"},"evals":["options.columnDefs.0.render","options.fnDrawCallback"]}</script><!--/html_preserve-->

##

Plot bar graphs using a months by decades layout. In this case I allow individual sparklines to have unique y-axis limits.
They are much easier to read, but in this case the focus is more clearly not on comparing across months or decades.


```r
d2 <- datatable(data.table(fai.tb), rownames = FALSE, options = list(columnDefs = colDefs2, 
    fnDrawCallback = cb_bar))
d2$dependencies <- append(d2$dependencies, htmlwidgets:::getDependency("sparkline"))
d2
```

<!--html_preserve--><div id="htmlwidget-3721" style="width:100%;height:auto;" class="datatables"></div>
<script type="application/json" data-for="htmlwidget-3721">{"x":{"data":[["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],["-17.8,-29.2,-27.8,-27.6,-25,-18.7,-28.1,-16.2,-18.6,-28.1","-25.5,-21.3,-18.5,-15.5,-26.3,-23.7,-22.9,-18.5,-16.4,-13.7","-7.9,-17.8,-12.6,-13.3,-11,-12,-14.2,-7.7,-8.8,-18.7","-1.9,1.2,-2.4,2.7,-3.3,-5.2,-0.6,0.1,1.3,-3.5","8.6,9.6,5.4,10.7,10.2,7.7,9.1,9.1,9,8.4","14.8,13.8,14.5,16.4,14.7,13,14.1,17.6,16.9,16.2","16.2,15.4,15.2,16.3,14.3,15.9,15.8,15.5,16.6,13.5","14.2,14.3,12.1,13.2,13.6,11.6,13.1,15.1,13.6,12.4","8,8.1,5.6,7.1,5.7,6.2,5.3,6.2,5.9,6.1","-3.1,-5.1,-0.4,-4.1,0,-4.3,-7.8,-1.2,-7.4,-4.1","-19.7,-10.2,-7.9,-15.3,-9.5,-21.9,-19.1,-9.5,-15.7,-12.9","-21.1,-22.3,-19.8,-20.4,-29.9,-23.2,-29.1,-26.7,-22.1,-23.4"],["-19.3,-18.2,-21.3,-16.3,-25.6,-26.9,-31.9,-25.5,-23.2,-31.7","-15.2,-19.5,-13.2,-17.1,-16.7,-26.5,-21.2,-20.8,-19.6,-21","-15.2,-17.2,-13.2,-13.2,-18.7,-5,-18.7,-12.1,-10.3,-11.8","-3,-4,-1.2,-4.2,-3.6,-0.7,-2.9,-0.4,-1.7,2.2","11.6,9.5,7,9.5,4.9,6,7.3,7.5,8.6,9.6","13.2,14.7,14.6,12.1,15.4,12.8,17.2,16.3,15.1,17.9","16.2,14.8,17,15.2,15,15.3,16.4,15,18.3,14.7","12.7,12.8,14.3,12.6,13.5,11.5,13.7,14.4,14.6,10","5,6.4,5,8.5,6.9,8.7,9.7,7.8,5.7,9.2","-2.8,-5.7,-0.4,-2.8,-1.7,-7.8,-4,-3.7,-5.1,1.2","-17,-17.9,-14,-20.3,-15.1,-14.4,-16.2,-11.3,-15.2,-15.9","-15.1,-29.4,-21.7,-16.3,-30,-25.9,-28.9,-19.1,-27.8,-15.8"],["-26.1,-31.2,-26.2,-27.2,-26.3,-25.7,-23.3,-13.4,-17,-21.1","-13.9,-19.6,-22.7,-18,-26.5,-19,-24.6,-12.3,-14.9,-30.4","-7.5,-16.8,-18.1,-11.1,-13.4,-10.7,-11.1,-15.2,-9.8,-11","-0.2,-3.1,-5.7,1.5,1.3,-1.1,1.9,-2.4,1.4,-0.8","10.9,8.4,8.4,10.2,10.6,11.7,8.7,9.2,10,9.9","14.2,17.2,15,15.5,14.6,17.1,15.1,15.1,12.5,13.9","16.4,15.7,17.6,16.2,17,18.9,16.1,16.6,17,15.9","13.7,13.2,14.8,12.7,14.9,13.3,15,16.8,15.1,15.7","4.6,6.7,4.2,8.2,10.1,7.4,7.1,7.3,7.9,7.9","-7,-2.1,-2.5,-3.6,-5.5,-4.2,-4.2,-3.1,-4.5,0.2","-11.9,-16.4,-12.7,-17,-16.3,-20.2,-8.1,-19.1,-11.8,-6.6","-23.6,-21.4,-19.7,-19.9,-24.5,-27,-20.2,-26.3,-16.5,-23.8"],["-22.4,-10,-27,-23.3,-20.4,-12.3,-18.1,-16.7,-19.9,-28.9","-12.2,-14.2,-19.3,-15.3,-24.5,-22.4,-14.6,-16.2,-15,-15.1","-8.1,-3.5,-10.4,-10.2,-6.8,-9.6,-14.3,-10.3,-7.8,-13.9","1.9,-0.6,-2.7,2.6,-1.2,-6.4,-4.7,1.3,0.7,2.1","10.4,10.7,8.1,10,8.3,8.1,8.6,10.3,11.4,8.7","13.5,14.7,14.5,16.5,16.2,14,16.7,16.3,16.9,15.4","15.7,14.1,16.8,17.3,15.6,16.8,17,17.3,18.2,17.6","12,12,13.5,11.8,12,13.3,12.5,14.2,14.5,15.9","5.8,6.4,9.2,4.7,7.9,5.8,7.6,6.4,6.6,8.9","0.7,-1.2,-7.3,-4.5,-3.2,-6.6,-2.4,0.9,-7.2,-2.9","-10.3,-10,-14.3,-11.8,-16.7,-19.1,-16.5,-13.3,-18.4,-20.5","-29.8,-20.5,-17,-20.2,-20,-13.8,-14.5,-19.8,-15.8,-15.6"],["-24.1,-19.5,-19.6,-19.2,-17.9,-22.2,-26.5,-26,-24.4,-26.3","-28.3,-17.7,-21.8,-15.6,-20.6,-17.1,-19.1,-12.6,-15.8,-24.7","-7.4,-11.1,-9.8,-8,-11.7,-15.2,-8.7,-15,-7.3,-13.1","3.2,1.7,-3.5,3.9,1.3,4.3,0.4,1.6,3.5,0.1","12.6,10.7,5.5,12,10.8,11.9,9.4,9.6,10.1,8.4","16.2,17.5,15.4,16.5,14.5,15.8,15.2,17,14.8,16.3","18.1,15.4,17.3,18.2,17.8,16.8,16.9,17.7,16.8,16","15.3,12.3,13.5,13.2,15.2,13.8,11.8,14.8,11.9,14.5","6.9,8.6,3.8,6.4,6.4,10.7,5.3,9.7,7.7,7.2","-4.1,-3.6,-7.7,-1.1,-5.7,-1.9,-8.5,-6.8,-2.9,-5.9","-19.5,-16.2,-10.9,-12,-16.5,-18.1,-17.6,-10.6,-13.7,-18.9","-21.7,-19.7,-22.3,-17.7,-22.7,-23.1,-25.5,-21.4,-21,-24.7"],["-22.3,-12.8,-14.9,-18.8,-25.7,-21.9,-29,-20.8,-22,-23.2","-12.9,-13.1,-17.4,-12.1,-16.4,-18.3,-13.8,-20.6,-19.7,-17.8","-7.9,-11.8,-11.9,-12.6,-13.8,-6.3,-15.2,-17.5,-9,-14","-0.1,0.8,-4.9,0.6,1.5,0.2,-1.3,3,-1,-0.7","7,6.9,10.2,8.5,11.3,13.2,10.1,10.6,9.9,11","16.1,16.2,14.5,15.8,19,16.2,14.5,16.4,15.5,15.8","15.3,15.2,16.2,15.8,17.7,16.4,16.1,17.7,15.7,18.8","11.5,14.1,12.5,13.4,16.8,14.2,12.6,16,12.7,12.8","5.2,8.5,8.4,5.6,5.1,7.9,9.6,8.2,8.1,8.9","-4.8,-4.9,0.2,0.7,-0.9,-2,0.3,-5.5,-6.5,-0.4","-11.8,-16.2,-7.1,-11.5,-12.7,-18.1,-20,-10,-17.1,-16.9","-17.9,-23.8,-15.2,-23.1,-20,-17.6,-19.2,-19.8,-22.3,-20.1"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>Month</th>\n      <th>1950s</th>\n      <th>1960s</th>\n      <th>1970s</th>\n      <th>1980s</th>\n      <th>1990s</th>\n      <th>2000s</th>\n    </tr>\n  </thead>\n</table>","options":{"columnDefs":[{"targets":[1,2,3,4,5,6],"render":"function(data, type, full){ return '<span class=spark>' + data + '</span>' }"}],"fnDrawCallback":"function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { type: 'bar', barColor: 'orange', negBarColor: 'purple', highlightColor: 'black' }); }\n","order":[],"autoWidth":false,"orderClasses":false},"callback":null,"filter":"none"},"evals":["options.columnDefs.0.render","options.fnDrawCallback"]}</script><!--/html_preserve-->

##

Plot bar graphs using a months by decades layout. The two versions below differ in their axis settings.
The first allows unique chart ranges like the previous bar graph. The second fixes all sparklines to a single range.


```r
d3 <- datatable(data.table(fai.tb), rownames = FALSE, options = list(columnDefs = colDefs2, 
    fnDrawCallback = cb_box1))
d3$dependencies <- append(d3$dependencies, htmlwidgets:::getDependency("sparkline"))
d3
```

<!--html_preserve--><div id="htmlwidget-143" style="width:100%;height:auto;" class="datatables"></div>
<script type="application/json" data-for="htmlwidget-143">{"x":{"data":[["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],["-17.8,-29.2,-27.8,-27.6,-25,-18.7,-28.1,-16.2,-18.6,-28.1","-25.5,-21.3,-18.5,-15.5,-26.3,-23.7,-22.9,-18.5,-16.4,-13.7","-7.9,-17.8,-12.6,-13.3,-11,-12,-14.2,-7.7,-8.8,-18.7","-1.9,1.2,-2.4,2.7,-3.3,-5.2,-0.6,0.1,1.3,-3.5","8.6,9.6,5.4,10.7,10.2,7.7,9.1,9.1,9,8.4","14.8,13.8,14.5,16.4,14.7,13,14.1,17.6,16.9,16.2","16.2,15.4,15.2,16.3,14.3,15.9,15.8,15.5,16.6,13.5","14.2,14.3,12.1,13.2,13.6,11.6,13.1,15.1,13.6,12.4","8,8.1,5.6,7.1,5.7,6.2,5.3,6.2,5.9,6.1","-3.1,-5.1,-0.4,-4.1,0,-4.3,-7.8,-1.2,-7.4,-4.1","-19.7,-10.2,-7.9,-15.3,-9.5,-21.9,-19.1,-9.5,-15.7,-12.9","-21.1,-22.3,-19.8,-20.4,-29.9,-23.2,-29.1,-26.7,-22.1,-23.4"],["-19.3,-18.2,-21.3,-16.3,-25.6,-26.9,-31.9,-25.5,-23.2,-31.7","-15.2,-19.5,-13.2,-17.1,-16.7,-26.5,-21.2,-20.8,-19.6,-21","-15.2,-17.2,-13.2,-13.2,-18.7,-5,-18.7,-12.1,-10.3,-11.8","-3,-4,-1.2,-4.2,-3.6,-0.7,-2.9,-0.4,-1.7,2.2","11.6,9.5,7,9.5,4.9,6,7.3,7.5,8.6,9.6","13.2,14.7,14.6,12.1,15.4,12.8,17.2,16.3,15.1,17.9","16.2,14.8,17,15.2,15,15.3,16.4,15,18.3,14.7","12.7,12.8,14.3,12.6,13.5,11.5,13.7,14.4,14.6,10","5,6.4,5,8.5,6.9,8.7,9.7,7.8,5.7,9.2","-2.8,-5.7,-0.4,-2.8,-1.7,-7.8,-4,-3.7,-5.1,1.2","-17,-17.9,-14,-20.3,-15.1,-14.4,-16.2,-11.3,-15.2,-15.9","-15.1,-29.4,-21.7,-16.3,-30,-25.9,-28.9,-19.1,-27.8,-15.8"],["-26.1,-31.2,-26.2,-27.2,-26.3,-25.7,-23.3,-13.4,-17,-21.1","-13.9,-19.6,-22.7,-18,-26.5,-19,-24.6,-12.3,-14.9,-30.4","-7.5,-16.8,-18.1,-11.1,-13.4,-10.7,-11.1,-15.2,-9.8,-11","-0.2,-3.1,-5.7,1.5,1.3,-1.1,1.9,-2.4,1.4,-0.8","10.9,8.4,8.4,10.2,10.6,11.7,8.7,9.2,10,9.9","14.2,17.2,15,15.5,14.6,17.1,15.1,15.1,12.5,13.9","16.4,15.7,17.6,16.2,17,18.9,16.1,16.6,17,15.9","13.7,13.2,14.8,12.7,14.9,13.3,15,16.8,15.1,15.7","4.6,6.7,4.2,8.2,10.1,7.4,7.1,7.3,7.9,7.9","-7,-2.1,-2.5,-3.6,-5.5,-4.2,-4.2,-3.1,-4.5,0.2","-11.9,-16.4,-12.7,-17,-16.3,-20.2,-8.1,-19.1,-11.8,-6.6","-23.6,-21.4,-19.7,-19.9,-24.5,-27,-20.2,-26.3,-16.5,-23.8"],["-22.4,-10,-27,-23.3,-20.4,-12.3,-18.1,-16.7,-19.9,-28.9","-12.2,-14.2,-19.3,-15.3,-24.5,-22.4,-14.6,-16.2,-15,-15.1","-8.1,-3.5,-10.4,-10.2,-6.8,-9.6,-14.3,-10.3,-7.8,-13.9","1.9,-0.6,-2.7,2.6,-1.2,-6.4,-4.7,1.3,0.7,2.1","10.4,10.7,8.1,10,8.3,8.1,8.6,10.3,11.4,8.7","13.5,14.7,14.5,16.5,16.2,14,16.7,16.3,16.9,15.4","15.7,14.1,16.8,17.3,15.6,16.8,17,17.3,18.2,17.6","12,12,13.5,11.8,12,13.3,12.5,14.2,14.5,15.9","5.8,6.4,9.2,4.7,7.9,5.8,7.6,6.4,6.6,8.9","0.7,-1.2,-7.3,-4.5,-3.2,-6.6,-2.4,0.9,-7.2,-2.9","-10.3,-10,-14.3,-11.8,-16.7,-19.1,-16.5,-13.3,-18.4,-20.5","-29.8,-20.5,-17,-20.2,-20,-13.8,-14.5,-19.8,-15.8,-15.6"],["-24.1,-19.5,-19.6,-19.2,-17.9,-22.2,-26.5,-26,-24.4,-26.3","-28.3,-17.7,-21.8,-15.6,-20.6,-17.1,-19.1,-12.6,-15.8,-24.7","-7.4,-11.1,-9.8,-8,-11.7,-15.2,-8.7,-15,-7.3,-13.1","3.2,1.7,-3.5,3.9,1.3,4.3,0.4,1.6,3.5,0.1","12.6,10.7,5.5,12,10.8,11.9,9.4,9.6,10.1,8.4","16.2,17.5,15.4,16.5,14.5,15.8,15.2,17,14.8,16.3","18.1,15.4,17.3,18.2,17.8,16.8,16.9,17.7,16.8,16","15.3,12.3,13.5,13.2,15.2,13.8,11.8,14.8,11.9,14.5","6.9,8.6,3.8,6.4,6.4,10.7,5.3,9.7,7.7,7.2","-4.1,-3.6,-7.7,-1.1,-5.7,-1.9,-8.5,-6.8,-2.9,-5.9","-19.5,-16.2,-10.9,-12,-16.5,-18.1,-17.6,-10.6,-13.7,-18.9","-21.7,-19.7,-22.3,-17.7,-22.7,-23.1,-25.5,-21.4,-21,-24.7"],["-22.3,-12.8,-14.9,-18.8,-25.7,-21.9,-29,-20.8,-22,-23.2","-12.9,-13.1,-17.4,-12.1,-16.4,-18.3,-13.8,-20.6,-19.7,-17.8","-7.9,-11.8,-11.9,-12.6,-13.8,-6.3,-15.2,-17.5,-9,-14","-0.1,0.8,-4.9,0.6,1.5,0.2,-1.3,3,-1,-0.7","7,6.9,10.2,8.5,11.3,13.2,10.1,10.6,9.9,11","16.1,16.2,14.5,15.8,19,16.2,14.5,16.4,15.5,15.8","15.3,15.2,16.2,15.8,17.7,16.4,16.1,17.7,15.7,18.8","11.5,14.1,12.5,13.4,16.8,14.2,12.6,16,12.7,12.8","5.2,8.5,8.4,5.6,5.1,7.9,9.6,8.2,8.1,8.9","-4.8,-4.9,0.2,0.7,-0.9,-2,0.3,-5.5,-6.5,-0.4","-11.8,-16.2,-7.1,-11.5,-12.7,-18.1,-20,-10,-17.1,-16.9","-17.9,-23.8,-15.2,-23.1,-20,-17.6,-19.2,-19.8,-22.3,-20.1"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>Month</th>\n      <th>1950s</th>\n      <th>1960s</th>\n      <th>1970s</th>\n      <th>1980s</th>\n      <th>1990s</th>\n      <th>2000s</th>\n    </tr>\n  </thead>\n</table>","options":{"columnDefs":[{"targets":[1,2,3,4,5,6],"render":"function(data, type, full){ return '<span class=spark>' + data + '</span>' }"}],"fnDrawCallback":"function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { type: 'box', lineColor: 'black', whiskerColor: 'black', outlierFillColor: 'black', outlierLineColor: 'black', medianColor: 'black', boxFillColor: 'orange', boxLineColor: 'black' }); }\n","order":[],"autoWidth":false,"orderClasses":false},"callback":null,"filter":"none"},"evals":["options.columnDefs.0.render","options.fnDrawCallback"]}</script><!--/html_preserve-->


```r
d4 <- datatable(data.table(fai.tb), rownames = FALSE, options = list(columnDefs = colDefs2, 
    fnDrawCallback = cb_box2))
d4$dependencies <- append(d4$dependencies, htmlwidgets:::getDependency("sparkline"))
d4
```

<!--html_preserve--><div id="htmlwidget-382" style="width:100%;height:auto;" class="datatables"></div>
<script type="application/json" data-for="htmlwidget-382">{"x":{"data":[["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],["-17.8,-29.2,-27.8,-27.6,-25,-18.7,-28.1,-16.2,-18.6,-28.1","-25.5,-21.3,-18.5,-15.5,-26.3,-23.7,-22.9,-18.5,-16.4,-13.7","-7.9,-17.8,-12.6,-13.3,-11,-12,-14.2,-7.7,-8.8,-18.7","-1.9,1.2,-2.4,2.7,-3.3,-5.2,-0.6,0.1,1.3,-3.5","8.6,9.6,5.4,10.7,10.2,7.7,9.1,9.1,9,8.4","14.8,13.8,14.5,16.4,14.7,13,14.1,17.6,16.9,16.2","16.2,15.4,15.2,16.3,14.3,15.9,15.8,15.5,16.6,13.5","14.2,14.3,12.1,13.2,13.6,11.6,13.1,15.1,13.6,12.4","8,8.1,5.6,7.1,5.7,6.2,5.3,6.2,5.9,6.1","-3.1,-5.1,-0.4,-4.1,0,-4.3,-7.8,-1.2,-7.4,-4.1","-19.7,-10.2,-7.9,-15.3,-9.5,-21.9,-19.1,-9.5,-15.7,-12.9","-21.1,-22.3,-19.8,-20.4,-29.9,-23.2,-29.1,-26.7,-22.1,-23.4"],["-19.3,-18.2,-21.3,-16.3,-25.6,-26.9,-31.9,-25.5,-23.2,-31.7","-15.2,-19.5,-13.2,-17.1,-16.7,-26.5,-21.2,-20.8,-19.6,-21","-15.2,-17.2,-13.2,-13.2,-18.7,-5,-18.7,-12.1,-10.3,-11.8","-3,-4,-1.2,-4.2,-3.6,-0.7,-2.9,-0.4,-1.7,2.2","11.6,9.5,7,9.5,4.9,6,7.3,7.5,8.6,9.6","13.2,14.7,14.6,12.1,15.4,12.8,17.2,16.3,15.1,17.9","16.2,14.8,17,15.2,15,15.3,16.4,15,18.3,14.7","12.7,12.8,14.3,12.6,13.5,11.5,13.7,14.4,14.6,10","5,6.4,5,8.5,6.9,8.7,9.7,7.8,5.7,9.2","-2.8,-5.7,-0.4,-2.8,-1.7,-7.8,-4,-3.7,-5.1,1.2","-17,-17.9,-14,-20.3,-15.1,-14.4,-16.2,-11.3,-15.2,-15.9","-15.1,-29.4,-21.7,-16.3,-30,-25.9,-28.9,-19.1,-27.8,-15.8"],["-26.1,-31.2,-26.2,-27.2,-26.3,-25.7,-23.3,-13.4,-17,-21.1","-13.9,-19.6,-22.7,-18,-26.5,-19,-24.6,-12.3,-14.9,-30.4","-7.5,-16.8,-18.1,-11.1,-13.4,-10.7,-11.1,-15.2,-9.8,-11","-0.2,-3.1,-5.7,1.5,1.3,-1.1,1.9,-2.4,1.4,-0.8","10.9,8.4,8.4,10.2,10.6,11.7,8.7,9.2,10,9.9","14.2,17.2,15,15.5,14.6,17.1,15.1,15.1,12.5,13.9","16.4,15.7,17.6,16.2,17,18.9,16.1,16.6,17,15.9","13.7,13.2,14.8,12.7,14.9,13.3,15,16.8,15.1,15.7","4.6,6.7,4.2,8.2,10.1,7.4,7.1,7.3,7.9,7.9","-7,-2.1,-2.5,-3.6,-5.5,-4.2,-4.2,-3.1,-4.5,0.2","-11.9,-16.4,-12.7,-17,-16.3,-20.2,-8.1,-19.1,-11.8,-6.6","-23.6,-21.4,-19.7,-19.9,-24.5,-27,-20.2,-26.3,-16.5,-23.8"],["-22.4,-10,-27,-23.3,-20.4,-12.3,-18.1,-16.7,-19.9,-28.9","-12.2,-14.2,-19.3,-15.3,-24.5,-22.4,-14.6,-16.2,-15,-15.1","-8.1,-3.5,-10.4,-10.2,-6.8,-9.6,-14.3,-10.3,-7.8,-13.9","1.9,-0.6,-2.7,2.6,-1.2,-6.4,-4.7,1.3,0.7,2.1","10.4,10.7,8.1,10,8.3,8.1,8.6,10.3,11.4,8.7","13.5,14.7,14.5,16.5,16.2,14,16.7,16.3,16.9,15.4","15.7,14.1,16.8,17.3,15.6,16.8,17,17.3,18.2,17.6","12,12,13.5,11.8,12,13.3,12.5,14.2,14.5,15.9","5.8,6.4,9.2,4.7,7.9,5.8,7.6,6.4,6.6,8.9","0.7,-1.2,-7.3,-4.5,-3.2,-6.6,-2.4,0.9,-7.2,-2.9","-10.3,-10,-14.3,-11.8,-16.7,-19.1,-16.5,-13.3,-18.4,-20.5","-29.8,-20.5,-17,-20.2,-20,-13.8,-14.5,-19.8,-15.8,-15.6"],["-24.1,-19.5,-19.6,-19.2,-17.9,-22.2,-26.5,-26,-24.4,-26.3","-28.3,-17.7,-21.8,-15.6,-20.6,-17.1,-19.1,-12.6,-15.8,-24.7","-7.4,-11.1,-9.8,-8,-11.7,-15.2,-8.7,-15,-7.3,-13.1","3.2,1.7,-3.5,3.9,1.3,4.3,0.4,1.6,3.5,0.1","12.6,10.7,5.5,12,10.8,11.9,9.4,9.6,10.1,8.4","16.2,17.5,15.4,16.5,14.5,15.8,15.2,17,14.8,16.3","18.1,15.4,17.3,18.2,17.8,16.8,16.9,17.7,16.8,16","15.3,12.3,13.5,13.2,15.2,13.8,11.8,14.8,11.9,14.5","6.9,8.6,3.8,6.4,6.4,10.7,5.3,9.7,7.7,7.2","-4.1,-3.6,-7.7,-1.1,-5.7,-1.9,-8.5,-6.8,-2.9,-5.9","-19.5,-16.2,-10.9,-12,-16.5,-18.1,-17.6,-10.6,-13.7,-18.9","-21.7,-19.7,-22.3,-17.7,-22.7,-23.1,-25.5,-21.4,-21,-24.7"],["-22.3,-12.8,-14.9,-18.8,-25.7,-21.9,-29,-20.8,-22,-23.2","-12.9,-13.1,-17.4,-12.1,-16.4,-18.3,-13.8,-20.6,-19.7,-17.8","-7.9,-11.8,-11.9,-12.6,-13.8,-6.3,-15.2,-17.5,-9,-14","-0.1,0.8,-4.9,0.6,1.5,0.2,-1.3,3,-1,-0.7","7,6.9,10.2,8.5,11.3,13.2,10.1,10.6,9.9,11","16.1,16.2,14.5,15.8,19,16.2,14.5,16.4,15.5,15.8","15.3,15.2,16.2,15.8,17.7,16.4,16.1,17.7,15.7,18.8","11.5,14.1,12.5,13.4,16.8,14.2,12.6,16,12.7,12.8","5.2,8.5,8.4,5.6,5.1,7.9,9.6,8.2,8.1,8.9","-4.8,-4.9,0.2,0.7,-0.9,-2,0.3,-5.5,-6.5,-0.4","-11.8,-16.2,-7.1,-11.5,-12.7,-18.1,-20,-10,-17.1,-16.9","-17.9,-23.8,-15.2,-23.1,-20,-17.6,-19.2,-19.8,-22.3,-20.1"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>Month</th>\n      <th>1950s</th>\n      <th>1960s</th>\n      <th>1970s</th>\n      <th>1980s</th>\n      <th>1990s</th>\n      <th>2000s</th>\n    </tr>\n  </thead>\n</table>","options":{"columnDefs":[{"targets":[1,2,3,4,5,6],"render":"function(data, type, full){ return '<span class=spark>' + data + '</span>' }"}],"fnDrawCallback":"function (oSettings, json) { $('.spark:not(:has(canvas))').sparkline('html', { type: 'box', lineColor: 'black', whiskerColor: 'black', outlierFillColor: 'black', outlierLineColor: 'black', medianColor: 'black', boxFillColor: 'orange', boxLineColor: 'black', chartRangeMin: -32.6, chartRangeMax: 19 }); }\n","order":[],"autoWidth":false,"orderClasses":false},"callback":null,"filter":"none"},"evals":["options.columnDefs.0.render","options.fnDrawCallback"]}</script><!--/html_preserve-->

##
##
#### A more useful table

Generally I would not use a table as a complete substitute for a plot. In cases where I can, it is because the data set is simple enough that a traditional text table will suffice.
If adding sparklines to a plot, my preference is to use them to enhance a particular column or two, which otherwise remains a standard data table, rather than turn it into a "many-paneled plot".

The above examples are for illustration. The table below seems like a good mix of data tables and sparklines.
This time I also grouped by location and climate variable even though they are constants in this data subset. This retains them in the final data table for display purposes.
I think it gives a better picture of what the table would look like with more columns which are not all narrow-width and numeric-valued.

In the column definitions and the callback function, note the use of `.sparkSeries` and `.sparkSamples` to differentiate which type of sparklines are placed in each of the two columns.
The box plot shows the distribution of values over a decade whereas the time series line gives a sense of whether any trend is present.
Although it is a simple example and each individual plot is based on only ten values,
it reveals how each in-line graph type draws the eye to different properties of the data and both are a nice compliment to the original data table.


```r
fai.t2 <- fai %>% filter(Var == "Temperature" & Month == "Aug" & Year >= 1950 & 
    Year < 2010) %>% group_by(Location, Var, Decade) %>% summarise(Mean = round(mean(Val), 
    1), SD = round(sd(Val), 2), Min = min(Val), Max = max(Val), Samples = paste(Val, 
    collapse = ",")) %>% mutate(Series = Samples) %>% data.table

cd <- list(list(targets = 7, render = JS("function(data, type, full){ return '<span class=sparkSamples>' + data + '</span>' }")), 
    list(targets = 8, render = JS("function(data, type, full){ return '<span class=sparkSeries>' + data + '</span>' }")))

cb = JS(paste0("function (oSettings, json) {\n  $('.sparkSeries:not(:has(canvas))').sparkline('html', { ", 
    line_string, " });\n  $('.sparkSamples:not(:has(canvas))').sparkline('html', { ", 
    box_string, " });\n}"), collapse = "")
```

##

This strikes a nice balance. On the one hand, I could add additional columns to the table such as the median and quartiles,
but I don't need to add these columns because I can hover over the box plot and see those values in the tooltip. I can also see information about outliers.
This alleviates the need for additional columns. I cannot look at trends easily, or at all, in a summary table.
I can only do this if I use a full table and summarise nothing. For this reason the time series plots are also helpful.

On the other hand, I could remove all my value columns, but I definitely do not want to.
Technically speaking, I can get the medians from the samples column using the box plots, which are close enough to the means, and the min and max values from the series column in-line graphs.
Neither plot type specifically provides the standard deviation, but perhaps seeing the distribution in a box plot is "better" in some instances anyhow, like if the data were highly skewed.
Ultimately, I do not want to be required to hover over all these little plots to essentially decrypt my table.
I want to look at a table and see numbers without any intermediary mental decoding.


```r
d5 <- datatable(data.table(fai.t2), rownames = FALSE, options = list(columnDefs = cd, 
    fnDrawCallback = cb))
d5$dependencies <- append(d5$dependencies, htmlwidgets:::getDependency("sparkline"))
d5
```

<!--html_preserve--><div id="htmlwidget-875" style="width:100%;height:auto;" class="datatables"></div>
<script type="application/json" data-for="htmlwidget-875">{"x":{"data":[["Fairbanks, Alaska","Fairbanks, Alaska","Fairbanks, Alaska","Fairbanks, Alaska","Fairbanks, Alaska","Fairbanks, Alaska"],["Temperature","Temperature","Temperature","Temperature","Temperature","Temperature"],["1950s","1960s","1970s","1980s","1990s","2000s"],[13.3,13,14.5,13.2,13.6,13.7],[1.08,1.43,1.27,1.37,1.32,1.66],[11.6,10,12.7,11.8,11.8,11.5],[15.1,14.6,16.8,15.9,15.3,16.8],["14.2,14.3,12.1,13.2,13.6,11.6,13.1,15.1,13.6,12.4","12.7,12.8,14.3,12.6,13.5,11.5,13.7,14.4,14.6,10","13.7,13.2,14.8,12.7,14.9,13.3,15,16.8,15.1,15.7","12,12,13.5,11.8,12,13.3,12.5,14.2,14.5,15.9","15.3,12.3,13.5,13.2,15.2,13.8,11.8,14.8,11.9,14.5","11.5,14.1,12.5,13.4,16.8,14.2,12.6,16,12.7,12.8"],["14.2,14.3,12.1,13.2,13.6,11.6,13.1,15.1,13.6,12.4","12.7,12.8,14.3,12.6,13.5,11.5,13.7,14.4,14.6,10","13.7,13.2,14.8,12.7,14.9,13.3,15,16.8,15.1,15.7","12,12,13.5,11.8,12,13.3,12.5,14.2,14.5,15.9","15.3,12.3,13.5,13.2,15.2,13.8,11.8,14.8,11.9,14.5","11.5,14.1,12.5,13.4,16.8,14.2,12.6,16,12.7,12.8"]],"container":"<table class=\"display\">\n  <thead>\n    <tr>\n      <th>Location</th>\n      <th>Var</th>\n      <th>Decade</th>\n      <th>Mean</th>\n      <th>SD</th>\n      <th>Min</th>\n      <th>Max</th>\n      <th>Samples</th>\n      <th>Series</th>\n    </tr>\n  </thead>\n</table>","options":{"columnDefs":[{"targets":7,"render":"function(data, type, full){ return '<span class=sparkSamples>' + data + '</span>' }"},{"targets":8,"render":"function(data, type, full){ return '<span class=sparkSeries>' + data + '</span>' }"},{"className":"dt-right","targets":[3,4,5,6]}],"fnDrawCallback":"function (oSettings, json) {\n  $('.sparkSeries:not(:has(canvas))').sparkline('html', { type: 'line', lineColor: 'black', fillColor: '#ccc', highlightLineColor: 'orange', highlightSpotColor: 'orange' });\n  $('.sparkSamples:not(:has(canvas))').sparkline('html', { type: 'box', lineColor: 'black', whiskerColor: 'black', outlierFillColor: 'black', outlierLineColor: 'black', medianColor: 'black', boxFillColor: 'orange', boxLineColor: 'black' });\n}\n","order":[],"autoWidth":false,"orderClasses":false},"callback":null,"filter":"none"},"evals":["options.columnDefs.0.render","options.columnDefs.1.render","options.fnDrawCallback"]}</script><!--/html_preserve-->

This is why I see the integration of sparklines inside data tables as complimentary to other information in a table, but not generally as a full replacement where the table becomes a series of pictures,
requiring human interaction with all the individual table cells in order to obtain certain types of information.

To make an simile, the numeric data columns are like open doorways to an aggregation of the data.
The box plots are more like closed doors. You have to fuss with them as a user to obtain similar information.
The time series graphs are more like locked doors in this context. You can figure out the mean from them, but doing so is ridiculous.
However, the box plots and time series lines are each open doors to disaggregated information from the original data set, where the summary statistics in the numeric columns are more like closed doors.
More complete distributional information and data at a more disaggregated scale can seamlessly be piped through into the summary table where it would normally never be visible. 

The right balance allows for the most information to be immediately accessible. Some information, like a specific statistic, is best shown as a clearly visible number.
Other information like the distribution of a random variable, a trend line, an expression of variability around a trend through time, or some other functional form, can be most quickly interpreted from a visual description.

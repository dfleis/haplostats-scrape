######################################################################################
# Testing how to implement the 'polite' library designed to "promote responsible
# web etiquette". From the documentation (https://github.com/dmi3kno/polite):
#
#   "The package’s two main functions bow and scrape define and realize a web 
#    harvesting session. bow is used to introduce the client to the host and ask 
#    for permission to scrape (by inquiring against the host’s robots.txt file), 
#    while scrape is the main function for retrieving data from the remote server. 
#    Once the connection is established, there’s no need to bow again. Rather, in 
#    order to adjust a scraping URL the user can simply nod to the new path, which 
#    updates the session’s URL, making sure that the new location can be negotiated 
#    against robots.txt.
#
#    The three pillars of a polite session are seeking permission, taking slowly 
#    and never asking twice."
#
#
#######################################################################################
library(rvest)
library(xml2)
library(polite)

url <- "https://worldpopulationreview.com/country-rankings/olympic-medals-by-country"


####################### without using 'polite' #########################
page <- read_html(url)
tabs <- html_table(page, header = T)

df <- as.data.frame(tabs[[1]])
df$pop2021 <- as.numeric(gsub(",", "", df$`2021 Population`))

##### figures #####
par(mfrow = c(2, 2), mar = c(2, 2, 2, 2))
plot(NA, xlim = range(df$pop2021), ylim = range(df$`Total Olympic Medals`), log = 'xy',
     main = "Tot. Olympic Medals vs. 2021 Pop.")
grid()
points(df$pop2021, df$`Total Olympic Medals`, pch = 19, cex = 0.75, col = rgb(0, 0, 0, 0.75))

with(subset(df, Gold > 0), {
  plot(NA, xlim = range(pop2021), ylim = range(Gold), log = 'xy',
     main = "Gold Medals vs. 2021 Pop.")
  grid()
  points(pop2021, Gold, pch = 19, cex = 0.75, col = rgb(0, 0, 0, 0.75))
})
with(subset(df, Silver > 0), {
  plot(NA, xlim = range(pop2021), ylim = range(Silver), log = 'xy',
       main = "Silver Medals vs. 2021 Pop.")
  grid()
  points(pop2021, Silver, pch = 19, cex = 0.75, col = rgb(0, 0, 0, 0.75))
})
with(subset(df, Bronze > 0), {
  plot(NA, xlim = range(pop2021), ylim = range(Bronze), log = 'xy',
       main = "Bronze Medals vs. 2021 Pop.")
  grid()
  points(pop2021, Bronze, pch = 19, cex = 0.75, col = rgb(0, 0, 0, 0.75))
})

####################### using 'polite' #########################

session <- bow(url, force = T)
result  <- scrape(session)
tabs    <- html_table(result, header = T)

df <- as.data.frame(tabs[[1]])
df$pop2021 <- as.numeric(gsub(",", "", df$`2021 Population`))
head(df)
























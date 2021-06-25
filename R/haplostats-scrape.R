#####################################################################################
# Scrapes data generated from the haplostats.org query page form. The
# first part sets the different arguments required by the haplostats 
# form. To see all the arguments required by the form print the results
# stored in the 'hapl.form' object.
#
# NOTES ON FORM FIELDS:
#   * (checkbox): Not sure. By default all populations seem to be selected.
#                 I have not yet tested how to remove populations/choose
#                 specific population groups.
#   * (text): The HLA type fields are text boxes and presumably would
#             return an error if an invalid value is passed through the
#             field. Fortunately, the string passed through using this
#             web scraping script should be identical to strings entered
#             if we were directly using the webpage.
#   * (select): One way to find what values are considered valid for the
#               different 'select' fields (dataset, haplotypeLoci) we can 
#               inspect the HTML code from the haplostats.org webpage 
#               (go to haplostats.org, right click and select 'Inspect'
#                or enter Ctrl+Shift+I). One in the Inspect panel, we have
#               to parse/navigate through the HTML structure to the fields
#               corresponding to the 'select' field of interest. It's 
#               difficult to provide an example in words, but expanding through
#               the HTML structure we find (using the 'dataset' field as an
#               example)
#               <select id="hladataset" name="dataset" tabindex="1" onchange="datasetUpdated(this);">
#                 <option value="84|NMDP.HIGHRES.1.1.0.2007-11-20|NMDP high res 2007">NMDP high res 2007</option>
#                 <option value="21|NMDP.FULL-COMPOSITE.1.1.0.2011-08-25|NMDP full 2011" selected="">NMDP full 2011</option></select>
#               If using Google Chrome, the field on the webpage should be highlighted
#               when hovering over the correct HTML code.
#               Valid values for the 'select' fields are listed next to 'option value='.
#               Note that these values are NOT necessarily the same as the label provided
#               in the select/dropdown options on the haplostats.org webpage itself.
#     
#               The only two 'select' fields seem to be 'dataset' and 'haplotypeLoci'
#               and so I've gone through the HTML code and found the valid values for each
#               of these fields.
#               
#               'dataset'
#                 "84|NMDP.HIGHRES.1.1.0.2007-11-20|NMDP high res 2007"     # label = NMDP high res 2007
#                 "21|NMDP.FULL-COMPOSITE.1.1.0.2011-08-25|NMDP full 2011"  # label = NMDP full 2011
#               'haplotypeLoci'
#                 "A~C~B~DRBX~DRB1~DQB1" # label = A~C~B~DRBX~DRB1~DQB1
#                 "A~C~B~DRB1~DQB1"      # label = A~C~B~DRB1~DQB1
#                 "C~B"                  # label = C~B
#                 "A~C~B"                # label = A~C~B
#                 "A~B~DRB1"             # label = A~B~DRB1
#                 "A~C~B~DRB1"           # label = A~C~B~DRB1
#
# NOTE ON WEB SCRAPING: 
#   * If the plan is to submit many requests to haplostats.org in quick succession
#     (say, in a loop or using a *apply type function) then it is a good idea to look
#     at the R library 'polite'. I have never used it but I know that it's a tool
#     that is designed not to overwhelm web servers when doing automated web scraping.
#
# NOTE ON PARSING HTML PAGES:
#   * Once we have produced 'hapl.html' we can use different HTML parsing tools to navigate 
#     through the webpage & select the parts that we are interested in. I'm by no means an 
#     expert in HTML parsing (or web scraping for that matter), but I know the "XML" library
#     has some useful tools. String/character manipulation tools (via 'stringr' or 'stringi')
#     may also be useful.
#
#
#####################################################################################
library(rvest)

#===== CREATE & LOOK AT THE HAPLOSTATS PAGE/FORM =====#
url          <- "https://haplostats.org/"
hapl.session <- session(url)
hapl.form    <- html_form(hapl.session)
hapl.form


#===== ENTER HAPLOSTATS QUERY VALUES =====#
## "HLA Dataset"
# "84|NMDP.HIGHRES.1.1.0.2007-11-20|NMDP high res 2007"    # NMDP high res 2007
# "21|NMDP.FULL-COMPOSITE.1.1.0.2011-08-25|NMDP full 2011" # NMDP full 2011
dataset <- "21|NMDP.FULL-COMPOSITE.1.1.0.2011-08-25|NMDP full 2011"

## "Haplotype Loci"
# "A~C~B~DRBX~DRB1~DQB1" # A~C~B~DRBX~DRB1~DQB1
# "A~C~B~DRB1~DQB1"      # A~C~B~DRB1~DQB1
# "C~B"                  # C~B
# "A~C~B"                # A~C~B
# "A~B~DRB1"             # A~B~DRB1
# "A~C~B~DRB1"           # A~C~B~DRB1
haplotypeLoci <- "A~C~B~DRB1~DQB1" 

## "HLA type"
a1 <- "01:01"
a2 <- "01:02"
b1 <- "08:01"
b2 <- "08:01"
c1 <- NULL
c2 <- NULL
drb1_1 <- "03:01"
drb1_2 <- "15:01"
dqb1_1 <- NULL
dqb1_2 <- NULL
drb3_1 <- NULL
drb3_2 <- NULL
drb4_1 <- NULL
drb4_2 <- NULL
drb5_1 <- NULL
drb5_2 <- NULL

#===== FILL VALUES INTO THE HAPLOSTATS FORM & SUBMIT FORM =====#
# If we wanted to set values for the 'Population' checkboxes we would
# include those arguments here (although I haven't tested how to do so).
filled.form <- html_form_set(form = hapl.form[[1]], 
                          "dataset" = dataset,
                          "haplotypeLoci" = haplotypeLoci,
                          "a1" = a1,
                          "a2" = a2,
                          "b1" = b1,
                          "b2" = b2,
                          "c1" = c1,
                          "c2" = c2,
                          "drb11" = drb1_1,
                          "drb12" = drb1_2,
                          "dqb11" = dqb1_1,
                          "dqb12" = dqb1_2,
                          "drb31" = drb3_1,
                          "drb32" = drb3_2,
                          "drb41" = drb4_1,
                          "drb42" = drb4_2,
                          "drb51" = drb5_1,
                          "drb52" = drb5_2)
hapl.page <- session_submit(x = hapl.session, form = filled.form, submit = "_eventId_success")

#===== EXTRACT DATA FROM PAGE GENERATED BY OUR SUBMISSION =====#
# structure whatever object submit_form creates to something more amenable to html parsing
hapl.html <- read_html(hapl.page) 

# (the following is the same text as in the preamble written at the top of this script)
# Once we have produced 'hapl.html' we can use different HTML parsing tools to navigate 
# through the webpage & select the parts that we are interested in. I'm by no means an 
# expert in HTML parsing (or web scraping for that matter), but I know the "XML" library
# has some useful tools. String/character manipulation tools (via 'stringr' or 'stringi')
# may also be useful.

################# IMPORTANT #################
# The following code is just what I found to work. It may not be robust to different
# inputs since I manually select different parts of the HTML structure (selecting 
# hapl.nodes1[[3]] to get to the sub-tree containing the example table, and
# selecting hapl.nodes2[[9]] to get to the sub-sub-tree which contains the 
# 'Unhphased Genotypes' data. These indices may not be the same if we enter different
# HLA types when submitting the form.

# descending the nested 'div' html structuring (I'm not sure if this is the right nomenclature)
hapl.nodes1 <- html_nodes(hapl.html, "div")
hapl.nodes2 <- html_nodes(hapl.nodes1[[3]], "div")
# hapl.nodes2[[9]] corresponds to <div id="_title_A-C-B-DRB1-DQB1_mug_id" ... which 
# contains the unphased genotype data (given the provided form values)
hapl.nodes3 <- html_nodes(hapl.nodes2[[9]], "table") 

# use html_table to try and automatically produce tables/matrices from the HTML tables
hapl.tables <- html_table(hapl.nodes3, header = T) 

# hapl.tables contains what I think is the (A-C-B-DRB1-DQB1) Unphased Genotypes (HLA type) drop-down table
# However, it's structured in a very ugly way since the 'Population HLA type frequencies' and 
# 'HLA typing resolution score' headers are not aligned in the same column (and so R reads it as 3 different
# columns)
# I believe hapl.tables[[1]] contains the entire Unphased Genotype data (R tries to put it into 1 big table
# but the number of columns is too large due to formatting issues), while the other hapl.tables[[i]]
# tables look to be individual cells in some cases and groups of cells in other cases
str(hapl.tables)
length(hapl.tables)
as.matrix(hapl.tables[[1]])
as.matrix(hapl.tables[[2]])
as.matrix(hapl.tables[[99]]) 
as.matrix(hapl.tables[[100]]) 

as.matrix(hapl.tables[[2]])


hapl.tables <- html_table(hapl.nodes3, header = F, na.strings = c("NA", "N/A", ""))
hapl.mat <- as.matrix(hapl.tables[[1]])
hapl.tables[[2]]
hapl.tables[[3]]
str(hapl.tables[[4]])
as.matrix(hapl.tables[[2]])
str(hapl.tables[[1]])

X <- as.matrix(hapl.tables[[1]])
x <- x[1,]
unname(x[!is.na(x)])

hapl.tables[[115]]



hla_type_idx <- which(hapl.mat == "HLA type", arr.ind = T)
hla_type_freq_idx <- which(hapl.mat == "HLA type freq", arr.ind = T)
likelihood_idx <- which(hapl.mat == "Likelihood", arr.ind = T)
hla_type_idx
hla_type_freq_idx


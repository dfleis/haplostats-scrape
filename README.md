# haplostats-scrape
Scripts and utilities for scraping data from the haplostats.org datasets

### Note on Web Scraping

If the plan is to submit many requests to haplostats.org in quick succession (say, in a loop or using a *apply type function) then it is a good idea to look at the R library `polite`. I have never used it (yet) but I know that it's a tool that is designed not to overwhelm web servers when doing automated web scraping.


### Overview

Uses the `rvest` library to scrape data generated from the haplostats.org query page form. At a high level the `rvest` pipeline works as follows
1) Create a "session" accessing the haplostats web form (via `rvest::session`).
2) Extract the fields required by the web form and create an object which will allow us to pass arguments to each field (via `rvest::html_form`).
3) Specify the values of the desired fields and fill the form (via `rvest::html_form_set`).
4) Read/structure/convert (?) output of step 3 to something that is more easily amenable to HTML parsing (via `rvest::read_html` which is itself imported from `xml2::read_html`).
5) Navigate/parse through the HTML document to find the data we wish to extract (via `rvest::html_node`, `rvest::html_nodes`, and/or `rvest::html_table`). I am not very experienced in parsing HTML (or web scraping!) and so this step in particular may be done more efficiently.
6) *To do...* The result of step 5 may not be trivially convertable into an R matrix/data frame and so we may have to do extra work wrangling the data into usable format.

### Notes on Form Fields (step 2/3)

The haplostats web form has a variety of different types of fields which it expects users to interact with. In order of appearance, these include *select* (HLA Dataset, Haplotype Loci), *checkbox* (Populations), and *text* (HLA Type). To see how the field categories and labels you can run steps 1-2 and print the results from `html_form`, i.e.
```R
hapl.session <- session(url)
hapl.form    <- html_form(hapl.session)
hapl.form
```
should output 
```
[[1]]
<form> 'hlarequest' (POST https://haplostats.org/haplostats?execution=e1s1)
  <field> (select) dataset: 
  <field> (checkbox) populations: AFA
  <field> (checkbox) populations: AAFA
  <field> (checkbox) populations: AFB
  <field> (checkbox) populations: CARB
  <field> (checkbox) populations: API
  <field> (checkbox) populations: AINDI
  <field> (checkbox) populations: FILII
  <field> (checkbox) populations: HAWI
  <field> (checkbox) populations: JAPI
  <field> (checkbox) populations: KORI
  <field> (checkbox) populations: NCHI
  <field> (checkbox) populations: SCSEAI
  <field> (checkbox) populations: VIET
  <field> (checkbox) populations: CAU
  <field> (checkbox) populations: MENAFC
  <field> (checkbox) populations: EURCAU
  <field> (checkbox) populations: HIS
  <field> (checkbox) populations: CARHIS
  <field> (checkbox) populations: MSWHIS
  <field> (checkbox) populations: SCAHIS
  <field> (checkbox) populations: NAM
  <field> (checkbox) populations: AMIND
  <field> (checkbox) populations: CARIBI
  <field> (button) : 
  <field> (button) : 
  <field> (select) haplotypeLoci: 
  <field> (text) a1: 
  <field> (text) b1: 
  <field> (text) c1: 
  <field> (text) drb11: 
  <field> (text) dqb11: 
  <field> (text) drb31: 
  <field> (text) drb41: 
  <field> (text) drb51: 
  <field> (text) a2: 
  <field> (text) b2: 
  <field> (text) c2: 
  <field> (text) drb12: 
  <field> (text) dqb12: 
  <field> (text) drb32: 
  <field> (text) drb42: 
  <field> (text) drb52: 
  <field> (submit) _eventId_success: Submit Query
```
The field categories are listed between parentheses while the corresponding label listed before the colon. Some observations I've made so far include:

* **(text)**: The HLA type fields are text boxes and presumably would return an error if an invalid value is passed through the field. Fortunately, the string passed through using this web scraping script should be identical to strings entered if we were directly using the webpage.
* **(checkbox)**: I have not yet tested how to remove populations/choose specific population groups. By default all populations seem to be selected. 
* **(select)**: One way to find the values haplostats.org treats as valid for each 'select'-type field is to inspect the HTML code from the haplostats.org webpage (go to haplostats.org, right click and select 'Inspect' or enter Ctrl+Shift+I). Once in the Inspect panel, we have to parse/navigate through the HTML structure to find the sections corresponding to the 'select' field of interest. It's difficult to provide an example in words, but expanding through the HTML structure we find lines (using the 'dataset' field as an example)
  ```
  <select id="hladataset" name="dataset" tabindex="1" onchange="datasetUpdated(this);">
    <option value="84|NMDP.HIGHRES.1.1.0.2007-11-20|NMDP high res 2007">NMDP high res 2007</option>
    <option value="21|NMDP.FULL-COMPOSITE.1.1.0.2011-08-25|NMDP full 2011" selected="">NMDP full 2011</option></select>
    ...
  ```
Note that the matching field on the webpage should be highlighted when hovering over the appropriate HTML code (I primarily use Chrome but I'm sure it's also true for any modern browser). Valid values for the 'select' fields are listed next to `option value=`. Note that these values are **NOT** necessarily the same as the label provided in the select/drop-down options on the haplostats.org webpage itself. The only two 'select' fields seem to be 'dataset' and 'haplotypeLoci' and so I've gone through the HTML code and found the valid values for each of these fields.
  ```
  'dataset'
    "84|NMDP.HIGHRES.1.1.0.2007-11-20|NMDP high res 2007"     # label = NMDP high res 2007
    "21|NMDP.FULL-COMPOSITE.1.1.0.2011-08-25|NMDP full 2011"  # label = NMDP full 2011
  'haplotypeLoci'
    "A~C~B~DRBX~DRB1~DQB1" # label = A~C~B~DRBX~DRB1~DQB1
    "A~C~B~DRB1~DQB1"      # label = A~C~B~DRB1~DQB1
    "C~B"                  # label = C~B
    "A~C~B"                # label = A~C~B
    "A~B~DRB1"             # label = A~B~DRB1
    "A~C~B~DRB1"           # label = A~C~B~DRB1
  ```                

### Note on Parsing HTML Pages

Once we have produced `hapl.html` we can use different HTML parsing tools to navigate through the webpage & select the parts that we are interested in. I'm by no means an expert in any of this, but I know the `XML` library has some useful tools. String/character manipulation tools may also be useful (i.e. `stringr` or `stringi`). 



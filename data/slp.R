library(rvest)
library(tidyverse)
library(stringr)
library(tm)
library(tidytext)
library(broom)

theme_set(theme_bw())

url <- "https://www.styleforum.net/threads/saint-laurent-paris-official-thread.317702/page-"
page <- c(2:13)
#1329
site <- paste0(url, page)

pull_posts <- function(i){
  html <- read_html(i)
  date <- html_nodes(html, ".datePermalink .DateTime") %>% html_text()
  post <- html_nodes(html, ".SelectQuoteContainer") %>%
    html_text() %>%
    gsub('[\r\n\t]', '', .) %>%
    gsub(".*:", "", .) %>% 
    gsub("↑.*Click to expand...", "", .) %>%
    gsub("//.*Click to expand...", "", .) %>%
    str_trim()
  
  cbind(date, post) %>% as.data.frame()
}

post_list <- lapply(site, pull_posts)
post_df <- do.call(rbind, post_list)
# saveRDS(post_df, "slp_post.rds")

names(post_df) <- c("doc_id", "text")
content_source <- DataframeSource(post_df)
content_corpus <- VCorpus(content_source)

clean_corpus <- function(corpus){
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removeWords, c(stopwords("en"), "like", "just",
                                          "really", "also", "theyre",
                                          "theres", "youre", "thats",
                                          "just", "can", "get", "dont",
                                          "ive", "etc", "cant"))
  return(corpus)
}

clean_corp <- clean_corpus(content_corpus)
content_dtm <- DocumentTermMatrix(clean_corp)

content_td <- tidy(content_dtm)


test <- as.data.frame(as.matrix(content_dtm))

### REFERENCES

https://cran.r-project.org/web/packages/tidytext/vignettes/tidying_casting.html
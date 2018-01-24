library(rvest)
library(tidyverse)
library(stringr)
library(tm)
library(tidytext)
library(broom)
library(lubridate)

theme_set(theme_bw())

url <- "https://www.styleforum.net/threads/saint-laurent-paris-official-thread.317702/page-"
page <- c(665:1330)
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
# saveRDS(content_td, "slp1_td.rds")
# saveRDS(content_td, "slp2_td.rds")
slp1 <- readRDS("slp1_td.rds")
slp2 <- readRDS("slp2_td.rds")

full_df <- bind_rows(slp1, slp2)
#### SOMETHING IS STILL WEIRD HERE
full_df$document <- mdy(full_df$document)

### BING

post_sent_bing <- full_df %>%
  inner_join(get_sentiments("bing"), by = c(term = "word"))

post_sent_bing %>%
  count(sentiment, term, wt = count) %>%
  ungroup() %>%
  filter(n >= 200) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(term = reorder(term, n)) %>%
  ggplot(aes(term, n, fill = sentiment)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  ylab("Contribution to sentiment")

post_sent_bing %>%
  count(term, sort = TRUE) %>%
  head(10)

### NRC
post_sent_nrc <- full_df %>%
  inner_join(get_sentiments("nrc"), by = c(term = "word"))

post_sent_nrc %>%
  # Filter to only choose the words associated with sadness
  filter(sentiment == "sadness") %>%
  # Group by word
  group_by(term) %>%
  # Use the summarize verb to find the mean frequency
  summarize(count = mean(count)) %>%
  # Arrange to sort in order of descending frequency
  arrange(desc(count))

joy_words <- post_sent_nrc %>%
  # Filter to only choose the words associated with sadness
  filter(sentiment == "joy") %>%
  # Group by word
  group_by(term) %>%
  # Use the summarize verb to find the mean frequency
  summarize(count = mean(count)) %>%
  # Arrange to sort in order of descending frequency
  arrange(desc(count))    

joy_words %>%
  top_n(20) %>%
  mutate(word = reorder(term, count)) %>%
  # Use aes() to put words on the x-axis and frequency on the y-axis
  ggplot(aes(word, count)) +
  # Make a bar chart with geom_col()
  geom_col() +
  coord_flip()

sentiment_by_time <- full_df %>%
  # Define a new column using floor_date()
  mutate(date = floor_date(show_date, unit = "6 months")) %>%
  # Group by date
  group_by(date) %>%
  mutate(total_words = n()) %>%
  ungroup() %>%
  # Implement sentiment analysis using the NRC lexicon
  inner_join(get_sentiments("nrc"))

### afinn
post_sent_afinn <- full_df %>%
  inner_join(get_sentiments("afinn"), by = c(term = "word"))

sentiment_contributions <- full_df %>%
  # Count by title and word
  count(term, sort = TRUE) %>%
  # Implement sentiment analysis using the "afinn" lexicon
  inner_join(get_sentiments("afinn"), by = c(term = "word")) %>%
  # Calculate a contribution for each word in each title
  mutate(contribution = score * n / sum(n)) %>%
  ungroup()

### REFERENCES

https://cran.r-project.org/web/packages/tidytext/vignettes/tidying_casting.html